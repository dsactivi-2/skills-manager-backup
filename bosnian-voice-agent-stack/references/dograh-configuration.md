# Dograh Configuration for Bosnian Voice Agents

## API Key Setup

Three keys are needed. All are set in Dograh UI under **Settings → API Keys**:

| Key | Provider | Get From | Used For |
|-----|----------|----------|----------|
| OpenAI API Key | OpenAI | https://platform.openai.com/api-keys | GPT-4.1 (LLM) + gpt-4o-mini-tts (TTS) — same key for both |
| Deepgram API Key | Deepgram | https://console.deepgram.com | Nova-3 STT |
| Dograh API Key | Dograh | https://app.dograh.com/api-keys | MCP/API access (not needed in UI) |

Keys are per-account, not per-workflow. Set once, all workflows inherit.

## Voice Agent Configuration

When creating a new voice agent in Dograh:

1. Navigate to the user-provided Dograh URL (e.g. `https://app.dograh.com/workflow/<id>`)
2. Create new agent with:
   - Name: descriptive, includes language and product
   - Type: Outbound (for telesales)
   - Language: target locale (e.g. Bosnian `bs-BA`)
3. STT settings:
   - Provider: Deepgram
   - Model: Nova-3
   - Language code: `bs` (Bosnian monolingual)
   - Keyterms: product names, brand terms, domain vocabulary
4. LLM settings:
   - Provider: OpenAI
   - Model: GPT-4.1 (NOT Mini/Nano for non-English production)
   - Temperature: 0.7
   - Max Tokens: 150 (keep responses short for voice)
5. TTS settings:
   - Provider: OpenAI
   - Model: gpt-4o-mini-tts
   - Voice: `cedar` (primary) or `marin` (alternative)
   - Instructions: language, tone, speed guidance
6. Call settings:
   - Max Call Duration: 180 seconds
   - Silence Timeout: 5 seconds
   - Barge-In: Enabled

## Dograh Instance URLs

Do NOT assume a fixed Dograh URL. The user may use:
- `https://app.dograh.com` (main instance)
- `https://voiceeu.activi.io` (EU instance)
- Other custom instances

Always ask or use the URL the user provided. The workflow ID is appended: `https://<instance>/workflow/<id>`.

## Common Pitfalls

- **Missing API keys**: Agent won't start. Check Settings → API Keys first.
- **Wrong STT language code**: Using multilingual model for single-language flow causes accuracy loss. Use monolingual code (`bs`, not `bs-BA` for Deepgram).
- **GPT-4.1 Mini for non-English**: Known quality degradation. Always test with real calls before using Mini for Bosnian.
- **Hardcoded URLs**: Different Dograh instances exist. Never hardcode `voiceeu.activi.io`.
