---
name: python
description: "Class-level umbrella for Python development tooling: CLI first-run setup for pipx/uv apps, debugpy/pdb remote debugging, and related Python workflows."
tags: ["python", "debugging", "cli", "devops"]
---

# Python Umbrella Skill

Consolidated skill for Python-related agent tasks.

## CLI First-Run Setup
Install, launch, and verify Python-based CLI/web apps on macOS, especially pipx/uv-hosted tools that need bootstrap, startup token, or LAN exposure.

See original `python-cli-first-run` for workflows, token handling, LAN verification, and references.

## Debugging
Debug Python: pdb REPL + debugpy remote (DAP). Covers local breakpoints, post-mortem, remote attach, pytest integration, and Hermes-specific processes.

See original `python-debugpy` for recipes, pitfalls, and cross-references to systematic-debugging.

## References
- Original skill bodies archived.
- `references/building-python-mcp-servers.md` — Patterns for building custom MCP servers in Python, Liferay portal scraping without browser, venv isolation pitfalls, and Hermes registration.
