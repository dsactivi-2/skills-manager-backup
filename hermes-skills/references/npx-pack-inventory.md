# List every skill in an npx pack

User: „liste alle Skills aus diesem Link“ / names + downloads + simple one-liners, numbered. Same shape for a topic search („hat Matt X, sonst andere“).

## Commands

| Goal | Command | What you get |
| --- | --- | --- |
| Full installable set | `npx skills add <owner/repo> --list -y` | Every skill name + pack description. Clones; does **not** install. |
| Popularity / install counts | `npx skills find [query] [--owner <owner>]` | Ranked **top ~20** by installs. Not complete. Not a name lookup. |
| One skill’s count | skills.sh page (fetch recipe below) | Display count + `userInteractionCount`. |

Do **not** loop `npx skills find <each-skill> --owner X` expecting per-skill hits — it keeps returning the same top-20.

## Topic search (Matt first, then others)

1. `npx skills add mattpocock/skills --list -y` — full names+blurbs, no install.
2. Keep only skills whose description matches the task. Do not treat `find --owner mattpocock` as that filter (popularity top; the named skill can be missing).
3. Other creators: `npx skills find <query> -y`. Drop false positives where query tokens hit unrelated names.
4. Per kept skill, take installs from the page recipe below. Prefer 1K+; under 1K only if the user asked for leftovers, marked vorsichtig.
5. Present Matt block first, then others. Confirm before any install.

One named skill „wo liegt der online, wie viele Downloads“: verify the local path first, then the catalog page `https://skills.sh/<owner>/<repo>/<skill>` (example: find-skills → `vercel-labs/skills/find-skills`).

## Install counts

`web_extract` often omits the Installs field. Bare `https://skills.sh/...` returns HTTP 308 — fetch `https://www.skills.sh/<owner>/<repo>/<skill>`.

Parse either:
- HTML: heading `Installs`, then the large `text-3xl` value (e.g. `238.0K`)
- JSON-LD: `userInteractionCount`

Canonical link in the answer: `https://skills.sh/<owner>/<repo>/<skill>` (no www). Missing parse → `—`, never invent.

## skills.sh vs `--list`

`https://skills.sh/<owner>/<repo>` HTML can list extra names that are templates/tests (`good-skill`, `good-skill-minimal`, `cli-e2e-testcase-writer`, umbrella `lark-suite`). `--list` is the installable set. Say so if the page has extras.

A **skill** page `https://skills.sh/<owner>/<repo>/<skill>` can show a high Installs number while `--list` omits that name and HEAD has no matching path (catalog leftover after the pack dropped it). Do not run `npx skills add --skill <name>` from the page alone. Confirm the name is in `--list` first.

No URL but a vendor name (e.g. Lark) → official pack `owner/repo` on skills.sh, then `--list`. Do not stall on the missing paste.

## Full pack + installed + Empfehlung

When the user wants every skill, sorted by downloads, plus installed ja/nein and whether to install:

1. Names from `--list` only.
2. Counts from the www.skills.sh recipe; sort by `userInteractionCount` descending.
3. Installed: `~/.hermes/skills/<name>` exists **and** has SKILL.md (follow symlink). Folder/symlink alone is not usable.
4. Already on disk → Empfehlung is **behalten** or **nicht nutzen**, never "installieren". Missing → **installieren ja/nein**. If the whole `--list` set is already present: lead with nichts nachinstallieren.
5. Catalog-only names (page exists, `--list` omits): leftover block, **nicht nachrüsten**.

## Present to Denis

CLI: numbered list (not a table). Each item: name, install count, skills.sh link on its own line, one Alltag sentence (German, simple words, Fachbegriff first). If asked: installed ja/nein + Empfehlung as above. Missing count → `—`. Do not invent. Do not dump SKILL.md / README bodies.
