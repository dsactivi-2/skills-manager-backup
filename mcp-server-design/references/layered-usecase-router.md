# Layered use-case router

Session-derived pattern: one MCP owns a branching use-case tree. Platforms (Dograh, n8n, CRM, SIP) are backends, not the first catalog the agent sees.

## Durable tools

Only these two should appear in `tools/list`:

### `start`

```json
{
  "usecase": "neuer_voice_agent"
}
```

Returns:

```json
{
  "ticket": "abc",
  "stufe": 1,
  "runbook": "Drei legale Wege. Kein Plattform-Katalog.",
  "erlaubt": [
    {"knopf": "1", "titel": "nur_pruefen", "ergebnis": "Statusbericht"},
    {"knopf": "2", "titel": "sip_neu", "ergebnis": "Ext + nächste Stufe"},
    {"knopf": "3", "titel": "bestehenden_nutzen", "ergebnis": "gebundenes Agent-Setup"}
  ]
}
```

### `waehle`

```json
{
  "ticket": "abc",
  "knopf": "2"
}
```

Server loads state `abc`. If `2` is not legal on this Stufe → error, same Stufe. If legal → run hard step (or only advance), then:

```json
{
  "ticket": "abc",
  "stufe": 2,
  "ast": "sip_neu",
  "runbook": "Zuerst Nebenstelle, dann Trunk prüfen. Keine n8n-Vollliste.",
  "erlaubt": [
    {"knopf": "A", "titel": "sip_anlegen", "ergebnis": "Ext-Nummer"},
    {"knopf": "B", "titel": "sip_nur_pruefen", "ergebnis": "OK/Fehler"}
  ]
}
```

Knopf `1` or `3` on Stufe 1 would have returned a **different** Stufe-2 `erlaubt` set.

## Hard vs soft on the tree

- Illegal transition (wrong ast, expired ticket, unknown knopf) → **hard reject**.
- Side effects behind a chosen knopf → **hard** (call Dograh/n8n/CRM inside this server).
- Which legal knopf among 2–3 → **soft** (model + system prompt).
- One knopf on a Stufe → that step is effectively hard.

## Do not

- Reply “öffne jetzt MCP n8n und nimm dort tools/list” (Zettel-Router).
- Mutate host `tools/list` between Stufen.
- Advertise 20 platform tools plus this wizard — the agent will skip the tree.

## Optional third tool

`stand(ticket)` — read-only replay of current Stufe/runbook. Useful after a dropped turn. Does not advance state.
