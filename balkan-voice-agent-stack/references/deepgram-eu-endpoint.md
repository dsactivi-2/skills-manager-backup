# Deepgram EU endpoint + Nova-3 bs (verified 2026-07-30)

## EU residency — exists (do not claim "no EU hosting")

| Item | Value |
|------|--------|
| EU base URL | `https://api.eu.deepgram.com` |
| Status | **GA** (changelog 2025-12-03; marketing "EU Endpoint GA") |
| Auth | **Same API keys as US** — only change host |
| Live DNS | resolves AWS IPs |
| Live geo (ipinfo) | **Frankfurt am Main, DE** (AS16509) |
| US default | `https://api.deepgram.com` — **not** EU |

Supported on EU endpoint: STT, TTS, Voice Agent, Text Intelligence (Whisper excluded on EU per GA notes).

## Access probe (before any Dograh code change)

Same key works on EU listen. Key source (Activi): 1Password vault **DograhEU**, item **Deepgram** (field Anmeldedaten).

```bash
export DEEPGRAM_API_KEY='…'   # from 1P DograhEU/Deepgram

# US control (projects list)
curl -sS -w "\nHTTP %{http_code}\n" \
  -H "Authorization: Token ${DEEPGRAM_API_KEY}" \
  "https://api.deepgram.com/v1/projects"

# EU STT smoke (this is the gate that matters)
python3 - <<'PY'
import wave
p='/tmp/silence.wav'
with wave.open(p,'w') as w:
    w.setnchannels(1); w.setsampwidth(2); w.setframerate(16000)
    w.writeframes(b'\x00\x00'*16000)
print(p)
PY
curl -sS -w "\nHTTP %{http_code}\n" \
  -H "Authorization: Token ${DEEPGRAM_API_KEY}" \
  -H "Content-Type: audio/wav" \
  --data-binary @/tmp/silence.wav \
  "https://api.eu.deepgram.com/v1/listen?model=nova-3-general&language=bs"
```

### Live probe result (2026-07-30, same DograhEU key)

| Call | HTTP | Note |
|------|------|------|
| US `/v1/projects` | **200** | key valid |
| EU `/v1/projects` | **404** | path not required for STT |
| EU `/v1/listen?model=nova-3-general&language=bs` | **200** | **EU STT access OK** |

Do not treat EU `/v1/projects` 404 as "no EU access".

## Deepgram CLI (`dg` / deepctl)

```bash
curl -fsSL https://deepgram.com/install.sh | sh   # → ~/.local/bin/dg
export PATH="$HOME/.local/bin:$PATH"              # also ~/.zshrc
```

Config: `~/Library/Application Support/deepctl/config.yaml`

### Activi working layout (live 2026-07-30)

| Profile | base_url | Role |
|---------|----------|------|
| **`us`** (default_profile) | `https://api.deepgram.com` | `dg listen` / `dg speak` / `dg api` **works** |
| **`dograheu`** | `https://api.eu.deepgram.com` | EU URL stored; **`dg listen -p dograheu` broken** |

Put `api_key:` under each profile (chmod 600) and/or `DEEPGRAM_API_KEY` in env. Key SoT: 1Password vault **DograhEU** / item **Deepgram**.

```bash
dg whoami                          # expect Profile us + Authenticated
dg listen file.wav -m nova-3 -l bs # US host — CLI OK
dg speak "Zdravo" -o /tmp/out.wav
dg api /v1/projects
```

### EU STT without broken CLI listen

Skill script: `scripts/dg-eu-listen.sh` (or `~/.local/bin/dg-eu-listen`).

```bash
bash scripts/dg-eu-listen.sh file.wav bs nova-3-general
```

| Pitfall | Action |
|---------|--------|
| `dg login` "valid but lacks permission for this project" while curl works | Prefer curl / config `api_key:` for STT |
| `dg listen` + EU base_url → `DeepgramClientEnvironment … agent_rest` | deepctl **0.2.25** bug — not "no EU"; use curl / script |
| `Not logged in` after logout | Re-write profile `api_key` from 1P; keep default_profile **us** |
| CLI flags | `dg listen` has **no** `--keyterm` — only `-l`/`-m` |
| Hermes MCP `dg mcp` / docs kapa | Optional; docs MCP may 401 |

## Nova-3 language

- Model: `nova-3` / `nova-3-general`
- Bosnian: **`bs`**
- Also `hr`, `sr` on Nova-3 overview (live HTTP 200)

## Dograh / voiceeu wiring (post-ship 2026-07-30)

### UI (AI Models → BYOK → Transcriber → Deepgram)

Fields: Provider, Model, Language, API Key. **No endpoint field** — host is code/env:

```text
stt.deepgram: provider, api_key, model, language
# base_url absent in org schema — OK; PR #6 pins EU in factory
```

Set model `nova-3-general`, language **`bs`**, Deepgram key.

### Factory (live image `dograhv2-api:dg-eu`)

```python
DEEPGRAM_BASE_URL = os.getenv("DEEPGRAM_BASE_URL", "api.eu.deepgram.com")
stt_base_url, flux_url, tts_ws = _deepgram_inference_urls()
return DeepgramSTTService(api_key=..., base_url=stt_base_url, settings=...)
```

Key validate may log US `GET api.deepgram.com/v1/projects` (EU has no projects) — normal.  
**Inference** = `api.eu.deepgram.com`.

### Call-path verify (safest/fastest)

```bash
docker logs -f dograh-api-1 2>&1 | grep -iE 'deepgram|api\.eu\.deepgram|api\.deepgram|/v1/listen'
# trigger call — expect eu host on listen/wss
```

Ops/rollback: `dograh-upstream-platform` → `references/voiceeu-prebuilt-deploy-fork.md`  
Server: `/root/dograh/dograh/rollback/`.

## When Deepgram is blocked

| Constraint | Path |
|------------|------|
| Org still Speechmatics | switch Transcriber=Deepgram + `bs` (EU code already live) |
| Image rolled back to Hub 1.43.0 | no `DEEPGRAM_BASE_URL` → US default if DG used |
| Residenz + stock Hub only | Azure Speech STT `bs-BA` @ GWC |
| Speechmatics only | Dograh SM list **`hr` not `bs`** — ghost text risk |

## Related

- Keyterms: `references/deepgram-keyterms.md`
- Script: `scripts/dg-eu-listen.sh`
- Org config API: `dograh-mcp-workflow-ops` → `references/org-tts-stt-llm-config.md`
- Ghost STT: `dograh-mcp-workflow-ops` → `references/ghost-stt-pas-open.md`
