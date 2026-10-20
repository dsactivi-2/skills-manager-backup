# Verified Zep install (2026-08-24)

Live commands from the Mac session that landed the Codex plugin + `zepctl`. Do not treat versions as forever-current; re-check with `zepctl version` / `codex plugin list --json`.

## Codex

```bash
codex plugin marketplace add getzep/building-with-zep-plugin --json
# marketplaceName: building-with-zep
# installedRoot: ~/.codex/.tmp/marketplaces/building-with-zep

codex plugin add building-with-zep@building-with-zep --json
# pluginId: building-with-zep@building-with-zep
# version: 0.4.2
# installedPath: ~/.codex/plugins/cache/building-with-zep/building-with-zep/0.4.2
```

## Homebrew

Tap-trust is mandatory:

```
Error: Refusing to load formula getzep/zepctl/zepctl from untrusted tap getzep/zepctl.
Run `brew trust --formula getzep/zepctl/zepctl` or `brew trust getzep/zepctl` to trust it.
```

```bash
brew tap getzep/zepctl https://github.com/getzep/zepctl.git
brew trust getzep/zepctl
brew install --formula getzep/zepctl/zepctl
# zepctl 0.2.1  commit 64cc471dd7098d066402c7d6fadc343a1b6de34f
```

If a first `brew install` is still compiling (`go build … ./cmd/zepctl`), wait. A second install fails with a Cellar lock on `/opt/homebrew/Cellar/zepctl`.

## Hermes MCP (not done in that session)

- Docs: `https://docs-mcp.getzep.com/mcp` — public, `printf 'n\nY\n' | hermes mcp add zep-docs --url …`
- Memory: `https://api.getzep.com/mcp` — OAuth/IdP, seats; never `auth: none`
