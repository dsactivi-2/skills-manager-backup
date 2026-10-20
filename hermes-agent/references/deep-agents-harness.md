# Deep Agents Harness + LangChain Skills Integration

## Deep Agents Definition
Opinionated framework on LangGraph with built-in middleware harness:
- TodoListMiddleware (planning)
- FilesystemBackend (context)
- SubAgentMiddleware (delegation)
- MemoryMiddleware + Store (persistence)
- HumanInTheLoopMiddleware (approvals)
- SkillsMiddleware (on-demand SKILL.md loading)

Core function: `create_deep_agent(model, tools, backend, skills, checkpointer, store, interrupt_on, subagents...)`

## Installation Pattern (this session)
1. `git clone https://github.com/langchain-ai/langchain-skills.git`
2. `cp -r langchain-skills/config/skills/* ~/.hermes/skills/langchain/`
3. Skills appear automatically under `langchain` category in `hermes skills list`
4. Load with `skill_view(deep-agents-core)` or `/skill deep-agents-core`

## MCP for Docs (no auth)
`hermes mcp add docs-langchain --url https://docs.langchain.com/mcp`
Tools: search_docs_by_lang_chain, query_docs_filesystem_docs_by_lang_chain

## Handover Format (standardized)
## What Happened
## People
## Entities
## Decisions & Reasoning
## Key Facts
## Files Modified
## Open Questions / TODO
## Next Steps

## Common Pitfalls Fixed
- Missing checkpointer → interrupts fail
- No Store for MemoryMiddleware
- No consistent thread_id → lost context
- Missing frontmatter in SKILL.md
- Skills not passed to subagents
- No FilesystemBackend for local skills

Use `create_deep_agent(..., skills=["./skills/"])` for all LangChain skill work.
