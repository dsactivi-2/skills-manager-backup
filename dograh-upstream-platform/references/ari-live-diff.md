# ARI: dograh-hq vs dsactivi-2/dograhV2 (live git)

Vergleich **immer** gegen die zwei Remotes, nicht gegen Memory/Doku:

- Original: `https://github.com/dograh-hq/dograh` `origin/main`
- Fork (Activi): `https://github.com/dsactivi-2/dograhV2` `HEAD`

```bash
git fetch <orig> main && git fetch <fork>
# extract listed files from each SHA, sha256, then unified_diff
```

Kern-Dateien: `ari_manager.py`, `providers/ari/{__init__,config,provider,serializers,strategies,transport}.py`, `external_pbx/*`, `ws_auth.py`.

## Stand 2026-08-14 (live)

| | SHA | Datum |
|--|-----|-------|
| dograh-hq origin/main | `66ab884` | 2026-08-14 |
| dograhV2 HEAD | `ac7c0a3` | 2026-08-04 |

Fork ist **älter**, nicht „anders designed“. Audio-Pfad identisch.

| Datei | Status |
|--|--|
| transport.py, serializers.py, `__init__.py` (8 kHz), strategies.py, ws_auth.py, audio_config.py | bytegleich |
| ari_manager.py | Original größer: Auto-Deactivate, Failure-Klassifikation, nur *aktive* Configs, `ws_client_name` fehlt → park |
| provider.py | Original: `default_from_number`, `validate_phone_number` |
| external_pbx/vicidial.py | Original: gezielte Header + `format=text` |
| test_ari_deactivation.py | nur Original |

`mint_ws_token` in **beiden** `ari_manager.py`. `TELEPHONY_WS_TOKEN_ENFORCE` ohne Secret → Stille (kein Codec-Thema).

## Punkt-Protokoll (User 2026-08-14)

Arbeitsordner: `/Users/activi/Downloads/dograhV2-ari-fixes/` (`NOTIZEN.md`, `BERICHT.md`, `SCHUBLADEN-IMPACT.md`).

| # | Funktion | Entscheidung |
|--|--|--|
| 1 | ARI-Verbindung halten (`async with`, 30 s, Backoff) | wie Original; **Code in Arbeitskopie** |
| 2 | Kaputte Config parken (5× / 1 h → inactive) | wie Original; notiert |
| 3 | kein `ws_client_name` → park | wie Original; notiert |
| 4 | nur `list_active_…` | wie Original; notiert |
| 5 | `redact_failure_message` auf Endpoint | wie Original; notiert |
| 6 | `default_from_number` in `provider.py` | wie Original; notiert |
| 7 | `validate_phone_number` immer ok | wie Original; notiert |
| 8 | kein extra `logger.error` vor Channel-Exception | wie Original; notiert |
| 9 | VICIdial-Header parallel + `lead_fields` | wie Original; notiert (ohne VICIdial kein Runtime-Effekt) |
| 10 | VICIdial `update_lead` + `format=text` | wie Original; notiert |
| 11 | Tests deactivation + external_pbx | wie Original; notiert |

Nicht ins Fork-Git ohne Freigabe. Punkt 1 nicht mit 2–11 vermischen beim Bauen.

## Schubladen — nie ganze Dateien vom Original über den Fork legen

Punkte 2/3/4/5/11 brauchen Infrastruktur, die dograhV2 **nicht** hat. Live 2026-08-14:

| Original braucht | Fork |
|--|--|
| `telephony_configurations.inactive` + `inactive_since` + `inactive_reason` | fehlen |
| Alembic `c7a1e4f93b26` (parent `b41f7c9d2e05`) | Parent **nicht** in Fork-Kette |
| `list_active_…` / `set_…_inactive` / `set_…_active` | fehlen (nur `list_all_…`) |
| `api/errors/failure.py` | fehlt |
| UI Inactive-Badge + Reactivate-Client | fehlen |

**Nur `ari_manager.py` auf Original-Stand bringen → Crash** (Import/SQL/AttributeError).

Erlaubt ohne Extra-Modul: Punkte 1, 6, 7, 8, 9, 10.

Wenn Schubladen: **chirurgisch**, nicht 1:1-Copy.

| Stück | Impact | Lösung |
|--|--|--|
| `failure.py` neu | Import `pipecat.utils.run_context.get_current_org_id` im Fork ungesichert | Datei holen, Import weich (try/except) |
| Alembic Original-Datei | Parent-Revision fehlt → Kette bricht | Neue Fork-Migration, gleicher SQL, `down_revision` = Fork-Head |
| `models.py` | Fork hat 0 eigene Zeilen in der Klasse | Nur 3 Spalten einfügen |
| `telephony_configuration_client.py` | Fork-Lookups weichen ab | Nur die 3 Methoden adden, Rest lassen |
| `factory.py` / `organization.py` / UI | Original zieht SIP, MPS, generated Reactivate-Client | Nicht kopieren. Kleiner Reactivate-Endpoint; UI später oder nur Backend |

## Praxis

- Klang/Format: ulaw 8 kHz, gleich.
- Betrieb: Original parkt tote ARI-Configs; Fork reconnectet weiter und warnt nur bei fehlendem `ws_client_name` (Anruf ohne Ton möglich).
- VICIdial-only Diffs ignorieren, wenn VICIdial nicht im Stack — User kann trotzdem „wie Original“ notieren.
- Live-Container voiceeu nicht mit Git-HEAD gleichsetzen — Image-Pin extra prüfen.

## Dograh-Telefonie (Code, nicht Doku-Marketing)

`api/services/telephony/providers/__init__.py` registriert: `ari`, `cloudonix`, `plivo`, `telnyx`, `twilio`, `vobiz`, `vonage`.
Einziger Self-Host-PBX-Adapter: **Asterisk ARI**. CPaaS bricht Brief-K.o. (EU/self-host) als Dograh-Gegenstelle.
Kette: voiceeu --ARI/WS ulaw--> Asterisk --SIP--> TG400 --GSM--> Mobil.
Doku-Pfad: `docs/integrations/telephony/asterisk-ari.mdx` (Asterisk 20 LTS oder 22+, `chan_websocket` + `res_websocket_client`).
PBX-Ranking ohne Ist-System (Bias). Codex-Phasen: nach Phase 0 auf `bestätige` warten.
