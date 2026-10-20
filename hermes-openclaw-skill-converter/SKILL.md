---
name: "hermes-openclaw-skill-converter"
description: "Use when the user pastes or links a Hermes or OpenClaw skill URL, markdown link, or file path and wants it evaluated and converted into a Codex skill. Always return a first recommendation of nutzen, nicht nutzen, or optimieren. For nutzen or optimieren, create the target Codex skill in ~/.codex/skills with only the files needed."
---

# Hermes/OpenClaw Skill Converter

Use this skill when a Hermes or OpenClaw skill link must become a Codex skill.

## Workflow
1. Read the linked skill first.
2. Judge whether it is worth reusing in Codex.
3. Return the recommendation first: `nutzen`, `nicht nutzen`, or `optimieren`.
4. Add a one-line reason.
5. If the recommendation is `nicht nutzen`, stop.
6. If the recommendation is `nutzen` or `optimieren`, create the target Codex skill step by step.
7. Save the result permanently under `~/.codex/skills/<skill-name>/`.
8. Create only the files that are required.
9. Keep the final skill short, imperative, and production-ready.
10. Validate that the new folder is a normal Codex skill.

## Conversion rules
- Preserve the original intent, but tighten the trigger for Codex.
- Make the frontmatter description explicit about Hermes/OpenClaw links and conversion.
- Keep the body lean.
- Add `agents/openai.yaml`, `references/`, or `scripts/` only when they are clearly needed.
- Do not add extra documentation.

## Output format
- Recommendation first.
- Short justification second.
- Then, if needed, the conversion work.
