# Fresh-source policy

At the start of every skill activation, refresh guidance once before recommendations or drafting. Keep the resulting source snapshot for the rest of that activation; do not re-query for every follow-up question.

## Required source categories

1. **Official Codex documentation:** Check the current OpenAI documentation for `AGENTS.md`, local skill discovery, `SKILL.md` format, and any feature relevant to the requested file.
2. **OpenAI Cookbook:** Search current official Cookbook material for a directly relevant pattern. If none applies, record that no relevant Cookbook guidance was found; do not force an unrelated example into the result.
3. **First-party repository material:** Check the documentation or examples of a relevant official OpenAI repository. If no repository is relevant to the requested file type, record that result; do not force unrelated repository material into the recommendation.

Use current official sources as evidence, but do not overwrite project policy merely because a generic example differs. Report source title, link, and access date in the recommendation when sources materially influence the decision.

## Research boundaries

- Prefer official OpenAI domains and first-party OpenAI repositories.
- Treat third-party blog posts, copied snippets, and stale repository issues as non-authoritative.
- If sources disagree or are incomplete, explain the uncertainty and request a decision before creating a configuration file.
- Do not access repositories, private systems, or external services that the user has not placed in scope.
