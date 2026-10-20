# Verify Deepgram host on a live call (voiceeu)

## Fastest safe check

```bash
# Terminal A (before call)
docker logs -f dograh-api-1 2>&1 | grep -iE 'deepgram|api\.eu\.deepgram|api\.deepgram|/v1/listen'

# Then start call 15–40s, speak once, hang up. Ctrl+C.
```

| Log | Meaning |
|-----|---------|
| `Creating STT service: provider=…DEEPGRAM, model=nova-3-general` | Deepgram STT used for that run |
| `GET https://api.deepgram.com/v1/projects` | Key validation only (US) — expected |
| `api.eu.deepgram.com` / listen | EU inference (often **not** logged by default) |

## Prove EU routing (no call needed)

One line (no line break inside `-c`):

```bash
docker exec dograh-api-1 python -c "from api.constants import DEEPGRAM_BASE_URL; from api.services.pipecat.service_factory import _deepgram_inference_urls; print(DEEPGRAM_BASE_URL); print(_deepgram_inference_urls())"
```

Expect: `api.eu.deepgram.com` + `wss://api.eu.deepgram.com/v2/listen` (Flux URL built always; Nova uses `stt_base` host only).

## After-call transcript quality

```bash
# run detail → transcript_public_url
curl -sS -H "X-API-Key: $MCP_DOGRAH_VOICEEU_API_KEY" \
  "https://voiceeu.activi.io/api/v1/workflow/22/runs/<ID>"
```

WF22 Deepgram samples (2026-07-30): better than SM ghosts; still short-token noise; Open edges may treat `Ali`/garbage as refuse/DNC.

## Keyterms

Org UI: no field. Set `workflow_configurations.dictionary` = `Aquaphor,Firmira,…` on the **published definition** path (or UI equivalent if exposed). `run_pipeline.py` splits on comma → `keyterms` → Nova-3 `keyterm=`.
