# Endpoint Doctor — HTTP Diagnostic Script

## Purpose
General HTTP endpoint diagnostics: DNS resolution, TCP port check, HTTP status, response headers, path variant testing, OPTIONS request, SSL/TLS check, and Ollama-specific checks.

## Key macOS fixes applied
- Port extraction: `sed -nE` instead of `grep -oP`
- DNS: `getent hosts` before `nslookup`/`dig` (handles localhost)
- No GNU-isms

## Usage
```bash
./endpoint_doctor.sh http://localhost:11434
./endpoint_doctor.sh https://api.example.com/webhook
./endpoint_doctor.sh http://192.168.1.50 8080
```

## Checks performed
1. DNS resolution (getent → nslookup → dig)
2. TCP port reachability via /dev/tcp
3. HTTP status code + metadata (size, time, content-type, redirects)
4. Response headers (Server, Location)
5. Path variants (trailing slash, case variants)
6. OPTIONS request (CORS, allowed methods)
7. SSL/TLS certificate (HTTPS only)
8. Ollama special checks (if port 11434 detected)

## Script location
`/Users/activi/endpoint_doctor.sh`
