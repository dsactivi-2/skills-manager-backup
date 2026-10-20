# Guard: Fish speech, Deepgram host, Langfuse project

## Langfuse
Guard OTel project is `cmt0fi14g00fsad0i32qc7k5u` (pk prefix `pk-lf-4302bc`), Org 1 `LANGFUSE_CREDENTIALS` on the VPS. Not DograhEU, not LocalM5. STT observations have no host/url. `GET api.deepgram.com/v1/projects` in API logs is key-check only (always US).

## Fish
`XMLFunctionTagFilter` does not strip `[calm]`. Greeting and LLM speech must be plain text. `save_workflow` = draft; user publishes. `create_workflow` publishes v1.

## Deepgram
Org UI = key + model + language, no endpoint. Overlay `deepgram_3` empty `DEEPGRAM_BASE_URL` → EU via `normalize_host`. Stock Pipecat empty → US. Pin with `DEEPGRAM_BASE_URL=api.eu.deepgram.com`.

## Infactory
Not a Guard provider. Do not list it as missing. Inworld is unused when TTS is `fish_audio`.
