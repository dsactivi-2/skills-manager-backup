# Locked stack (nicht ändern)

| Schicht | Wert | Wo |
|---|---|---|
| STT | Deepgram `nova-3`, `language=bs`, EU `https://api.eu.deepgram.com` | `build_session` |
| LLM | LiveKit Inference `openai/gpt-4.1` `provider=azure` | `build_session` |
| TTS | Soniox `tts-rt-v2`, speed **0.9**, `language=bs` | `build_session` |
| TTS-WS | `wss://tts-rt.eu.soniox.com/tts-websocket` | Env / Code |
| Stimme | Default Nina; Mujo = Daniel | `voice=` Argument |
| Turn | LiveKit turn detector | `build_session` |
| Deploy | eu-central, neuer Agent = neuer `lk agent create` | nicht Amina-CMD |

Funktion: `amina.agent_soniox.build_session`.  
Maya + tts-rt-v2 = 400. Fish-Hyphen auf Soniox = Stottern.
