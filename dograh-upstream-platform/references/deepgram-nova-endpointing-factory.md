# Deepgram Nova endpointing + factory string-patches (verified 2026-08)

## What `endpointing` is

Deepgram query param **`endpointing`** = milliseconds of **silence** before `speech_final=true`. Not a Dograh UI field. Not `endpointingPause`. Not Flux `eot_timeout_ms`. Not TTS `silence_time_s`.

Sources: https://developers.deepgram.com/docs/endpointing · https://developers.deepgram.com/docs/understand-endpointing-interim-results

| Source | Value |
|---|---|
| Deepgram default | 10 ms |
| Deepgram doc example | **300 ms** |
| dograh-hq Nova (non-Flux) | **100** hardcoded `service_factory.py` |
| dograhV2 `DEEPGRAM` / `_2` | 100 |
| dograhV2 `DEEPGRAM_3` | **400** |
| dograh-devshift Nova US+EU | shared dict `"endpointing": 100` |
| Live Aquaphor Cloud traces | `settings.endpointing=100` |
| `utterance_end_ms` | ≥1000, needs `interim_results` — different lever |
| Flux | `eot_timeout_ms=3000` — do not mix |

Org `PUT …/configurations/user` has **no** endpointing field. Change = factory + image.

## Test protocol (DE/BS telesales)

100 is already Ist on HQ/default Nova — do not “introduce” it.

- Hear cut-off (address, “also…”, numbers) → **300** (Deepgram example).
- Still cut-off → 400 (V2 DG3) then 500 max.
- Agent too slow and no cut-off → leave 100.
- Do not jump to 1000 as endpointing (dead air). Noisy rooms: `utterance_end_ms`, not lower endpointing.

## Factory string-replace pitfall (dograh-devshift)

HQ-shaped patches look for:

```python
settings=DeepgramSTTSettings(
    language=language,
    endpointing=…,
    keyterm=keyterms or [],
)
```

or a Flux-sized dict of only `model` + `keyterm`.

**dograh-devshift** Nova US+EU is one dict + `DeepgramSTTSettings(**settings_kwargs)`:

```python
settings_kwargs = {
    "language": language,
    "profanity_filter": False,
    "endpointing": 100,
    "model": user_config.stt.model,
    "keyterm": keyterms or [],
}
```

A script that only `if old_kw in text` / `if old_settings in text` will:
- still print “patched”
- maybe flip `"endpointing": 100` → `300`
- **never** wire `punctuate` / `smart_format` / `replace` / vocab helper
- leave `_deepgram_nova_vocab` as dead code

Always `git diff` the **Nova dict**. If `punctuate`/`replace`/`STT_KEYTERMS` are not in that dict, the patch failed.

Re-running a script that `write_text`s `bosnian_stt_vocab.py` **wipes** weekly fills. Run once.

Flux / `vad_events` / `pipecat/` submodule: leave untouched unless the live block is Flux.

Correct Nova dict shape for this fork:

```python
nova_keyterm, nova_replace = _deepgram_nova_vocab(keyterms)
settings_kwargs = {
    "language": language,
    "profanity_filter": False,
    "endpointing": 300,
    "model": user_config.stt.model,
    "keyterm": nova_keyterm,
    "punctuate": True,
    "smart_format": True,
    "replace": nova_replace,
}
```

Pipecat `DeepgramSTTSettings` accepts `replace` / `punctuate` / `smart_format` (`pipecat/src/pipecat/services/deepgram/stt.py`). Empty `replace=[]` is fine if wired; unused helper is not.

Local fork path seen 2026-08: `/Users/activi/Projects/dograh-devshift` (not `Code/Projects`).
