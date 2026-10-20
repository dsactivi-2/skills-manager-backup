# n8n compose + Host-Caddy + Ollama CPU (Contabo)

## 502 / white page on the public host

Caddy HTTPS 200/502 with empty body: DNS and Caddy are fine. n8n is not on the host port.

`docker ps` often shows `5678/tcp` **without** `127.0.0.1:5678->5678`. Fix in `/opt/n8n/docker-compose.override.yml`:

```yaml
services:
  n8n:
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "127.0.0.1:5678:5678"
```

`docker compose stop caddy` if compose also ships Caddy. Host-Caddy already binds 80/443. `n8n-caddy-1 Exited (128)` is expected.

One Main + `N8N_RUNNERS_ENABLED=true` (in-container task-runner) is **not** queue workers. Redis/Postgres only for `EXECUTIONS_MODE=queue`.

## Ollama CPU, no models

Official `install.sh` with no GPU → CPU-only. Do not `ollama pull` unless asked.

`127.0.0.1:11434` is not reachable from n8n-Docker. Bind the compose gateway (`docker inspect n8n-n8n-1` → `.Gateway`) and keep CPU:

```
OLLAMA_HOST=<gateway>:11434
OLLAMA_LLM_LIBRARY=cpu
CUDA_VISIBLE_DEVICES=
```

n8n credential URL: `http://<gateway>:11434`. Do not put 11434 on Caddy.

video/render groups from install.sh ≠ GPU mode.
