# FreePBX + TG400 + LiveKit outbound (2026-08-24)

Do not invent SIP. Host is **`ari.activi.io`** (not `ati.asteriks.io`). Extensions **only in FreePBX GUI**.

## LiveKit trunk fields

| Field | Value |
|---|---|
| Address | `ari.activi.io` — never `192.0.2.0` |
| Transport | **UDP** (PBX listen `0.0.0.0:5060` only) |
| SRTP | off |
| Username | new **330** `livekit-amina` (or interim **320** Hermes) |
| Password | that ext **Kennwort** (GUI auto-fills). Not SSH/root/admin |
| Numbers | `+38767104865` (TG SIM on ext **300**, not a FreePBX DID) |

CLI trunk already exists: `ST_oKoQmwh9o75X` `freepbx-tg400-ba` (320). Do not Create a second UI trunk.

## Never 300 / 310 as LiveKit auth

TG registered both from `213.91.103.192`. `max_contacts=1`. Guarddograh: 310 = default caller, 300 = `hermes-ext-300`, both WF #2, Stasis `dograh_cba9558c7e96`. Leave ARI config 2.

## GSM dialplan (in place)

`[from-internal-custom]` after Stasis hops: `_+387.` `_00387.` `_067.` → `Dial(PJSIP/${EXTEN}@300)`. CID `+38767104865`. Internal 300 still Guarddograh.

## New ext 330 GUI

First menu item: **Neue SIP [chan_pjsip]**. Then user says „330 ist an“. Pull secret locally; replace trunk; delete `ST_oKoQmwh9o75X`.

## Observability vs token server

Settings → **Observability** (not Development token server). CLI cannot flip it. Langfuse OTLP ≠ e2e. Keep GPT-4.1 until A/B; Gemma is LiveKit latency default only.

## Access

`lk` = project `aai` / agent `CA_J8AZ7K6yJ5o3` `amina-soniox-v2` `eu-central`. MCP `livekit-docs` = docs only. GraphQL `freepbx-api.env` token 200 — still no GUI-ext create.
