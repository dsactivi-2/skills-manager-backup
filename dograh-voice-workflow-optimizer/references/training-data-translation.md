# Training Data Translation for Non-English Voice Agents

## Problem
Languages like Bosnian (bs-BA) have no public call-center datasets. Synthetic generation from scratch produces unnatural dialogues.

## Solution: Translate Real Datasets

### Step 1: Download real call center data
Use HuggingFace datasets with real English call center transcripts:
- `AIxBlock/92k-real-world-call-center-scripts-english` — 92k real transcripts
- Focus on outbound sales ZIPs: `insurance_outbound.zip`, `medical_equipment_outbound.zip`

### Step 2: Filter for sales relevance
Keyword match on: sell, sale, offer, price, discount, order, buy, purchase, product, interest, deal, promotion

### Step 3: Translate with GPT-4.1
- Use structured prompt with product context (Aquaphor Smile, 100 KM, 1 year warranty)
- Output format: JSON array with `{"role": "agent"/"customer", "text": "..."}`
- Keep dialogue structure identical to original
- Adapt names, locations, and product references to target market

### Step 4: Extract few-shot examples
- Select 3-8 best examples (successful sales, objection handling, callbacks)
- Keep compact (~1000 chars total) for prompt injection
- Inject into workflow globalNode prompt via MCP

## Script
Location: `~/Code/Tools/dograh-aquaphor-telesales/scripts/translate_datasets.py`

## Pitfalls
- NEVER use `datasets` library streaming mode — it breaks on this dataset's JSON format
- Download ZIPs directly from HuggingFace and extract manually
- Avoid `{original}` in Python f-strings/format() when the text contains curly braces — use `.replace()` instead
- The `openai` Python library may have connection issues; use `urllib` directly
- API key must be in `~/.hermes/.env` as `OPENAI_API_KEY=...`
