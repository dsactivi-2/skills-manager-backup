# Direct-MCP large-workflow recipe + localization checklist + simulation details

## 1. Direct MCP call (bypass tool truncation)

```python
import os, json, urllib.request
key = os.environ["MCP_DOGRAH_API_KEY"]        # ~/.hermes/.env
url = "https://api.dograh.com/api/v1/mcp/"

def rpc(method, params, _id=1):
    body = json.dumps({"jsonrpc":"2.0","id":_id,"method":method,"params":params}).encode()
    req = urllib.request.Request(url, data=body, method="POST", headers={
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream"})
    raw = urllib.request.urlopen(req, timeout=90).read().decode()
    if "data:" in raw[:60]:                    # SSE framing
        for l in raw.splitlines():
            if l.startswith("data:"): raw = l[5:].strip(); break
    return json.loads(raw)

rpc("initialize", {"protocolVersion":"2024-11-05","capabilities":{},
                   "clientInfo":{"name":"x","version":"1"}})

# READ large workflow
res = rpc("tools/call", {"name":"get_workflow_code","arguments":{"workflow_id":8184}}, 2)
txt = "".join(c.get("text","") for c in res["result"]["content"] if c.get("type")=="text")
open("wf.ts","w").write(json.loads(txt)["code"])

# DEPLOY as a NEW workflow
res = rpc("tools/call", {"name":"create_workflow","arguments":{"code": open("final.ts").read()}}, 3)
# -> {"created": true, "workflow_id": <new>, "node_count":..., "edge_count":...}
```
After create_workflow, VERIFY live: re-read the new id, grep for source-language
residue, confirm node/edge counts match expectation.

## 2. Localization layer checklist (assert before deploy)

Translate to target language:
- [ ] globalNode persona prompt (rewrite the source-language block, e.g. `## Bosanski jezik` -> `## Deutsch`)
- [ ] every node `prompt`
- [ ] `qa_system_prompt` (translate instructions, KEEP all JSON keys/enums/tags verbatim)
- [ ] every edge `label` + `condition`   <- ROUTING, easily missed
- [ ] every node `extraction_prompt`      <- EXTRACTION, easily missed
- [ ] every `extraction_variables[].prompt` (nested)  <- EXTRACTION, most missed

Keep verbatim (infrastructure contract):
- [ ] English enum tokens & variable names inside extraction prompts
      (won, follow_up, lost, handoff, wrong_number, high/medium/low, True/False,
       order_confirmed, final_outcome, qualified, ...)
- [ ] all QA-node output JSON keys/enums/tags (n8n/CRM contract)
- [ ] webhook payload_template {{variables}}, tool_uuids
- [ ] swap timezone token (Europe/Sarajevo -> Europe/Berlin)

Apply method: build deterministic mapping JSONs (source->target), replace by
exact quoted-string match, assert 0 unmatched mapping keys, then residue-grep
the assembled file for source-language markers. Internal const identifiers are
cosmetic (never spoken) — safe to rename for readability, don't affect routing.

## 3. Local simulation engine + rubric

- Pull the live globalNode prompt read-only (via #1) so the sim runs against the
  ACTUAL agent; keep a hardcoded fallback prompt for no-key/no-net.
- Engine: OpenAI/GPT-4.1 default. On HTTP 429 `insufficient_quota` switch to
  OpenRouter: `OPENROUTER_API_KEY`, `https://openrouter.ai/api/v1/chat/completions`,
  model `anthropic/claude-sonnet-4`. NOTE `anthropic/claude-3.5-sonnet` 404s on
  OpenRouter — probe one isolated call to confirm any slug before the full batch.
  Add HTTP-Referer + X-Title headers. Request/response shape = OpenAI-compatible.
- Rubric in the target language's terms. German booleans to score: sie_form_ok
  (durchgehend Sie, no Du at the customer), numbers_spoken_ok (prices/dates as
  words). Penalize pressure-after-a-clear-no. Never reuse a source-language rubric.
- Scenario coverage (20 is a good set): friendly-open, price objection, price-haggle,
  already-has-filter, trust/number-origin, data-privacy, wants-human,
  hard-no/do-not-contact, wrong-number, callback-wanted, buy-ready-full-order,
  elderly-slow, busy-short, ASR-noise, annoyed-but-stays, health-motive, smalltalk.
- Cost: ~cents for 20 local sims vs dollars for real calls. Fix bottom-3, then call.
