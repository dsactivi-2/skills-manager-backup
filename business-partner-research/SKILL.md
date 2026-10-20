---
name: business-partner-research
description: Research business partners, affiliate programs, supplier networks, and recruitment partner programs across European markets. Multi-language parallel search, structured report compilation, contact strategy, and outreach templates.
---

# Business Partner Research

## Trigger
Use when the user asks to find business partners, affiliate programs, supplier networks, recruitment partner programs, or any B2B partnership opportunities — especially across multiple European markets and languages.

## Methodology

### Phase 1: Parallel Multi-Language Search
Run 5+ web searches simultaneously with different language variants and angles. Never search sequentially when queries are independent.

**Language matrix for European B2B research:**
- English: broadest reach, international programs
- German (Deutsch): DACH market specifics
- Dutch (Nederlands): NL/BE specifics
- French: if FR/BE/LU relevant
- Local language of target candidate markets (e.g., Balkan languages if sourcing from there)

**Query pattern — mix these angles:**
- "[topic] partner program [country]"
- "[topic] supplier registration [country]"
- "[topic] affiliate program [country]"
- "[topic] [local language term] Partnerprogramm"
- "[topic] [local language term] Kooperation"
- "become a partner" OR "supplier registration" OR "agency partner" [topic] [region]

### Phase 2: Deep-Dive Extraction
For promising hits, use `web_extract` on the specific partner/supplier/referral pages. Extract:
- Partner program existence (public vs. unclear)
- Commission/revenue model
- Payout terms
- Geographic scope
- Candidate/supplier requirements
- Contact details

### Phase 3: Structured Report
Compile findings into a markdown report with these sections:

1. **Main table** — all providers with columns: Rank, Name, Website, Market, Type, Profiles, Partner Program Public?, Revenue Model, Commission, Payout, Non-EU Accepted?, Balkan/Turkey?, Visa Support, Company Required?, Contact Link, Source, Credibility (1-10), Fit (1-10), Priority (A/B/C), Risks, Recommendation
2. **Top-10 shortlist** — why interesting, what to supply, how to earn, what's confirmed, what's unclear, pre-start checks, first action
3. **Contact strategy** — phased outreach plan (immediate → week 1 → week 2 → follow-up)
4. **Required documents** — what to prepare before outreach
5. **Key questions per provider** — standardized checklist
6. **Contact templates** — English + German (or relevant languages), with subject line
7. **Final summary** — best overall, best per market, clearest model, highest uncertainty, next steps

### Phase 4: Prioritization Framework
Rate every provider 1-10 on fit and credibility. Categorize:
- **A (9-10):** Contact immediately — clear program, high fit
- **B (7-8):** Review and contact — good fit, some unknowns
- **C (5-6):** Monitor — possible but unclear
- **Not suitable (1-4):** Exclude

## Pitfalls

- **Do NOT fabricate data.** If commission rates, payout terms, or partner requirements are not publicly stated, write "nicht öffentlich angegeben" or "not publicly stated". Never guess.
- **Distinguish "Partnerprogramm unklar" from "kein Partnerprogramm".** If a provider looks interesting but has no public partner page, mark as "Partnerprogramm unklar – Kontaktaufnahme erforderlich" rather than excluding them.
- **Quality over quantity.** Don't pad the list with weak matches. If only 25 good providers exist, deliver 25 — not 30 with 5 filler entries.
- **Verify before recommending.** A provider with a "Partners" page is stronger than one where you're guessing. Weight public program clarity heavily in the priority rating.
- **Multi-language queries are not optional for European research.** English-only searches miss 40-60% of relevant local providers, especially in DACH and NL markets.

## Report File Convention
Save the report to a path that reflects the topic and date, e.g.:
`~/Code/Tools/<topic-slug>-report.md`

## Reference Files
- `references/outreach-english.md` — English first-contact email template for recruitment partnerships
- `references/outreach-german.md` — German first-contact email template (deutsche Erstkontakt-Nachricht)
- `references/due-diligence-questions.md` — 15 standardized questions to ask every potential partner before committing
