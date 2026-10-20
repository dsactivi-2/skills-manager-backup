# Soniox EU endpoints + voices (2026-07-30)

## Regional API
| Region | REST | STT RT | TTS RT |
|--------|------|--------|--------|
| US | api.soniox.com | stt-rt.soniox.com | tts-rt.soniox.com |
| EU | api.eu.soniox.com | stt-rt.eu.soniox.com | tts-rt.eu.soniox.com |
| JP | api.jp.soniox.com | stt-rt.jp.soniox.com | tts-rt.jp.soniox.com |

- Region set **when creating the project** in Console
- Use that project’s API key + matching domain
- Content (audio/transcripts) stays in region; billing/account metadata may leave
- Docs: https://soniox.com/docs/data-residency · marketing: https://soniox.com/europe

## Language codes (BKS)
| Language | Code | TTS script |
|----------|------|------------|
| Bosnian | bs | Latin only |
| Croatian | hr | Latin |
| Serbian | sr | Latin only (not Cyrillic) |

## Built-in TTS voices (name → gender → notes)
From https://soniox.com/docs/tts/concepts/voices — every voice can speak `bs`.

| Voice | G | Telesales BS note |
|-------|---|-------------------|
| Maya | F | clear, warm, measured — primary F shortlist |
| Mina | F | soft, warm, sincere |
| Grace | F | gentle — support more than hard close |
| Emma | F | relaxed contemporary |
| Claire | F | polished bright |
| Nina | F | youthful expressive — demos; not default sales |
| Adrian | M | deep professional — primary M shortlist |
| Daniel | M | polished mature |
| Jack | M | friendly upbeat discovery |
| Owen | M | dry composed |
| Noah | M | youthful lively |
| Kenji | M | calm precise |
| Oliver/Arthur/Isla/Victoria | — | British accent pack |
| Rafael/Mateo/Lucia/Sofia | — | Spanish accent pack |
| Cooper/Mason/Ruby/Elise | — | Australian pack |
| Arjun/Rohan/Priya/Meera | — | Indian pack |

## Clone lifecycle
1. Upload short clear sample (Console or Voices API)
2. Poll until model status `ready` (seconds typical)
3. TTS: `voice="<uuid>"` + `language="bs"`
4. New TTS model later → recompute voice; `failed` is terminal → new voice from fixed clip
5. Project-scoped limits → delete unused / raise limit in Console

Python sketch:
```python
from soniox import SonioxClient
client = SonioxClient()  # SONIOX_API_KEY; point base URL at EU if needed
v = client.voices.create("reference.wav", name="bs-telesales-f")
# poll client.voices.get(v.id) until ready for tts-rt-v1
client.tts.generate_to_file("out.wav", text="…", model="tts-rt-v1",
                            language="bs", voice=v.id, audio_format="wav")
```

## Org repos (no voice assets)
Pinned usefulness: `soniox_examples`, `soniox-compare`, `soniox-python`, `soniox-js`, Twilio STT example, Pipecat voicebot demo.
