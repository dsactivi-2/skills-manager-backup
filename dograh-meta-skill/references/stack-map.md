# Dograh Skill Routing Matrix

Use this table to route to the strongest lead skill. Pick one lead, then add support only when it changes the output.

## Direct Dograh/Agentbuilder Work

| Task | Lead | Support | What to produce |
|---|---|---|---|
| New Dograh voice agent | `build-dograh-voice-agent` | Dograh MCP, DACH, Sales, Tool/Handoff | Persona, nodes, edges, prompts, tools, evals |
| Existing Dograh workflow edit | Dograh MCP + `build-dograh-voice-agent` | `dograh-stepwise-tool-wiring` | SDK code edits and safe save plan |
| Node schema / field choice | Dograh MCP | `build-dograh-voice-agent` | `list_node_types`, `get_node_type`, field mapping |
| Prompt writing inside Dograh nodes | Dograh MCP | `dach-telesales-agent-builder`, `voice-agent-prompt-builder` | Stage-guided prompt sections |
| Tool or transfer wiring | `add-tools-and-handoffs` | Dograh MCP, `dograh-stepwise-tool-wiring` | Tool schema, trigger rules, recovery behavior |
| Draft/publish/runtime wiring issue | `dograh-stepwise-tool-wiring` | Dograh MCP | State diagnosis and minimal fix |
| Workflow optimization from traces | `dograh-voice-workflow-optimizer` | Langfuse, Cekura/Tuner-style checks | Evidence map and targeted edits |
| Reusable telesales template | `dograh-telesales-base-template-builder` | DACH, Sales, Cekura | Template, placeholders, variants, QA plan |
| Workflow inventory or docs | `dograh-workflow-documentation-inventory` | Dograh MCP | Read-only table and descriptions |

## Voice, Sales, Language, Runtime

| Task | Lead | Support | What to produce |
|---|---|---|---|
| German/DACH script | `dach-telesales-agent-builder` | Sales, Voice | Spoken German prompt, disclosure, objection lines |
| Sales state machine | `research-backed-sales-agents` | Dograh, DACH | Claims ledger, states, objections, eval rubric |
| Voice naturalness | `telesales-voice-agent-builder` | Langfuse voice optimization | STT/TTS/VAD/turn-taking tuning |
| Generic voice prompt audit | `voice-agent-prompt-builder` | Domain-specific skills | Structured prompt audit |
| Objection handling | `objection-handling` | Sales, DACH | Pushback responses and coaching lines |
| Closing / appointment booking | `closing` | Sales, DACH | Buying signals, close rules, booking language |
| TTS/SSML production output | `tts-ssml-prompt-hardening` | Voice | Speech-safe rewriting prompt |

## Telephony, Observability, Debug

| Task | Lead | Support | What to produce |
|---|---|---|---|
| Twilio/Telnyx setup | `configure-telephony` | Dograh setup/MCP | Carrier and webhook plan |
| Call metrics / transcripts | `inspect-calls-and-metrics` | Langfuse, Dograh optimizer | Cost, latency, transcript findings |
| Langfuse voice quality | `langfuse-voice-call-quality-optimization` | Dograh optimizer | Trace-based quality fixes |
| Observability gaps | `voice-call-observability-audit` | Langfuse, metrics | Observed-vs-missing evidence report |
| Azure OpenAI BYOK failure | `dograh-azure-openai-byok-debug` | Langfuse, Dograh config | Correlated root cause and fix plan |
| Dograh platform broken | `dograh-setup` | Dograh MCP docs | Setup/repair/doctor flow |

## Project Setup

| Task | Lead | Support | What to produce |
|---|---|---|---|
| First setup wizard | `dograh-project-setup-agents-wizard` | Dograh meta | Secret-safe project setup pack |
| Safe project handover | `dograh-project-setup-agents-wizard` | Documentation inventory | Onepager, checklist, readiness report |

## MCP Tool Map

| Need | Dograh MCP tool |
|---|---|
| List workflows | `list_workflows` |
| Read workflow | `get_workflow_code` or `get_workflow` |
| Discover node types | `list_node_types` |
| Read node schema | `get_node_type` |
| Prompt authoring guide | `get_voice_prompting_guide` |
| Save existing workflow draft | `save_workflow` |
| Create new workflow | `create_workflow` |
| List or create tools | `list_tools`, `create_tool` |
| Use credentials/docs/recordings | `list_credentials`, `list_documents`, `list_recordings` |
| Dograh docs | `search_docs`, `read_doc`, `list_docs` |

## Default Combos

| User intent | Default combo |
|---|---|
| "Baue einen Dograh Agenten" | `dograh-meta-skill` -> `build-dograh-voice-agent` -> Dograh MCP |
| "Baue deutschen Telesales Agenten" | Dograh + DACH + Sales + Tool/Handoff |
| "Optimiere bestehenden Agenten" | Dograh optimizer + call metrics/Langfuse + Dograh MCP |
| "Verbinde CRM/n8n/Kalender" | Tool/Handoff + Dograh MCP |
| "Agent klingt schlecht" | Telesales voice builder + Langfuse voice optimization |
| "Dokumentiere alle Workflows" | Workflow documentation inventory + read-only Dograh MCP |
| "Dograh startet nicht" | Dograh setup, not workflow builder |
