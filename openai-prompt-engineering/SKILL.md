---
name: openai-prompt-engineering
description: >-
  Write and review OpenAI Responses API prompts: instructions versus
  developer/user/assistant roles, Identity/Instructions/Examples/Context,
  few-shot XML, prompt caching, snapshot pinning, and GPT versus reasoning
  versus coding, frontend, and agentic prompting. Use when the user runs
  /openai-prompt-engineering, or asks to write, improve, or review an OpenAI
  prompt, developer message, Responses API input, few-shot set, or
  gpt-6-astra prompting, or to move a saved v1/prompts object into code.
---

# OpenAI prompt engineering

Build a Responses API prompt as application code: a stable instruction block plus a per-request input. Read `output_text`. Do not index `output[0].content[0].text` — `output` also holds tool calls and reasoning items.

## Workflow

1. Classify the task: open text, classification, coding, frontend, agentic, or multi-step reasoning.
2. Choose the model class (below). In production, pin a dated snapshot. Add fixtures and an eval check before changing the prompt or the snapshot.
3. Split what is identical on every request from what changes per request.
4. Draft the stable block with [references/developer-message.md](references/developer-message.md). Start from [assets/developer-message.txt](assets/developer-message.txt).
5. If the task is coding, frontend, agentic, or a reasoning model, read only the matching section of [references/model-prompting.md](references/model-prompting.md).
6. Send the stable block as `instructions` (it outranks `input`) and the request as `input`. A `developer` message plus a `user` message is the same split. `developer` is the function; `user` is the arguments; `assistant` is model output.
7. Keep the prompt builder in a small module next to the feature. Pass typed arguments into it. Roll changes out through the app deploy path.
8. On each turn that uses `previous_response_id`, send `instructions` again. Prior turns do not keep them.

For JSON, use Structured Outputs with a schema on the request. Look up the current parameter in the Structured Outputs guide before writing the call. Do not rely on "reply with JSON" in prose.

## Model class

| Task | Prompt style |
| --- | --- |
| Multi-step planning, underspecified goal | Reasoning model. State the goal and done-condition. Leave the procedure to the model. |
| General text, prompt iteration | GPT model. Default while iterating: `gpt-6-astra`. State the procedure and the exact output shape. |
| Narrow, latency- or cost-sensitive | Mini or nano, still with explicit instructions. |

## Caching

Put reused text at the start of the prompt and early in the JSON body (`instructions` before `input`). Put proprietary or per-request context last, in the user turn, inside XML tags. That is also where retrieved passages go (RAG). Constrain the model to those passages when the answer must come from them.

## Review checklist

- Stable rules are outside the user turn.
- Section order matches the developer-message reference.
- Few-shot pairs are diverse, wrapped in XML, and paired by `id`.
- Production `model` is a snapshot, not a floating alias.
- `instructions` are resent when `previous_response_id` is set.
- Callers read `output_text`.
- A fixture covers a normal case and one edge case.

Saved prompt objects are deprecated: creation is de-emphasized from 2026-06-03, and `v1/prompts` shuts down on 2026-11-30. Migrate an existing prompt id with the prompt-object migration guide. Do not create a new one.
