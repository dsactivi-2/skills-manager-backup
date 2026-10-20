---
name: markdownlint
description: Use when writing Markdown. Run markdownlint-cli2.
---

# Markdownlint

After every write or edit of a Markdown file (`.md`, `SKILL.md`, `README`,
`AGENTS.md`, specs, docs), lint the **touched files only**, then fix findings.
Chat replies are not linted.

## Command

Global binary: `markdownlint-cli2`
(`~/Library/pnpm/bin/markdownlint-cli2`). No second npm install.

Run from the file's directory with the basename. Absolute `/Users/...` paths
are treated as globs and silently lint 0 files.

If the project has `.markdownlint-cli2.jsonc` (or `.markdownlint.json`):

```bash
markdownlint-cli2 SKILL.md
```

Otherwise pass the home fallback (home config is not auto-discovered):

```bash
markdownlint-cli2 --config ~/.markdownlint-cli2.jsonc --no-globs SKILL.md
```

Done when exit 0. Re-run after each fix.

`--fix` only for trailing spaces and extra blank lines. Headings, lists, and
fences: edit the file. Do not lint the whole repo unless asked.

## Defaults (home fallback)

- MD013 (line length) off — agent docs wrap for reading, not 80 cols
- MD041 (first-line heading) off — YAML frontmatter is valid
- MD033 (inline HTML) off — docs/skills may use HTML
