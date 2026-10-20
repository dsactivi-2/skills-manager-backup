---
name: skillify-hermes-openclaw-skills
description: "Convert Hermes/OpenClaw hub skills into installed Codex skills with a first-pass recommendation and a stepwise build flow."
trigger: "Use when the user provides a Hermes or OpenClaw skill link and wants a durable Codex skill created, updated, validated, and ready for reuse."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019eef71-c9b0-7b12-a103-e9520320e36c
  - activi_dsactivi's Organization_default_019eef72-0da5-78f2-b489-53add16efd33
  - activi_dsactivi's Organization_default_019eef61-92c5-7002-b95b-e19af2fbeb41
contributors:
  - activi
version: 2
created_by_agent: codex
created_at: 2026-06-22T13:11:11.553Z
updated_at: 2026-06-22T13:24:11.881Z
---

## When to use
Use when a user gives a Hermes or OpenClaw hub skill link and wants Codex to turn it into a reusable installed Codex skill.

## Workflow
1. Open the provided skill link and identify the skill's purpose, trigger, inputs, outputs, and dependencies.
2. Give one recommendation first: `nutzen`, `nicht nutzen`, or `optimieren`.
3. Keep the recommendation short and concrete. Use up to 3 reasons tied to scope, quality, and fit for Codex.
4. If the recommendation is `nicht nutzen`, stop after the evaluation.
5. If the recommendation is `nutzen` or `optimieren`, create or update the Codex skill under `~/.codex/skills/<kebab-case-name>/`.
6. Write a focused `SKILL.md` with:
   - a precise trigger description for Hermes/OpenClaw skill links
   - a short `When to use` section
   - a minimal stepwise `Workflow`
   - an `Anti-patterns` section
7. Add only supporting files that materially improve execution, such as `references/` for source-specific guidance and `scripts/` for repeatable validation.
8. Keep the skill minimal, production-ready, and reusable. Prefer direct instructions over broad frameworks.
9. Validate the skill and confirm the final skill name and path.
10. If the link or required inputs are missing, ask only for the single missing item needed to continue safely.

## Anti-patterns
- Skipping the initial recommendation
- Creating a broad, generic skill instead of a focused converter
- Adding unnecessary files, abstractions, or unrelated domains
- Failing to make the skill durable and reusable in Codex
- Continuing past missing inputs when one clarification would unblock the work
