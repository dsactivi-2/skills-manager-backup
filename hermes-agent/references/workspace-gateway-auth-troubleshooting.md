# Hermes Workspace ↔ Gateway Verbindungsprobleme

## Symptom
- Workspace zeigt: "No compatible backend detected yet" (roter Status)
- Oder: API-Calls vom Workspace zum Gateway ergeben 401 Unauthorized
- Gateway-Prozess läuft aber (PID vorhanden, Logs zeigen Telegram-Verbindung)

## Root-Cause
Der Hermes Agent API-Server (`api_server`-Plattform) verlangt `API_SERVER_KEY` als **Umgebungsvariable** (aus `.env` oder Shell-Env). Der Workspace braucht denselben Key als `HERMES_API_TOKEN` in seiner eigenen `.env`.

## Diagnose (Reihenfolge)

1. **Gateway-Status prüfen**
   ```bash
   hermes gateway status
   lsof -i :8642
   ```

2. **API-Server-Key-Prüfung**
   ```bash
   grep API_SERVER_KEY ~/.hermes/.env
   ```
   → Wenn leer, ist das der Fehler.

3. **Workspace-Token-Prüfung**
   ```bash
   grep HERMES_API_TOKEN ~/hermes-workspace/.env
   ```
   → Wenn leer/auskommentiert, fehlt die Verbindung.

4. **Log-Check**
   ```bash
   tail -20 ~/.hermes/logs/gateway.log
   ```
   → Suchmuster: `Refusing to start: API_SERVER_KEY is required`

## Fix (2-Minuten-Rezept)

**Schritt 1 – Gateway-Key setzen:**
```bash
# Generiere oder setze Key
API_KEY="workspace-$(openssl rand -hex 8)"
echo "API_SERVER_KEY=$API_KEY" >> ~/.hermes/.env
```

**Schritt 2 – Workspace-Token setzen:**
```bash
cd ~/hermes-workspace
echo "HERMES_API_TOKEN=$API_KEY" >> .env
echo "HERMES_API_URL=http://127.0.0.1:8642" >> .env
```

**Schritt 3 – Gateway neu starten:**
```bash
launchctl unload ~/Library/LaunchAgents/ai.hermes.gateway.plist
launchctl load ~/Library/LaunchAgents/ai.hermes.gateway.plist
```

**Schritt 4 – Vite-Dev-Server neu starten:**
```bash
cd ~/hermes-workspace
pkill -f vite
pnpm dev
```

**Schritt 5 – Verifizierung:**
```bash
curl http://localhost:3000/api/models
# Erwartet: {"ok":true,"data":[{"id":"hermes-agent",...}]}
```

## Häufige Pitfalls

| Fehler | Ursache | Fix |
|--------|---------|-----|
| `hermes config set api_server.key xyz` → Gateway startet trotzdem nicht | Key muss als **Env-Var** (`API_SERVER_KEY`), nicht als verschachtelter Config-Wert | Direkt in `.env` schreiben |
| `hermes config set platforms.api_server.key xyz` → Gleiches Problem | `hermes config set` schreibt in `config.yaml`, aber Gateway-Code liest `os.environ["API_SERVER_KEY"]` | `.env` verwenden |
| Workspace zeigt weiterhin "No backend" nach Gateway-Restart | Vite-Server hat die alte `.env` gecacht | `pkill -f vite && pnpm dev` |
| `curl :8642/v1/models` gibt 401 | Key fehlt im Request-Header oder falscher Key | `curl -H "Authorization: Bearer $API_KEY" ...` testen |

## Zusammenhang zur Config-Struktur

```yaml
# config.yaml (NICHT hier setzen – funktioniert nicht)
platforms:
  api_server:
    enabled: true
    extra:
      port: 8642
      host: 127.0.0.1

# .env (HIER setzen – funktioniert)
API_SERVER_KEY=workspace-59172f51152ad620
```

→ Die Env-Variable `API_SERVER_KEY` wird von `hermes_cli/config.py` als Umgebungsvariable definiert und von `gateway/platforms/api_server.py` per `os.environ["API_SERVER_KEY"]` gelesen.

## Variante: Docker-Compose

Wenn der Workspace per Docker Compose läuft, müssen **beide** Env-Vars in `docker-compose.yml` an den Hermes-Agent-Container übergeben:
```yaml
environment:
  - API_SERVER_KEY=${API_SERVER_KEY}
  - HERMES_API_URL=http://hermes-agent:8642
```

Und die Workspace-`.env` braucht:
```
HERMES_API_TOKEN=${API_SERVER_KEY}
```
