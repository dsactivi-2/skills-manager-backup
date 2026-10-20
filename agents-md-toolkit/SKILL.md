---
name: agents-md-toolkit
description: "Create, revise, or audit high-signal AGENTS.md guidance end to end: choose the correct scope, gather repository evidence, write concise instructions, and validate them. Use when one workflow should handle both scope and content."
---

# AGENTS.md Toolkit

Create the smallest durable instruction set that lets coding agents work safely and accurately in the target scope. Do not use this skill for ordinary code changes or to turn generic development advice into persistent rules.

## 1. Locate the right instruction surface

Inspect applicable global, repository, and nested `AGENTS.md` or `AGENTS.override.md` files. The closest applicable instruction file wins.

Choose the owner of each rule:

- Conversation for one-off constraints.
- Global guidance for personal cross-repository defaults.
- Root `AGENTS.md` for repository-wide facts and conventions.
- Nested guidance only for real subtree differences.
- A skill for reusable procedures, or a config, hook, test, or script for behavior that can be mechanically enforced.

Split mixed-scope requests. Preserve unrelated user-authored content. Request authorization before writing outside the current workspace.

## 2. Establish repository evidence

Before drafting, inspect manifests and lockfiles, task runners and CI, relevant docs and policies, existing test layout, generated artifacts, and local code conventions. Record only facts that the repository supports. Do not invent package managers, commands, workflows, review rules, or deployment processes.

## 3. Write the instruction file

Prefer short headings, bullets, tables for comparable commands, and repository-relative paths. Include only information that is both durable and non-obvious:

- Exact setup and narrow test, lint, typecheck, build, or run commands.
- Generated, security-sensitive, public, or otherwise constrained surfaces.
- Project-specific conventions and required companion changes.
- Pointers to existing architecture, API, release, or policy documents.

Omit generic advice, copied documentation, rationales that do not prevent an error, installed-skill inventories, secrets, and machine-local paths. Keep the root file under 60 lines when possible; exceed 100 only when evidence makes it necessary.

Add a Claude-compatible redirect only when the repository convention or user explicitly asks for it; never maintain divergent instruction copies.

## 4. Validate

Confirm each command and path exists, the hierarchy is not redundant, and no secret or volatile local detail was added. State any check that could not run and why. For global instruction changes, tell the user that a new Codex task may be needed for the change to load.
