---
name: dograh-dual-instance
description: "Use when Cloud vs self-host Dograh/voiceeu OR dual Langfuse routing (which MCP when)."
version: 1.5.1
license: MIT
metadata:
  hermes:
    tags: [dograh, mcp, self-host, ari, voiceeu, dual-instance, langfuse]
    related_skills:
      - hermes-mcp-http
      - voice-ai-infrastructure
      - dograh-setup
      - dograh-selfhost-guides
      - barbarez-three-lanes
      - langfuse
      - langfuse-voice-call-quality-optimization
      - voice-call-observability-audit
---

# Dograh dual instance (Cloud + self-host) + Langfuse

## 1) Dograh instances (Activi)

| Rolle | URL | Hermes MCP | Tool-Prefix | Env-Key |
|-------|-----|------------|-------------|---------|
| **Cloud** | app / api.dograh.com | `dograh` | `mcp__dograh__*` | `MCP_DOGRAH_API_KEY` (Bearer) |
| **Self-Host** | **https://voiceeu.activi.io** | `dograh-voiceeu` | `mcp__dograh_voiceeu__*` | `MCP_DOGRAH_VOICEEU_API_KEY` (**X-API-Key**) |

**Regel:** Es gibt **zwei getrennte Dograh-Welten**. Cloud-MCP sieht keine voiceeu-Workflows/ARI/Logs und umgekehrt.

### Pitfall: Handoff-IDs ≠ Instanz-IDs (KRITISCH)
Cloud-Handoffs (#8783 DE, #8184 BiH, #8829 Marge) sind **andere Nummern** als voiceeu (oft 3–10).  
Nie Handoff-ID als SoT auf der anderen Welt. Immer `list_workflows` live.  
Lokal `de/workflow/8783_*.ts` = Cloud-Export, nicht automatisch voiceeu-Live.  
Details: `references/handoff-id-mismatch.md`.

### Wann welche Dograh-MCP?

| User / Aufgabe sagt … | MCP aufrufen |
|------------------------|--------------|
| voiceeu, Self-Host, DograhEUV2, ARI GonoPBX, „unsere Instanz“ | **`dograh-voiceeu`** |
| app.dograh.com, Cloud, „hosted Dograh“ | **`dograh`** |
| unklar | **nachfragen** — Default Barbarez = **voiceeu** |

Nie Cloud-IDs mit voiceeu-Tools mischen.


## Profile barbares — voiceeu-only + BS-only (2026-07-28)

Barbarez working language/product: **Bosnian workflows on voiceeu**.  
Prompt/opening/human/pacing: **`dograh-voice-agent-craft`** (class umbrella + references/).  
Narrow siblings (user-owned): opening-greeting, human-conversation, telesales-pacing, bosnian-voice-prompts — adopt to curator-merge later.  
DE Cloud out of scope until user re-enables. Machine talk → craft skill first, not TTS/codec swap.

## Profile barbares — voiceeu-only (ab 2026-07-28)

Im Profil **barbares** sind vorerst **deaktiviert** (`enabled: false`):
- MCP `dograh` (Cloud)
- MCP `langfuse-dograh-cloud`

**Aktiv:** `dograh-voiceeu`, `langfuse-voiceeu`, `langfuse-docs` (und composio falls gesetzt).

Barbarez soll Cloud-Tools **nicht** aufrufen, bis der User Cloud wieder freigibt.  
`hermes mcp test dograh` kann trotz disabled grün sein — **`mcp list` mit ✗ disabled** ist maßgeblich.

SOUL/AGENTS **v1.3** + `barbarez-three-lanes`. Start:  
`cd ~/Code/Tools/dograh-aquaphor-telesales && hermes -p barbares` (neue Session).  
Handoff: `START_BARBAREZ.md`, `TOOLS.md`, `SKILLS.md`.

## 2) Langfuse (Observability) — ebenfalls dual geroutet

Langfuse speichert **Call-Traces/Scores**. Das ist **nicht** der Dograh-Workflow-MCP.

| Rolle | Wann nutzen | Hermes MCP | Auth-Env |
|-------|-------------|------------|----------|
| **Langfuse ↔ Dograh Cloud** | Traces/Scores zu **Cloud**-Calls | `langfuse-dograh-cloud` → `mcp__langfuse_dograh_cloud__*` | `LANGFUSE_DOGRAH_CLOUD_MCP_AUTH` |
| **Langfuse ↔ voiceeu** | Traces/Scores zu **Self-Host**-Calls | `langfuse-voiceeu` → `mcp__langfuse_voiceeu__*` | `LANGFUSE_VOICEEU_MCP_AUTH` |
| **Langfuse Docs** | Wie Langfuse funktioniert | `langfuse-docs` | (public docs MCP) |

Host heute: `https://cloud.langfuse.com` (SaaS).  
Auth = HTTP Basic aus pk:sk (`Basic base64(pk:sk)`), in `.env` als `LANGFUSE_*_MCP_AUTH`.

**Wichtig:** Wenn beide Auth-Env **dieselben** Keys haben, ist es **ein** Langfuse-Projekt für beide Dograh-Welten — dann nach Trace-Metadaten/Workflow-ID/Umgebung filtern. Wenn du später **getrennte** Langfuse-Projekte hast: unterschiedliche Keys in  
`LANGFUSE_DOGRAH_CLOUD_MCP_AUTH` vs `LANGFUSE_VOICEEU_MCP_AUTH` setzen.

### Wann welche Langfuse-MCP?

| Kontext | Langfuse-MCP |
|---------|----------------|
| User arbeitet an **voiceeu** / Self-Host-Calls | **`langfuse-voiceeu`** |
| User arbeitet an **Cloud**-Dograh-Calls | **`langfuse-dograh-cloud`** |
| Doku / „wie score ich“ | **`langfuse-docs`** + Skill `langfuse` (einzeln; kein `-official`) |

### Skills (Langfuse + Sim-Verbesserung)

| Skill | Nutzen |
|-------|--------|
| `langfuse` | CLI/API + Docs; global `langfuse` CLI; dual routing |
| `dograh-mcp-workflow-ops` | Large WF + post-call QA→Langfuse score relay v2 |
| `langfuse-voice-call-quality-optimization` | Wärme, Opening, Naturalness aus Evidence |
| `voice-call-observability-audit` | Dograh↔Langfuse QA-Pfad (älterer 4-score Contract ggf. parallel) |
| `dograh-voice-workflow-optimizer-v2` | Sim/Trace → ein Fix |
| Projekt-Scripts `simulate_dialogues*.py` | Virtuelle Kunden **ohne** Langfuse |

Loop: Persona/Sim oder Live-Call → (Langfuse lesen wenn Traces da) → eine Rubrik → MCP **passende Dograh-Instanz** Draft.

CLI (DograhEU): `langfuse --env ~/.hermes/.env api traces list --limit 10`. Score-Contract v2: `dograh-mcp-workflow-ops` → `references/langfuse-qa-score-relay-v2.md` (score-config/queue/dataset bootstrap; skip Prompt Mgmt + live Evaluators). Pointer: `references/langfuse-cli-and-score-v2.md`.


### Activi Langfuse projects (live, verified 2026-07-28)
| Route | Env prefix | Project on cloud.langfuse.com | Notes |
|-------|------------|-------------------------------|-------|
| voiceeu | `LANGFUSE_VOICEEU_*` + `LANGFUSE_VOICEEU_MCP_AUTH` | **DograhEU** | barbares primary; MCP `langfuse-voiceeu` |
| cloud | `LANGFUSE_CLOUD_*` + `LANGFUSE_DOGRAH_CLOUD_MCP_AUTH` | **Hermes LocalM5** | MCP `langfuse-dograh-cloud` (disabled on barbares) |

Details: `references/langfuse-dual-projects.md`, `references/selfhost-x-api-key.md`.  
Keys in chat → rotate after `.env` wiring.

## 3) Dograh MCP auth (OSS self-host)

Create key at `https://voiceeu.activi.io/api-keys` → paste into `~/.hermes/.env` **and** `profiles/barbares/.env` as `MCP_DOGRAH_VOICEEU_API_KEY=…` (never chat).

```yaml
# ~/.hermes/config.yaml
dograh-voiceeu:
  url: https://voiceeu.activi.io/api/v1/mcp/
  headers:
    X-API-Key: ${MCP_DOGRAH_VOICEEU_API_KEY}
  enabled: true
```

| Header | Self-host OSS |
|--------|----------------|
| `X-API-Key: dgr_…` | OK (REST + tools) |
| `Authorization: Bearer dgr_…` | **401** on tools/REST; `initialize` / `hermes mcp test` may still look green |

After yaml/env change: **reload MCP or new session**. Headers do not hot-reload reliably.

Verify:

```bash
hermes mcp test dograh-voiceeu   # expect X-API-Key + 16 tools
```

## Explain dual-MCP to user (preference)

Plain DE, short tables. Metaphor: **zwei Fernbedienungen** (Cloud vs eigener Server). Avoid long YAML walls until they ask. Key file: `~/.hermes/.env`; UI key page: `/api-keys` on **that** host.

## OSS DB: users / superuser / orgs / telephony / org transfer (voiceeu)

Live Postgres on **DograhEUV2** only (`dograh-postgres-1`), not via MCP.

| Need | Action |
|------|--------|
| List users | `users` + `organization_users` |
| Admin on OSS | `users.is_superuser=true` — **no** Stack team permission |
| Multi-org access | rows in `organization_users`; active = `selected_organization_id` |
| Telephony | **org-scoped** configs/phones; max **one** default outbound per org |
| Provider/BYOK/Langfuse | `organization_configurations` (not only `user_configurations`) |
| Workflows → other account | **COPY** folders+workflows+definitions (new UUIDs); prefer not MOVE |
| „Keys/endpoints gesetzt?“ | parity SQL: lengths + equality; never dump full secrets |
| Passwords | bcrypt only; plaintext never stored |

Full runbook + SQL: `references/voiceeu-oss-db-users.md`.

**Pitfalls**
- Stack-Team-Permission on voiceeu → plain-DE table OSS vs Stack; set `is_superuser`.
- No separate admin role column.
- Second telephony on same org: `is_default_outbound=false` or unique index fails.
- Never copy foreign `inbound_workflow_id` across orgs.
- VoiceEU ARI = Org-2 `dograh_eu`; Org-3 `GOno PBX ARI EU`/`dograh`/8000 is separate.
- After provider copy, source can **drift** (TTS voice/lang) — re-`md5` / re-sync before claiming equal.
- Def-count can grow on source after WF copy while WF-count still matches — report both.
- SSH multi-line heredoc into `docker exec psql` often **no-ops** (exit 0). Prefer `/tmp/*.sql` + `docker exec -i … < file` or one `-c` per statement; always SELECT-verify.
- `credentials` is `json` → cast `::jsonb` for `?` operator.

## ARI ring / no audio (split hosts)

| Host | Role |
|------|------|
| DograhEUV2 (app) `167.233.126.212` | Docker API/UI/Postgres — no Asterisk CLI |
| GonoPBX (PBX) `178.105.223.175` | Real Asterisk (often container) |

Browser OK + phone rings + silence → media path, not prompts/BYOK.

Media: `chan_websocket` externalMedia → `…/api/v1/telephony/ws/ari`, codec **ulaw**. Not browser TURN.

**Never** `apt install asterisk` when phones already ring (`command not found` on host ≠ no PBX). Apt prompt → **`n`**.

PBX: discover via `docker ps` / `ps` → `docker exec … asterisk -rx "module show like chan_websocket"` (+ `res_websocket_client`, `res_ari`).

Self-host media URI should target **voiceeu** (or that deploy’s API), not cloud, unless intentional.

Full runbook: `voice-ai-infrastructure` → `references/dograh-ari-ring-no-audio.md`.

## Upstream inventory (quick)

- No sales workflow JSON seeds in Git; templates = DB/UI + NL create API; fixtures/examples/Helm only.
- Voice-prompt topics via MCP `get_voice_prompting_guide`.
- New model provider brand = code fork (`registry.py` + factory); BYOK covers built-ins.
- `AGENTS.md` chain = coding-agent docs, not runtime telephony.
- **voiceeu images:** API **`dograhv2-api:dg-eu`** (Deepgram EU live); UI still Hub `1.43.0`. Rollback dir **`/root/dograh/dograh/rollback/`** (`./rollback-api-to-pre-dg-eu.sh`, `verify-current.sh`; git `deploy/voiceeu/rollback/`). `update_remote.sh` = dograh-hq only. No-buildx ship: `dograh-upstream-platform` → `references/voiceeu-prebuilt-deploy-fork.md`.
- Org TTS/STT = PUT `/user/configurations/user` (X-API-Key), not WF draft. Ghost STT ≠ Vesna/`speed`.
- **DG call host check (fastest):** `docker logs -f dograh-api-1 | grep -iE 'deepgram|api\.eu\.deepgram|/v1/listen'` then trigger call — EU listen vs US `/v1/projects` only.

## Companion skills

- **`dograh-voice-agent-craft`** — prompts, pacing, opening, human talk, guide usage, ulaw (prefer this for craft)
- `dograh-setup` + `doctor.sh` on **app** host compose dir.
- `dograh-selfhost-guides` offline docs (user-owned → `hermes curator adopt …` if curator must patch).
- `barbarez-three-lanes` — Barbarez A/B/C on voiceeu (user-owned → adopt to patch).
- `hermes-mcp-http` → `references/dograh-mcp-setup.md` for dual URL + X-API-Key.
- `hermes-profile-soul-agents` when wiring SOUL/AGENTS for builder profiles.

## Profile note (barbares)

- config: `dograh` + `dograh-voiceeu` + `langfuse-voiceeu` + `langfuse-dograh-cloud` + `langfuse-docs`; default work = **voiceeu**.
- Env (default + barbares): `MCP_DOGRAH_*`, `LANGFUSE_*_MCP_AUTH`, `LANGFUSE_PUBLIC/SECRET/BASE_URL`.
- Start Builder: `cd ~/Code/Tools/dograh-aquaphor-telesales && hermes -p barbares` (new session → SOUL).
- Orchestrierung: `barbarez-three-lanes` (A Infra / B Graph / C Prompt+Sim+LF).

## Plain-DE (user preference)

Short tables + Fernbedienung-Metaphor. No long YAML until asked. Explain dual-MCP and “Builder starten” simply first.

## Sales-strong stack (after dual routing is clear)

When user asks how to make the telesales script sell hard (KB, tools, memory, closings):
→ `references/sales-stack-voiceeu.md`

Live inventory on **dograh-voiceeu** first: `list_workflows` + `list_tools` + `list_documents`.
Empty tools/KB is common on self-host — not a bug; next lever after prompt P1–P3.
Phone “memory” = workflow vars + globalNode state rules (not Hermes MEMORY.md).
Handoff may still cite Cloud-era IDs (e.g. 8783) while voiceeu has different ids — live list wins.

## References

- `references/mcp-matrix-activi.md` — MCP name → URL → header → when
- `references/langfuse-dual-routing.md` — LF MCP + Basic auth + pairing
- `references/langfuse-dual-projects.md` — DograhEU vs Hermes LocalM5 + env layout
- `references/langfuse-cli-and-score-v2.md` — CLI install, single skill, QA score relay v2 pointer
- `references/selfhost-x-api-key.md` — OSS X-API-Key vs Bearer 401 ladder
- `references/mcp-x-api-key-401.md` — test green + tool 401 ladder
- `references/ari-split-hosts.md` — DograhEUV2 vs GonoPBX
- `references/voiceeu-oss-db-users.md` — Postgres users, superuser, multi-org, telephony/provider/workflow COPY, parity checks, SSH/psql pitfalls
- `references/builder-start-plain-de.md` — plain-DE „Builder starten“
- `references/sales-stack-voiceeu.md` — verkaufsstark: guide topics, KB/tools empty, memory kinds, sim loop
- `references/handoff-id-mismatch.md` — Cloud handoff IDs vs voiceeu live list

## Do not

- Cross-use Cloud/self-host API keys
- Diagnose ARI silence as WebRTC codec first
- Install Ubuntu asterisk beside working PBX
- Claim session tools work after config change without MCP reload
- Tell user upstream monorepo AGENTS.md files are “8 agents to deploy”
- Lead with long YAML when user asked for simple explanation of dual-MCP or builder start
- Call disabled Cloud MCPs from barbares while voiceeu-only is in force
- Treat handoff workflow IDs as SoT without voiceeu `list_workflows`
- Confuse Hermes builder memory with on-call agent memory
- Fix “robot conversation” by swapping TTS before globalNode emotion + ban-list + startCall
- Assume empty `list_tools`/`list_documents` on voiceeu means MCP broken
- Assume a-law/Opus/G.729 replace **ulaw** on Dograh ARI externalMedia
- Pass both `stage` and `topic` to `get_voice_prompting_guide` (API rejects)
- Treat LangGraph “strong vs weak prompt repos” as Dograh product rule
- Expect Stack Auth / team-admin on voiceeu OSS — use `is_superuser` + `organization_users`
- Promise plaintext passwords from Postgres (only bcrypt hashes)
- Use ssh multi-line heredoc into `docker exec psql` without verifying row counts
- Claim Org1 provider parity without re-checking `md5(value)` after source org edits
- Copy `inbound_workflow_id` or force two `is_default_outbound=true` on one org
- MOVE workflows from ds@ by default — COPY unless user wants source emptied

