#!/usr/bin/env python3
"""Render a Dograh voice-agent plan from a structured JSON brief."""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import sys
from pathlib import Path
from typing import Any


SECRETISH_KEYS = re.compile(
    r"(api[_-]?key|token|secret|password|credential|private[_-]?key)",
    re.IGNORECASE,
)


def fail(message: str) -> None:
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)


def load_brief(path: Path) -> dict[str, Any]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail(f"input file not found: {path}")
    except json.JSONDecodeError as exc:
        fail(f"invalid JSON at line {exc.lineno}, column {exc.colno}: {exc.msg}")
    if not isinstance(data, dict):
        fail("brief JSON must be an object")
    return data


def check_no_secret_values(value: Any, trail: str = "") -> None:
    if isinstance(value, dict):
        for key, child in value.items():
            child_trail = f"{trail}.{key}" if trail else str(key)
            if SECRETISH_KEYS.search(str(key)) and child not in (None, "", "REFERENCE_ONLY"):
                fail(
                    f"secret-like field has a value at {child_trail}; "
                    "store only credential references, never secret values"
                )
            check_no_secret_values(child, child_trail)
    elif isinstance(value, list):
        for index, child in enumerate(value):
            check_no_secret_values(child, f"{trail}[{index}]")


def as_list(value: Any) -> list[str]:
    if value is None:
        return []
    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]
    text = str(value).strip()
    return [text] if text else []


def bullet(items: list[str], fallback: str = "TBD") -> str:
    if not items:
        return f"- {fallback}"
    return "\n".join(f"- {item}" for item in items)


def markdown_table_cell(value: Any) -> str:
    if value is None or value == "":
        return "TBD"
    text = str(value)
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"\s*\n\s*", "<br>", text.strip())
    return text.replace("|", r"\|")


def table(rows: list[dict[str, Any]], columns: list[str]) -> str:
    header = "| " + " | ".join(columns) + " |"
    sep = "| " + " | ".join("---" for _ in columns) + " |"
    body = []
    for row in rows:
        if not isinstance(row, dict):
            row = {"name": row}
        body.append("| " + " | ".join(markdown_table_cell(row.get(col, "TBD")) for col in columns) + " |")
    if not body:
        body.append("| " + " | ".join("TBD" for _ in columns) + " |")
    return "\n".join([header, sep, *body])


def render(data: dict[str, Any]) -> str:
    generated = dt.datetime.now(dt.timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")
    name = data.get("use_case_name", "Dograh Voice Agent")
    company = data.get("company_name", "TBD")
    language = data.get("language", "TBD")
    goal = data.get("primary_goal", "TBD")

    nodes = data.get("nodes")
    if not isinstance(nodes, list) or not nodes:
        nodes = [
            {"name": "global", "purpose": "Shared role, goal, speech handling, and constraints"},
            {"name": "start_call", "purpose": "Greet caller and establish context"},
            {"name": "main_task", "purpose": "Complete the core use case"},
            {"name": "tool_action", "purpose": "Use approved external systems"},
            {"name": "confirm_outcome", "purpose": "Confirm result and next steps"},
            {"name": "handoff_or_fallback", "purpose": "Handle uncertainty or restricted requests"},
            {"name": "end_call", "purpose": "Close concisely"},
        ]

    tools = data.get("tools")
    if not isinstance(tools, list):
        tools = []

    return f"""# {name} - Dograh Voice Agent Plan

Generated: {generated}
Status: PASS_WITH_GAPS until discovery, dry-run, and approval are complete.

## Summary

- Company: {company}
- Primary goal: {goal}
- Call type: {data.get("call_type", "TBD")}
- Target language/voice: {language}
- Production target: {data.get("production_target", "TBD")}

## Capabilities

{bullet(as_list(data.get("capabilities")))}

## Boundaries

{bullet(as_list(data.get("not_allowed")), "No boundaries supplied yet")}

## Workflow Nodes

{table(nodes, ["name", "purpose"])}

## Tool Matrix

{table(tools, ["name", "system", "risk", "inputs", "dry_run", "failure_behavior"])}

## Global Prompt Skeleton

```text
You are the voice AI agent for {company}.
Your goal is: {goal}
Speak in {language}. Keep answers short, natural, and focused.
Ask one question at a time. Do not repeat yourself unless asked or audio was unclear.
Use tools for external facts. Escalate or hand off when the caller asks for anything outside scope.
```

## Test Cases

{bullet(as_list(data.get("test_cases")), "Happy path, refusal, unsupported request, unclear audio, tool failure, handoff")}

## Guardrails

- Do not use live Dograh Cloud, n8n, Telnyx, CRM, database, or calling actions without explicit approval.
- Run preflight/dry-run where possible before any write action.
- Store credential references only; never store secret values in this brief or report.
- After any live change, run post-checks and record PASS/WARN/FAIL/PASS_WITH_GAPS.
"""


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("brief", type=Path, help="Path to JSON brief")
    parser.add_argument("--out", type=Path, help="Output Markdown path")
    args = parser.parse_args()

    data = load_brief(args.brief)
    check_no_secret_values(data)
    output = render(data)
    if args.out:
        args.out.write_text(output, encoding="utf-8")
    else:
        print(output)


if __name__ == "__main__":
    main()
