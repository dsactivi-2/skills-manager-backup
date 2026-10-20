# Filter

| field | ops | Alltag |
|---|---|---|
| trade | all / any | all = Ausbildung UND Job. any = eins reicht |
| trained_as | has | nur Ausbildung |
| worked_as | has | nur Jobtext + optional min_years |
| job_title | contains | Freitext-Job |
| occupation | in | nur gemapptes Kürzel |
| age | between | 21–40 |
| country | in | BA RS HR |
| city | contains | Tuzla |
| has_license | eq | Führerschein |
| license_category | in | B CE |
| language | has | {code, min_level} |
