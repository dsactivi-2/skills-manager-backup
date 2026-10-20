#!/usr/bin/env python3
"""Load credentials, ask for missing path/task, start the investigation session."""

from __future__ import annotations

import argparse
import os
import stat
import subprocess
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
if str(SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(SCRIPT_DIR))

import agents_session  # noqa: E402

PROJECT_ID = "proj_Ud2wWkyDYQnOu2etpfq0vvPW"
ENV_NAMES = (".env.local", ".env")
SEARCH_DIRS = (
    SCRIPT_DIR,
    SCRIPT_DIR.parent,
    Path.cwd(),
    Path.home() / ".codex/skills/github-issue-investigation",
    Path("/Users/activi/Documents/Codex/2026-09-19/build-a-runnable-application-in-this"),
    Path("/Users/activi/Documents/Codex/2026-09-19/build-a-runnable-application-in-this/outputs/github-issue-investigation-agent"),
)


def parse_env_file(path: Path) -> dict[str, str]:
    values: dict[str, str] = {}
    for raw in path.read_text(errors="replace").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        if line.startswith("export "):
            line = line[7:].strip()
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip("\'").strip('"')
        if key:
            values[key] = value
    return values


def env_candidates() -> list[Path]:
    seen: set[Path] = set()
    out: list[Path] = []
    for base in SEARCH_DIRS:
        try:
            base = base.expanduser()
        except Exception:
            continue
        for name in ENV_NAMES:
            path = base / name
            try:
                resolved = path.resolve()
            except OSError:
                continue
            if resolved in seen or not path.is_file():
                continue
            seen.add(resolved)
            out.append(path)
    return out


def load_env() -> Path | None:
    if os.environ.get("OPENAI_API_KEY", "").strip():
        return None
    for path in env_candidates():
        values = parse_env_file(path)
        key = values.get("OPENAI_API_KEY", "").strip()
        if not key:
            continue
        os.environ["OPENAI_API_KEY"] = key
        if values.get("OPENAI_PROJECT") and not os.environ.get("OPENAI_PROJECT"):
            os.environ["OPENAI_PROJECT"] = values["OPENAI_PROJECT"]
        return path
    return None


def save_key(key: str, dest: Path) -> Path:
    key = key.strip()
    if not key:
        raise SystemExit("empty API key")
    dest = dest.expanduser()
    dest.parent.mkdir(parents=True, exist_ok=True)
    existing = parse_env_file(dest) if dest.is_file() else {}
    existing["OPENAI_API_KEY"] = key
    existing.setdefault("OPENAI_PROJECT", os.environ.get("OPENAI_PROJECT", PROJECT_ID))
    dest.write_text("".join("%s=%s\n" % (k, v) for k, v in existing.items()))
    os.chmod(dest, stat.S_IRUSR | stat.S_IWUSR)
    os.environ["OPENAI_API_KEY"] = key
    os.environ.setdefault("OPENAI_PROJECT", existing["OPENAI_PROJECT"])
    return dest


def prompt(question: str) -> str:
    if not sys.stdin.isatty():
        return ""
    try:
        return input(question).strip()
    except EOFError:
        return ""


def git_info(path: Path) -> dict[str, str]:
    info: dict[str, str] = {"path": str(path), "exists": str(path.exists())}
    if not path.exists():
        return info
    info["is_dir"] = str(path.is_dir())
    git = ["git", "-C", str(path)]
    remote = subprocess.run(git + ["remote", "get-url", "origin"], capture_output=True, text=True)
    if remote.returncode == 0 and remote.stdout.strip():
        info["git_remote"] = remote.stdout.strip()
    head = subprocess.run(git + ["rev-parse", "--short", "HEAD"], capture_output=True, text=True)
    if head.returncode == 0 and head.stdout.strip():
        info["git_head"] = head.stdout.strip()
    branch = subprocess.run(git + ["branch", "--show-current"], capture_output=True, text=True)
    if branch.returncode == 0 and branch.stdout.strip():
        info["git_branch"] = branch.stdout.strip()
    return info


def build_message(path_text: str, task: str) -> str:
    path_text = path_text.strip()
    task = task.strip()
    lines = [task or "Investigate the reported GitHub issue and produce the report required by your instructions.", ""]
    if path_text.startswith("http://") or path_text.startswith("https://"):
        lines.append("GitHub URL: " + path_text)
        lines.append("If this is an issue URL, use it as the bug report. Clone a public repository only when needed.")
    elif path_text:
        info = git_info(Path(path_text).expanduser())
        lines.append("Local path supplied by the user: " + info["path"])
        if info.get("git_remote"):
            lines.append("git remote origin: " + info["git_remote"])
        extra = ""
        if info.get("git_branch"):
            extra = " (" + info["git_branch"] + ")"
        if info.get("git_head"):
            lines.append("git HEAD: " + info["git_head"] + extra)
        lines.append("This path is on the user machine. The hosted sandbox does not mount it. Clone the public remote if you need source, or say exactly what is missing.")
        if info.get("exists") != "True":
            lines.append("Warning: the local path does not exist.")
    else:
        lines.append("No repository path was provided.")
        lines.append("If a checkout is missing, say exactly what you need.")
    lines.append("Do not edit source files unless the user explicitly asked for a fix.")
    return "\n".join(lines)


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Start the GitHub issue investigation agent.")
    parser.add_argument("--path", help="Local repo path, GitHub repo URL, or issue URL")
    parser.add_argument("--task", "--issue", dest="task", help="What the agent should investigate or do")
    parser.add_argument("--save-key", action="store_true", help="Read API key from stdin and write .env.local")
    parser.add_argument("--dest", help="Env file to write with --save-key (default: cwd/.env.local)")
    parser.add_argument("--check", action="store_true", help="Print missing inputs and exit")
    parser.add_argument("rest", nargs="*", help="Optional free-form task text")
    return parser.parse_args(argv)


def missing(path_text: str, task: str, have_key: bool) -> list[str]:
    items = []
    if not have_key:
        items.append("api_key")
    if not path_text:
        items.append("path")
    if not task:
        items.append("task")
    return items


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    load_env()

    if args.save_key:
        key = sys.stdin.read()
        dest = Path(args.dest) if args.dest else Path.cwd() / ".env.local"
        saved = save_key(key, dest)
        print("saved OPENAI_API_KEY to %s" % saved)
        return 0

    path_text = (args.path or "").strip()
    task = (args.task or "").strip()
    if args.rest:
        extra = " ".join(args.rest).strip()
        task = (task + " " + extra).strip() if task else extra

    have_key = bool(os.environ.get("OPENAI_API_KEY", "").strip())

    if args.check:
        items = missing(path_text, task, have_key)
        if items:
            for item in items:
                print("MISSING:%s" % item)
            return 2
        print("ok")
        return 0

    if not have_key:
        if sys.stdin.isatty():
            print("OPENAI_API_KEY fehlt. Platform-Key fuer Projekt %s einfuegen." % PROJECT_ID)
            typed = prompt("API key: ")
            if typed:
                dest = Path.cwd() / ".env.local"
                save_key(typed, dest)
                print("Key gespeichert in %s (nicht im Chat ausgeben)." % dest)
                have_key = True
        if not have_key:
            print("MISSING:api_key")
            return 2

    if not path_text and sys.stdin.isatty():
        path_text = prompt("Welcher Pfad oder welche GitHub-URL? ")
    if not task and sys.stdin.isatty():
        task = prompt("Was soll der Agent tun? ")

    still = missing(path_text, task, True)
    if still:
        for item in still:
            print("MISSING:%s" % item)
        return 2

    message = build_message(path_text, task)
    print("[path] %s" % (path_text or "(none)"))
    print("[task] %s" % task[:240])
    return agents_session.create_and_stream(agents_session.load_config(), message)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

