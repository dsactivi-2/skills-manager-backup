# Public Dograh fork: mirror + DograhV2 branding

Live example (2026-07): source `dsactivi-2/dograh` (or upstream `dograh-hq/dograh`) → public **`dsactivi-2/dograhV2`**.

## 1) Create empty public repo + mirror push

```bash
gh auth status   # active account must own the target org/user
gh repo create OWNER/dograhV2 --public --description "DograhV2 — public fork of Dograh"

mkdir -p ~/.cache/repo-mirrors && cd ~/.cache/repo-mirrors
rm -rf dograh.git
git clone --mirror https://github.com/SOURCE/dograh.git
cd dograh.git
git push --mirror https://github.com/OWNER/dograhV2.git
# Expect: branches/tags OK; refs/pull/*/head|merge → remote rejected (normal on GitHub)
git ls-remote https://github.com/OWNER/dograhV2.git
```

Worktree for edits:

```bash
git clone --branch main https://github.com/OWNER/dograhV2.git dograhV2-work
```

## 2) Surface branding (safe set)

Touch these classes of files:

- Root `README.md` + locale READMEs: title **DograhV2**, fork banner linking upstream + this repo, install curls → `raw.githubusercontent.com/OWNER/dograhV2/...`
- `api/pyproject.toml` distribution name/description (e.g. `dograhv2-api`)
- `sdk/python/pyproject.toml` dist name (e.g. `dograhv2-sdk`) + repository URL; **keep** `[tool.hatch] packages = ["src/dograh_sdk"]` and import `dograh_sdk`
- `sdk/typescript/package.json`: repository URL + description; **keep** `"name": "@dograh/sdk"` unless you also rewrite every import + MCP generator fixtures
- `ui/package.json` name (e.g. `dograhv2-ui`), `GitHubStarBadge` + overview links → this repo
- `docs/docs.json` `name`, deploy docs install URLs that pointed at the old clone
- `deploy/helm/*/Chart.yaml` chart `name` / description / sources (template helpers may still say `dograh.*` — OK)
- `docker-compose.yaml`: comments + optional `container_name`; **keep** `image: ${REGISTRY:-dograhai}/dograh-api|ui` so prebuilt pull works

## 3) Do not bulk-rewrite

| Keep | Why |
|------|-----|
| `@dograh/sdk` / `@dograh/sdk/typed` | MCP TS validator, tests, examples |
| `dograh_sdk` Python path | Installable import surface |
| `dograhai/dograh-api`, `dograh-ui` | Official prebuilt images |
| `dograh-hq/dograh-plugins` | Claude/Codex setup skill marketplace |
| `app.dograh.com`, `docs.dograh.com` | Upstream SaaS/docs |
| `upstream` → `dograh-hq/dograh` | Sync / contribute-back path |

False positive from naive replace: `…/dograh-plugins` → `…/dograhV2-plugins`. Grep for `V2-plugins` after any rewrite.

## 4) README edit safety

1. `git checkout HEAD -- README*.md` if a bad regex ate content (check `git diff --stat` line deltas).
2. Replace title line + insert a short banner; then targeted URL replaces for **raw.githubusercontent** and **star/clone** links only.
3. Re-fix banner “upstream Dograh” link so it still points at `dograh-hq/dograh`, not the fork.

## 5) Verify + ship

```bash
rg -n 'dograhV2-plugins|dsactivi-2/dograhV2' -g '!CHANGELOG.md' | head
git diff --stat   # README should not shrink by tens of lines unexpectedly
git commit -m "chore: brand public fork as DograhV2"
git push origin main
gh repo edit OWNER/dograhV2 --description "DograhV2 — public fork of Dograh (...)"
```

Optional later (not default branding): own image tags + build pipeline for `dograhv2-api`/`dograhv2-ui`.
