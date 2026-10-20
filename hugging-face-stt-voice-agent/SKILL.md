---
name: hugging-face-stt-voice-agent
description: "Choose and validate Hugging Face STT models and endpoint wiring for voice agents, including CPU/T4 tradeoffs, endpoint-vs-router URL shape, and Dograh configuration traps."
trigger: "Use when selecting a German STT model for a voice agent or debugging Hugging Face STT endpoint/router requests."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ef005-7771-72c1-a2d7-780d02741018
contributors:
  - activi
version: 4
created_by_agent: codex
created_at: 2026-06-22T16:15:04.560Z
updated_at: 2026-06-22T16:34:30.478Z
---

# Hugging Face STT for voice agents

## When to use
Use when you need a German speech-to-text model for a voice agent, especially when the choice depends on hardware, latency, or whether you are calling a Hugging Face Inference Endpoint, Hugging Face Inference Providers, or a tool like Dograh that exposes only a base URL field.

## Workflow

1. Pick the model based on the runtime:
- CPU / low-latency voice agent: `pbechhaus/whisper-tiny-german-ct2`
- CPU / better accuracy fallback: `mkenfenheuer/whisper-small-cv11-german-ct2`
- T4 GPU / best balance: `primeline/whisper-large-v3-turbo-german`
- T4 GPU / maximum quality: `primeline/whisper-large-v3-german`

2. For voice agents, prefer the fastest model that is still accurate enough for turn-taking. Voice-only systems are latency-sensitive; do not default to a larger model just because it is more accurate.

3. For CPU-only voice agents, start with `whisper-tiny-german-ct2`. Move to `whisper-small-cv11-german-ct2` only if transcript quality is clearly insufficient.

4. For T4 GPU voice agents, use `whisper-large-v3-turbo-german` as the default. Use `whisper-large-v3-german` only when quality matters more than latency.

5. If you are calling a Hugging Face **Inference Endpoint**, use the exact endpoint URL and route from the dashboard or generated test snippet.
- Some endpoints require the full route after the host.
- For audio ASR endpoints, send binary audio, not base64 in JSON.
- Use the exact content type the endpoint expects, commonly `audio/x-flac` for FLAC input.

6. Minimal endpoint test:
```python
import os
import requests

url = "https://<your-endpoint>.<region>.aws.endpoints.huggingface.cloud/<route>"
headers = {
    "Authorization": f"Bearer {os.environ['HF_TOKEN']}",
    "Content-Type": "audio/x-flac",
    "Accept": "application/json",
}

with open("sample1.flac", "rb") as f:
    r = requests.post(url, headers=headers, data=f.read(), timeout=60)

print(r.status_code)
print(r.text)
```

7. If you are using Hugging Face **Inference Providers** or a tool like Dograh that only exposes a base URL, do not paste a dedicated endpoint host into a field meant for the provider router.
- Provider router base URL: `https://router.huggingface.co`
- OpenAI-compatible router base URL: `https://router.huggingface.co/v1`
- Use the model id in the model field, for example `openai/whisper-large-v3-turbo`
- This is a different integration path from a private `*.aws.endpoints.huggingface.cloud` endpoint.

8. If Dograh only gives you a base URL field, check whether it is configured for the router flow or the dedicated endpoint flow.
- Router flow: base URL points to `router.huggingface.co`, model id selects the backend.
- Dedicated endpoint flow: base URL must be the private endpoint host, and the UI must be able to express the required route if one exists.
- If Dograh cannot represent the full endpoint URL or required route, the private endpoint is not directly usable there.

9. If you get `404`, check these first:
- wrong host or missing route path
- calling the deployment URL instead of the model endpoint URL
- using the router base URL with a dedicated endpoint path expectation, or vice versa
- endpoint not ready / wrong deployment environment
- using JSON/base64 when the endpoint expects raw audio bytes

10. If you get `401`, check auth before payload shape. If you get `404`, treat it as routing/URL shape first, not an auth problem.

## Anti-patterns
- Sending base64 audio inside JSON when the endpoint expects binary
- Choosing a large Whisper model for CPU-only voice agent traffic
- Optimizing for benchmark accuracy instead of end-to-end latency
- Treating `404` as an auth problem before checking the URL and route
- Debugging without printing `status_code` and raw `response.text`
- Truncating the Hugging Face endpoint to the host only when a full route is required
- Pointing Dograh at a private endpoint host when the field is actually meant for the Hugging Face router base URL
