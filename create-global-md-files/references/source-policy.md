# Fresh Source Policy

## Per activation

Before giving a recommendation, obtain a fresh source snapshot for the file
type in scope. Prefer the current official OpenAI Codex documentation. Search
and open the relevant page; do not rely on search snippets or remembered
behavior.

Use the smallest source set that can answer the question:

1. Official Codex documentation for `AGENTS.md`, configuration, skills, or
   permissions, as applicable.
2. Official OpenAI API documentation only when the proposed configuration or
   skill concerns API behavior.
3. Official OpenAI Cookbook material only when it provides a relevant example
   or current practice not established by the documentation.
4. A first-party OpenAI repository only when official documentation does not
   establish implementation behavior. Read only the relevant files.

Never use an arbitrary repository, blog, or copied template as authority for a
global configuration decision. If fresh sources are unavailable, disclose the
gap, provide only cautious general guidance, and do not claim current best
practice.

## Source report

Before the write gate, state the sources consulted, their retrieval date, and
which recommendation each source supports. Keep the snapshot for the current
activation. Re-check only when the selected file type changes or the user asks
for another fresh review.
