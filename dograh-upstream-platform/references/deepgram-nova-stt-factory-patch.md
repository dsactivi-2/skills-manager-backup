# Deepgram Nova STT factory (dograh-devshift) — verified 2026-08

Workdir: `/Users/activi/Projects/dograh-devshift` (not `~/Code/Projects`).

## Live Nova block (US + EU share one dict)
`api/services/pipecat/service_factory.py` — after Flux, comment `# Other models than flux`:

```
language = getattr(user_config.stt, "language", None) or "multi"
settings_kwargs = {
    "language": language,
    "profanity_filter": False,
    "endpointing": 100,
    "model": user_config.stt.model,
    "keyterm": keyterms or [],
}
if is_deepgram_eu:
    settings_kwargs["extra"] = {"tag": list(DEEPGRAM_EU_USAGE_TAGS)}
    return DeepgramSTTService(..., base_url=DEEPGRAM_EU_BASE_URL, settings=DeepgramSTTSettings(**settings_kwargs), ...)
return DeepgramSTTService(..., settings=DeepgramSTTSettings(**settings_kwargs), ...)
```

There is **no** Org-UI / `registry.py` field for `endpointing`, `punctuate`, `smart_format`, `replace`, or `diarize`. Change = factory code.

## Endpointing (not "endpointingPause")
Deepgram `endpointing` = ms of silence until `speech_final=true`.
| Source | Value |
|---|---|
| Deepgram default | 10 ms |
| Deepgram docs example | **300 ms** |
| This factory Nova (US+EU) | **100** (already live; Cloud traces match) |
| dograhV2 `DEEPGRAM_3` | 400 |
| Flux | `eot_timeout_ms=3000`, not this knob |

Protocol: if callers are cut off, raise 100 → 300, then 400, then 500. Do not start another “try 100” experiment. Do not raise to 1000 (use `utterance_end_ms` ≥1000 for noisy rooms). TTS `silence_time_s` is unrelated.

https://developers.deepgram.com/docs/endpointing
https://developers.deepgram.com/docs/understand-endpointing-interim-results

## Diarize does not protect the agent
Diarize **labels** words `speaker: 0/1`. It does **not** drop the second voice.
Pipecat `DeepgramSTTService._on_message` uses only `alternatives[0].transcript` — no speaker filter (`pipecat/.../deepgram/stt.py`).
Telephony STT is usually **mono customer** (ulaw). Background / someone shouting into the room is the same channel. Flux: no diarize.
https://developers.deepgram.com/docs/diarization
https://developers.deepgram.com/docs/multichannel-vs-diarization

## String-patch pitfalls (v1 and v2 reviewed against this file)
1. **Match this fork’s `settings_kwargs` dict**, not HQ-style `DeepgramSTTSettings(language=..., endpointing=..., keyterm=...)`. That constructor shape is absent here — v1 printed “patched” and only flipped endpointing.
2. **Never insert a helper at `def create_stt_service(`.** The line above is `@_report_service_factory_failures(ErrorSource.STT, config_section="stt")`. Inserting there **steals the decorator** onto the helper; all STT providers lose failure annotation. Insert before the decorator line (or after `create_stt_service`’s body).
3. Flux dict has `eot_*` keys — do not treat a `model`+`keyterm`-only snippet as a match.
4. `VOCAB.write_text` overwrites weekly lists — abort if `bosnian_stt_vocab.py` exists; do not re-run.
5. Empty `replace` should be omitted (v2 does this). `punctuate` / `smart_format` / `replace` are valid `DeepgramSTTSettings` fields in the vendored Pipecat.

Success check: decorator still sits **directly** on `create_stt_service`; Nova dict (or helper call) has `endpointing` 300 + `punctuate`/`smart_format`; `if is_deepgram_eu:` tag block unchanged; Flux unchanged.
