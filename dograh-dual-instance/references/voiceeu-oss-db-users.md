# voiceeu OSS — Postgres users, orgs, telephony, org transfer (live ops)

Host: **DograhEUV2** `root@167.233.126.212`, key `~/.ssh/dograh_vps`.  
Domain: https://voiceeu.activi.io  
Compose: `/root/dograh/dograh/` · Postgres container: `dograh-postgres-1` (DB/user `postgres`).

## Auth model (OSS)

- Users are **email + bcrypt `password_hash`** (`provider_id` like `oss_…`).
- **No Stack Auth** on this deploy (`.env` has `OSS_JWT_SECRET`, no `STACK_*`).  
  „Stack-Team-Permission = admin“ **existiert hier nicht** → Admin = `users.is_superuser = true`.
- Klartext-Passwörter **nie** in DB; nur `$2b$…` Hash. Reset = neuer Hash schreiben oder UI Signup/Login-Flow.
- Plain DE: zwei Auth-Welten (Cloud Stack-Teams vs Self-Host OSS-Flag). Kurz + Tabelle; kein YAML-Wall.

## Schema (relevant)

| Table | Zweck |
|-------|--------|
| `users` | `email`, `password_hash`, `is_superuser`, `selected_organization_id`, `provider_id` |
| `organization_users` | M2M `(user_id, organization_id)` — PK, `ON CONFLICT DO NOTHING` |
| `organizations` | Tenant; `provider_id` `org_oss_…` |
| `telephony_configurations` | **org-scoped** ARI/etc.; unique `(organization_id, name)`; **max one** `is_default_outbound=true` per org |
| `telephony_phone_numbers` | **org-scoped** unique `(organization_id, address_normalized)` |
| `organization_configurations` | KEY/VALUE JSON (`MODEL_CONFIGURATION_V2`, `LANGFUSE_CREDENTIALS`, `ORGANIZATION_PREFERENCES`) |
| `user_configurations` | per-user (`MODEL_CONFIGURATION`, `ONBOARDING`) — not the BYOK org pipeline |
| `folders` | org-scoped unique `(organization_id, name)` |
| `workflows` | `organization_id`, `user_id`, `workflow_uuid` unique, `released_definition_id`, JSON snapshot cols |
| `workflow_definitions` | versions; `is_current`; circular FK with `workflows.released_definition_id` |

Keine separate admin/superadmin-Rolle außer `is_superuser`.

## Live inventory (verified 2026-07-29)

| User | email | notes |
|------|-------|--------|
| 1 | activi@activi.io | operator; superuser + multi-org after ops |
| 2 | ds@activi.io | Org 2 — primary VoiceEU content (workflows/BYOK) |
| 3 | arman@activi.io | Org 3 — Gono PBX ARI sample |

ARI apps (do not mix without intent):

| Org | tel name | app_name | phone | role |
|-----|----------|----------|-------|------|
| 2 / 1 copy | dograh_eu | dograh_eu | +493…5900 PSTN | VoiceEU default outbound |
| 3 / 1 copy | GOno PBX ARI EU | dograh | SIP 8000 | second ARI app |

## Read users

```bash
ssh -i ~/.ssh/dograh_vps -o IdentitiesOnly=yes -o BatchMode=yes root@167.233.126.212 \
  "docker exec dograh-postgres-1 psql -U postgres -d postgres -c \"
SELECT id, email, is_superuser, selected_organization_id,
       CASE WHEN password_hash IS NULL THEN 'no' ELSE 'bcrypt' END AS pwd
FROM users ORDER BY id;\""
```

## Promote superuser + multi-org

```bash
docker exec dograh-postgres-1 psql -U postgres -d postgres -c \
  "UPDATE users SET is_superuser=true, selected_organization_id=1
   WHERE id=1 AND email='activi@activi.io';"

docker exec dograh-postgres-1 psql -U postgres -d postgres -c \
  "INSERT INTO organization_users (user_id, organization_id) VALUES (1,2) ON CONFLICT DO NOTHING;
   INSERT INTO organization_users (user_id, organization_id) VALUES (1,3) ON CONFLICT DO NOTHING;"
```

`selected_organization_id` = active session org. Multi-membership ≠ auto-switch — re-login / UI context after changes.

## Telephony mirror

Telephony is **org-scoped**, not user-scoped. Membership on org 2/3 unlocks those configs when selected_org switches.  
For **home org 1**, mirror configs:

1. **Default outbound** = Org2 `dograh_eu` (`is_default_outbound=true`).
2. **Second ARI** = Org3 `GOno PBX ARI EU` with `is_default_outbound=false` (unique partial index on default).
3. Phones: copy address/label; **`inbound_workflow_id` always NULL** on cross-org copy (FK points at foreign workflow). Map inbound later to an Org1 workflow id if needed.

Credentials JSON keys (all required for ARI): `ari_endpoint`, `app_name`, `app_password`, `ws_client_name`.

## Provider settings (org configs)

Source of truth for BYOK on voiceeu content org = **Org2** keys:

| key | fields to verify |
|-----|------------------|
| `MODEL_CONFIGURATION_V2` | `mode=byok`; pipeline llm/tts/stt provider + endpoint/region + `api_key[0]` lengths |
| `LANGFUSE_CREDENTIALS` | `host`, `public_key`, `secret_key` lengths |
| `ORGANIZATION_PREFERENCES` | e.g. `test_phone_number` |

Upsert:

```sql
INSERT INTO organization_configurations (organization_id, key, value, created_at, updated_at, last_validated_at)
SELECT 1, key, value, NOW(), NOW(), last_validated_at
FROM organization_configurations WHERE organization_id = 2
ON CONFLICT ON CONSTRAINT _organization_key_uc DO UPDATE
SET value = EXCLUDED.value, updated_at = NOW(), last_validated_at = EXCLUDED.last_validated_at;
```

**Drift pitfall:** source org keeps changing (TTS voice/lang etc.). After any copy, re-check `md5(value::text)` Org1 vs Org2; re-`UPDATE` if unequal. Keys can still be “set” while voice/language drifted.

## Workflow transfer (COPY, not MOVE)

Prefer **copy** Org2 → Org1/user1 so production on ds@ stays intact. Move only if user explicitly wants ownership removed from source.

Order (circular FK):

1. Copy `folders` (ON CONFLICT name keep).
2. Insert each `workflows` row with **new** `workflow_uuid` (`gen_random_uuid()::text`), `user_id=1`, `organization_id=1`, `released_definition_id=NULL`, mapped `folder_id`.
3. Copy all `workflow_definitions` for that workflow → new ids; keep `is_current` / version_number / JSON snapshots.
4. Map old `released_definition_id` → new def id; `UPDATE workflows` set released + `workflow_definition` from released JSON.
5. Guard: if Org1 already has workflows for user1, skip bulk copy (avoid duplicates) unless user asks force.

Do **not** copy by default: `workflow_runs`, campaigns, embed_tokens, agent_triggers (run history / side effects).

## Parity verify (keys + endpoints without dumping secrets)

```sql
-- counts
SELECT organization_id,
  (SELECT count(*) FROM telephony_configurations t WHERE t.organization_id=o.id) AS tel,
  (SELECT count(*) FROM organization_configurations c WHERE c.organization_id=o.id) AS cfg,
  (SELECT count(*) FROM workflows w WHERE w.organization_id=o.id) AS wf,
  (SELECT count(*) FROM workflow_definitions d JOIN workflows w ON w.id=d.workflow_id WHERE w.organization_id=o.id) AS defs
FROM organizations o ORDER BY 1;

-- telephony fields present
SELECT organization_id, name, is_default_outbound,
  length(credentials->>'app_password') AS pw_len,
  credentials->>'ari_endpoint' AS endpoint,
  credentials->>'app_name' AS app
FROM telephony_configurations WHERE organization_id IN (1,2,3) ORDER BY 1,2;

-- equality (true/false)
SELECT 'MODEL_V2' AS k,
  (SELECT value::text FROM organization_configurations WHERE organization_id=1 AND key='MODEL_CONFIGURATION_V2')
  = (SELECT value::text FROM organization_configurations WHERE organization_id=2 AND key='MODEL_CONFIGURATION_V2') AS eq
UNION ALL SELECT 'LANGFUSE',
  (SELECT value::text FROM organization_configurations WHERE organization_id=1 AND key='LANGFUSE_CREDENTIALS')
  = (SELECT value::text FROM organization_configurations WHERE organization_id=2 AND key='LANGFUSE_CREDENTIALS')
UNION ALL SELECT 'tel dograh_eu',
  (SELECT credentials::text FROM telephony_configurations WHERE organization_id=1 AND name='dograh_eu')
  = (SELECT credentials::text FROM telephony_configurations WHERE organization_id=2 AND name='dograh_eu');

-- MODEL detail (lengths only)
SELECT organization_id,
  value#>>'{byok,pipeline,llm,endpoint}' AS llm_ep,
  length(coalesce(value#>>'{byok,pipeline,llm,api_key,0}','')) AS llm_k,
  value#>>'{byok,pipeline,tts,voice}' AS tts_v,
  length(coalesce(value#>>'{byok,pipeline,tts,api_key,0}','')) AS tts_k,
  length(coalesce(value#>>'{byok,pipeline,stt,api_key,0}','')) AS stt_k,
  md5(value::text) AS md5
FROM organization_configurations
WHERE key='MODEL_CONFIGURATION_V2' AND organization_id IN (1,2);

-- every org1 workflow released + exactly one current def
SELECT NOT EXISTS (
  SELECT 1 FROM workflows WHERE organization_id=1 AND released_definition_id IS NULL
) AS all_released,
NOT EXISTS (
  SELECT 1 FROM workflows w WHERE w.organization_id=1
    AND (SELECT count(*) FROM workflow_definitions d WHERE d.workflow_id=w.id AND d.is_current) <> 1
) AS one_current_each;
```

Answer shape for user „sind keys/endpoints gesetzt?“: short table Status OK/GAP + lengths/equality, **no full secrets**.

Note: def **counts** can drift (source org publishes new versions after copy) while workflow **counts** still match — report both.

## Pitfall: SSH + SQL

- **Broken:** multi-line bash-heredoc through `ssh … docker exec … psql <<EOF` — often exit 0 with **zero** statements applied.
- **Works:**
  1. `ssh … 'cat > /tmp/x.sql <<EOF … EOF'` then `docker exec -i dograh-postgres-1 psql -U postgres -d postgres -v ON_ERROR_STOP=1 < /tmp/x.sql`
  2. Or one `psql -c "…"` per statement over ssh.
- `credentials` column type is `json` not `jsonb` → use `credentials::jsonb ? 'app_password'` or `credentials->>'…'`.
- Always verify with `SELECT` counts after writes.

## Secrets policy

ARI passwords + BYOK keys are **plaintext inside JSON columns**. Chat/reports: lengths + prefixes only. Superuser only for known operator mails.

## Related

- Host split: `references/ari-split-hosts.md`
- MCP auth OSS: `references/selfhost-x-api-key.md`
- Preflight (Mac): `~/Documents/Dograh Selfhosted Voccieeu/scripts/voiceeu_remote_preflight.sh`  
  (dograh=`root@167.233.126.212`, pbx=`root@178.105.223.175`)
