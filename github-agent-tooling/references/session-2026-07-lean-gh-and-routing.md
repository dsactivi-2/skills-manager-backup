# Session notes — lean gh + discovery routing (2026-07)

## Tooling decisions (user)

- Global `gh` via Homebrew is enough for all agents; **no** default GitHub MCP.
- Do **not** install `github/gh-copilot` (deprecated). Separate Copilot CLI only if user wants it (default no).
- Installed extensions (user requested): `gh-s`, `gh-poi`, `gh-markdown-preview`.
- Skip `gh-f` unless user wants fzf picker TUI.
- Agent path: natural-language instructions → non-interactive `gh` (`gh search … --json`, `gh s "q" -l …`). User need not type raw gh.
- `gh poi`: always `--dry-run` first.

## Skill routing

| User intent | Skill |
|-------------|--------|
| Find **GitHub repos** by use case / function (no name) | `repo-by-usecase` |
| Choose gh vs MCP vs extensions | this skill (`github-agent-tooling`) |
| Bosnian/Balkan **STT/LLM/TTS providers** | `balkan-voice-agent-stack` / `bosnian-tts-provider-comparison` — NOT gh search |
| Agent skills ecosystem | `find-skills` / `hermes-skills` |
| HF models | `huggingface-hub` / `llama-cpp` |

## SKILL.md integrity

This skill's SKILL.md acquired a **corrupted duplicate** "Repo search patterns" section (half-merged workflow + repo-by-usecase pointer). Autonomous curator patch/edit was blocked (`read_before_write` / ownership). Fix manually or:

```bash
hermes curator adopt github-agent-tooling
# then re-edit SKILL.md to single clean section pointing at repo-by-usecase
```

Also adopt if needed: `repo-by-usecase` (created this session, reported created_by=None).

## Overlap

`balkan-voice-agent-stack` vs `bosnian-tts-provider-comparison` (frontmatter name `bosnian-voice-agent-stack`) — consolidate candidates for background curator.
