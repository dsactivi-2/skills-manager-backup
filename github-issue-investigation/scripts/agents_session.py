#!/usr/bin/env python3
"""Start and stream an OpenAI Agents API session using curl."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from pathlib import Path
from typing import Any, Iterator
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parent
WORK = ROOT / "work"
CONFIG_PATH = ROOT / "config.json"
DEFAULT_MESSAGE = """Investigate this GitHub-style bug report and produce the report required by your instructions.

Repository: not checked out in this sandbox.
Issue title: Directory tree helper prints an empty tree when the current directory contains only hidden files
Expected: hidden files such as .gitignore are listed, or the tool documents that it skips them.
Actual: the script prints only the root directory name and then exits 0.
Reproduction:
1. Create a directory that contains only hidden files.
2. Run the tree helper from that directory.
3. Observe an empty tree.

Do not edit source files. If a repository checkout is missing, say exactly what you need. Otherwise inspect the sandbox, attempt a focused reproduction with available tools, and return reproduction result, root cause or hypothesis, suggested change, and a regression test. Distinguish confirmed findings from guesses."""


class AgentsApiError(RuntimeError):
    def __init__(self, message: str, body: Any = None):
        super().__init__(message)
        self.body = body


def _load_dotenv_quietly() -> None:
    if os.environ.get("OPENAI_API_KEY", "").strip():
        return
    roots = [ROOT, Path.cwd(), Path.home() / ".codex/skills/github-issue-investigation"]
    for root in roots:
        for name in (".env.local", ".env"):
            path = root / name
            if not path.is_file():
                continue
            for raw in path.read_text(errors="replace").splitlines():
                line = raw.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                if line.startswith("export "):
                    line = line[7:].strip()
                key, _, value = line.partition("=")
                key = key.strip()
                value = value.strip().strip("'").strip('"')
                if key and key not in os.environ:
                    os.environ[key] = value
            if os.environ.get("OPENAI_API_KEY", "").strip():
                return

def load_config() -> dict[str, Any]:
    return json.loads(CONFIG_PATH.read_text())


def require_api_key() -> str:
    _load_dotenv_quietly()
    key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not key:
        raise AgentsApiError(
            "OPENAI_API_KEY is not set. Export a project API key with "
            "api.agents.read, api.agents.write, and api.responses.write."
        )
    return key


def headers(cfg: dict[str, Any], sse: bool = False) -> list[str]:
    items = [
        "-H", "OpenAI-Beta: agents=v1",
        "-H", "Authorization: Bearer " + require_api_key(),
        "-H", "OpenAI-Project: " + cfg["project_id"],
        "-H", "Content-Type: application/json",
    ]
    if sse:
        items.extend(["-H", "Accept: text/event-stream"])
    return items


def try_json(text: str) -> Any:
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        return None


def error_message(parsed: Any, text_out: str, err_out: str) -> str:
    if isinstance(parsed, dict) and isinstance(parsed.get("error"), dict):
        err = parsed["error"]
        parts = [err.get("message") or "Agents API request failed"]
        if err.get("type"):
            parts.append("type=" + str(err["type"]))
        if err.get("code"):
            parts.append("code=" + str(err["code"]))
        return " ".join(parts)
    return (text_out.strip() or err_out.strip() or "curl failed")[:2000]


def curl_json(cfg: dict[str, Any], method: str, path: str, payload: Any | None = None) -> Any:
    url = cfg["api_base"].rstrip("/") + path
    args = ["curl", "-sS", "--fail-with-body", "-X", method, url] + headers(cfg)
    stdin = None
    if payload is not None:
        args.extend(["--data-binary", "@-"])
        stdin = json.dumps(payload).encode()
    proc = subprocess.run(args, input=stdin, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    out = proc.stdout.decode("utf-8", errors="replace")
    err = proc.stderr.decode("utf-8", errors="replace")
    if proc.returncode != 0:
        parsed = try_json(out)
        raise AgentsApiError(error_message(parsed, out, err), body=parsed or out)
    if not out.strip():
        return None
    return json.loads(out)


def iter_sse(stream) -> Iterator[dict[str, Any]]:
    event_name = None
    data_lines: list[str] = []

    def flush():
        nonlocal event_name, data_lines
        if not data_lines:
            event_name = None
            return None
        payload = "\n".join(data_lines)
        data_lines = []
        name = event_name
        event_name = None
        if payload.strip() == "[DONE]":
            return None
        try:
            event = json.loads(payload)
        except json.JSONDecodeError:
            event = {"type": name or "unknown", "raw": payload}
        if name and isinstance(event, dict) and "type" not in event:
            event["type"] = name
        return event if isinstance(event, dict) else None

    for raw in stream:
        line = raw.decode("utf-8", errors="replace").rstrip("\n").rstrip("\r")
        if line.startswith(":"):
            continue
        if not line:
            event = flush()
            if event:
                yield event
            continue
        if line.startswith("event:"):
            event_name = line[6:].strip()
        elif line.startswith("data:"):
            data_lines.append(line[5:].lstrip())
    event = flush()
    if event:
        yield event


def extract_text(event: dict[str, Any]) -> str:
    chunks: list[str] = []
    for key in ("delta", "text", "output_text"):
        value = event.get(key)
        if isinstance(value, str) and value:
            chunks.append(value)
    item = event.get("item")
    if isinstance(item, dict):
        content = item.get("content")
        if isinstance(content, list):
            for part in content:
                if isinstance(part, dict):
                    for key in ("text", "output_text"):
                        if isinstance(part.get(key), str):
                            chunks.append(part[key])
    return "".join(chunks)


def required_actions(event: dict[str, Any]) -> list[dict[str, Any]]:
    session = event.get("session") if isinstance(event.get("session"), dict) else {}
    actions = event.get("required_actions") or session.get("required_actions") or []
    return [a for a in actions if isinstance(a, dict)] if isinstance(actions, list) else []


def is_primary_turn(event: dict[str, Any]) -> bool:
    turn = event.get("turn")
    if not isinstance(turn, dict):
        return True
    return turn.get("subagent_id") in (None, "", False)


def terminal_failure(event: dict[str, Any]) -> str | None:
    etype = event.get("type")
    if etype == "error":
        err = event.get("error") if isinstance(event.get("error"), dict) else {}
        return err.get("message") or "stream error event"
    if etype in {"agent.session.failed", "agent.session.environment.failed"}:
        return "Agent lifecycle failure: " + str(etype)
    if etype == "agent.session.turn.failed" and is_primary_turn(event):
        turn = event.get("turn") if isinstance(event.get("turn"), dict) else {}
        err = turn.get("error") if isinstance(turn.get("error"), dict) else {}
        return str(etype) + ": " + (err.get("message") or "turn failed")
    if etype == "agent.session.turn.cancelled" and is_primary_turn(event):
        return "The agent turn was cancelled"
    return None


def submit_tool_results(cfg: dict[str, Any], session_id: str, actions: list[dict[str, Any]]) -> None:
    events = []
    for action in actions:
        action_type = action.get("type")
        name = action.get("name") or "unknown"
        if action_type == "function_call":
            print("[tool] function_call %s call_id=%s -> error result" % (name, action.get("call_id")), flush=True)
            events.append(
                {
                    "type": "agent.session.input.tool_result",
                    "turn_id": action.get("turn_id"),
                    "call_id": action.get("call_id"),
                    "success": False,
                    "error": (
                        "No local function handler is registered for '%s'. "
                        "Hosted sandbox commands are executed by OpenAI."
                    ) % name,
                }
            )
        else:
            print("[tool] unsupported required action: %s" % json.dumps(action)[:500], flush=True)
            if action.get("turn_id") and action.get("call_id"):
                events.append(
                    {
                        "type": "agent.session.input.tool_result",
                        "turn_id": action["turn_id"],
                        "call_id": action["call_id"],
                        "success": False,
                        "error": "Unsupported required action type: %s" % action_type,
                    }
                )
    if events:
        curl_json(cfg, "POST", "/agents/sessions/%s/events" % session_id, {"events": events})


def retrieve_agent(cfg: dict[str, Any]) -> dict[str, Any] | None:
    try:
        return curl_json(cfg, "GET", "/agents/%s" % cfg["agent_id"])
    except AgentsApiError as exc:
        print("[warn] could not load saved agent %s: %s" % (cfg["agent_id"], exc), flush=True)
        return None


def retrieve_session(cfg: dict[str, Any], session_id: str) -> dict[str, Any] | None:
    try:
        return curl_json(cfg, "GET", "/agents/sessions/%s" % session_id)
    except AgentsApiError as exc:
        print("[warn] could not retrieve session %s: %s" % (session_id, exc), flush=True)
        return None


def summarize_agent(agent: dict[str, Any]) -> str:
    tools = agent.get("tools") or []
    tool_types = []
    for tool in tools:
        if isinstance(tool, dict):
            tool_types.append(str(tool.get("type") or tool.get("name") or "tool"))
    return "saved agent id=%s name=%r model=%s tools=%s" % (
        agent.get("id"),
        agent.get("name"),
        agent.get("model"),
        tool_types or "[]",
    )


def create_and_stream(cfg: dict[str, Any], user_message: str) -> int:
    WORK.mkdir(parents=True, exist_ok=True)
    payload = {
        "agent_id": cfg["agent_id"],
        "agent": cfg["agent_overrides"],
        "environment": cfg["environment"],
        "input": user_message,
        "stream": True,
        "metadata": {
            "agent_name": cfg["agent_name"],
            "app": "github-issue-investigation-agent",
        },
    }
    payload_path = WORK / "session_create.json"
    payload_path.write_text(json.dumps(payload, indent=2) + "\n")
    url = cfg["api_base"].rstrip("/") + "/agents/sessions"
    args = (
        ["curl", "--no-buffer", "-sS", "-N", "--fail-with-body", "-X", "POST", url]
        + headers(cfg, sse=True)
        + ["--data-binary", "@" + str(payload_path)]
    )
    print("[http] POST %s stream=true environment=%s" % (urlparse(url).path, cfg["environment"]["type"]), flush=True)
    proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    assert proc.stdout is not None

    session_id = None
    assistant_text: list[str] = []
    handled_calls: set[str] = set()
    completed = False
    failure = None
    last_event_type = None
    first_chunk = True
    leftover = b""

    try:
        while True:
            chunk = proc.stdout.readline()
            if not chunk:
                break
            if first_chunk:
                first_chunk = False
                stripped = chunk.lstrip()
                if stripped.startswith(b"{") and b'"error"' in stripped:
                    leftover = chunk + proc.stdout.read()
                    parsed = try_json(leftover.decode("utf-8", errors="replace"))
                    raise AgentsApiError(error_message(parsed, leftover.decode("utf-8", errors="replace"), ""), body=parsed)
            # Re-parse line-oriented SSE from this and following lines via a simple adapter
            line_iter = [chunk]
            # After first line, consume the rest as a generator wrapping current + remaining
            def rest():
                yield chunk
                for more in proc.stdout:
                    yield more
            for event in iter_sse(rest()):
                etype = str(event.get("type") or "unknown")
                last_event_type = etype
                sid = event.get("session_id")
                if not sid and isinstance(event.get("session"), dict):
                    sid = event["session"].get("id")
                if sid and not session_id:
                    session_id = sid
                    (WORK / "last_session.json").write_text(
                        json.dumps({"session_id": session_id, "created_at": int(time.time())}, indent=2) + "\n"
                    )
                    print("[session] %s" % session_id, flush=True)

                text = extract_text(event)
                if text and "delta" in etype:
                    sys.stdout.write(text)
                    sys.stdout.flush()
                    assistant_text.append(text)
                else:
                    preview = text.replace("\n", " ")[:180] if text else ""
                    extra = " " + preview if preview else ""
                    print("[event] %s%s" % (etype, extra), flush=True)

                if etype in {"agent.session.requires_action", "agent.session.tool.requires_action"} or required_actions(event):
                    pending = []
                    for action in required_actions(event):
                        call_id = str(action.get("call_id") or "")
                        if call_id and call_id in handled_calls:
                            continue
                        if call_id:
                            handled_calls.add(call_id)
                        pending.append(action)
                    if pending and session_id:
                        try:
                            submit_tool_results(cfg, session_id, pending)
                        except AgentsApiError as exc:
                            print("[error] tool result submit failed: %s" % exc, flush=True)

                fail = terminal_failure(event)
                if fail:
                    failure = fail
                    proc.terminate()
                    break
                if etype == "agent.session.turn.completed" and is_primary_turn(event):
                    completed = True
                    proc.terminate()
                    break
            break
        stderr = proc.stderr.read() if proc.stderr else b""
        proc.wait(timeout=10)
        err_text = stderr.decode("utf-8", errors="replace") if stderr else ""
        if proc.returncode not in (0, None, -15) and not completed and failure is None and not session_id:
            raise AgentsApiError(error_message(try_json(err_text), "", err_text), body=err_text)
        if proc.returncode not in (0, None, -15) and failure is None and not completed:
            print("[warn] curl exited %s: %s" % (proc.returncode, err_text[:500]), flush=True)
    finally:
        if proc.poll() is None:
            proc.terminate()

    if assistant_text and not "".join(assistant_text).endswith("\n"):
        print()

    if session_id:
        session = retrieve_session(cfg, session_id)
        if session:
            status = session.get("status") or (session.get("session") or {}).get("status")
            print("[session] retrieved status=%r id=%s" % (status, session_id), flush=True)

    if failure:
        print("[failed] %s" % failure, flush=True)
        return 1
    if completed:
        print("[ok] primary turn completed", flush=True)
        return 0
    print(
        "[warn] stream ended without a terminal turn event (last=%s). Retrieve the saved session before retrying input."
        % last_event_type,
        flush=True,
    )
    return 2


def main(argv: list[str]) -> int:
    cfg = load_config()
    user_message = " ".join(argv[1:]).strip() or DEFAULT_MESSAGE
    print("[agent] %s" % cfg["agent_name"], flush=True)
    print("[agent] id=%s" % cfg["agent_id"], flush=True)
    print("[project] %s" % cfg["project_id"], flush=True)
    print("[env] %s (OpenAI-hosted sandbox; no local executor)" % cfg["environment"]["type"], flush=True)
    try:
        require_api_key()
        agent = retrieve_agent(cfg)
        if agent:
            print("[saved] %s" % summarize_agent(agent), flush=True)
        print("[input] sending initial user message", flush=True)
        return create_and_stream(cfg, user_message)
    except AgentsApiError as exc:
        print("[error] %s" % exc, flush=True)
        msg = str(exc).lower()
        if any(token in msg for token in ("api key", "biscuit", "401", "unauthorized", "invalid_api_key", "actor")):
            print(
                "[hint] This app reads OPENAI_API_KEY from the environment. "
                "Use a Platform project API key for proj_Ud2wWkyDYQnOu2etpfq0vvPW with "
                "api.agents.read, api.agents.write, and api.responses.write. "
                "ChatGPT or Manifest tokens are not valid here.",
                flush=True,
            )
        return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))

