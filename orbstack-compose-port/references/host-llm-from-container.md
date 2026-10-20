# Host-LLM from an OrbStack container

When a compose app talks to Mac Ollama (or any host OpenAI-compatible server), the caller is usually a **backend container**, not the browser.

## Probe before changing host Ollama

```
docker --context=orbstack run --rm --add-host=host.docker.internal:host-gateway \
  curlimages/curl -sS -m 8 http://host.docker.internal:11434/api/version
```

If this returns JSON + HTTP 200, leave host `OLLAMA_HOST` alone. IPv4 listen on `127.0.0.1:11434` can still work through OrbStack's `host.docker.internal`.

Always put this on the backend service:

```yaml
extra_hosts:
  - "host.docker.internal:host-gateway"
```

## UI field vs who fetches

If the web form posts `api_endpoint` and FastAPI then does `OpenAI(base_url=api_endpoint)`, `http://localhost:11434/v1` is the **container** loopback. Use `http://host.docker.internal:11434/v1` as the default (and a model that `ollama list` actually has).

Browser → Next.js `/api/*` → backend is fine with `FASTAPI_API_URL=http://backend:8000` (server-side env, not `NEXT_PUBLIC_`).

## Overlay YAML

Do not edit upstream `docker-compose.yaml`. Add `docker-compose.orbstack.yaml` and:

```
docker --context=orbstack compose -f docker-compose.yaml -f docker-compose.orbstack.yaml --env-file .env up -d --build
```

## Optional cloud keys

Write `OPENAI_API_KEY=` when unused. Never copy `your_openai_api_key_here` into `.env`. Default the UI to Ollama if no key exists. A backend log `FATAL: OPENAI_API_KEY not set` is expected on the Ollama path.

## Verify

| Check | Command |
|---|---|
| Context | `docker --context=orbstack info --format '{{.Name}} {{.Architecture}}'` |
| Host LLM | curl `host.docker.internal:11434/api/version` from a throwaway container |
| Backend → Ollama | `docker --context=orbstack exec <backend> python -c '…urlopen(host.docker.internal:11434/api/version)'` |
| UI / API | curl localhost + `<container>.orb.local:<port>` |
