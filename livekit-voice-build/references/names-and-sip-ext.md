# LiveKit names + FreePBX/TG (verified 2026-08-24)

## Three name layers — never mix in chat

| Layer | Example | Meaning |
|---|---|---|
| File / comment | `agent_soniox.py` docstring „v1_soniox“ | local module |
| Dispatch `agent_name=` | `amina`, `amina-soniox`, `amina-soniox-v2`, `template-v1` | LiveKit job name |
| Template product | **Template V1** | clone kit, not a live worker |

Live Cloud: only **`amina-soniox-v2`**. Dockerfile CMD is that module `start`. Mac Desktop `.command` = same code, no container.

Do not call `agent_soniox.py` „v1“ when the user asks which agent is live. Quote `agent_name=` from the file.

## SIP: LiveKit auth ≠ TG register

PJSIP `max_contacts=1` + `remove_existing=true`. Two clients on one ext kick each other.

| Role | Ext (this LAN) | Password |
|---|---|---|
| TG400 register (GSM) | **330** Avail — Yeastar `192.168.31.150` | **Kennwort of that ext** (GUI). Not ARI, not WS, not SSH |
| LiveKit outbound digest | **320** (red/unregistered until a call) | 320 secret; Cloud trunk `ST_oKoQmwh9o75X` |
| Guarddograh / old TG | 310 / 300 | do not reuse for LiveKit |

Yeastar Register: User+Auth = ext number, Password = **that ext Kennwort**. ARI `dograh`/`guarddograh` is HTTP :8088 only.

Outbound GSM: dialplan `_387.` / `_+387.` / `_067.` → `Dial(PJSIP/${EXTEN}@330)`. CID SIM **`+387671048463`** (user-corrected; older `…4865` stale).

Address for LiveKit trunk: `ari.activi.io`, Transport **UDP** (PBX only `:5060` UDP). Placeholder `192.0.2.0` is not a host.

Observability: Settings → **Observability** (not Development token server). Session recording is inside Agent observability. PII redaction EN-only — leave off for bs.

## Do not

- Register TG as the same ext LiveKit authenticates as
- Create a second Cloud trunk when `freepbx-tg400-ba` exists
- Put ARI/WS/server password into Yeastar
- Invent +387 — user/SIM only
