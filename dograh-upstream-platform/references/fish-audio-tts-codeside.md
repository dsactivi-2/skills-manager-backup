# Fish Audio TTS in Dograh (code-side add) + proper-name pronunciation

Fish Audio is **NOT** in Dograh's shipped TTS provider list (as of the
`configurations/voice` doc: ElevenLabs, OpenAI, Google, Azure Speech, Deepgram,
Cartesia, Smallest AI, MiniMax, Sarvam, Rime, Inworld, Camb.ai, xAI, LMNT,
Dograh + Speaches for self-host). No dropdown slot, and the "point OpenAI-TTS at
Fish" trick does NOT work — Fish's **cloud** API has no OpenAI-compatible
`/v1/audio/speech` endpoint (only an open feature request); it speaks its own
`/v1/tts` + `reference_id` + `model` header format. So Fish only works on a
**self-hosted** Dograh where you patch the source. Pipecat already ships a
`FishAudioTTSService`, so this is wiring, not a new service from scratch.

## Verify FIRST — the pinned-submodule trap (load-bearing)

Dograh vendors a **pinned pipecat fork as a git submodule** (repo shows
`pipecat @ <commit>`), NOT `pip install pipecat-ai`. Never trust the public
pipecat docs for the exact import/Settings shape — verify against the vendored
version before writing code:

```
grep -ri "FishAudio" pipecat/src/pipecat/services/fish/
```

Determine: real import path (`from pipecat.services.fish.tts import
FishAudioTTSService`), and whether the API is new `settings=FishAudioTTSService.Settings(voice=...)`
or the deprecated `reference_id=...` / `model=...` form (pipecat migration 1.0
renamed `model`→`reference_id`, then moved to `Settings(voice=...)`). If the
service is missing from the submodule → stop; the fork must be bumped/patched
first.

## The 5 edit sites (mirror ElevenLabs + MiniMax patterns)

1. `api/services/configuration/registry.py` — add `FISH = "fish"` to
   `ServiceProviders` enum (else `ServiceProviders.FISH.value` → ImportError).
2. `api/services/pipecat/service_factory.py` — new `elif` in
   `create_tts_service` **before the final `else`** (which raises HTTPException).
   The Fish **reference_id (clone model ID) goes in the `voice` field** (exactly
   like ElevenLabs carries its voice_id in `voice`). Default `model="s2-pro"`.
   Keep the standard args every other block has:
   `text_filters=[xml_function_tag_filter]`,
   `skip_aggregator_types=["recording_router", "recording"]`, `silence_time_s=1.0`.
3. `api/services/configuration/options.py` — register Fish + model options
   (`s2-pro`, `s1`) so it shows in the backend dropdown.
4. Frontend TTS provider list — add Fish; "Voice" must be a **free text field**
   (it's a clone reference_id, not a fixed dropdown).
5. `api/requirements.txt` / container build — Fish deps (`ormsgpack`,
   `websockets`). With the submodule setup do NOT rely on
   `pip install "pipecat-ai[fish]"`; ensure the packages land in the image or
   you get `ModuleNotFoundError` at first-call runtime.

Sketch (verify shape against the submodule!):
```python
elif user_config.tts.provider == ServiceProviders.FISH.value:
    from pipecat.services.fish.tts import FishAudioTTSService
    speed = getattr(user_config.tts, "speed", None) or 1.0
    return FishAudioTTSService(
        api_key=user_config.tts.api_key,
        settings=FishAudioTTSService.Settings(
            voice=user_config.tts.voice,          # clone reference_id
            model=user_config.tts.model or "s2-pro",
            prosody_speed=speed,
        ),
        text_filters=[xml_function_tag_filter],
        skip_aggregator_types=["recording_router", "recording"],
        silence_time_s=1.0,
    )
```

## Do NOT enum-lock the language

Fish streams via WebSocket (fits real-time telephony). Bosnian is not on Fish's
official language list — it works empirically but must not be forced into a
fixed Language enum (like Rime's `en/de/fr/es/hi` map), which would silently
coerce `bs` → English → wrong pronunciation. Two safe options: omit language
(Fish detects it from the text's `č ć š ž đ`), or pass it through raw the way
Camb does (`tts._settings.language = language`, bypassing enum conversion).

## Emotion / expression tags

Come from the **LLM output text**, not the TTS config. S1 = `(parentheses)` fixed
tag set; S2 = `[brackets]` free-form, placed anywhere. Instruct the agent-node
prompt to emit them. `xml_function_tag_filter` only strips XML function tags —
round/square brackets pass through, so no conflict.

## Proper-name pronunciation = G2P error on OOV words (the real problem)

Symptom: a name like `Đenita` is mispronounced; writing it phonetically
(`Dženita`, or `dže-ni-te`) fixes it. Terminology:
- **Grapheme-to-Phoneme (G2P)** = the text→sound step where it goes wrong.
- **Out-of-Vocabulary (OOV)** = why it hits proper names/brands/foreign words.
- **Phonetic respelling** = the manual fix (rewrite the word as it should sound).
- **Pronunciation dictionary / lexicon (SSML `<phoneme>` / IPA)** = the scalable
  fix — but **Fish Audio has NONE of these.** Fish's own guidance is literally
  "rewrite hard terms phonetically", so respelling is Fish's *official* method,
  not a hack. For `Đ`, the BiH digraph `Dž` (→ `Dženita`) usually lands better
  than hyphen-syllables; test per word.

### In an agent (LLM writes the text live) — automate it
Don't respell by hand and don't rely on the LLM prompt (it forgets). Add a fixed
replacement table applied as a **`text_filter`** just before text hits Fish —
the same `text_filters=[...]` slot in the Fish `elif` block. Append a small
custom filter with entries like `Đenita → Dženita`, `Baščaršija → Bašcharšija`.
Deterministic, consistent, LLM-agnostic. (Prompt-side instruction is the weaker
fallback for a few non-critical words.)

## Fast verification (no telephony)
Use Dograh **Web Call** (browser, no Twilio): set provider=fish, voice=reference_id,
model=s2-pro; put a bs test sentence with all tricky letters in the Start-Call
greeting (`Dobar dan! Ja sam vaš asistent. Hvala što ste se javili — kako vam
mogu pomoći?`), start the call, listen. Backend log should show
`Creating TTS service: provider=fish, model=...`. Isolate voice-vs-integration by
testing the clone first on fish.audio/tts or via `POST /v1/tts` before wiring.
