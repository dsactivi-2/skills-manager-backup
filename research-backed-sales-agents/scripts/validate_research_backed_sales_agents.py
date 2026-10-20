#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "SKILL.md"
REFERENCE = ROOT / "references" / "paper-principles.md"
OPENAI = ROOT / "agents" / "openai.yaml"
PROMPT_PACK_TEMPLATE = ROOT / "assets" / "prompt-pack-template.md"
AUDIT_SHEET = ROOT / "assets" / "sales-agent-audit-sheet.md"

REQUIRED_SKILL_TERMS = [
    "Intake",
    "Operating Modes",
    "Audit Mode",
    "Dynamic Outline",
    "script library",
    "voice from action",
    "factual claims ledger",
    "Prompt Pack Contract",
    "Test Scenarios",
    "Route models",
    "Evaluation Plan",
]

REQUIRED_REFERENCE_TERMS = [
    "AI-Salesman",
    "Talk Less, Call Right",
    "Small Language Models",
    "DOGA",
    "Action-first",
    "LLM-to-SLM",
    "Prompt Pack Guidance",
    "Scenario Test Matrix",
]

REQUIRED_ASSET_TERMS = {
    PROMPT_PACK_TEMPLATE: ["Base System Prompt", "Dynamic State Prompts", "Tool And Action Contract", "Factual Claims Ledger"],
    AUDIT_SHEET: ["Findings", "Failure Map", "Scenario Tests", "Final Verdict"],
}


def check(condition: bool, status: str, message: str) -> tuple[str, str]:
    return (status if condition else "FAIL", message)


def main() -> int:
    results: list[tuple[str, str]] = []
    failures = 0

    skill_text = SKILL.read_text(encoding="utf-8") if SKILL.exists() else ""
    reference_text = REFERENCE.read_text(encoding="utf-8") if REFERENCE.exists() else ""
    openai_text = OPENAI.read_text(encoding="utf-8") if OPENAI.exists() else ""

    results.append(check(SKILL.exists(), "PASS", "SKILL.md exists"))
    results.append(check(REFERENCE.exists(), "PASS", "paper principles reference exists"))
    results.append(check(OPENAI.exists(), "PASS", "agents/openai.yaml exists"))
    results.append(check(PROMPT_PACK_TEMPLATE.exists(), "PASS", "prompt pack template exists"))
    results.append(check(AUDIT_SHEET.exists(), "PASS", "sales agent audit sheet exists"))

    frontmatter_match = re.match(r"---\n(.*?)\n---", skill_text, flags=re.DOTALL)
    results.append(check(bool(frontmatter_match), "PASS", "frontmatter exists"))
    results.append(check("name: research-backed-sales-agents" in skill_text, "PASS", "skill name is valid"))
    results.append(
        check(
            "description: Use when" in skill_text,
            "PASS",
            "description is trigger-oriented",
        )
    )

    for term in REQUIRED_SKILL_TERMS:
        results.append(check(term in skill_text, "PASS", f"SKILL.md includes `{term}`"))

    for term in REQUIRED_REFERENCE_TERMS:
        results.append(check(term in reference_text, "PASS", f"reference includes `{term}`"))

    results.append(
        check(
            "$research-backed-sales-agents" in openai_text,
            "PASS",
            "default prompt mentions the skill token",
        )
    )

    for asset_path, terms in REQUIRED_ASSET_TERMS.items():
        asset_text = asset_path.read_text(encoding="utf-8") if asset_path.exists() else ""
        for term in terms:
            results.append(check(term in asset_text, "PASS", f"{asset_path.name} includes `{term}`"))

    for status, message in results:
        print(f"{status}: {message}")
        if status == "FAIL":
            failures += 1

    if failures:
        print(f"FAIL: {failures} validation issue(s)")
        return 1

    print("PASS: research-backed-sales-agents skill validated")
    return 0


if __name__ == "__main__":
    sys.exit(main())
