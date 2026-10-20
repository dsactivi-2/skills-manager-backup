# Dograh JSON → LiveKit brief

User: extract **data**, do not copy node count or graph.

## Keep

- Persona, firm, product, market, language lock + BiH lexicon
- PAS as conversation method (problem → pain → solution)
- Order safety: consent before PII, one field/turn, digit-by-digit phone, full read-back
- Exits: DNC, wrong number, callback, human note (no live transfer)
- Never invent price/ETA/stock; price only if caller asks (unless brief says never)
- Post-call n8n/Cekura/Langfuse as shutdown hooks, not live-call tools

## Drop

- 17-node Dograh layout as LiveKit architecture
- In-call QA LLM / huge QA JSON
- Edges phrased as “call tool X” when only graph edges exist
- Re-intro every node
- Fish tags `[happy] [calm] [empathetic] [serious]`

## Target LiveKit shape

Opener (permission) → Sales (discover + pain + offer) → Order TaskGroup → Wrap.

Write the brief to `docs/PROJECT.md` in the LiveKit project. Open questions at the end (voice_id, price KM, SIP carrier, n8n reuse).
