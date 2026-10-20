# BH Telecom Imenik — Implementation Details

## Source

- **URL**: `https://moj.bhtelecom.ba/imenik`
- **Framework**: Java Liferay Portal (Spring MVC/Portlet)
- **Portlet ID**: `portalimenikmvc_INSTANCE_fupE15A9jBpo`
- **CAPTCHA**: Mentioned in footer but NOT enforced in practice
- **JS required**: No — pure HTML forms

## Three search modes

### 1. FIZIČKA LICA (Person search)

**Navigation URL**:
```
/web/guest/imenik?p_p_id={PORTLET_ID}&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_{PORTLET_ID}_mvcPath=%2FsearchFizickaLica.jsp
```

**Form fields**:
- `_{PORTLET_ID}_ime_prezime` — name input
- `_{PORTLET_ID}_captchatoken` — hidden, always empty

**Form action**: `javax.portlet.action=search`

**Result table headers**: `Ime i prezime: | Broj telefona: | Adresa: | Grad/Mjesto:`

### 2. PRAVNA LICA (Business search)

**Navigation URL**:
```
/web/guest/imenik?p_p_id={PORTLET_ID}&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_{PORTLET_ID}_mvcPath=%2FsearchPravnaLica.jsp
```

**Form fields**:
- `_{PORTLET_ID}_naziv_korisnika` — business name input (NOT `naziv`!)
- `_{PORTLET_ID}_captchatoken` — hidden, always empty

**Form action**: `javax.portlet.action=search`

**Result table headers**: `Naziv pravnog lica: | Naziv priključka: | Broj telefona: | Adresa: | Grad/Mjesto:`

### 3. PRETRAGA PO BROJU (Reverse number lookup)

**Navigation URL**:
```
/web/guest/imenik?p_p_id={PORTLET_ID}&p_p_lifecycle=0&p_p_state=normal&p_p_mode=view&_{PORTLET_ID}_mvcPath=%2FsearchNumber.jsp
```

**Form fields**:
- `_{PORTLET_ID}_pozivni` — prefix select (033, 030, 031, ..., 069)
- `_{PORTLET_ID}_telefon` — number input
- `_{PORTLET_ID}_captchatoken` — hidden, always empty

**Form action**: `javax.portlet.action=searchformnumber` (DIFFERENT from person/business!)

**Available prefixes**: 030-039, 049-069 (all Bosnian area codes)

**Result table headers**: Same as person search: `Ime i prezime: | Broj telefona: | Adresa: | Grad/Mjesto:`

## Session management

- `JSESSIONID` cookie set on first GET
- `COOKIE_SUPPORT=true`, `GUEST_LANGUAGE_ID=bs_BA` also set
- `BIGipServerWEB_portal_80` — F5 load balancer cookie
- `TS01c33561` — F5 ASM security cookie

## No-results messages

- Person/business: `Nema dostupnih podataka`
- Number: `Za traženi broj nema rezultata`

## Data availability

The directory is **opt-in** — only subscribers who explicitly consented are listed. Most common Bosnian names return zero results. This is expected behavior, not a scraper bug.

## Other Bosnian phone directories (not scraped)

| Provider | URL | Status |
|----------|-----|--------|
| HT Eronet | `hteronet.ba/telefonski-imenik` | JS-only, form not in static HTML |
| m:tel | `mtel.ba` | Cookie wall, JS-dependent |
| Telemach | `telemach.ba/telefonija/javni-imenik` | **Active reCAPTCHA v2**, not scrapable without CAPTCHA solving |
