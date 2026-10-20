# Dograh Azure TTS + SSML runtime (2026-07-30)

## Verdict
Stock Dograh/Pipecat **does not** pass LLM classic SSML tags through to Azure. Service-built SSML only; agent text is XML-escaped.

## Code
| Component | Location | Notes |
|-----------|----------|--------|
| Escape + construct | `dograh-hq/pipecat` `src/pipecat/services/azure/tts.py` | `_escape_text`, `_construct_ssml` |
| Pin used by dograhV2 | submodule sha `555a9b2` | public fork `dsactivi-2/dograhV2` |
| Factory | `api/services/pipecat/service_factory.py` | `speed`→`rate` only |
| Schema | `AzureSpeechTTSConfiguration` | voice, language, region, speed |
| Live voiceeu | `dograhai/dograh-api` image | `/opt/venv/.../pipecat/services/azure/tts.py` |

## Works now
- Global rate via Dograh TTS `speed`
- Sentence rhythm via punctuation / short turns / pacing prompts
- Pre-recorded greetings

## Needs patch for full Emotion-SSML
- Skip-escape / passthrough when body is trusted SSML, **or**
- Pre-TTS SSML builder processor, **or**
- Expose pitch/volume/style in registry + factory (Pipecat already supports)

## Verify
1. Read `_escape_text` in image or submodule.
2. Testcall with literal `<break time="2000ms"/>` — no long silence = confirmed.
3. Do not use Portal character metrics as passthrough proof.

## Billing
Azure Neural per character; lean control tags; no redeploy cost for SSML.

## Related
- `balkan-voice-agent-stack` (Vesna/Goran, Camb residency)
- `foundry-model-ops` / `references/foundry-tts-voice-clone.md`
