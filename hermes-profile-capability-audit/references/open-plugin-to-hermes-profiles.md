# Open-plugin format → Hermes multi-profile

## Two installers, two worlds

| Command | Targets | Hermes effect |
|---------|---------|----------------|
| `npx plugins add owner/repo [-y] [--scope user]` | Claude Code, Codex, Copilot CLI, Grok Build, Cursor, Kimi | None |
| `hermes plugins install owner/repo` | Hermes `$HERMES_HOME/plugins/` | Clones only; needs `plugin.yaml` or `__init__.py` to load |
| Symlink skill dirs into `skills/<cat>/` | Hermes skill index | **Actual** skill availability |

`npx plugins targets` lists agent configs (e.g. `~/.claude`, `~/.codex`). Hermes never appears.

## Why hermes plugins install is insufficient for vercel-plugin

- Repo is open-plugin format (`.claude-plugin`, skills/, hooks/) not Hermes plugin format.
- Warning: "doesn't contain plugin.yaml or __init__.py".
- Directory may exist under `~/.hermes/plugins/vercel-plugin` but `hermes plugins enable vercel-plugin` → not installed/bundled.
- Skills still work if linked into the skills tree.

## Why hermes skills install local path fails

`hermes skills install` expects hub IDs or HTTP(S) SKILL.md URLs. Absolute local paths error with "Could not fetch … from any source".

## Proven multi-profile recipe (vercel/vercel-plugin)

```bash
# 1) Optional: other coding agents
npx plugins add vercel/vercel-plugin -y --scope user

# 2) Shared clone (once)
# Prefer existing: ~/.hermes/plugins/vercel-plugin
# Or: git clone --depth 1 https://github.com/vercel/vercel-plugin.git ~/.hermes/plugins/vercel-plugin

SRC=~/.hermes/plugins/vercel-plugin/skills
CAT=vercel

# 3) Default + every profile
link_into() {
  local skills_root="$1"
  mkdir -p "$skills_root/$CAT"
  for d in "$SRC"/*; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    dest="$skills_root/$CAT/$name"
    rm -rf "$dest"
    ln -s "$d" "$dest"
  done
}

link_into ~/.hermes/skills
for p in ~/.hermes/profiles/*/; do
  link_into "$p/skills"
  mkdir -p "$p/plugins"
  ln -sfn ~/.hermes/plugins/vercel-plugin "$p/plugins/vercel-plugin"
done

# 4) Verify
hermes skills list | rg "│ $CAT "
HERMES_HOME=~/.hermes/profiles/marge hermes skills list | rg "│ $CAT " | head
```

Script wrapper: `scripts/hermes-open-plugin-to-profiles.sh`.

## Pitfalls

- **Mass-install bloat:** 30 Vercel skills on every lean voice profile increases skill index size. Only do all-profiles when user asks; else default + selected roles.
- **Name collisions:** frontmatter `name:` is the Hermes skill id (not folder alone). Scan existing SKILL.md names before linking.
- **Nested SKILL.md:** some plugin skill trees contain nested skills (e.g. next-best-practices under a parent). `rglob` may show more names than top-level dirs — fine; top-level symlink still exposes them if Hermes walks subdirs.
- **Grok Build:** `npx plugins` may fail with unrecognized `plugin` subcommand — ignore if Hermes path succeeded.
- **Bun:** Vercel plugin docs mention Bun for hook build; Hermes skill consumption only needs the SKILL.md tree (no Bun required).
- **Updates:** pull shared clone once (`git -C ~/.hermes/plugins/vercel-plugin pull`); all profile symlinks see new content. Then `/reload-skills` or new session.

## Related

- No global shared store: `references/no-global-shared-store.md`
- Selective copy without open-plugin: `scripts/hermes-profile-sync.sh`
