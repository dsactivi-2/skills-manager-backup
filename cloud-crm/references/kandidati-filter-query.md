# Candidate database queries: guide for an MCP or LLM agent

Use this guide when answering questions about candidates by querying the database directly. Start with the meaning of the user's request, then choose tables and predicates. The existing CRM filter is a useful reference for terminology, but it has known bugs and should not be copied as a SQL template.

## First decide what the user means

Before writing SQL, identify:

1. **Population:** active candidates, archived candidates, or both? The CRM normally treats `kandidat_status = 3` as archived and excludes it from the regular list.
2. **Requested output:** unique candidates, a count, or related records such as languages or education? State the unit of the answer.
3. **Occupation:** recorded work-position text, a normalized work group, an academic profession, the application position, or simply any work experience? Use the corresponding field.
4. **Schooling source:** candidate education, the linked ND profile, or both? Keep school and direction on the same source record.
5. **Date:** registration (`kandidat_datetime`), birth (`kandidat_datumrodjenja`), or another event date? Do not substitute one for another.
6. **Unknown values:** should `NULL`, empty text, unmapped positions, and explicit values such as `BEZ ZNANJA` count as the same thing? Usually they do not.
7. **Match rule:** exact value, minimum language level, partial school name, or a combination? Ask for clarification when this changes the result materially.

If the user does not specify archive behavior, use non-archived candidates and say so. If the user asks for a count, count distinct candidate IDs and report the applied filters alongside the number.

## Database map

Verify the live database with `SHOW COLUMNS` or `DESCRIBE` because schema dumps may be stale. The new occupation mapping was introduced by `phase5_import_mysql.sql`. Query only the columns needed for the answer.

| Meaning | Table and relationship | Important fields |
| --- | --- | --- |
| Candidate identity and common filters | `idk_kandidati k`; one row per `kandidat_id` | `kandidat_status`, `kandidat_group`, `kandidat_status_prijave`, `kandidat_datetime`, `kandidat_datumrodjenja`, `kandidat_drzavljanstvo_vrsta`, `boravak_eu`, `kandidat_porijeklo`, `kandidat_vozacka_dozvola`, `kandidat_vozacka_kategorija`, `kandidat_dipl_id`, `kandidat_prijava_na`, `kandidat_iskustvo_u_struci` |
| Group label | `idk_kandidati_grupe g` on `k.kandidat_group = g.kg_id` | `kg_title`; filter by ID after resolving a name |
| Candidate status label | `idk_kandidat_status s` on `k.kandidat_status = s.status_id` | `status_naziv`; `3` means archived in the candidate list |
| Application status label | `idk_kandidat_status_prijave sp` on `k.kandidat_status_prijave = sp.status_id` | `status_naziv`; a missing status can be `NULL` |
| Languages | `idk_kandidat_jezici j` on `j.kj_kandidatid = k.kandidat_id` | `kj_naziv`, `kj_slusanje`, `kj_citanje`, `kj_pisanje`; potentially multiple rows per candidate |
| Work experience | `idk_kandidat_radno_iskustvo w` on `w.kri_kandidat_id = k.kandidat_id` | `kri_pozicija` is the original free-text position; `kri_darum_od` (schema spelling), `kri_datum_do`; potentially multiple rows |
| Normalized work occupation | `beruf_mapping bm` on `bm.freitext_wert = w.kri_pozicija` | `berufsgruppe_id` is the occupation group key; `confidence` and `quelle` describe the mapping |
| Education | `idk_kandidat_edukacija e` on `e.ke_kandidat_id = k.kandidat_id` | `ke_naziv` (school), `ke_naziv_kvalifikacije` (program), `ke_skola_id`, `ke_smjer_id`; potentially multiple rows |
| Linked ND education | `idk_nd_kandidata nd` on `nd.id_broj_nd_kandidata = k.kandidat_dipl_id` | `skola_nd_kandidata` links to `idk_skole.skola_id`; `skola_smjer_nd_kandidata` links to `idk_skole_smjerovi.ss_id` |
| School and academic profession catalogs | `idk_skole sk` and `idk_skole_smjerovi ss` on `ss.ss_skola_id = sk.skola_id` | `skola_naziv`, `ss_naziv`, `ss_struka_id`; this academic struka ID is unrelated to `bm.berufsgruppe_id` |
| Source link and account | `k.kandidat_visitedurl = idk_link_generator.lg_id`, then `lg_nalogid = idk_nalozi.nalog_id` | Do not confuse the account reached through the application link with `k.kandidat_nalog_id` |
| DIPL record | `k.kandidat_dipl_id = idk_nd_kandidata.id_broj_nd_kandidata` | `status_nd_kandidata`; `kandidat_dipl_id = 0` is used for “not in DIPL” by the CRM filter |
| Recognition | `k.kandidat_dipl_id = idk_nostrifikovane_diplome.id_cand_dipl` | `full_recognition`; possible multiple rows, so define whether “any” or “latest” is intended |

## Work occupation mapping and search

The initial `phase5_import_mysql.sql` import used 19,591 `INSERT IGNORE` statements. It produced 18,812 mapping rows across 194 groups at import time. Manual additions can change those counts, so verify them in the live database. `freitext_wert` is unique; `berufsgruppe_id` is a normalized string key, not a foreign key to a group table. `confidence` is classification metadata, and `quelle` is typically `auto` or `manual`. The CRM group filter does **not** impose a confidence threshold.

```sql
-- Discover valid groups and resolve a position before querying candidates.
SELECT DISTINCT berufsgruppe_id FROM beruf_mapping ORDER BY berufsgruppe_id;
SELECT freitext_wert, berufsgruppe_id, confidence, quelle
FROM beruf_mapping
WHERE freitext_wert = :position_text;
```

The join is `w.kri_pozicija = bm.freitext_wert` using the database collation. A work row with no mapping does not belong to any mapped group. One candidate can have several work rows and groups. Keep these concepts separate:

- `w.kri_pozicija`: a position actually recorded in work experience.
- `bm.berufsgruppe_id`: the normalized group of that position.
- `k.kandidat_prijava_na`: the position for which the candidate applied.
- `k.kandidat_iskustvo_u_struci` and `kandidat_iskustvo_u_struci_trajanje`: separate candidate-level flag and duration.
- `ss.ss_struka_id`: an academic profession grouping for school directions, unrelated to `berufsgruppe_id`.

The candidate page searches existing mapped and unmapped position text through `ajax_data.php?page=search_beruf_position`. When adding a new or unmapped position, `kandidati.php?page=add_kandidat_iskustvo` requires a group, saves a `manual` mapping with confidence `1.00`, and then saves the work row. Its `INSERT IGNORE` leaves an existing position mapping unchanged. See `DOKUMENTACIJA_IMPORT_BHS.md` for import history; use the live table as the source of truth.

For a candidate count by group, aggregate matching candidate IDs once. This avoids duplicate candidates and avoids the very slow correlated mapping lookup seen with large group selections:

```sql
SELECT COUNT(*) AS candidate_count
FROM idk_kandidati AS k
JOIN (
    SELECT w.kri_kandidat_id
    FROM idk_kandidat_radno_iskustvo AS w
    JOIN beruf_mapping AS bm ON bm.freitext_wert = w.kri_pozicija
    WHERE bm.berufsgruppe_id = :group_id
    GROUP BY w.kri_kandidat_id
) AS work_match ON work_match.kri_kandidat_id = k.kandidat_id
WHERE k.kandidat_status <> 3;
```

For several groups, bind a list of group IDs in `IN (...)`. A match to **any** selected group qualifies. Do not expand thousands of mapped position strings into `OR` predicates or run one query per position. A simple "has work experience" request should instead use `EXISTS` on `idk_kandidat_radno_iskustvo` and include unmapped rows. For "has an unmapped position," use `LEFT JOIN beruf_mapping` with `bm.id IS NULL`, then specify whether at least one unmapped row or no mapped rows is intended.

## School, direction, and linked ND profile

The CRM school and direction filter checks **either** a candidate education row **or** the linked ND profile. In each branch the school and direction must agree within the same record. Their numeric candidate/profile IDs differ; link `k.kandidat_dipl_id` to `nd.id_broj_nd_kandidata`. The ND school's `skola_nd_kandidata` links to `idk_skole.skola_id`, and `skola_smjer_nd_kandidata` links to `idk_skole_smjerovi.ss_id`. Check that `ss.ss_skola_id = nd.skola_nd_kandidata`.

```sql
-- Bind both school-pattern parameters to the same value, e.g. '%technical%'.
-- Bind both direction parameters to the same selected direction.
SELECT COUNT(*) AS candidate_count
FROM idk_kandidati AS k
WHERE k.kandidat_status <> 3
  AND (
    EXISTS (
      SELECT 1
      FROM idk_kandidat_edukacija AS e
      WHERE e.ke_kandidat_id = k.kandidat_id
        AND e.ke_naziv LIKE :school_pattern
        AND e.ke_naziv_kvalifikacije LIKE :direction_name
    )
    OR EXISTS (
      SELECT 1
      FROM idk_nd_kandidata AS nd
      JOIN idk_skole AS sk ON sk.skola_id = nd.skola_nd_kandidata
      JOIN idk_skole_smjerovi AS ss
        ON ss.ss_id = nd.skola_smjer_nd_kandidata
       AND ss.ss_skola_id = nd.skola_nd_kandidata
      WHERE nd.id_broj_nd_kandidata = k.kandidat_dipl_id
        AND sk.skola_naziv LIKE :school_pattern_nd
        AND ss.ss_naziv LIKE :direction_name_nd
    )
  );
```

The CRM uses a partial school-name match and an exact direction-name match through SQL `LIKE`. When only a school or only a direction is requested, omit the unused predicate in **both** branches. Multiple choices within one field are OR-ed; school and direction are AND-ed within the same education or ND record. Do not match the school from one education row to the direction from another, or take the school from education and the direction from ND. Candidate education stores free text, so do not assume `e.ke_skola_id` or `e.ke_smjer_id` is reliably populated.

To combine occupation, school, and direction, join the aggregated work-match IDs to `idk_kandidati k` and add the education-or-ND predicate:

```sql
SELECT k.kandidat_id, k.kandidat_ime, k.kandidat_prezime
FROM idk_kandidati AS k
JOIN (
    SELECT w.kri_kandidat_id
    FROM idk_kandidat_radno_iskustvo AS w
    JOIN beruf_mapping AS bm ON bm.freitext_wert = w.kri_pozicija
    WHERE bm.berufsgruppe_id = :group_id
    GROUP BY w.kri_kandidat_id
) AS work_match ON work_match.kri_kandidat_id = k.kandidat_id
WHERE k.kandidat_status <> 3
  AND (
    EXISTS (
      SELECT 1
      FROM idk_kandidat_edukacija AS e
      WHERE e.ke_kandidat_id = k.kandidat_id
        AND e.ke_naziv LIKE :school_pattern
        AND e.ke_naziv_kvalifikacije LIKE :direction_name
    )
    OR EXISTS (
      SELECT 1
      FROM idk_nd_kandidata AS nd
      JOIN idk_skole AS sk ON sk.skola_id = nd.skola_nd_kandidata
      JOIN idk_skole_smjerovi AS ss
        ON ss.ss_id = nd.skola_smjer_nd_kandidata
       AND ss.ss_skola_id = nd.skola_nd_kandidata
      WHERE nd.id_broj_nd_kandidata = k.kandidat_dipl_id
        AND sk.skola_naziv LIKE :school_pattern_nd
        AND ss.ss_naziv LIKE :direction_name_nd
    )
  )
ORDER BY k.kandidat_id DESC
LIMIT 50;
```

The work row and education row may differ; only school and direction must stay together. Count each candidate once. In the CRM multi-select form, selecting **every** option in occupation, school, or direction removes that field's restriction. Large partial selections are packed into JSON on the initial form POST because PHP's normal `max_input_vars` limit is 1,000 and the UI can offer about 1,848 directions. For a direct MCP query, apply the user's requested scope rather than assuming an empty filter means "has any recorded value."

## Reliable query patterns

Start from candidate IDs and add filters one at a time. Prefer `EXISTS` for one-to-many tables; a direct join can duplicate a candidate and inflate counts. These are patterns, not ready-made answers: bind parameters and choose the exact values only after checking the live data.

```sql
-- Unique, non-archived candidates with recorded work experience.
SELECT k.kandidat_id, k.kandidat_ime, k.kandidat_prezime
FROM idk_kandidati AS k
WHERE k.kandidat_status <> 3
  AND EXISTS (
    SELECT 1
    FROM idk_kandidat_radno_iskustvo AS w
    WHERE w.kri_kandidat_id = k.kandidat_id
  )
ORDER BY k.kandidat_id DESC
LIMIT 50;
```

```sql
-- Education-only example: school and program must be on the SAME row.
-- For CRM-equivalent results, include the linked ND branch shown above.
SELECT COUNT(*) AS candidate_count
FROM idk_kandidati AS k
WHERE k.kandidat_status <> 3
  AND EXISTS (
    SELECT 1
    FROM idk_kandidat_edukacija AS e
    WHERE e.ke_kandidat_id = k.kandidat_id
      AND e.ke_naziv = :school_name
      AND e.ke_naziv_kvalifikacije = :program_name
  );
```

For a minimum language level, compare the field the user actually means. The CRM filter uses **listening** (`kj_slusanje`) and treats “at least B1” as `IN ('B1','B2','C1','C2')`. It does not check speaking, reading, or writing. Use one `EXISTS` on `idk_kandidat_jezici` with both the language and level conditions. Resolve the stored language spelling with a small `SELECT DISTINCT kj_naziv ...` before filtering; do not assume an accented and unaccented spelling behave identically.

“No knowledge” is an explicit `kj_slusanje = 'BEZ ZNANJA'` row. “No language information” means no relevant language row or no recognized level; these are different populations. Use `NOT EXISTS` for the latter only after agreeing on what qualifies as a valid level.

For EU citizenship, the CRM uses `kandidat_drzavljanstvo_vrsta LIKE 'EU%'`. Its NON-EU branch includes values that do not start with `EU` **and** `NULL`; if the user means confirmed NON-EU citizenship, do not silently include unknown values. Inspect `SELECT DISTINCT kandidat_drzavljanstvo_vrsta` and use explicit values when possible.

### Age: always use completed years

When the user asks for **ages 20–45**, both endpoints are inclusive: each candidate must have **at least 20 and at most 45 completed years on the same reference date**. A 19-year-old is excluded until their 20th birthday; a candidate leaves the range on their 46th birthday. For “today”, use the database date `CURDATE()` and the same expression for filtering and displaying age:

```sql
SELECT k.kandidat_id,
       k.kandidat_datumrodjenja,
       TIMESTAMPDIFF(YEAR, k.kandidat_datumrodjenja, CURDATE()) AS age_years
FROM idk_kandidati AS k
WHERE k.kandidat_status <> 3
  AND k.kandidat_datumrodjenja IS NOT NULL
  AND TIMESTAMPDIFF(YEAR, k.kandidat_datumrodjenja, CURDATE()) BETWEEN 20 AND 45
ORDER BY k.kandidat_id DESC
LIMIT 50;
```

For an “as of” date supplied by the user, replace **both** `CURDATE()` calls with the same bound `:as_of_date` parameter. Do not use `YEAR(NOW()) - YEAR(kandidat_datumrodjenja)`: that is the CRM filter's approximation (`serversidedata.php:109–114`, `kandidati.php:592`), and it counts birthdays that have not happened yet. Before answering, check the calculated ages in the result: for a 20–45 request, the minimum must not fall below 20 and the maximum must not exceed 45. Missing birth dates mean unknown age and must not be silently included. For other date ranges, use the requested date column and a half-open interval for timestamps, e.g. `kandidat_datetime >= :from_date AND kandidat_datetime < :next_date`.

## Checks before returning a result

- Resolve labels and stored values with small lookup queries. Use reference tables for group and status names. Do not guess IDs from a label.
- Inspect `NULL`, blanks, capitalization, and distinct values for ambiguous columns before building the final predicate.
- Validate cardinality: `COUNT(DISTINCT k.kandidat_id)` when joins are necessary; otherwise count base candidate rows with `EXISTS`. If returning a list, check for duplicate `kandidat_id`.
- For a surprising result, inspect a few matching and excluded candidate IDs with the columns that caused the decision. Prefer IDs and minimal evidence over exposing full candidate profiles.
- Keep total counts consistent with the same filters as the result query, including free-text search and archive rules. Apply `LIMIT` only to the displayed list, not the count.
- For age ranges, make sure the displayed age uses the same reference date and `TIMESTAMPDIFF` as the `WHERE` clause; never return ages 19 or 46 for a 20–45 request.
- State the query's scope in the answer: archive inclusion, date column/range, how unknown values were handled, and whether a language level means listening only.

## Relationship to the CRM implementation

For comparison only, the richer CRM list is `kandidati.php?page=list_ajax` and its endpoint is `serversidedata.php?page=lista_kandidata`. The older `page=list` GET flow and `page=list_ajax_2` use different queries. Current application behavior has known pitfalls: the licence switch changes `DA` to `Da` before the endpoint checks for `DA`; multi-select EU residence is sent as one CSV value to `LIKE`; and DataTables `recordsFiltered` omits text search. Do not reproduce these bugs in direct database answers.
