# LiveKit Cloud access, observability, SIP (verified 2026-08-24)

## Access (do not claim dashboard admin)

| Channel | Can | Cannot |
|---|---|---|
| CLI `lk` (project `aai`, `p_3dsfdizoiyr`) | agents, secrets **names**, SIP list, deploy, numbers | flip Data/Observability toggles |
| MCP `livekit-docs` | documentation only | account, recordings, switches |
| Preview if user is logged in | **read** settings pages | do not click toggles without Freigabe |

No LiveKit Cloud-admin MCP. Recording/observability = user dashboard.

## Observability (not the token-server screenshot)

Path: Settings → **Observability** (`/settings/observability`).  
General → Data and privacy only says “these settings have moved”.

| Control | Live 2026-08-24 | Notes |
|---|---|---|
| Agent observability | ON | Bundles traces + transcript + **audio** (no separate Session-recording toggle) |
| PII redaction | OFF | Docs: English-only. Leave off for Bosnian |
| Development token server | ON (`aai-1gs0s5`) | Frontend tokens only — **not** call recording |
| Data residency note | US possible | Observability upload may be processed in US |

SDK `record=True` is default on `session.start`. Upload is **after** hangup. Old sessions stay empty.  
Langfuse OTLP ≠ LiveKit Insights. US judge LLM does not add live e2e.

Test Cloud agent: dashboard **Launch Console**, not Desktop `.command` (that is local mic).

## Deployed Amina (aai)

| | |
|---|---|
| ID | `CA_J8AZ7K6yJ5o3` |
| Dispatch | `amina-soniox-v2` |
| Region | `eu-central` (immutable after create) |
| Config | `livekit.eu-central.toml` |
| Worker CMD | `python -m amina.agent_soniox_v2 start` — not `__main__.py` (Fish) |
| LLM until A/B | `openai/gpt-4.1` Azure via Inference. Gemma 4 31B = later A/B only |

## SIP outbound via FreePBX + TG400 (user chose this)

LiveKit Cloud **INVITE →** `ari.activi.io` UDP **5060** (open). Not Telnyx/Twilio unless user names them.

| LiveKit field | Value | Why |
|---|---|---|
| Address | `ari.activi.io` | not `192.0.2.0` (docs placeholder) |
| Transport | **UDP** | PBX has only `0.0.0.0:5060` UDP |
| Username | **`320`** (Hermes, unused) | **never** 300/310 |
| Password | ext 320 secret from **FreePBX GUI** — never chat |
| Numbers | `+387…` of the **TG SIM** | Sipgate `+493075435897/8` is DE, not BA |

### Do not steal 300/310

Live: both registered from `213.91.103.192` (TG400). `max_contacts=1` + `remove_existing=true`.  
300 = tg400 register **and** Guarddograh Stasis. 310 = Guarddograh default CID + Stasis `dograh_cba9558c7e96`.  
Internal dial 300/310 → AI, not GSM.

### GSM path is missing (do not invent)

PBX outbound trunks = Sipgate only. **No +387** in Asterisk. No `tg-ba` route.  
Need: outbound route (387 / 00387 / 06.) **before** Sipgate → `PJSIP/${NUM}@310`.  
TG: IP→Mobile to the chosen GSM port. User must name **port + MSISDN**.

Dograh: leave Stasis 300/310 if inbound GSM stays Guarddograh. Change only if inbound should hit LiveKit dispatch.

## “Fish-Tags” in chat

Often means **git tags** (`v0.2.1-amina`), not Fish Audio emotion tags. Soniox tags (`[warm] [calm]`) are not Fish lexicon / `Ami-na`.
