# voiceeu health scripts (fork-only)

Live tree check (2026-08-18): **`dograh-hq/dograh` has zero paths matching `health`**. Dedicated health scripts exist only on **`dsactivi-2/dograhV2`** under `deploy/voiceeu-health/`.

Do not confuse with Compose `healthcheck:` keys or `scripts/start_services_dev.sh` waiting on `/api/v1/health`.

## Pack

| File | Role | Mutates? |
|------|------|----------|
| `00_preflight_full.sh` | Inventory (paths, containers, URLs, env flags) → `preflight-full.{env,md,json}` | no |
| `10_health_full.sh` | PASS/WARN/FAIL: host, docker, API/UI, PG/Redis/MinIO, ports, TLS, processes | no |
| `20_status_scan_readonly.sh` | One-shot vs Deepgram-EU known-good baseline | no |
| `30_verify_fish_streaming.sh` | Fish TTS is WSS/PCM streaming, not HTTP MP3 | no (optional live WSS if key set) |
| `README.md` | Flow + exit codes | — |

Standard: `00` then `10`. Exit 0 = no FAIL (WARN OK); 1 = FAIL.

Raw: `https://raw.githubusercontent.com/dsactivi-2/dograhV2/main/deploy/voiceeu-health/<file>`

On server: `/root/dograh-eu-verify` per README. Local copy often at `~/Downloads/dograhV2-main/deploy/voiceeu-health/`.

## Related, not the pack

| Path | What |
|------|------|
| `scripts/start_services_dev.{sh,ps1}` | waits for `/api/v1/health` |
| `scripts/rolling_update.sh` | worker health retries |
| `docker-compose*.yaml` / `deploy/hostinger/docker-compose.yaml` | Compose `healthcheck:` |
| `ui/src/app/api/config/version/route.ts` | fetches backend `/api/v1/health` |
| `deploy/voiceeu/rollback/verify-current.sh` | rollback verify |

## Pitfall

`~/.cache/repo-mirrors/dograhV2-work` can lag GitHub. `git ls-files | rg health` there may be empty while `gh api repos/dsactivi-2/dograhV2/git/trees/HEAD?recursive=1` still lists `deploy/voiceeu-health`. Prefer live `gh api` tree for “what exists in the fork”.
