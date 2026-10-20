---
name: de-job-portal-leads
description: "Use when building DE job-ad upsell leads for voice agents."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [recruiting, leads, job-portals, jeff]
    related_skills: [ask-jeff, recruiting-crm]
---

# DE job-portal second-listing leads

## When to Use

German firms with a fresh job ad; the product is selling a listing on a portal they do not already use. Voice-agent handoff. Not candidate sourcing.

Voice agents sell a second job-portal slot, not candidates. Germany only. Repeat the understood brief (need, lead fields, use) and wait for Go before any search or paid call.

## Hard kill (no lead)

- Not a German company / not DE location.
- Incomplete ad (need full text, source URL, posted window).
- No phone (ad first, else Impressum of the domain on the ad). Email is extra, never a substitute.
- Cross-portal status UNKLAR or already DA on the sell-target portal.
- Guessed numbers, guessed "not listed".

## Procedure

1. Lock source portal vs sell-target portal (e.g. Indeed vs StepStone) and freshness window. One source of structured ads; do not invent APIs.
2. Capture the full listing: title, body, location, company raw, URL, portal id, date.
3. Canonical identity: legal name + alias list (Rechtsform on/off, umlauts, brand vs GmbH, parent vs operating co). A short-name search that misses the legal name produces a false NICHT DA.
4. Phone from ad, else Impressum. Else drop.
5. Cross-portal proof on the live target portal (not Google snippets, not Jeff):
   - Search every alias; then company + title + Ort.
   - Save hit count, result URLs, timestamp (HTML/screenshot if possible).
   - DA = same firm + (same title or same role+place).
   - NICHT DA = all aliases and both query shapes empty on the real portal.
   - UNKLAR = captcha, login, name collision, agency posting — never convert to NICHT DA.
   - Second pass on the saved search URL before NICHT DA stands.
6. Jeff (`ask-jeff`) only after step 5. State must include full ad, aliases, proof, phone. Noul/score for buy-likelihood of the missing slot. Jeff must not be asked to check a portal.
7. Hand off one record: legal+aliases, Ort, full ad+URL+date, portals DA/NICHT DA+proof, sell-target, contact+phone(+email), Jeff score+one-line why, status ready-for-call|drop|unsicher.

## Do not

- Taskfuel/Apollo as job search.
- "I searched, it wasn't there" without saved portal queries.
- Batch before one proven sample lead.
