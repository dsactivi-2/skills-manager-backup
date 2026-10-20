# s-ella ← Mac-Ollama über Tailscale

VPS-Profil `s-ella` (myhermi) nutzt ein **auf dem Mac geladenes** lokales Modell. Öffentlicher API-Proxy: nein (uncensored + Telegram).

## Live-SoT (vor Write erneut prüfen)

| | |
|---|---|
| VPS | myhermi `100.122.29.48` — `tailscaled` active, `hermes-gateway-s-ella` |
| Mac | activibook `100.67.104.24` (`MacBook-Pro-von-Denis-2.local`) |
| Primary | `huihui_ai/gemma-4-abliterated:latest` via `http://100.67.104.24:11434/v1` |
| Fallback | `xai-oauth` / `grok-4.5` (Mac sleep / TS down) |
| Aux on VPS | bleibt `http://127.0.0.1:11434/v1` (VPS-Ollama, z.B. cloud-Tags) |

`127.0.0.1:11434` auf myhermi ist der **VPS**-Daemon. Dort liegt `gemma4:31b-cloud`, nicht das Mac-GGUF.

## Mac-Fallen

- Tailscale.app kann **stopped** sein, während `tailscale ip -4` noch eine gecachte `100.x` druckt. Start: `open -a Tailscale`, dann `Tailscale up`. `--exit-node-allow-lan-access` nur zusammen mit `--exit-node`.
- Homebrew-`tailscale` CLI auf dem Agent-Mac kann crashen (`BundleIdentifiers`). Peer-IP von **myhermi** `tailscale status` lesen.
- `brew services restart ollama` **überschreibt** `~/Library/LaunchAgents/homebrew.mxcl.ollama.plist` und löscht handgesetztes `OLLAMA_HOST`.
- Typisch: IPv4 `127.0.0.1:11434` + IPv6 `*:11434`. VPS-curl über TS kann trotzdem 200 sein. `127.0.0.1` behalten — lokales Artemis OrbStack braucht `host.docker.internal:11434`.
- Ping oft **DERP(fra)**, nicht direct — Latenz, aber ok. Mac muss wach + TS + Ollama bleiben.

## VPS vor Config

```bash
ssh myhermi 'systemctl is-active tailscaled; tailscale ip -4'
ssh myhermi 'tailscale ping --c 2 --timeout 3s 100.67.104.24'
ssh myhermi 'curl -sS -m 8 http://100.67.104.24:11434/api/tags'
```

## Hermes-Keys (`hermes-config-persistence`)

`model.default`-**Werte** dürfen `/` und `gemma-4` enthalten. Der Dot-Trap gilt nur für Key-Pfade.

```bash
hermes -p s-ella config set model.provider custom
hermes -p s-ella config set model.base_url "http://100.67.104.24:11434/v1"
hermes -p s-ella config set model.default "huihui_ai/gemma-4-abliterated:latest"
hermes -p s-ella config set model.api_key ollama
# model.api_mode unset
systemctl restart hermes-gateway-s-ella
# telegram: connecting → connected
```

Fallbacks/auxiliary nicht mit umlegen. E2E:

```bash
curl -sS -m 180 http://100.67.104.24:11434/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{"model":"huihui_ai/gemma-4-abliterated:latest","messages":[{"role":"user","content":"Reply with exactly: ella-ok"}],"max_tokens":24}'
```
