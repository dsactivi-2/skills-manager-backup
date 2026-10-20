# Foundry TTS / audio catalog + voice clone (verified 2026-07-30)

Tooling: **no** standalone `foundry` CLI on this Mac — use Azure CLI model catalog.

```bash
az cognitiveservices model list --location swedencentral -o json
az cognitiveservices model list --location westeurope -o json
az cognitiveservices model list --location germanywestcentral -o json
```

## Deployable audio-related models (SE/WE/DE snapshot)

| Model | Role | Voice clone from sample? | SKUs seen | Regions seen |
|-------|------|--------------------------|----------|--------------|
| `tts` | OpenAI TTS (preset voices) | **No** | Standard | SE |
| `tts-hd` | OpenAI TTS HD | **No** | Standard | SE |
| `gpt-audio` / `gpt-audio-mini` / `gpt-audio-1.5` | Multimodal audio chat | **No** | GlobalStandard | SE |
| `gpt-realtime*` (+ mini / 1.5 / 2 / 2.1) | Realtime speech-to-speech | **No** (builtin voices) | mostly Global; **`gpt-realtime-1.5` has DataZoneStandard** | SE (`area: EUR` on some caps) |
| `whisper` / `gpt-4o-*-transcribe*` | STT only | — | mixed; some DataZone on transcribe | SE; whisper also WE/DE |
| `gpt-4o-mini-tts` | — | — | **Not in catalog** SE/WE/DE this check | — |
| Any name with `clone` / personal voice | — | — | **0 hits** in OpenAI/AIServices catalog | — |

SKUs live under `model.skus[].name` (top-level `skus` often null).

## Where voice cloning actually lives (Microsoft)

| Product | Surface | Foundry `deployment create`? | Notes |
|---------|---------|------------------------------|-------|
| Azure Speech **Personal Voice** | Speech resource + Voice Gallery/API | **No** | Faster clone; consent; Dragon/HD Omni; gated form |
| Azure Speech **Custom Neural Voice** | Speech + gated professional training | **No** | Stronger quality; approval; EU Speech region possible |
| Foundry `tts` / `tts-hd` | AIServices/OpenAI deploy | Yes | Preset voices only |
| Foundry `gpt-realtime*` | AIServices deploy | Yes | Builtin voices; not sample-clone |

Activi Speech: `vesna` @ germanywestcentral, `mujo` @ westeurope. AIServices warm: `dsselmanovic-6165-resource` (SE), `activids` (WE) — no TTS deployments last check.

## SSML (no redeploy)

- Request-body markup (break/rate/pitch) — not a model deploy.
- Dograh AzureTTS maps config `speed` → SSML `rate`.
- Billing: text + most control tags billable; bare `<speak>`/`<voice>` excluded. Lean SSML ~+10–30% chars if rich.
- BS Vesna/Goran: **no StyleList**.

## BCS neural (GWC live 2026-07-30)

| ShortName | Locale | BiH prod? |
|-----------|--------|-----------|
| `bs-BA-VesnaNeural` / `bs-BA-GoranNeural` | bs-BA | **Yes — default** |
| `hr-HR-GabrijelaNeural` / `hr-HR-SreckoNeural` | hr-HR | **No** as BS substitute |
| sr Sophie/Nicholas | sr-* | Serbia |

`xml:lang=bs-BA` on Gabrijela does not create a Bosnian model.

### EN Multilingual → BS + monotony (same day)

- **29** EN `*MultilingualNeural` on `vesna` list with `bs-BA` in SecondaryLocaleList (Ava/Andrew/Emma/Turbo…).
- Steer with SSML `<lang xml:lang="bs-BA">` (not OpenAI-style instructions). Always set lang — autodetect flaky.
- Timbre vs locale: Multilingual/Personal Voice **decouple**; Vesna/Goran **couple** mono-locale + **empty StyleList** → monotony is structural.
- Personal Voice: docs target locales include **`bs-BA`**; `GET …/customvoice/personalvoices` on `vesna` → 200 empty (API up, no profiles). Gated intake + consent.
- DragonHD/Omni short names: **0** on GWC list that day — re-list before recommending HD.
- Full recipes/samples: `references/azure-speech-bs-multilingual-clone.md`

## Answer shape when user wants "Foundry TTS + clone"

1. Live catalog filter — TTS/audio table.
2. Explicit: **Foundry catalog = no clone.**
3. Clone = Speech Personal/Custom Neural on EU Speech (`bs-BA` is a Personal Voice target locale).
4. Optional: `tts`/`tts-hd` only if preset voices OK.
5. BS/DE EU-prod: Speech GWC Vesna/Goran + SSML; not Camb, not Gabrijela-as-BS.
6. Vesna monotony: no StyleList → prosody/text → Multilingual+`lang bs-BA` A/B → Personal Voice.
7. EN voice speaking BS: MultilingualNeural + SSML `lang`; quality ≠ native Vesna.

## Related
- BS Multilingual/clone deep dive: `references/azure-speech-bs-multilingual-clone.md`
- BS/DE + Camb: `balkan-voice-agent-stack` / `references/camb-tts-dograh.md`
- Multistack: `foundry-multistack-voice-agent` (user-owned `--activi`; adopt if curator should own)
- SSML prompts: `tts-ssml-prompt-hardening` (user-owned)
