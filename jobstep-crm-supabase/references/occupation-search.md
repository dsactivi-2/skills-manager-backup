# Jobstep CRM — Berufe zählen

Eine Spalte reicht nicht. `kri_pozicija` allein (Elektriker) war ~3.8k; plus Ausbildung/Smjer ~17k eindeutige `kandidat_id`.

## Felder (live)

| Quelle | Spalten |
| --- | --- |
| Berufserfahrung | `idk_kandidat_radno_iskustvo.kri_pozicija`, `_de`, `_en` |
| Ausbildung Text | `idk_kandidat_edukacija.ke_naziv_kvalifikacije`, `_de`, `ke_naziv` |
| Schulrichtung | `ke_smjer_id` → `idk_skole_smjerovi.ss_naziv` / `_de` |
| PP-Position | `idk_kandidati.kandidat_pp_pozicija` (wenig gefüllt) |
| `struka_sa_prijave` | integer → `idk_struke`; fast leer, nicht Elektro-Katalog |

## Filter (mit User abstimmen)

Raus typisch: Autoelektričar, Inženjer/Bachelor/Diplomirani, Elektro-Schweißer.  
Kein `unaccent()` auf dem Projekt — `č/c` in Regex (`elektri[cč]ar`).

## Zählregel

`count(distinct kandidat_id)`. Summe der Berufsgruppen > Unique (eine Person, mehrere Titel). DIPL `idk_nd_kandidata` extra, nicht mit CRM mischen.
