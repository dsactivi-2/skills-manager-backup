---
name: network-endpoint-diagnostics
category: devops
description: Diagnose HTTP endpoint failures (404, connection refused, timeouts) with a structured 7-step probe — DNS, TCP, HTTP status, headers, path variants, OPTIONS, SSL. Includes Ollama-specific checks and a request-sniffing proxy.
---

# Network Endpoint Diagnostics

## Trigger
Use when debugging HTTP endpoint failures: 404, connection refused, timeout, 502/503, or "why can't my app reach this service". Also when the user asks to verify an API endpoint is healthy.

**Not this skill:** general Mac/internet/Wi-Fi slowness, ISP vs machine attribution, `networkQuality`/speed tests, multi-day link monitoring, or RAM/swap mistaken for "slow internet". Use `macos-network-health` instead.

## Core Workflow (7-Step Probe)

Run these in order — each step narrows the failure domain:

1. **DNS Resolution** — `getent hosts`, `ping`, or `dig`. `localhost` will fail DNS tools but succeed at TCP — that's normal.
2. **TCP Port** — `echo >/dev/tcp/$HOST/$PORT` (bash builtin, no netcat needed). Confirms the port is listening.
3. **HTTP Status** — `curl -s -o /dev/null -w "%{http_code}"`. Classify: 200=OK, 404=path issue, 000=connection failure, 401/403=auth, 405=wrong method, 502/503=upstream down.
4. **Response Headers** — `curl -s -I`. Check `Server`, `Location` (redirects), `Allow` (for 405).
5. **Path Variants** — If 404, test: root `/`, trailing slash, lowercase variant. Often the fix.
6. **OPTIONS Request** — `curl -X OPTIONS`. Reveals allowed methods, CORS config.
7. **SSL/TLS** — `openssl s_client -connect`. Check cert validity, expiry, self-signed status.

## Ollama-Specific Diagnostics

Ollama runs on port 11434. Key endpoints:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/tags` | List models (also used for auto-detection) |
| GET | `/api/version` | Server version |
| GET | `/v1/models` | OpenAI-compatible model list |
| POST | `/api/generate` | Legacy completion |
| POST | `/api/chat` | Native chat |
| POST | `/v1/chat/completions` | OpenAI-compatible chat |

**Model auto-detection**: Parse `/api/tags` JSON to extract the first model name. Use this for subsequent POST tests instead of guessing.

**Common Ollama 404 causes**:
- Wrong model name in JSON body (model doesn't exist locally)
- GET instead of POST on `/api/generate` or `/api/chat`
- Using `/v1/chat/completions` when Ollama is older than 0.1.24

## Request Sniffing (Proxy Pattern)

When you need to see the EXACT HTTP request an app sends (to debug path/header/body mismatches):

1. Start a TCP proxy on a different port (e.g. 11435) that forwards to the real service (11434)
2. Point the app at the proxy port
3. The proxy logs every request before forwarding

Reference script: `scripts/ollama_sniffer.py` — a zero-dependency Python TCP proxy that prints full HTTP requests.

## Pitfalls

### macOS: `grep -P` does not exist
macOS uses BSD grep, which lacks `-P` (Perl regex). Use `sed -E` instead:
```bash
# BROKEN on macOS:
echo "$url" | grep -oP ':\K[0-9]+'

# WORKS everywhere:
echo "$url" | sed -nE 's|.*:([0-9]+).*|\1|p'
```

### DNS failure on localhost is a false positive
`nslookup` and `dig` query DNS servers directly and skip `/etc/hosts`. `localhost` resolves via `/etc/hosts`, not DNS. If TCP connects but DNS tools fail, the endpoint is fine.

### 405 on GET for POST-only endpoints
Ollama's `/api/generate` and `/api/chat` return 405 on GET. This is correct behavior — they require POST with a JSON body.

### Port extraction from URLs
Always extract the port explicitly from the URL string. Don't assume default ports — `http://host:11434/path` has port 11434, not 80.

## Connection-refused triage

A TCP `Connection refused` is materially different from a timeout: the destination IP (or a device on its path) actively rejected the connection. It rules out a plain DNS failure for that address, but does not prove which process or firewall rule caused the rejection.

When SSH and both web ports are refused on the same resolved IP:

1. Report the distinction plainly: the name resolves, the IP is reachable, but the tested ports are closed or actively rejected.
2. Do not infer the hosting provider from reverse DNS alone.
3. Explain the next access path in concrete terms: the server provider’s dashboard may offer power status, firewall settings, an out-of-band web/KVM console, or a rescue environment. These are only needed if no other trusted administrative path exists.
4. In an out-of-band console, verify listeners and firewall state before changing anything: `sshd`, the reverse proxy/web service, and the host firewall.

### VNC console interaction

Provider VNC consoles are emergency displays, not normal terminals. Clipboard forwarding is often absent or unreliable. Give a user one short, read-only command at a time as plain text; do not label fenced commands with a language token because users may type that token as part of the command. Confirm from the returned screenshot that the intended command actually ran before drawing conclusions. Start with `systemctl status ssh`, then inspect listeners with `ss -ltnp`, and only then inspect host firewall or Fail2ban.

A running `sshd` service alone does not establish public reachability: verify its listening address and port, then compare that to the external TCP result. A proxy cannot explain an SSH (`:22`) failure; if SSH and web ports fail together while all three processes listen on public addresses, scope the fault to an effective host firewall or the provider/network edge.

Do not treat `fail2ban-client status sshd` with zero current bans as conclusive: Fail2ban reject rules can persist in the effective nftables/iptables ruleset. Check the user’s current source IP against `nft list ruleset` or `iptables -S` before excluding it. Fail2ban remains SSH-specific and cannot by itself explain simultaneous web-port failures.

Treat a nearby provider-firewall activity as a lead, not causal proof. After any dashboard rule change, immediately re-probe externally at both layers: TCP ports, then an authenticated SSH command and an HTTPS response. Current rules prove the current state only; if a previous rule set was overwritten, reconstructing the original cause may be impossible without a provider activity/audit record captured at the time.

### Hetzner Cloud API cross-check

When `hcloud` is configured, use read-only API state alongside the external probe:

- `hcloud server describe <server> -o json` — verify server `running`, primary IPv4 `blocked: false`, and attached firewall ID/status.
- `hcloud firewall describe <firewall-id> -o json` — verify the current inbound port/source rules and `applied_to` target.

If external TCP still returns `Connection refused` while the guest previously proved listeners on public addresses, the primary IP is not blocked, and the attached Hetzner firewall currently permits the ports, state the evidence without inventing an exact cause: the remaining boundary is the provider network/firewall dataplane or an effective guest rule that must be observed during the failure. Capture timestamps and open a provider support case; a restart may restore service but does not establish root cause.

## Reference

- `references/hetzner-cloud-emergency-access.md` — verified emergency VNC/password-reset path and VNC-friendly triage for Hetzner Cloud.

## Scripts

- `scripts/endpoint_doctor.sh` — General-purpose 7-step HTTP endpoint diagnostic
- `scripts/ollama_full_check.sh` — Ollama-specific full diagnostic (GET + POST + model detection)
- `scripts/ollama_sniffer.py` — TCP proxy that logs exact HTTP requests between client and Ollama
