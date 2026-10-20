# Lark CLI skills → Hermes profiles

Verified 2026-09-03. User: „hast du die lark skills installiert“ then „global für alle hermes instanzen“.

Official pack: 28 `lark-*` skills in `github.com/larksuite/cli` `skills/` (plus optional `meegle` in the dedicated `hermes-lark` profile — not part of this pack).

## No first-class global store

Same rule as the parent skill: do **not** invent one skills tree for every profile. Practical pattern: one SoT + per-profile **symlinks** of the 28 dirs. Fat default; lean RP/companion profiles stay empty of Lark.

„Alle Instanzen“ = every **Hermes home** (Mac default + named *work* profiles + remote **default**). It is **not** „every VPS role including s-ella / s-pornsearch“. Skip RP-only profiles even when the user says global.

## Two installers, pick one SoT

| Command | What it actually does |
|---------|------------------------|
| `hermes skills install …` | Hub IDs / HTTP SKILL.md only. Local `skills/` paths fail. |
| `npx skills add larksuite/cli` | Not the preferred path here (28 names, overwrite risk on class folders). |
| `npx @larksuite/cli@latest install` | Installs **binary** `lark-cli` **and** copies skills into `~/.agents/skills/lark-*`. Also **retargets** `~/.hermes/skills/lark-*` to those dirs. Named profiles are **not** updated. Does **not** run `config init` / `auth login`. |
| Sparse git clone `larksuite/cli` → `~/.hermes/plugins/lark-cli` | Skills-only SoT when the host has git but no npm (e.g. myhermi). |

After the official npm installer, **one SoT**: `~/.agents/skills/lark-*`. Relink default **and** every work profile to that path. Do not leave default → `.agents` while `hermes-lark` / `barbares` still point at `plugins/lark-cli` (two trees, later updates diverge).

```bash
# Mac: after npx @larksuite/cli@latest install
SRC=~/.agents/skills
for home in ~/.hermes/skills ~/.hermes/profiles/*/skills; do
  for d in "$SRC"/lark-*; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    dest="$home/$name"
    rm -rf "$dest"
    ln -s "$d" "$dest"
  done
done
# verify
hermes skills list | rg 'lark-'
HERMES_HOME=~/.hermes/profiles/barbares hermes skills list | rg -c 'lark-'
```

Host without npm: sparse-clone `skills/` under `$HERMES_HOME/plugins/lark-cli` and symlink those dirs into **default** only unless the user named extra work profiles.

## Collisions on a dedicated Lark profile

`hermes-lark` already had **top-level copies** (`skills/lark-im/…`, not `skills/lark/lark-im`). Linking a category folder **and** keeping the copies → Ambiguous `name:`. Replace the copies with symlinks to the shared SoT (backup first). Do not also add `skills/lark/`.

Scan frontmatter `name:` on the target profile before mass-link. 28 names, all `lark-*` — default/barbares/marge/hermesvoice were free on 2026-09-03.

## Auth is not part of skill install

`lark-cli config init --new` and `lark-cli auth login` need App Secret and a browser. Stop after skills + binary. Report login as a remaining interactive step. Do not copy Lark App Secret across profiles or VPS.

## Verify

- Disk: 28 `lark-*` dirs, each a symlink, `SKILL.md` present.
- CLI: `hermes -p <name> skills list` count 28 (or `HERMES_HOME=…/profiles/<p>`).
- Binary (Mac): `command -v lark-cli` — skills without CLI are inert instruction files.
- This session: `skill_view(name='lark-shared')` after link; other sessions need `/reload-skills` or a new session.
