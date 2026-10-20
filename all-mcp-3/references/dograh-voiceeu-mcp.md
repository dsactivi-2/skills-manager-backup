# Dograh Voiceeu Tools Reference

## Preferred method: Native Hermes MCP

Dograh MCP is now available as a native Hermes MCP server. Prefer `mcp__dograh__*` tools directly — no gateway, no `call-tool.py` script needed.

Setup (one-time):
```bash
hermes mcp add dograh --url https://api.dograh.com/api/v1/mcp/ --auth header
```
Then configure the API key when prompted. After `/reset`, all Dograh tools are available as `mcp__dograh__*`.

## Fallback: MCP2Skill Gateway (legacy)

If native MCP is unavailable, use the gateway approach below.

## create_tool

Create a reusable tool the agent can invoke during calls.

The request schema is the same `CreateToolRequest` used by the REST API
and generated SDKs. Use it to create HTTP API, end-call, transfer-call,
calculator, or MCP-server tools. For authenticated HTTP or MCP tools,
reference an existing `credential_uuid` from `list_credentials`; users
create credential secrets in the UI, and this flow only stores the UUID
reference. For MCP tools, the server best-effort discovers the remote
tool catalog and caches it in `definition.config.discovered_tools`.

On success, returns `created: true` and the new `tool_uuid`; use that
UUID in workflow node `tool_uuids`. On failure, returns `created: false`,
a machine-readable `error_code`, and a human-readable `error`. Possible
`error_code` values:
- `validation_error` — the request failed schema validation.
- `credential_not_found` — a supplied credential_uuid is not in this
  organization; ask the user to create/select it in the UI first.
- `organization_required` — the API key user has no selected organization.
- `create_failed` — unexpected persistence or backend failure; retry once,
  then surface the error.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| request | object | Yes | Request schema for creating a reusable tool. |

### Example

```bash
python3 scripts/call-tool.py create_tool '{"request":{}}'
```

---

## create_workflow

Parse SDK TypeScript and create a new published workflow.

`code` is TypeScript source using `@dograh/sdk`. The workflow name
comes from `new Workflow({ name: "..." })` — it is required.

Example code:
    import { Workflow } from "@dograh/sdk";
    import { startCall, endCall } from "@dograh/sdk/typed";

    const wf = new Workflow({ name: "lead_qualification" });
    const greeting = wf.addTyped(startCall({ name: "Greeting", prompt: "Hi!" }));
    const done     = wf.addTyped(endCall({ name: "Done", prompt: "Bye." }));
    wf.edge(greeting, done, { label: "done", condition: "conversation complete" });

On success the new workflow is published as version 1. Use
`save_workflow(workflow_id, code)` for subsequent edits — those go to
a draft.

On failure the result has `created: false`, a machine-readable
`error_code`, and a human-readable `error` (with file:line:column
where the problem is locatable). Resubmit the full corrected source —
patches are not accepted. Possible `error_code` values:
- `parse_error` — disallowed construct or malformed TypeScript.
- `validation_error` — node data failed spec validation (unknown
  field, missing required, wrong type, option out of range).
- `schema_validation` — wire-format (DTO) rejection; rare.
- `graph_validation` — structural rule broken (e.g. no start node,
  unreachable node, edge to/from the wrong node type).
- `missing_name` — `new Workflow({ name })` is absent or empty; the
  name is required and there is no prior workflow to fall back to.
- `trigger_path_conflict` — a trigger node's path is already used by
  another workflow in this organization; rename it and resubmit.
- `bridge_error` — internal/transient; retry once, then surface it.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| code | string | Yes | - |

### Example

```bash
python3 scripts/call-tool.py create_workflow '{"code":"..."}'
```

---

## get_node_type

Fetch the authoring schema for a node type: each property's name,
type, default, requiredness, enum options, validation bounds, and
LLM-readable description, plus worked examples and graph constraints.

UI-only metadata (display labels, placeholders, conditional visibility
rules, renderer hints) is intentionally omitted — set only the fields
you need. Use the property `description`/`llm_hint` and the `examples`
list to understand semantics; types alone are not enough.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| name | string | Yes | - |

### Example

```bash
python3 scripts/call-tool.py get_node_type '{"name":"..."}'
```

---

## get_voice_prompting_guide

Fetch staged voice-prompting guidance for authoring Dograh workflows.

Call this BEFORE composing or revising any prompt field on a node. The
guide is the authoritative source for prompt-authoring craft (turn-taking,
persona, readback rules, disfluencies); product-mechanics questions
(how a node type works at runtime) belong in `search_docs` / `read_doc`.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| node_type | mixed | No | Optional filter. Most useful with `stage="create"`. |
| stage | mixed | No | "plan" | "create" | "review". Returns a stage briefing — a
short intro plus the list of topics relevant at this stage,
each with a one-line lens. Combine with `node_type` during the
create stage to narrow to topics that apply to that node type's
prompts (e.g. `node_type="agent"`). |
| topic | mixed | No | A topic id from a prior briefing. Returns the full content
for that atom. Use after the briefing flags a topic worth
drilling into. Mutually exclusive with `stage`. |

### Example

```bash
python3 scripts/call-tool.py get_voice_prompting_guide '{"node_type":"...","stage":"...","topic":"..."}'
```

---

## get_workflow

Fetch a single agent by id, projected into the SDK code view.

Output shape:
    {"id": int, "name": str, "status": str, "version": "draft" | "published" | "legacy", "version_number": int | None, "code": "<TS source>"}

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| workflow_id | integer | Yes | - |

### Example

```bash
python3 scripts/call-tool.py get_workflow '{"workflow_id":0}'
```

---

## get_workflow_code

Return the workflow as SDK TypeScript code the LLM can edit.

Output shape:
    {"code": "<TS source>", "workflow_id": int, "version": "draft" | "published" | "legacy"}

The LLM edits `code`, then calls `save_workflow(workflow_id, code)`.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| workflow_id | integer | Yes | - |

### Example

```bash
python3 scripts/call-tool.py get_workflow_code '{"workflow_id":0}'
```

---

## list_credentials

List external credentials available for webhook auth and pre-call fetch.

Returns each credential's `credential_uuid` (use this in node
`credential_uuid` / `pre_call_fetch_credential_uuid` properties), `name`,
`description`, and `credential_type`.

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py list_credentials '{}'
```

---

## list_docs

Browse the Dograh docs hierarchy before reading a page in full.

``path`` addresses navigation sections exposed by this tool. Page paths
returned by ``search_docs`` and ``read_doc`` are the published docs routes
instead, for example ``voice-agent/tools/mcp-tool``.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| depth | integer | No | - |
| path | mixed | No | - |

### Example

```bash
python3 scripts/call-tool.py list_docs '{"depth":0,"path":"..."}'
```

---

## list_documents

List knowledge-base documents the agent can reference during a call.

Returns each document's `document_uuid` (use this in node
`document_uuids` properties), `filename`, and `processing_status`.

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py list_documents '{}'
```

---

## list_node_types

List every available node type with a brief summary.

Use this first to discover what nodes exist, then call `get_node_type`
for the full schema of any node you intend to use.

Returns:
    A dict with `spec_version` (pin against this in any generated workflow
    code) and `node_types` (list of {name, display_name, description,
    category}).

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py list_node_types '{}'
```

---

## list_recordings

List pre-recorded audio files available for greetings and edge
transition speech.

Returns each recording's `recording_id` (use this in
`greeting_recording_id` / `transition_speech_recording_id` properties),
`transcript`, and TTS metadata. Pass `workflow_id` to filter to one
workflow's recordings.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| workflow_id | mixed | No | - |

### Example

```bash
python3 scripts/call-tool.py list_recordings '{"workflow_id":"..."}'
```

---

## list_tools

List tools the agent can invoke during a call.

Returns each tool's `tool_uuid` (use this in node `tool_uuids` properties),
`name`, `description`, and `category`. Pass `status=None` to include
archived tools.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | mixed | No | - |

### Example

```bash
python3 scripts/call-tool.py list_tools '{"status":"..."}'
```

---

## list_workflows

List agents (workflows) in the caller's organization.

Returns id, name, status, and created_at for each agent. Use
`get_workflow` to fetch a single agent's current SDK view and
metadata. Defaults to active agents; pass `status="archived"` to
list archived agents, or `status=None` to list all.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| status | mixed | No | - |

### Example

```bash
python3 scripts/call-tool.py list_workflows '{"status":"..."}'
```

---

## read_doc

Read one docs page after you have narrowed to a likely match.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| path | string | Yes | - |
| section | mixed | No | - |

### Example

```bash
python3 scripts/call-tool.py read_doc '{"path":"...","section":"..."}'
```

---

## save_workflow

Parse SDK TypeScript and save the resulting workflow as a draft.

`code` is TypeScript source using `@dograh/sdk`. Fetch the current
code first via `get_workflow_code(workflow_id)`, edit it, then pass
the full updated source here.

Example code:
    import { Workflow } from "@dograh/sdk";
    import { startCall, endCall } from "@dograh/sdk/typed";

    const wf = new Workflow({ name: "lead_qualification" });
    const greeting = wf.addTyped(startCall({ name: "Greeting", prompt: "Hi!" }));
    const done     = wf.addTyped(endCall({ name: "Done", prompt: "Bye." }));
    wf.edge(greeting, done, { label: "done", condition: "conversation complete" });

On success the draft version is saved; the published version is
untouched.

On failure the result has `saved: false`, a machine-readable
`error_code`, and a human-readable `error` (with file:line:column
where the problem is locatable). Resubmit the full corrected source —
patches are not accepted. Possible `error_code` values:
- `parse_error` — disallowed construct or malformed TypeScript.
- `validation_error` — node data failed spec validation (unknown
  field, missing required, wrong type, option out of range).
- `schema_validation` — wire-format (DTO) rejection; rare.
- `graph_validation` — structural rule broken (e.g. no start node,
  unreachable node, edge to/from the wrong node type).
- `bridge_error` — internal/transient; retry once, then surface it.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| code | string | Yes | - |
| workflow_id | integer | Yes | - |

### Example

```bash
python3 scripts/call-tool.py save_workflow '{"code":"...","workflow_id":0}'
```

---

## search_docs

Search the Dograh documentation and return a lean ranked shortlist.

Use this first for keyword or acronym lookup. Once the right page looks
likely, call ``read_doc(path)`` instead of reasoning from summaries alone.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| limit | integer | No | - |
| query | string | Yes | - |

### Example

```bash
python3 scripts/call-tool.py search_docs '{"limit":0,"query":"..."}'
```

---

