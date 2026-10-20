# Paperclip on OrbStack

Official image (linux/amd64 + linux/arm64): `ghcr.io/paperclipai/paperclip:latest`.
Prefer pull+run over cloning the repo and `docker compose --build`.

## Run

Publish only loopback. Keep secrets in a 600 env file, never in chat.

```
docker --context=orbstack run -d --name paperclip --restart unless-stopped \
  -p 127.0.0.1:3100:3100 \
  -e HOST=0.0.0.0 \
  -e PAPERCLIP_HOME=/paperclip \
  -e PAPERCLIP_DEPLOYMENT_MODE=authenticated \
  -e PAPERCLIP_DEPLOYMENT_EXPOSURE=private \
  -e PAPERCLIP_PUBLIC_URL=http://127.0.0.1:3100 \
  -e PAPERCLIP_AUTH_PUBLIC_BASE_URL=http://127.0.0.1:3100 \
  -e PAPERCLIP_ALLOWED_HOSTNAMES=127.0.0.1,localhost \
  -e BETTER_AUTH_TRUSTED_ORIGINS=http://127.0.0.1:3100,http://localhost:3100 \
  --env-file <secrets.env> \
  -v paperclip-data:/paperclip \
  ghcr.io/paperclipai/paperclip:latest
```

Required in the env file: `BETTER_AUTH_SECRET` (and `PAPERCLIP_TOOL_ACTION_SIGNING_SECRET` if the image expects it). Do not pass provider API keys unless the user supplied them — UI starts without them; agents will not.

Tell the user **one** URL and use that same origin in env. Mixing `http://localhost:3100` in env with a browser on `http://127.0.0.1:3100` fails auth.

## Verify

- `docker --context=orbstack ps --filter name=paperclip`
- `curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:3100/api/health` → 200
- Logs: `trustedOrigins` must include the browser origin. `Invalid origin` is a config bug, not a password bug.
- Login is done only when the user can create/sign in in the browser. Do not POST `/api/auth/sign-up/email` as a probe — first successful signup claims instance admin.

## Auth pitfalls

- Better Auth without a trusted client-IP header shares one per-path rate bucket. Origin 403s then look like 429 Too many requests.
- First-admin UI: Sign in / Create account in the browser, or `npx paperclipai auth bootstrap-ceo` **inside** the running instance (needs DB). Host `npx` against an empty home is a different install.
- Banner `Agent JWT missing` does not mean the server is down; adapters need `PAPERCLIP_AGENT_JWT_SECRET` / onboard later.
