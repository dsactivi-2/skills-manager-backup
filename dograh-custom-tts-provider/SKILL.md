---
name: dograh-custom-tts-provider
description: "Add a custom TTS provider to self-hosted Dograh code."
version: 1.0.0
author: Agent
license: MIT
---

# Adding a Custom TTS Provider to Self-Hosted Dograh (code-level)

Class-level skill for registering a **new TTS (or STT/LLM) provider that
Dograh does not ship** — e.g. Fish Audio — into a **self-hosted** Dograh
checkout. This is code work in `api/`, not UI config. Verified against the real
`dograh-hq/dograh` repo structure + the Pipecat submodule, 2026-08 (Fish Audio
as worked example).

## When this applies
- The provider is NOT in Dograh's built-in TTS list. Built-ins (2026-08):
  ElevenLabs, OpenAI, Google, Azure Speech, Deepgram, Cartesia, Smallest AI,
  MiniMax, Sarvam, Rime, Inworld, Camb.ai, xAI, LMNT, Dograh TTS, + Speaches
  (self-hosted OpenAI-compatible).
- "Add voice ID manually" in the Dograh UI only picks a voice **within an
  already-supported provider** — it does NOT add a new provider. A brand-new
  provider requires the code edits below and therefore **self-hosting**.
- Fish Audio's cloud has **no** OpenAI-compatible `/v1/audio/speech` endpoint
  (only an open feature request), so you cannot fake it via the OpenAI provider
  slot. It speaks its own format (`/v1/tts`, `reference_id`, `model` header) →
  you must add a real provider branch.

## Verify BEFORE coding — the #1 pitfall
Dograh vendors a **pinned Pipecat fork as a git submodule** (`pipecat @
<commit>` in the repo root), NOT `pip install pipecat-ai`. Public Pipecat docs
may not match your commit. Before writing any import:
```bash
grep -ri "FishAudio" pipecat/src/pipecat/services/fish/
```
Confirm the EXACT: import path (`from pipecat.services.fish.tts import
FishAudioTTSService`), settings class shape (`Settings(voice=...)` new vs
deprecated `reference_id=...` / `model=...` — Pipecat renamed these), and which
params the Settings class in THAT commit accepts (voice, model, prosody_speed,
prosody_volume, latency, output_format). If the service is missing from the
submodule, stop and update/patch the fork first.

### FIRST check whether the work is already done in the DEPLOYED fork
Before writing anything, grep the fork that is actually deployed for the
provider — the integration may already exist. A user can have several local
Dograh checkouts (e.g. `dograh-upstream`, `Dograh selfhosted`, `New project N`)
plus a private GitHub fork (e.g. `dsactivi-2/dograhV2`) that is the real
deployed stack. The local copies often track `dograh-hq` upstream (no custom
provider), while the private fork already has the full integration merged.
Verify against the deployed fork's raw files, not a stale local clone:
```bash
grep -rn "FISH_AUDIO\|FishAudio" api/services/configuration/registry.py \
  api/services/pipecat/service_factory.py \
  api/services/configuration/check_validity.py
```
If registry enum + `TTSConfig` union + factory branch + validator are all
present, the code work is DONE — skip to the deploy/verify steps and don't
re-implement into a copy that isn't the live one. Identify the live stack via
`docker ps` / mounted volumes or the git remote, not by filename guesses.

## The files to touch (worked pattern — mirror ElevenLabs / MiniMax / LMNT)
1. `api/services/configuration/registry.py`
   - Add enum member, e.g. `FISH_AUDIO = "fish_audio"` to `ServiceProviders`.
   - Add a `provider_model_config(...)` title/description block.
   - Add a `@register_tts` config class (subclass `BaseTTSConfiguration`) with
     `provider: Literal[...]`, `model` (default e.g. `s2-pro`), `voice`
     (the clone `reference_id`), `speed`, `latency`, optional `language`.
   - Add the new config class to the `TTSConfig` discriminated `Union` AND to
     `BaseServiceConfiguration.provider: Literal[...]` — miss either and the
     Pydantic config POST fails validation.
2. `api/services/pipecat/service_factory.py`
   - Add an `elif user_config.tts.provider == ServiceProviders.FISH_AUDIO.value:`
     branch inside `create_tts_service`, **before** the final
     `else: raise HTTPException(... "Invalid TTS provider ...")`.
   - The clone `reference_id` rides in the **`voice`** field (same as
     ElevenLabs' voice_id).
   - Copy the standard args every other block passes:
     `text_filters=[xml_function_tag_filter]`,
     `skip_aggregator_types=["recording_router", "recording"]`,
     `silence_time_s=1.0`. Set `output_format="pcm"` and
     `sample_rate=audio_config.transport_out_sample_rate` (like LMNT) so audio
     matches the transport.
3. Dependencies / submodule extras: Fish TTS needs `ormsgpack` + `websockets`
   (`pipecat-ai[fish]`). In a submodule setup do NOT rely on the extra —
   ensure the packages land in the container build (`api/requirements.txt`),
   else `ModuleNotFoundError` at first call, not at startup.
4. `options.py` is usually **not** needed if voices are free-form IDs (a clone
   `reference_id` is a free text field, not a fixed dropdown).
5. Frontend provider list (only if you want it selectable in the UI dropdown;
   "voice" must be a free text field for the clone ID).
6. `api/services/configuration/check_validity.py` — the real fork adds a
   per-provider API-key validator. Add a `_check_<provider>_api_key` method AND
   register it in `UserConfigurationValidator._validator_map` keyed by
   `ServiceProviders.<X>.value`. Best-effort smoke test only: hit a cheap
   authed endpoint (Fish: `GET https://api.fish.audio/model` with
   `Authorization: Bearer <key>`) and reject **only** on a clear `401/403`;
   treat other statuses as inconclusive so transient errors / API changes don't
   block a valid key. Skip this file and the UI "validate key" step silently
   passes or errors oddly on save.

## Language must stay free-form (locale pitfall)
Some provider branches force language into a fixed `Language` enum (e.g. Rime
knows only en/de/fr/es/hi). If your target locale (e.g. Bosnian `bs`) isn't in
that enum, Dograh silently downgrades to English → wrong pronunciation even
though the engine could do it. For an unofficial-locale provider, either omit
language (let the engine auto-detect from the text's diacritics) or pass it as
a raw string bypassing the enum — the Camb block does this with
`tts._settings.language = language`.

## What you do NOT need
- A custom wrapper class (unlike MiniMax's session-ownership wrapper) — the
  Pipecat Fish service owns its own WebSocket lifecycle.
- Any STT/LLM factory changes — TTS only.

## Test / verify
1. Save an agent config with the new provider → agent starts without
   `Invalid TTS provider <name>`.
2. Backend log at call start shows `Creating TTS service: provider=<name>,
   model=...`.
3. Fastest end-to-end check: Dograh **Web Call** (browser, no telephony). Put a
   locale test sentence in the Start-Call node greeting and listen.
4. Emotion tags: they come from the LLM writing them into the text, NOT the TTS
   config. Fish `(excited)` = S1 syntax, `[excited]` = S2 syntax — match your
   model. `xml_function_tag_filter` strips only XML function tags; round/square
   brackets pass through.

## Typical errors → cause
| Symptom | Cause |
|---|---|
| `Invalid TTS provider <name>` | factory branch missing / enum value mismatch |
| Pydantic validation error on config POST | provider missing from `Literal[...]` or `TTSConfig` Union |
| `ModuleNotFoundError: ormsgpack` | Fish extra not in the container build |
| 401 from provider | wrong/empty `api_key` in agent config |
| robotic / wrong-speed / no audio | wrong `sample_rate` or not `output_format="pcm"` |
| English pronunciation of a non-English name | language forced into a fixed enum |

## Copy-paste code
See `references/fish-audio-worked-example.md` for the full registry block,
factory branch, example agent config JSON, and the 5-step test checklist —
ready to adapt to your submodule's actual Settings shape.

## Emotion, G2P, and the Fish MCP (runtime-side, not code-side)
Once the provider branch exists, the day-to-day levers are prompt/UI work, not
more code. See `references/fish-emotion-and-g2p-in-dograh.md` for the verified
three-layer model (emotion-direction vs Fish tags vs name respelling) mapped
onto Dograh's actual node set, the full Fish S1/S2 tag inventory, the Bosnian
"not officially supported" caveat, and how to install/use the Fish Audio MCP
(`https://api.fish.audio/mcp`, OAuth — no header) to test tags + respelling
against the real model instead of guessing.

## Fish also ships an MCP server (verification aid, not the runtime path)
Separate from the code integration above, Fish Audio exposes an MCP server at
`https://api.fish.audio/mcp` (OAuth sign-in in the browser, **no API key**). It
gives voice-library search / TTS-generate / STT tools — handy for picking a
clone `reference_id`, auditioning voices, or round-trip pronunciation checks
BEFORE wiring the provider. It is NOT the call-time TTS path (that stays the
Pipecat Fish service in `service_factory.py`).

**Registration is OAuth, and it does NOT "just work" with a bare URL** (this
corrects an earlier assumption). Verified 2026-08:
- A bare `fish-audio: {url: …}` entry registers as `auth: none` → every call
  returns **401 Unauthorized**. `hermes mcp login fish-audio` then refuses:
  *"Server is not configured for OAuth (auth=None)"*.
- The server must be registered **as an OAuth server**:
  `hermes mcp add fish-audio --url https://api.fish.audio/mcp --auth oauth`.
- The **initial browser OAuth handshake requires an interactive TTY** — a
  non-interactive agent shell fails with *"non-interactive environment and no
  cached tokens found"* and the entry is saved **disabled**. The USER must run
  `hermes mcp login fish-audio` themselves, then
  `hermes config set mcp_servers.fish-audio.enabled true` and
  `hermes mcp test fish-audio` (expect `✓ Connected`, not 401).
- Agent CAN write the config via `hermes config set mcp_servers.<name>.<key>`
  (the `patch`/`write_file` path to `~/.hermes/config.yaml` is refused as
  security-sensitive; the CLI is the allowed channel) — but that only writes
  `auth: none`, so prefer `hermes mcp add … --auth oauth` for OAuth servers.
- Full OAuth-MCP registration mechanics live in skill `hermes-mcp-http`
  (§"OAuth-based MCP servers").
- **Fallback if OAuth is fiddly:** the Fish MCP is only a verification aid. The
  production levers (globalNode emotion rules + `text_filters` respelling in
  `service_factory.py`) work **without** it — don't block the build on it.

## Related
- `tts-pronunciation-correction` — respelling/round-trip for names the engine
  mis-says (the `text_filters` hook lives in the same factory block).
- `soniox-voice-platform` — a bs-capable evaluator/STT candidate.
- `dograh-setup` / `dograh-selfhost-guides` — running the self-hosted stack.
- Env: user runs self-hosted Dograh; Fish clone `reference_id` example lives in
  `~/bs-voice-tool` alongside the `fish-audio-sdk` venv.
