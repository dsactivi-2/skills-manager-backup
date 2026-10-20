---
name: openclaw-ollama-embeddings-migration
description: "Migrate OpenClaw builtin memory embeddings from OpenAI to local Ollama with model selection, loopback binding, dry-run config patches, and a separate reindex gate."
trigger: "Use when OpenClaw memory embeddings fail on OpenAI/quota or need local multilingual embeddings via Ollama."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ec7f8-7ba8-7070-9865-2fc0cbac4eda
  - activi_dsactivi's Organization_default_019ec7f8-39c8-7492-8f28-a60ec6e38f6f
  - activi_dsactivi's Organization_default_019ec7f4-cf83-7373-8dde-79222417d631
  - activi_dsactivi's Organization_default_019ec6d1-fa14-7be2-9a51-8478f5a05f7e
  - activi_dsactivi's Organization_default_019ec6b3-b9ad-7501-84b7-a671a0756d10
  - activi_dsactivi's Organization_default_019ec7e5-6a3c-7092-ad01-eb5293bd0f13
  - activi_dsactivi's Organization_default_019ec7e4-28cd-71f2-a1e6-113b96486206
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-06-15T01:01:24.273Z
updated_at: 2026-06-15T01:01:24.273Z
---

# OpenClaw Ollama embeddings migration

## When to use

Use when an OpenClaw VPS uses builtin memory and embeddings need to move from OpenAI to local Ollama, especially for multilingual Serbian/Croatian/Bosnian retrieval.

## Workflow

1. Read project instructions and prior state first:
   - `/Users/activi/Documents/Agent OS Systeme/AGENTS.md`
   - `/Users/activi/.codex/RTK.md`
   - `/Users/activi/Documents/Agent OS Systeme/reports/openclaw-ai-persona-os-install-report.md`
2. Run read-only discovery and stop on unclear state:

```bash
openclaw memory status --json || true
openclaw memory status --deep --json || true
openclaw config get agents.defaults.memorySearch --json || true
command -v ollama || true
systemctl is-active ollama || true
free -h
df -h
ss -ltnp | grep 11434 || true
```

3. If Ollama is absent, produce an install plan and dry-run/preflight only. Do not install, pull models, patch config, or reindex without explicit approval.
4. Prefer `nomic-embed-text-v2-moe` for multilingual/BKS embeddings. Use `mxbai-embed-large` only if the primary model is unavailable or incompatible. Use `nomic-embed-text` as the low-resource fallback.
5. Plan the target state:
   - 4 GB swap if the VPS has no swap
   - Ollama as a systemd service
   - `OLLAMA_HOST=127.0.0.1:11434`
   - no public firewall rule for `11434`
   - model `nomic-embed-text-v2-moe` present locally
   - OpenClaw config patched, but no reindex yet
6. Prepare a patch such as `/tmp/memory-ollama-patch.json5`:

```json5
{
  agents: {
    defaults: {
      memorySearch: {
        provider: "ollama",
        model: "nomic-embed-text-v2-moe",
        remote: {
          baseUrl: "http://127.0.0.1:11434"
        }
      }
    }
  }
}
```

7. Validate before apply whenever available:

```bash
openclaw config patch --file /tmp/memory-ollama-patch.json5 --dry-run
```

8. Apply only after explicit approval. After apply, run:

```bash
openclaw config validate --json
openclaw config get agents.defaults.memorySearch --json
openclaw memory status --json
openclaw memory status --deep --json
ollama list
curl -fsS http://127.0.0.1:11434/api/tags
ss -ltnp | grep 11434 || true
systemctl status ollama --no-pager || true
```

`dirty`, `Indexed: 0/2`, or similar after the patch is expected until reindex. Do not treat that alone as installation failure.

## Ollama service debugging

Do not leave `nohup`, `screen`, `tmux`, or an ad-hoc `ollama serve` as the final state. If Ollama fails, gather service evidence:

```bash
systemctl status ollama --no-pager || true
journalctl -u ollama -n 120 --no-pager || true
systemctl cat ollama || true
id ollama || true
getent passwd ollama || true
ss -ltnp | grep 11434 || true
curl -fsS http://127.0.0.1:11434/api/tags || true
```

Only make a narrow systemd/env correction that preserves loopback-only binding, then restart and recheck.

## Reindex gate

Reindex is a separate phase. Before `openclaw memory index --force`, request approval, record the current status, and back up `/root/.openclaw/memory/main.sqlite` if present. Never combine install/config apply and forced reindex in one approval.

Do not change AI Persona OS files during this migration: `SOUL.md`, `AGENTS.md`, `MEMORY.md`, `persona-config.yaml`, or `skills/ai-persona-os`.

## Anti-patterns

- Treating OpenAI quota errors as permission to mutate config immediately
- Choosing `mxbai-embed-large` first when BKS/multilingual retrieval is the goal
- Opening Ollama publicly on `0.0.0.0:11434`
- Running `openclaw memory index --force` in the same phase as installation
- Running `openclaw doctor --fix` or repair commands without separate approval
- Calling a dirty index a failed Ollama migration without checking provider/config reachability
- Editing persona files while only changing embedding infrastructure
