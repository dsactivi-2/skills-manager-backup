# Defang sample on OrbStack

Do not start the official `llm` gateway or publish host port 80. Use host Ollama.

```yaml
# compose.orbstack.yaml
services:
  app:
    platform: linux/arm64
    environment:
      LLM_URL: http://host.docker.internal:11434/v1/
      LLM_MODEL: huihui_ai/gemma-4-abliterated:latest
      OPENAI_API_KEY: ollama
    extra_hosts:
      - "host.docker.internal:host-gateway"
    depends_on: !override []
    volumes: !override []
  llm:
    profiles:
      - cloud-llm
```

```bash
export DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock
export COMPOSE_BAKE=0
export DOCKER_DEFAULT_PLATFORM=linux/arm64
docker --context=orbstack compose -p <name> \
  -f compose.yaml -f compose.dev.yaml -f compose.orbstack.yaml \
  up --build -d
```

Remap published ports if occupied (`3000` often is). After up: container status, `curl` the UI, one real chat POST. Optional vendor keys (Tavily) stay optional — do not crash import when unset.
