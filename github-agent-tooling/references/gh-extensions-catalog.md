# gh extensions — short catalog + use cases

Install only on explicit need: `gh extension install owner/repo`  
List/search: `gh extension list`, `gh extension search`  
Always verify installed set with `gh extension list` before re-installing.

| Extension | Function | Use case | Agent-relevant? | Local default |
|-----------|----------|----------|-----------------|---------------|
| `dlvhdr/gh-dash` | TUI dashboard for PRs/Issues | Daily human review queue in terminal | No (human TUI) | not installed |
| `gennaro-tedesco/gh-s` | Interactive/keyword repo search | Browse hits without knowing name | Medium — prefer `gh search repos` in agent; `gh s "q" -l lang` OK | **installed** (`gh s`) |
| `gennaro-tedesco/gh-f` | fzf wrapper around gh | Fuzzy pick repo/PR then act | Low — pick, not discover | skip unless asked |
| `seachicken/gh-poi` | Safe local branch cleanup | After many merged feature branches | Yes for hygiene; **`--dry-run` first** | **installed** (`gh poi`) |
| `yusukebe/gh-markdown-preview` | Local MD rendered like GitHub | README/PR body preview before push | Optional | **installed** |
| `github/gh-stack` | Stacked PR management | Large feature split into dependent PRs | Yes if user stacks PRs | on need |
| `github/gh-actions-importer` | Migrate CI → GitHub Actions | Jenkins/GitLab/Azure DevOps/etc. move | Project-only | on need |
| `github/gh-gei` | GitHub Enterprise Importer | Org/repo move between GH instances | Project-only | on need |
| `mona-actions/gh-repo-stats` | Repo metadata stats for migrations | Pre-migration sizing/priority | Project-only | on need |
| `github/gh-skyline` | 3D contribution model | Fun/visual only | No | no |
| `github/gh-copilot` | Old Copilot-in-CLI | **Deprecated** — do not install | No | never |

## Agent usage rules

- User gives natural-language tasks; agent runs `gh` / extensions.
- Prefer non-interactive: `gh search … --json …`, `gh s "query" -l python`, `gh poi --dry-run`.
- Do not launch bare interactive TUIs (`gh s` with no args, `gh f`, `gh dash`) inside the agent loop.
- Separate **GitHub Copilot CLI** product ≠ this extension; only install if user asks + has subscription (default no — Hermes covers “how do I build this command?”).

## Core substitutes (no extension)

```bash
gh search repos "livekit voice agent" --limit 20
gh search repos "topic:voice-ai language:Python" --sort stars
gh search code "create_agent" --language python
gh pr list --author @me
gh issue list --label bug
gh poi --dry-run
gh markdown-preview README.md
```
