# Console vs SIP vs Inference proof (2026-08-24)

## LiveKit Inference EU — how to prove it

Dashboard **Inference region restriction = Enabled** is only a **catalog filter** (models offered in the project data region). It does **not** name the region and does not by itself prove Azure GPT-4.1 runs in the EU.

**Proof that worked:** LiveKit test/session message `extra.livekit.inference_deployment` = `azure_francecentral_datazone` for `openai/gpt-4.1` + `provider=azure`. That is France Central Data Zone.

Sub-processor page listing Microsoft as United States is too coarse — do not contradict live `inference_deployment`.

Plugin Deepgram EU: `base_url="https://api.eu.deepgram.com/v1/listen"` (not just the host).

## Console ≠ phone

`python -m amina.agent console`: **local** mic/speakers, **no** LiveKit room. Keys still needed for Inference. STT/LLM/TTS APIs are remote.

Phone/SIP: default PCMU/PCMA **8 kHz**. G.722 HD is 16 kHz. **Do not** set Fish TTS to 8 kHz. Keep ~24 kHz; LiveKit resamples on the SIP hop. Console sounds better than PSTN.

Realism ladder: console → `dev` + Cloud browser → SIP.

## Fish scripts

Outside a job worker, wrap Fish plugin calls with `async with livekit.agents.utils.http_context.open():`.

## Snapshot

Before breaking Amina changes: git commit + tag in `/Users/activi/Code/Projects/LiveKit`. First working console: tag `v0.1-amina` (`85c1cca`).
