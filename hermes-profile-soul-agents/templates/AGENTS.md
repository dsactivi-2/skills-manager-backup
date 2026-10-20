# AGENTS.md — <profile-display> / <project-slug>

Kurz, verhaltenswirksam. Kein Changelog. Session-Details → `handoff_*/`.

## Role
…

## Project root
`/absolute/path`

Multi-track (if any):
| Spur | Inhalt |
|------|--------|
| … | … |

Session-Start: neueste `handoff_*/SESSION_RESUME.md` → HANDOFF → NEXT_ACTIONS → live check.

## Source of truth (Muster)
| Was | Regel |
|-----|--------|
| Produktion | Published live = ARBEITSOBJEKT im aktuellen Handoff; MCP-live prüfen |
| Geschützte Basis | Handoff-markiert — nie ändern |
| Wegwerf-Test | Expliziter Test-Workflow |
| Lokal `*.ts` / prompts | Arbeitsstand/Doku |
| Locale/UI-only settings | Nicht im Code-Pfad annehmen |

IDs/Namen: `handoff_*/INDEX.md` + live get — **nicht aus Gedächtnis**.

## Hard rules
1. Live-Verify first
2. Plattform-MCP first (nie Browser-Login wenn MCP existiert)
3. Nicht-destruktiv / Dry-Run
4. Keine eigenmächtigen Prod-Writes
5. Verify-before-claim
6. Blocker ehrlich
7. Deutsch, direkt, knapp
8. Publish nur User

## Standard change loop
1. Belegen
2. Skills + platform prompt guides laden
3. Live-Code holen (Truncation → RPC-on-disk pattern)
4. Lokal bauen + verify scripts
5. Freigabe
6. Draft save → live check
7. Sim/test mit env placeholder für ID
8. Report; User published

## Open work
Immer `handoff_*/NEXT_ACTIONS.md` — hier nicht kopieren.

## Skills
- `…` — wann laden
Pitfall: skills may live under `~/.hermes/skills` (default).

## Ops pitfalls
- …

## Approval matrix
| Aktion | Ohne Freigabe? |
|--------|----------------|
| Lesen / Sim / lokaler Entwurf | Ja |
| Draft save Prod-Arbeitsobjekt | Nein |
| Publish | Nur User |
| Geschützte Basis | Nie |

## Latency & quality bar
(if voice/sales) …

## Model / session hygiene
Auth außerhalb Session; kein Mid-session model switch ohne Handoff.

## Proactivity
| Phase | Verhalten |
|-------|-----------|
| Plan/Build | Risiken aktiv |
| Test/Opt | Hoch |
| Stable | Niedrig |
| Critical | Sofort |
