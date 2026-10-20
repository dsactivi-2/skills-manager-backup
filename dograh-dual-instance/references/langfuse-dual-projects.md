# Langfuse dual projects (Activi)

## Verified split (2026-07-28)

| Role | Langfuse project name | Typical use |
|------|----------------------|-------------|
| voiceeu / Self-Host Dograh | **DograhEU** | Traces for https://voiceeu.activi.io |
| Cloud / default Hermes | **Hermes LocalM5** | Cloud Dograh + general Hermes traces |

Host: `https://cloud.langfuse.com` (SaaS). Not a self-hosted Langfuse server.

## Env layout

```bash
# voiceeu project
LANGFUSE_VOICEEU_PUBLIC_KEY=pk-lf-…
LANGFUSE_VOICEEU_SECRET_KEY=sk-lf-…
LANGFUSE_VOICEEU_BASE_URL=https://cloud.langfuse.com
LANGFUSE_VOICEEU_MCP_AUTH=Basic …   # base64(pk:sk)

# cloud project (when separate)
LANGFUSE_CLOUD_PUBLIC_KEY=pk-lf-…
LANGFUSE_CLOUD_SECRET_KEY=sk-lf-…
LANGFUSE_DOGRAH_CLOUD_MCP_AUTH=Basic …
```

Profile **barbares**: primary `LANGFUSE_PUBLIC_KEY`/`SECRET` should equal **voiceeu** keys.

## Hermes MCP names

| MCP config key | Auth env | When |
|----------------|----------|------|
| langfuse-voiceeu | LANGFUSE_VOICEEU_MCP_AUTH | Barbarez / voiceeu work |
| langfuse-dograh-cloud | LANGFUSE_DOGRAH_CLOUD_MCP_AUTH | Cloud Dograh only |
| langfuse-docs | none | Langfuse product docs |

## Dograh platform side

Each Dograh instance UI → Tracing/Langfuse must use the **matching** project keys or traces land in the wrong project.

## Pitfalls

- Same pk/sk on both MCP names ⇒ one project, two labels — filter by metadata/workflow id.
- Posting keys in chat ⇒ rotate in Langfuse UI after wiring `.env`.
- `hermes mcp test` green ≠ correct project if auth still points at old Basic string — re-test after env change + new session.
