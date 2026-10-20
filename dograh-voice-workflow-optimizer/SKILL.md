---
name: dograh-voice-workflow-optimizer
description: "Optimize Dograh voice-agent workflows from live traces, drafts, and language-specific call behavior."
trigger: "Use when iterating on Dograh outbound voice workflows or agents from trace evidence, draft versions, or model/provider tuning."
---

# Dograh voice workflow optimizer

## CRITICAL: MCP-first rule
ALWAYS use Dograh MCP tools (mcp__dograh__*) for workflow operations. NEVER use browser login, UI navigation, or manual steps when MCP can do it. The MCP provides: get_workflow, get_workflow_code, save_workflow, create_workflow, list_workflows, and more.

Dograh MCP setup (one-time):
```
hermes mcp add dograh --url https://api.dograh.com/api/v1/mcp/ --auth header
```
Then configure the API key when prompted. After setup, all workflow operations go through MCP.

## Workflow
1. Confirm MCP access and current workflow IDs.
   - Use `mcp__dograh__get_workflow(workflow_id=N)` to read the live workflow definition before changing anything.
   - Use `mcp__dograh__get_workflow_code(workflow_id=N)` to get editable TypeScript source.
2. Inspect recent production traces before editing.
   - Read the last 3 Langfuse traces for the workflow.
   - Classify the failure as one of: prompt/flow, STT/ASR, TTS/voice, or model.
3. Optimize minimally.
   - For sales flows, do not end on the first "no"; add a second polite objection-handling turn.
   - For multilingual agents, tune greeting and closing in the target language, not English.
   - Make numbers and dates sound natural; do not force digit-by-digit speech.
   - Treat short backchannels, questions, and ASR noise as non-rejection unless clearly negative.
4. Save as draft via MCP, then verify.
   - Use `mcp__dograh__save_workflow(workflow_id=N, code=...)` to save as draft.
   - Verify with `mcp__dograh__get_workflow(workflow_id=N)` to confirm version increment.
5. Re-check traces after a test call and repeat if the same failure persists.

## Few-shot example injection
To add few-shot examples to a workflow's globalNode prompt:
1. Get current code: `mcp__dograh__get_workflow_code(workflow_id=N)`
2. Locate the globalNode prompt string (ends with `\",\n}));` after the prompt text)
3. Append a `## Few-Shot Examples` section with 3 compact, realistic dialogues (~1000 chars total)
4. Save: `mcp__dograh__save_workflow(workflow_id=N, code=modified_code)`
5. Examples should cover: successful sale, objection handling, callback scheduling
6. Keep examples short — prompt bloat hurts latency and costs

## Training data for non-English voice agents
When building training data for languages without public datasets (e.g. Bosnian):
1. Download real call center datasets from HuggingFace (e.g. AIxBlock/92k-real-world-call-center-scripts-english)
2. Filter for sales-relevant dialogues using keyword matching
3. Translate/adapt with GPT-4.1 into the target language
4. NEVER generate synthetic dialogues from scratch — always start from real data
5. See `references/training-data-translation.md` for the full workflow and script

## Model and provider heuristics
- Do not switch models first. Fix prompt, language handling, and STT boundary rules before moving the LLM.
- Standardize a pinned lightweight model when behavior is already good and cost matters.
- For languages with frequent ASR mistakes, prefer tighter STT language settings and a better-fitting voice before a larger LLM.
- If the agent sounds depressed or robotic, adjust TTS/voice tuning before increasing model size.

## Local simulation before Dograh test runs
Before running expensive Dograh test calls, simulate all training dialogues locally with the same LLM used in production:
1. Extract the system prompt from the workflow's globalNode (via `mcp__dograh__get_workflow_code`).
2. Feed customer turns from `training_dialogues.jsonl` to GPT-4.1, collect agent responses.
3. Evaluate each simulated conversation on: opening, flow, objection_handling, closing, naturalness.
4. Identify the bottom 3-5 problem cases — these are the ones worth running as real Dograh test calls.
5. This saves hours and credits: 50 local simulations take ~5 min vs hours for real calls.
6. See `references/local-simulation.md` for the full script and evaluation rubric.

## Simulation → analysis → prompt-fix loop (proven workflow)
After running local simulations, follow this loop to systematically improve the prompt:
1. **Run simulation**: 50 dialogues, collect scores and full conversations.
2. **Identify bottom 3**: Read the full conversation transcripts of the worst-scored dialogues.
3. **Find patterns**: Look for recurring failure modes (e.g. "ignores rejection signals", "no clear closing", "repeats questions 4+ times").
4. **Encode as explicit rules**: Add a `## KRITICNE GRESKE` section to the globalNode prompt with numbered, concrete rules. Each rule must state: (a) what to detect, (b) what to do, (c) what NOT to do.
5. **Re-simulate**: Run the simulation again and verify scores improve.
6. **Only then run real Dograh test calls** on the 3-5 worst cases.

Example KRITICNE GRESKE rules (from Aquaphor Smile project):
```
1. PREPOZNAJ ODBIJANJE ODMAH: "ne", "nisam", "smorio sam se" → SOFORT beenden. Kein Nachfragen.
2. SVAKI ODGOVOR MORA IMATI JASAN ZAVRSETAK: Nur 3 Optionen: Kauf-Frage, konkreter nächster Schritt, oder "Hvala, ugodan dan".
3. SLUSAJ, NE PRATI SKRIPTU: Erst auf das antworten was der Kunde sagt, dann weitermachen.
4. TRI PUTA JE MAKSIMUM: Gleiche Frage max. 3x, dann "nije pravi trenutak" und Ende.
```

## Localizing an existing workflow to a new language (proven)
When cloning a working workflow (e.g. Bosnian #8184) into another language (e.g. German), the
source text lives on **5 distinct layers** — a surface translation that only touches node prompts
silently ships a broken agent that routes on foreign-language conditions. Localize ALL of:
1. **Node prompts** (globalNode persona + agentNode + endCall) — the visible/spoken layer.
2. **QA node `qa_system_prompt`** — but preserve EVERY JSON output key, enum value, tag, and
   score-dimension verbatim (they are the n8n/Cekura/CRM contract). Only translate the instruction
   prose. Verify the key set survives with a token-count check before deploy.
3. **Edge `label` + `condition`** — these drive LLM routing between nodes. Foreign conditions =
   wrong branching in the new language.
4. **Top-level `extraction_prompt`** per node.
5. **Nested `extraction_variables[].prompt`** — easiest to miss; keep English enum tokens
   (high/medium/low, won/follow_up/handoff, True/False) but translate the surrounding description.

Deterministic pipeline that worked: pull full source → extract each layer to JSON → translate
(delegate long batches to subagents with hard rules: keep enums/keys English) → produce
source→target mapping JSONs → apply by exact quoted-string replace → verify no residue +
all contract tokens intact + edge endpoints valid → `create_workflow` as a NEW workflow (never
mutate the source). Rename code-internal `const` identifiers last (cosmetic, whole-word only).
Note: Voice/STT/TTS locale is NOT in the TS code — set it separately in the Dograh UI/metadata.
See `references/workflow-localization.md` for the exact extraction/verify recipe.

## Large workflow code exceeds MCP tool truncation (>~110k chars)
`mcp__dograh__get_workflow_code` / `create_workflow` truncate their tool-result payload around
110k chars, so a 50k+ TS workflow can't be round-tripped through the normal tool call. Fix: hit
the MCP endpoint directly via a small `python urllib` JSON-RPC call (initialize → tools/call) with
the Dograh bearer token, and write the `code` field straight to disk. This keeps the huge string
out of the context window entirely. See `references/workflow-localization.md` for the RPC snippet.

## Authorization & scope discipline (user-enforced)
This user runs voice-agent work in explicit phases and expects strict instruction-following.
- **Never create/publish/deploy a workflow without explicit go-ahead.** `create_workflow` and
  `save_workflow` are account-visible writes. Even a NEW (non-destructive) workflow must be
  authorized first. Building the whole thing locally is fine; pushing it to the account is a
  separate, gated step.
- **Do not jump ahead to the next phase on your own.** "Go to the next phase" is not a blanket
  mandate to define and execute that phase end-to-end. Confirm what the phase is, then do only it.
- **When a clarify() question times out with no answer, STOP and report — do not pick a default
  and barrel ahead** on anything with side effects or strategic assumptions (target market,
  deploy, topology). Silence is not consent. (A read-only default is acceptable; a write is not.)
- **Separate "translated" from "optimized" honestly.** A 1:1 localization is NOT an optimization.
  If the user's goal was "meaningfully better than a manual prompt," a pure translation does not
  meet it — say so plainly instead of implying the goal is done.
- Distinguish live account state from a local working copy when reporting readiness — verify
  against the live workflow via MCP, not just the on-disk `.ts`.

## Anti-patterns
- Creating or publishing a workflow (`create_workflow`/`save_workflow`) without explicit user authorization — even a new, non-destructive one.
- Auto-selecting a default and proceeding after a clarify() timeout on a side-effecting or strategic decision.
- Presenting a pure translation as if it were an optimization.
- Localizing only node prompts and leaving edge conditions / extraction prompts in the source language (agent routes on foreign conditions).
- Translating QA-node JSON keys / enum values / tags (breaks the n8n/Cekura/CRM contract — keep them verbatim).
- Publishing before draft validation.
- Treating one short "no", a question, or a backchannel as a full rejection.
- Changing prompt, model, STT, and voice at the same time.
- Using multilingual STT for a single-language sales flow.
- Telling the model to pronounce multi-digit numbers one digit at a time.
- Claiming the UI draft is visible without verifying the version in the frontend.
- Using browser login when MCP is available.
- Generating synthetic training data from scratch instead of translating real datasets.
- Running all 50 training dialogues as real Dograh test calls without local simulation first.
