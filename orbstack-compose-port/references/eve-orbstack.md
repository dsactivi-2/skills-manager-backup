# vercel/eve on OrbStack (verified 2026-09-03)

Live stack: `/Users/activi/Code/Projects/eve-orbstack`, container `eve-orbstack`, image `eve-orbstack:local`.
Host `127.0.0.1:12000` → container `2000`. Not `:3000` (Dograh).

## What to run

`packages/eve/Dockerfile` in github.com/vercel/eve is the **sandbox** base (`ubuntu`, user `vercel-sandbox`). It does not start an agent.

Do not clone the monorepo for "baue das in OrbStack". Scaffold with `npx eve@latest init <dir>` (npm `eve`, same version as the repo package), then `eve build` + `eve start --host 0.0.0.0 --port 2000` in `node:24-bookworm` (`uname -m` → `aarch64`).

Self-host docs: https://eve.dev/docs/guides/deployment/self-hosting

## Init isolation

`eve init` walks up to `~/pnpm-workspace.yaml` and may rewrite `~/package.json` (`engines.node: 24.x`). `--yes` has no effect.

In the project `pnpm-workspace.yaml`:

```yaml
packages:
  - "."
```

Revert home `package.json` if engines appeared. Do not expand the home workspace.

## Compose pitfalls

- Persist **only** `.eve/.workflow-data`. A volume on `.eve` hides image builds under `.eve/builds`.
- Named volume + `USER node` → `DataDirAccessError` / `EACCES` on `.workflow-data`. Run as `user: "0:0"` or chown the volume before start.
- `eve start` default port is 3000; `eve dev` default is 2000. Bind `--host 0.0.0.0`.
- Model calls need `AI_GATEWAY_API_KEY`. Health works without it.

## Verify

```
curl -sS http://127.0.0.1:12000/eve/v1/health
# 200 {"ok":true,"status":"ready",...}
```
