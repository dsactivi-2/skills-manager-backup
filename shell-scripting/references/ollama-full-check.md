# Ollama Full Check — Diagnostic Script

## Purpose
Ollama-specific full diagnostic: DNS, TCP, GET endpoints, model auto-detection, POST /api/generate, /api/chat, /v1/chat/completions, response body preview, SSL.

## Key macOS fixes applied
- Port extraction: `sed -nE 's|.*:([0-9]+).*|\1|p'` (was `grep -oP ':\K[0-9]+'`)
- Model detection: `sed -nE 's/.*"name"\s*:\s*"([^"]+)".*/\1/p'` (was `grep -oP`)
- DNS: `getent hosts` → `getent ahosts` → `ping` fallback chain

## Usage
```bash
./ollama_full_check.sh http://localhost:11434
./ollama_full_check.sh http://192.168.1.50:11434
```

## Checks performed
1. DNS resolution (getent → ahosts → ping)
2. TCP port reachability
3. GET root URL
4. GET endpoints: /api/tags, /api/version, /v1/models
5. Model auto-detection from /api/tags
6. POST endpoints: /api/generate, /api/chat, /v1/chat/completions
7. Response body preview (first 200 chars)
8. SSL/TLS (HTTPS only)

## Script location
`/Users/activi/ollama_full_check.sh`
