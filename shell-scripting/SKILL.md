---
name: shell-scripting
category: software-development
description: Cross-platform shell scripting — macOS/Linux portability, common pitfalls, diagnostic script patterns.
---

# Shell Scripting (macOS-first)

## Trigger
Use when writing, debugging, or porting bash/shell scripts — especially diagnostic, network, or API-probing scripts that must run on macOS.

## Core Rules

1. **No `grep -P` on macOS.** BSD grep (default on macOS) does not support Perl-compatible regex (`-P`). Use `sed -E` for capture groups, or install GNU grep via `brew install grep` and invoke as `ggrep`.
2. **Port extraction from URLs.** Use `sed -nE 's|.*:([0-9]+).*|\1|p'` — works on both macOS and Linux. Avoid `grep -oP ':\K[0-9]+'`.
3. **JSON field extraction without jq.** When `jq` may not be installed, use `sed -nE 's/.*"key"\s*:\s*"([^"]+)".*/\1/p'` instead of `grep -oP`.
4. **DNS resolution for localhost.** `nslookup` and `dig` bypass `/etc/hosts` and cannot resolve `localhost`. Use `getent hosts` or `ping -c1` for localhost resolution. A DNS failure on `localhost` is a false positive — the TCP connection test is the real signal.
5. **TCP port check.** `timeout N bash -c "echo >/dev/tcp/$HOST/$PORT"` is the most portable way to test TCP connectivity without `nc`.

## Pitfalls

| Pattern | Broken (Linux-only) | Fixed (cross-platform) |
|---------|---------------------|------------------------|
| grep Perl regex | `grep -oP ':\K[0-9]+'` | `sed -nE 's|.*:([0-9]+).*|\1|p'` |
| grep JSON extract | `grep -oP '"name"\s*:\s*"\K[^"]+'` | `sed -nE 's/.*"name"\s*:\s*"([^"]+)".*/\1/p'` |
| DNS localhost | `nslookup localhost` → fails | `getent hosts localhost` or `ping -c1 localhost` |
| Port from URL | `grep -oP` | `sed -nE` (see above) |

## Diagnostic Script Templates

Two proven diagnostic scripts live in `references/`:

- `references/endpoint-doctor.md` — General HTTP endpoint diagnostics (DNS, TCP, HTTP status, headers, path variants, OPTIONS, SSL, Ollama-specific checks).
- `references/ollama-full-check.md` — Ollama-specific full diagnostic (GET endpoints, model detection, POST /api/generate, /api/chat, /v1/chat/completions, response preview).

Both are macOS-compatible (no `grep -P`, no GNU-isms).

## Verification

After writing a shell script, run it immediately against a known-good target (e.g. `http://localhost:11434` for Ollama) to catch portability issues before the user does.
