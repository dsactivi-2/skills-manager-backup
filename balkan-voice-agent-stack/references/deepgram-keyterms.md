# Deepgram Keyterm Prompting (Nova-3)

## Why

Keyterms boost recognition of product names, brands, and jargon so the transcript matches CRM/script spelling. Critical for bs telesales tool-calls.

## Nova-3 vs Keywords (live API 2026-07-30)

| | Nova-3 / Flux | Nova-2 and older |
|--|---------------|------------------|
| Param | `keyterm` | `keywords` |
| Weights | none | `term:2` intensifier |
| Multi | repeat `keyterm=` | repeat `keywords=` |

Live: `keywords=Aquaphor:2` + nova-3 → **HTTP 400** ("use keyterm").  
`keyterm=Aquaphor&keyterm=Firmira` + `language=bs` → **HTTP 200** (US and EU).

## BS telesales defaults

```text
model=nova-3-general
language=bs
keyterm=Aquaphor
keyterm=Firmira
keyterm=Amina
keyterm=Smile
punctuate=true
smart_format=true
numerals=true
# streaming only (batch rejects endpointing):
endpointing=200
interim_results=true
```

Do not use `language=multi` as BS primary. `detect_language` does not list `bs` — pin `language=bs`. Flux has no `bs`.

## Examples

```bash
HOST=https://api.eu.deepgram.com   # or api.deepgram.com
curl -X POST \
  "${HOST}/v1/listen?model=nova-3-general&language=bs&keyterm=Aquaphor&keyterm=Firmira&keyterm=Amina&punctuate=true&smart_format=true" \
  -H "Authorization: Token $DEEPGRAM_API_KEY" \
  -H "Content-Type: audio/wav" \
  --data-binary @call.wav
```

Streaming: same query string on websocket listen URL. Batch + `endpointing` → 400.

## CLI / Dograh

- `dg listen`: only `-m` / `-l` — **no keyterm flag** → curl or factory.
- Dograh `create_stt_service(..., keyterms=[...])` maps to Deepgram `keyterm`. Org UI often lacks keyterm field.
- EU still needs factory `base_url` — see `deepgram-eu-endpoint.md`.

## Limits / pitfalls

- ~500 tokens total across keyterms per request.
- No commas/semicolons as multi-term separators; no `:intensifier` on keyterm.
- Pair with `language=bs` for Bosnian monostreams.
- Keyterm ≠ TTS SSML; STT has no break/emotion tags.
