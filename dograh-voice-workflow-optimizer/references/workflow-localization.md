# Cross-language localization of a Dograh workflow — exact recipe

Proven on: BS workflow #8184 (v49, "Aquaphor Smile BiH Telesales") → DE workflow #8783
("Aquaphor Smile - DE Telesales - Produktion v1 - Amina"). 20 nodes, 38 edges, ~52k TS.

## 0. Pull full source without truncating context
`mcp__dograh__get_workflow_code` truncates its tool result near ~110k chars. For any 50k+ workflow,
call the MCP endpoint directly and write `code` to disk:

```python
import os, json, urllib.request
key = os.environ["<DOGRAH_BEARER_ENV_VAR>"]   # the Bearer token used by the dograh MCP server
url = "https://api.dograh.com/api/v1/mcp/"
def rpc(method, params, _id=1):
    body = json.dumps({"jsonrpc":"2.0","id":_id,"method":method,"params":params}).encode()
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "Authorization": f"Bearer {key}", "Content-Type":"application/json",
        "Accept":"application/json, text/event-stream"})
    raw = urllib.request.urlopen(req, timeout=90).read().decode()
    if "data:" in raw[:60]:                       # unwrap SSE framing if present
        for line in raw.splitlines():
            if line.startswith("data:"): raw = line[5:].strip(); break
    return json.loads(raw)
rpc("initialize", {"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"x","version":"1"}})
res = rpc("tools/call", {"name":"get_workflow_code","arguments":{"workflow_id":8184}}, 2)
txt = "".join(c["text"] for c in res["result"]["content"] if c.get("type")=="text")
code = json.loads(txt)["code"]
open("src.ts","w").write(code)
```
`create_workflow` deploys the same way: `rpc("tools/call", {"name":"create_workflow","arguments":{"code": open("final.ts").read()}})` → returns `{"created":true,"workflow_id":N,...}`.

## 1. The 5 text layers (extract each with regex over the raw TS)
- Node prompts: `wf\.addTyped\((\w+)\(\{(.*?)\}\)\);` → inside, `name:\s*"..."` and `prompt:\s*"..."`.
- QA prompt: `qa_system_prompt:\s*"((?:[^"\\]|\\.)*)"`.
- Edge label/condition/transition_speech: `wf\.edge\(\s*(\w+)\s*,\s*(\w+)\s*,\s*\{(.*?)\}\s*\)`
  then `label:`, `condition:`, `transition_speech:` inside the body.
- Top-level extraction: `extraction_prompt:\s*"((?:[^"\\]|\\.)*)"`.
- Nested vars: for each `extraction_variables:\s*\[(.*?)\]`, match
  `\{\s*name:\s*"..."\s*,\s*type:\s*"(\w+)"\s*,\s*prompt:\s*"..."\}`.

Unescape for reading: `raw.encode().decode('unicode_escape').encode('latin1').decode('utf-8')`.

## 2. Translation rules (hand to subagents for long batches)
- Node prompts / greetings / closings: rewrite for natural SPOKEN target language, not word-for-word.
  Map structural headers consistently (e.g. `## Glavni zadatak`→`## Hauptaufgabe`,
  `## Tok`→`## Ablauf`, `## Kriteriji uspjeha`→`## Erfolgskriterien`, `Predji na X`→`Wechsle zu X`).
- KEEP ENGLISH VERBATIM everywhere: QA JSON keys, enum values (won, follow_up, lost, handoff,
  wrong_number, do_not_contact, APPROVE_ORDER/HUMAN_REVIEW/BLOCK_ORDER/NOT_AN_ORDER,
  PASS/WARN/FAIL, high/medium/low, qualified/…), tag names, score-dimension names, variable names,
  True/False. Only translate the prose around them.
- Timezone + locale details: swap `{{current_time_Europe/Sarajevo}}`→`.../Europe/Berlin`, weekday
  list to target language, replace any source-language "verbindlich" language block with a
  target-language one (Sie-form for German cold calls; never claim prior consent — cold-call legal).

## 3. Assemble deterministically
Do NOT hand-edit the 52k TS. Build a mapping JSON per layer (`{source_string: target_string}`)
with source strings as EXACT keys, then apply by quoted-literal replace:
`src = src.replace('"'+ts_escape(bs)+'"', '"'+ts_escape(de)+'"')` where
`ts_escape = s.replace("\\","\\\\").replace('"','\\"').replace("\n","\\n")`.
Apply longest keys first to avoid substring collisions; skip pairs where `bs==de` (unchanged enums).

## 4. Verify before deploy (all must pass)
- **No residue**: count strong source-language markers across the whole file → must be 0
  (watch out: code-internal `const` identifiers may still contain source words; those are cosmetic
  and safe, but rename them whole-word for clean code).
- **Contract intact**: assert every QA JSON key / enum / tag / score-dim (build the list from the
  source) still appears in the localized QA prompt. A missing one breaks n8n/Cekura.
- **Infra intact**: webhook URLs, `{{...}}` bindings, tool_uuids, payload_template counts unchanged.
- **Edge integrity**: every `wf.edge(a,b,...)` endpoint resolves to a `const … = wf.addTyped(...)` var.
- **TS sanity**: unescaped `"` count is even; `wf.addTyped`/`wf.edge` counts match the source.
- Re-run the residue + contract check against the LIVE persisted workflow after `create_workflow`,
  not just the local file — trust the round-trip, not the create response alone.

## 5. Deploy non-destructively
Always `create_workflow` a NEW workflow. Never `save_workflow` over the source. The source workflow
is the fallback if the localized one regresses.
