# API_SERVER_KEY Troubleshooting Reference

## Symptom
Hermes Gateway läuft, aber Workspace meldet "No compatible backend detected yet".
Gateway-Logs zeigen wiederholt: `API_SERVER_KEY is required for the API server, including loopback-only binds on 127.0.0.1.`

## Root Cause
Der API-Server-Adapter liest `API_SERVER_KEY` ausschließlich aus **Umgebungsvariablen** (`os.environ` / `~/.hermes/.env`), nicht aus `config.yaml`. Der Befehl `hermes config set platforms.api_server.key <val>` schreibt in YAML, wird aber vom Code ignoriert.

## Fix
```bash
echo "API_SERVER_KEY=$(openssl rand -hex 16)" >> ~/.hermes/.env
hermes gateway restart
```

## Verifikation
```bash
curl -s http://localhost:8642/v1/models
lsof -i :8642
```

Quelle: Session 2026-06-01, Hermes Workspace Backend-Verbindung.
