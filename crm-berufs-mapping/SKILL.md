---
name: crm-berufs-mapping
version: 1.0.0
description: >
  Freitext-Berufsbezeichnungen aus dem CRM (kri_pozicija) mit Jev (TypeSafe)
  klassifizieren und einer geschlossenen Berufsliste zuordnen. Nutze diesen
  Skill wenn der Nutzer Berufs-Mapping, Berufsgruppen oder Jev-Klassifizierung
  anspricht. NICHT fuer Kandidatensuche - das ist crm-kandidatensuche.
---

# CRM-Berufs-Mapping (Jev / TypeSafe)

Klassifiziert 36.859 Unique Freitext-Berufe aus `idk_kandidat_radno_iskustvo.kri_pozicija`
in 194 Berufsgruppen. Ergebnis: `mapping_results.csv` (Auto ≥0,8) + `review_queue.csv` (<0,8).

## Arbeitspfad

`/Users/activi/handoff/handoff/job_mapping/`

## Dateien

| Datei | Zweck |
|---|---|
| `unique_values.csv` | Alle 36.859 Unique-Werte mit Häufigkeit (n) und Kandidaten-IDs |
| `berufsliste.yaml` | 194 Berufsgruppen mit Beschreibungen (kanonisch) |
| `classify_parallel.py` | Haupt-Script: ThreadPoolExecutor, 5 Threads, Schwelle ≥0,8 |
| `mapping_results.csv` | Auto-zugeordnet (≥0,8): val,n,berufsgruppe,confidence,prob_top |
| `review_queue.csv` | Zu prüfen (<0,8): val,n,vorschlag,confidence,prob_top |
| `checkpoint.csv` | Fortschritts-Tracker (alle verarbeiteten vals) |
| `phase4_v4.log` | Lauf-Log |

## Ablauf

### Phase 1: Export (abgeschlossen 2026-09-23)

SQL: `sql/07_berufs_mapping_export.sql` → `unique_values.csv`

### Phase 2: Berufsliste bauen (abgeschlossen 2026-09-23)

- 194 Gruppen in `berufsliste.yaml`
- User-Korrekturen eingebaut: Elektriker/Elektrotechniker getrennt, Fahrer aufgeteilt
  (lkw_fahrer/taxifahrer/kurier), solar_monteur aufgelöst → elektriker, etc.

### Phase 3: Testlauf (abgeschlossen 2026-09-23)

200 Stichproben, ~92% Auto-Rate im Test. Schwelle ≥0,8 festgelegt.

### Phase 4: Volllauf (läuft seit 2026-09-24 04:45)

```bash
cd /Users/activi/handoff/handoff/job_mapping/
TYPESAFE_API_KEY=$(grep '^TYPESAFE_API_KEY=' ~/.env.local | cut -d= -f2-) \
  venv/bin/python3.13 classify_parallel.py
```

- 5 Threads, ~830/Minute
- Checkpoint alle 100, Batch-Speicherung alle 500
- Wiederaufnahme: löscht nichts, liest `checkpoint.csv`, überspringt fertige

**Wichtig:** System-Python ist 3.9 (zu alt). Immer `venv/bin/python3.13` verwenden.

### Phase 5: Einspielen (geplant)

1. Review-Queue dem User zeigen → Korrekturen einbauen
2. `beruf_mapping.csv` final erstellen
3. SQL-Migration: neue Tabelle + Spalte in `idk_kandidat_radno_iskustvo`
4. Suchfunktion `crm_search_candidates` um Filter `occupation_groups` erweitern

## Regeln

1. **Niemals direkt in die DB schreiben.** Erst SQL-Datei im Repo (`sql/NN_*.sql`),
   dann Freigabe, dann Einspielen über db-query-agent.
2. **Keine Personendaten** in Mapping-Dateien. Nur `kandidat_id + berufserfahrung_text`.
3. **API-Key nie in Dateien committen.** Quelle: `~/.env.local`.
4. **Schwelle ≥0,8 = automatisch übernehmen.** Alles darunter → Review-Queue.
5. **Wiederaufnahme immer möglich** via `checkpoint.csv`.

## Typische Fehler

| Fehler | Ursache | Fix |
|---|---|---|
| `KeyError: 'val'` | Checkpoint ohne Header | `csv.reader` statt `DictReader` |
| Kein Fortschritt | TCP-Timeout | Prozess prüfen (`ps aux`), ggf. neu starten |
| Doppelte Einträge | Checkpoint-Bug (alt) | Fix in `classify_parallel.py` übernehmen |

## Jev-Beispiel

```python
from typesafe_sdk import Choice, TypeSafeClient

client = TypeSafeClient(api_key=os.environ["TYPESAFE_API_KEY"])
response = client.system_one(
    state="električar",
    questions={
        "beruf": Choice(
            instructions="Welche Berufsgruppe beschreibt diesen Eintrag am besten?",
            criteria={"elektriker": "Elektriker, Elektroinstallateur...", ...},
        )
    },
    model="jev-latest",
)
# → answer.choice, answer.confidence, answer.probabilities
```

## Update 2026-09-24: Bereinigung und Neustart

### Was wurde bereinigt?

Vor dem Neustart wurden Duplikate und Konflikte aus früheren Läufen bereinigt:

| Datei | Vorher | Nachher | Änderung |
|---|---|---|---|
| `mapping_results.csv` | 12.545 + Dups | 12.545 | Duplikate konsolidiert |
| `review_queue.csv` | 12.202 + Dups | 9.900 | Duplikate entfernt, Konflikte markiert |

**Konflikte (142):** Einträge mit verschiedenen Zuordnungen wurden markiert mit
`needs_human_review=true` in `review_queue.csv`. Diese werden nach Phase 4
beim menschlichen Review entschieden.

### Was wurde im Skript gefixt?

1. **Sofort-Speicherung:** Ergebnisse werden alle 100 Einträge gespeichert (nicht erst bei 500)
2. **Vollständiger Checkpoint:** Alle verarbeiteten Einträge (auch Review) werden im Checkpoint erfasst
3. **Clean-Dateien:** Skript verwendet jetzt `mapping_results_clean.csv` und `review_queue_clean.csv`

### Backup

Vor der Bereinigung wurde ein Backup erstellt:
`backup_20260924_0512/` mit allen Original-Dateien.

### Neustart

Phase 4 läuft mit 5 Threads, ~800/Minute, ETA ~18 Minuten.
Verifiziert: Keine Duplikate, keine Überlappung, sauberer Stand.

