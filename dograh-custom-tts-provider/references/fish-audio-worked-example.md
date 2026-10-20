# Fish Audio → Dograh: copy-paste worked example

Concrete code blocks from a real integration pass (2026-08). Mirror the
ElevenLabs / MiniMax / LMNT branches. **Verify the Pipecat submodule import
first** (`grep -ri "FishAudio" pipecat/src/pipecat/services/fish/`) — these
blocks assume the current `FishAudioTTSService.Settings(voice=...)` API, which
Pipecat renamed from the deprecated `reference_id=` / `model=` kwargs.

## 1. registry.py — enum + provider config + config class

```python
class ServiceProviders(str, Enum):
    # ... existing ...
    LMNT = "lmnt"
    FISH_AUDIO = "fish_audio"   # new

FISH_AUDIO_PROVIDER_MODEL_CONFIG = provider_model_config(
    "Fish Audio",
    description=(
        "Fish Audio streaming TTS with voice cloning and expressive tags "
        "(e.g. [excited], [laughing])."
    ),
    provider_docs_url="https://docs.fish.audio/",
)

FISH_AUDIO_TTS_MODELS = ["s2-pro", "s2.1-pro", "s1"]

@register_tts
class FishAudioTTSConfiguration(BaseTTSConfiguration):
    model_config = FISH_AUDIO_PROVIDER_MODEL_CONFIG
    provider: Literal[ServiceProviders.FISH_AUDIO] = ServiceProviders.FISH_AUDIO
    model: str = Field(
        default="s2-pro",
        description="Fish Audio TTS model.",
        json_schema_extra={"examples": FISH_AUDIO_TTS_MODELS, "allow_custom_input": True},
    )
    voice: str = Field(
        description="Fish Audio voice / reference_id (clone model ID).",
        json_schema_extra={"allow_custom_input": True},
    )
    speed: float = Field(default=1.0, ge=0.5, le=2.0,
                         description="Speech speed multiplier (prosody).")
    latency: Literal["normal", "balanced"] = Field(
        default="balanced",
        description="balanced (faster TTFA) or normal (higher quality).",
    )
    language: str | None = Field(
        default=None,
        description="Optional language hint (e.g. en, de, bs).",
        json_schema_extra={"allow_custom_input": True},
    )
```

Then add `FishAudioTTSConfiguration` to the `TTSConfig` discriminated `Union`
AND add the provider to `BaseServiceConfiguration.provider: Literal[...]`. Miss
either → Pydantic validation error on the config POST.

## 2. service_factory.py — the create_tts_service branch

Insert before the final `else: raise HTTPException(...)`, e.g. after LMNT:

```python
elif user_config.tts.provider == ServiceProviders.FISH_AUDIO.value:
    from pipecat.services.fish.tts import FishAudioTTSService
    voice = getattr(user_config.tts, "voice", None)
    if not voice:
        raise HTTPException(
            status_code=400,
            detail="Fish Audio TTS requires a voice (reference_id).",
        )
    model = getattr(user_config.tts, "model", None) or "s2-pro"
    speed = getattr(user_config.tts, "speed", None) or 1.0
    latency = getattr(user_config.tts, "latency", None) or "balanced"
    language_code = getattr(user_config.tts, "language", None)

    settings_kwargs: dict = {
        "model": model,
        "voice": voice,               # the clone reference_id
        "latency": latency,
        "prosody_speed": speed,
    }
    if language_code:
        try:
            settings_kwargs["language"] = Language(language_code)
        except ValueError:
            settings_kwargs["language"] = language_code  # bypass enum for bs etc.

    return FishAudioTTSService(
        api_key=user_config.tts.api_key,
        output_format="pcm",
        sample_rate=audio_config.transport_out_sample_rate,
        settings=FishAudioTTSService.Settings(**settings_kwargs),
        text_filters=[xml_function_tag_filter],
        skip_aggregator_types=["recording_router", "recording"],
        silence_time_s=1.0,
    )
```

## 3. Example agent TTS config (after the code is in)

```json
{
  "tts": {
    "provider": "fish_audio",
    "api_key": "YOUR_FISH_API_KEY",
    "model": "s2-pro",
    "voice": "d9b1befa09a34947b8c334268767abb6",
    "speed": 1.0,
    "latency": "balanced"
  }
}
```

## Fish SDK for standalone testing (outside Dograh)

`pip install "fish-audio-sdk[utils]"` (>=1.0.0 = new `fishaudio` package; the
old `fish_audio_sdk` name still imports but is frozen). Quick TTS + save:

```python
from fishaudio import FishAudio
from fishaudio.types import TTSConfig, Prosody
from fishaudio.utils import save  # play() also available

client = FishAudio(api_key=...)            # or FISH_API_KEY env var
cfg = TTSConfig(reference_id="<clone-id>", prosody=Prosody(speed=1.0),
                format="wav", latency="balanced")
audio = client.tts.convert(text="...", config=cfg)
save(audio, "out.wav")
client.account.get_credits()               # confirms key validity
```

Use this to generate the audio side of the round-trip pronunciation optimizer
(see `tts-pronunciation-correction`). Prefer `format="wav"` (not mp3) when the
audio is fed straight into an STT evaluator.
