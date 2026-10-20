---
name: langchain-skill-audit-handover
description: "Audit LangChain/LangGraph/Deep Agents skills, verify the LangChain docs MCP, confirm global or local installs, and produce plain-language handover prompts or briefs for the current stack."
trigger: "Use when asked to inspect installed LangChain skills, verify the LangChain docs MCP, compare skills against docs, write a plain-language handover brief, or generate a ready-to-paste prompt for the next agent."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ee7e4-611c-7803-b405-f68c4790e5bc
  - activi_dsactivi's Organization_default_019ee76a-5c73-7c23-a327-5f6ce02aed29
  - activi_dsactivi's Organization_default_019ee1db-5c32-7843-8e6c-f325c8fa2875
  - activi_dsactivi's Organization_default_019ee1c7-430c-7cf0-b71a-839a592c2677
  - activi_dsactivi's Organization_default_019ee1b8-ced6-70c0-9339-a1e53e7b7207
  - activi_dsactivi's Organization_default_019ee1aa-419d-7d60-83ba-fe8904790096
  - activi_dsactivi's Organization_default_019ee191-fa32-7042-9340-4eb64f2b9e68
  - activi_dsactivi's Organization_default_019edafa-9a4b-7072-9a43-fa366b967349
contributors:
  - activi
version: 40
created_by_agent: codex
created_at: 2026-06-19T14:43:59.122Z
updated_at: 2026-06-21T02:49:09.160Z
---

# LangChain skill audit and handover

## When to use
Use when the task is to:
- check whether LangChain, LangGraph, or Deep Agents skills are installed locally or globally
- confirm where the bundle lives, especially `~/.agents/skills` versus the current project
- verify the LangChain docs MCP is present and usable
- audit installed skills against current docs and explain them in simple words
- compare LangChain, LangGraph, and Deep Agents as separate stack layers
- produce a handover prompt, session brief, or first-turn instruction for a new agent
- analyze the installed LangChain skill bundle and say what each skill is for
- turn an installation state into a ready-to-paste prompt for the next session

## Workflow
1. Confirm the LangChain docs MCP exists before summarizing skill content. Prefer it as the live reference when current docs matter. Record the MCP name and URL if known.
2. Inventory installed skills and record where they live, especially global installs under `~/.agents/skills` versus project-local installs. If asked whether skills are installed, answer with exact scope and count.
3. If the common LangChain bundle is present, verify the exact installed set and count it. The 14-skill bundle is:
   - `deep-agents-core`
   - `deep-agents-memory`
   - `deep-agents-orchestration`
   - `ecosystem-primer`
   - `langchain-dependencies`
   - `langchain-fundamentals`
   - `langchain-middleware`
   - `langchain-rag`
   - `langgraph-cli`
   - `langgraph-fundamentals`
   - `langgraph-human-in-the-loop`
   - `langgraph-persistence`
   - `managed-deep-agents`
   - `swarm`
4. Group skills by theme:
   - LangChain fundamentals and dependencies
   - LangGraph fundamentals, persistence, HITL, CLI
   - Deep Agents core, memory, orchestration
   - ecosystem primer / general orientation
   - deployment / managed hosting / server setup
   - swarm / multi-agent coordination
5. Read the actual skill files and cross-check with the LangChain docs MCP when needed.
6. Summarize each skill in plain language without code:
   - what it is for
   - when to use it
   - typical use cases
   - how it fits the broader stack
7. When comparing stack layers, explain them separately:
   - LangChain = model/tool/agent building blocks
   - LangGraph = workflow, state, retries, branching, interrupts, server runtime
   - Deep Agents = a higher-level agent framework built on LangChain + LangGraph
8. If deployment planning comes up, explain the practical pieces in plain terms:
   - provider packages are model adapters and can be added later
   - checkpointer remembers thread/workflow state
   - store remembers long-term data across threads
   - RAG/vector DB is for document retrieval
   - MCPs are tool surfaces, not model providers
   - managed versus self-hosted deployment changes where costs and control live
9. If the user wants a handover, write it as a ready-to-paste prompt or clean session brief that includes:
   - current setup
   - installed skills and their count
   - docs MCP status and the MCP name/URL if known
   - whether the skills are global or local
   - what the next agent should do first
   - a direct instruction to analyze all installed skills in simple words, without code, with use cases
10. When asked for a ready-to-paste prompt, include wording that tells the next agent to:
   - verify the LangChain docs MCP first
   - inspect all installed skills, especially the full 14-skill bundle if present
   - use the MCP as needed for up-to-date context
   - explain all skills in simple words, without code, with use cases
   - state whether the skills are installed globally or only in the project
11. End with a short priority list of the most relevant skills or stack pieces for the current project.

## Good output shape
For each skill or stack piece, keep the explanation concrete:
- purpose
- best fit
- example use cases
- relationship to the rest of the stack

## Anti-patterns
- Treating a skill name as enough without reading the skill body
- Explaining skills with code when the user asked for plain language
- Skipping the docs MCP check when the user asked to use it
- Repeating raw installation output instead of translating it into use cases
- Forgetting to mention whether skills are global or local
- Mixing unrelated framework families into one summary without grouping them
- Writing a handover that omits the installed-skill inventory, the docs MCP status, or next-step priorities
- Failing to mention the exact installed bundle when the user asks about the 14 LangChain skills
- Omitting a ready-to-paste prompt when the user explicitly wants one
- Treating deployment, provider, memory, or RAG choices as the same thing instead of separate layers
