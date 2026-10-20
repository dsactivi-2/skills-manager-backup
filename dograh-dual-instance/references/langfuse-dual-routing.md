# Langfuse dual routing (Activi)

Langfuse ≠ Dograh workflow MCP. Use for traces/scores/prompts in LF project.

## Hermes MCP names

| MCP | URL | Auth env | When |
|-----|-----|----------|------|
| `langfuse-voiceeu` | `https://cloud.langfuse.com/api/public/mcp` | `LANGFUSE_VOICEEU_MCP_AUTH` | Self-host / voiceeu call traces |
| `langfuse-dograh-cloud` | same host | `LANGFUSE_DOGRAH_CLOUD_MCP_AUTH` | Cloud Dograh call traces |
| `langfuse-docs` | `https://langfuse.com/api/mcp` | none | LF product docs |

Tool prefixes: `mcp__langfuse_voiceeu__*`, `mcp__langfuse_dograh_cloud__*`, `mcp__langfuse_docs__*`.

## Auth construction

```text
LANGFUSE_*_MCP_AUTH=Basic base64(public_key:secret_key)
```

Also keep `LANGFUSE_PUBLIC_KEY` / `LANGFUSE_SECRET_KEY` / `LANGFUSE_BASE_URL` (and optional `HERMES_LANGFUSE_*`) for CLI/skills.

If both MCP auth vars equal the same Basic string → **one** LF project for both Dograh worlds; filter traces by workflow id / metadata / env. Separate LF projects later → different keys per auth var.

## Pair with Dograh MCP

| Dograh work | Dograh MCP | Langfuse MCP |
|-------------|------------|--------------|
| voiceeu | dograh-voiceeu | langfuse-voiceeu |
| Cloud | dograh | langfuse-dograh-cloud |

## Skills

- `langfuse` / `langfuse-official` — CLI/API
- `langfuse-voice-call-quality-optimization` — warmth/opening/naturalness
- `voice-call-observability-audit` — Dograh↔LF QA path
- Local sims: project `simulate_dialogues*.py` (no LF required)

## Verify

```bash
hermes -p barbares mcp test langfuse-voiceeu
hermes -p barbares mcp test langfuse-dograh-cloud
hermes -p barbares mcp test langfuse-docs
```
