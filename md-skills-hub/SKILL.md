---
name: md-skills-hub
description: Present the five Markdown and Codex-configuration skills, explain their purpose, and route an explicit user choice to the selected skill. Use only when the user asks to choose among these skills.
---

# MD Skills Hub

Help the user select one of the five available Markdown and Codex-configuration
skills. This hub is only a menu and router; it does not replace their rules or
perform their work itself.

## Show the selection

Present this numbered list in simple language, then ask the user to reply with
one number or one skill name:

1. **create-global-md-files** — creates or improves global Codex rules and
   skills that should work on this Mac across projects.
2. **create-project-md-files** — creates or improves durable Markdown files
   for the current project, such as `AGENTS.md`, runbooks, decisions, evals,
   and project skills.
3. **create-session-md-files** — creates only the small Markdown files useful
   for one concrete task or work phase, for example a task plan.
4. **update-md-files** — reviews and improves existing global, project, or
   task Markdown instructions and operations files.
5. **release-check** — checks whether a planned release is ready and reports
   missing checks or risks; it never publishes a release.

## Route the selection

- Accept a number, the exact skill name, or an unambiguous German description.
- Confirm the selected skill by name.
- Read the selected skill's `SKILL.md` from `~/.codex/skills/<skill-name>/`.
  If it is unavailable, use the matching project copy under
  `.agents/skills/<skill-name>/`. For `create-global-md-files`, also check
  `~/.agents/skills/<skill-name>/` as a fallback.
- Follow the selected skill from that point onward, including its approval and
  safety rules. Do not continue applying this hub's menu workflow.
- If the choice is unclear or unavailable, show the five options again and
  explain the missing path. Do not guess or substitute another skill.

## Boundary

Selecting a skill loads and follows its instructions; it does not cause a
visible user-interface jump and does not grant permission for writes, releases,
or external actions.
