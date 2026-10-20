# Prompt style vs model strength (Dograh-verified)

## Myth from generic LangGraph posts
- Strong model → free prompts, few nodes, model picks phase
- Weak model → scripted 1-2-3 nodes, dual `nodes_strong/` / `nodes_cheap/`

## Dograh product truth
- Always a **workflow graph** (nodes + edges)
- Official craft = `get_voice_prompting_guide` topics for **all** models
- Model choice = inference config / BYOK — not a second prompt tree
- Weaker models: add **clearer edges + success_criteria + fewer collisions**; do not robot-script open

## Prefer
| Do | Don't |
|----|-------|
| extraction_prompt + edge conditions | Spoken `[INTENT:…]` tags |
| One graph, tighten criteria | Parallel strong/cheap prompt repos |
| Natural speech + tight structure | "Say exactly these 4 sentences" every turn |

## Guide API pitfall
`get_voice_prompting_guide`: pass **either** `stage` **or** `topic`, never both (MCP error).
