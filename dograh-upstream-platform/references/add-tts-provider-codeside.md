# Add a NEW TTS provider to self-hosted Dograh (code-side)

Use when a provider is **not** in the shipped BYOK list and the user wants it as
a first-class Dograh TTS option. Fish Audio is the worked example, but the recipe
is generic.

## First: is it even needed?

Shipped TTS providers (from `docs/configurations/voice`): ElevenLabs, OpenAI,
Google, Azure Speech, Deepgram, Cartesia, Smallest AI, MiniMax, Sarvam, Rime,
Inworld, Camb.ai, xAI, LMNT, Dograh TTS, **Speaches** (self-hosted, OpenAI-compat).

- If the target has an **OpenAI-compatible `/v1/audio/speech`** endpoint → no fork
  needed: pick the OpenAI provider, set `base_url`, done.
- **Fish Audio does NOT have this** — its cloud API (`api.fish.audio`) speaks its
  own shape (`/v1/tts`, `reference_id`, `model` header). The OpenAI-compat endpoint
  is only an open GitHub feature request (fishaudio/fish-speech #1272), not shipped.
  So Fish genuinely requires the code-side add below. Only possible on **self-host**.
- The UI "add voice ID manually" affordance only picks a voice **within an already
  supported provider** — it cannot introduce a new provider.

## The 5 touchpoints (all must change, or it ImportErrors / never appears)

| # | File | Change |
|---|------|--------|
| 1 | `api/services/configuration/registry.py` | Add `FISH = "fish"` to `ServiceProviders` enum (else `ServiceProviders.FISH.value` → AttributeError). |
| 2 | `api/services/pipecat/service_factory.py` | Add an `elif` block in `create_tts_service` (before the final `else` that raises HTTPException). |
| 3 | `api/services/configuration/options.py` | Register provider + model options (`s2-pro`, `s1`) so it appears in the dropdown. |
| 4 | Frontend provider list (UI) | Add Fish as a selectable TTS provider + a "Voice = reference_id" field. |
| 5 | `api/requirements.txt` / pipecat extras | Install Fish deps (`ormsgpack`, `websockets`; upstream extra is `pipecat-ai[fish]`). |

## The factory block (matches the house style of every other provider)

```python
elif user_config.tts.provider == ServiceProviders.FISH.value:
    from pipecat.services.fish.tts import FishAudioTTSService
    speed = getattr(user_config.tts, "speed", None) or 1.0
    return FishAudioTTSService(
        api_key=user_config.tts.api_key,
        settings=FishAudioTTSService.Settings(
            voice=user_config.tts.voice,        # <- the clone reference_id
            model=user_config.tts.model or "s2-pro",
            prosody_speed=speed,
        ),
        text_filters=[xml_function_tag_filter],
        skip_aggregator_types=["recording_router", "recording"],
        silence_time_s=1.0,
    )
```

Every TTS block in `create_tts_service` carries these three the same way:
`text_filters=[xml_function_tag_filter]`, `skip_aggregator_types=["recording_router","recording"]`,
`silence_time_s=1.0`. Copy them.

## Load-bearing traps

1. **Pinned pipecat submodule, not `pip install pipecat-ai`.** Repo shows
   `pipecat @ <sha>` as a git submodule. Verify the import path + Settings shape
   **against that checked-out submodule**, not upstream docs — pipecat renamed the
   Fish param: old `reference_id=...` → new `settings=FishAudioTTSService.Settings(voice=...)`
   (migration 1.0). Grep before coding:
   `grep -ri "FishAudio" pipecat/src/pipecat/services/fish/`.
2. **clone `reference_id` travels in the `voice` field.** Dograh has no dedicated
   reference_id field; like ElevenLabs' voice_id, put the Fish model/clone id in
   `tts.voice`. User types it as "Voice" in the UI.
3. **Emotion tags come from the LLM, not TTS config.** For `(excited)` /
   `(whispering)` / `(prijateljski)` to be spoken, the **Agent-node system prompt**
   must instruct the LLM to emit them in the answer text. The `xml_function_tag_filter`
   in each block only strips XML function-call tags — it lets `(parentheses)` through,
   so no conflict.
4. **Deps must land in the image build.** Submodule setups won't get `[fish]` extras
   automatically → `ModuleNotFoundError` at first call unless added to requirements /
   Dockerfile.
5. **Language coverage is a separate risk.** Fish S1/S2 officially lists ~13 langs;
   Bosnian (`bs-BA`) is NOT among them. It may sound fine (BCMS are related + the model
   is multilingual) but there's no guarantee across model-version bumps — re-test
   pronunciation after any Fish model change, and keep Azure Vesna EU as fallback.

## Sequencing

Verify (grep submodule) → registry+factory+options (1–3) → frontend (4) →
deps+rebuild (5) → test call + emotion-tag-in-prompt. Do not code before the grep.
