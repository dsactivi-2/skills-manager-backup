# Dograh Deepgram Nova factory wiring (devshift)

Verified 2026-08 against `/Users/activi/Projects/dograh-devshift`.

## What the factory actually sends (Nova US + EU)

One shared `settings_kwargs` for non-Flux Nova. EU only adds `extra.tag = ["dograh", "eu"]` and `base_url=api.eu.deepgram.com`.

Pipecat `DeepgramSTTService` starts with store-mode defaults, then `apply_update` copies **only given** fields. Factory-omitted keys keep Pipecat defaults:

| Flag | Effective if factory omits it |
|------|-------------------------------|
| punctuate | **on** (`True`) |
| smart_format | **off** (`False`) |
| diarize | off |
| endpointing | Pipecat `None` unless factory sets it (devshift Nova sets `100`) |

Do not claim “punctuate is off because the factory does not list it.”

Registry/UI expose only provider, model, language, api_key. There is no Org-UI knob for endpointing, punctuate, diarize, or replace.

## Endpointing

Deepgram `endpointing` = milliseconds of silence until `speech_final`. Official example is 300 ms; API default is 10 ms. dograh-hq and unpatched devshift Nova hardcode **100**. Flux uses `eot_timeout_ms=3000`, not this flag.

Protocol if callers are cut off: raise 100 → 300 → 400/500. Do not raise to 1000. `utterance_end_ms` is a different lever (≥1000, needs interim results).

v3 applied on this fork sets Nova helper `endpointing=300`, `punctuate=True`, `smart_format=True`. Empty vocab: `api/services/pipecat/bosnian_stt_vocab.py`. Flux and EU tags stay untouched.

## Diarize does not mute the second person

Deepgram diarize only labels words `speaker: 0/1`. Pipecat pushes `alternatives[0].transcript` only — no speaker filter. Telephony is mono; background speech still lands in the LLM text. Do not enable diarize expecting the agent to ignore a second voice.

## String-patch pitfalls (factory)

1. Match the **live** Nova dict (`settings_kwargs = { language, profanity_filter, endpointing, model, keyterm }`). A Flux-shaped `{model, keyterm}` or a `DeepgramSTTSettings(language=..., endpointing=...)` constructor will not match this fork.
2. Never insert a helper immediately before `def create_stt_service(`. That steals `@_report_service_factory_failures(ErrorSource.STT, ...)`. Insert **before the decorator+def pair**.
3. After insert, AST-check: decorator list on `create_stt_service` stays; helper has none.
4. Do not overwrite `bosnian_stt_vocab.py` on a second run if lists may be filled.
5. Factory + empty vocab is enough for Nova flags. Do **not** patch the `pipecat/` submodule or registry/UI for punctuate/smart_format/endpointing.

## APPLY vs health wrapper

User one-shot v3 is `python3 patch_deepgram_stt.py` with **no** subcommands. A Hermes `status`/`apply`/`repair` wrapper in the same path is a different file. Before any APPLY: read the first 20 lines. If `argparse` is present, it is not v3. Replace with the user’s script or ask; do not run `… apply`.

After a successful v3: `git diff` Factory + vocab only. Do not push. Do not run twice. Live effect needs a backend restart. Fill keyterms later from real transcripts, not by re-running the patcher.
