---
name: github-issue-investigation
description: Start the GitHub issue investigation Agents API session. Use when the user wants to investigate a GitHub bug, trigger the investigation agent, or run $github-issue-investigation. Asks for repo path and task if missing; loads OPENAI_API_KEY from .env.local without manual env setup.
---

# GitHub issue investigation

Start a hosted Agents API session with the saved agent agent_d0f0db34168346889c4d5d93dc68bc8181b16fbcd32b473e87 in project proj_Ud2wWkyDYQnOu2etpfq0vvPW. Run the bundled script; do not reimplement curl calls.

## When triggered

1. Collect two facts if they are not already in the user message:
   - path: local repo directory, GitHub repo URL, or issue URL
   - task: what to investigate or do
   Ask in the user language. One short question is enough when only one fact is missing. Wait for the answer before starting the session.
2. Do not ask the user to export env vars or source .env.local. The script loads .env.local itself.
3. Ensure a key, then start:

```bash
python3 "$HOME/.codex/skills/github-issue-investigation/scripts/investigate.py" --path "<path>" --task "<task>"
```

4. Report the script output. Keep the session_id. Stop after the turn completes, fails, or is blocked on missing input.

## API key

The script searches OPENAI_API_KEY, then .env.local / .env next to the script, in the current workspace, and in this skill folder.

If it prints MISSING:api_key:

1. Ask the user for a Platform project key for proj_Ud2wWkyDYQnOu2etpfq0vvPW with api.agents.read, api.agents.write, and api.responses.write.
2. Write it without echoing. Send the key on stdin, not in argv:

```bash
python3 "$HOME/.codex/skills/github-issue-investigation/scripts/investigate.py" --save-key --dest "<workspace>/.env.local"
```

3. Rerun the investigate command.

Never print the key. Never put it in config.json, chat, or logs.

## Constraints

- Session overrides are only model, instructions, reasoning, and text. Do not send tools: [].
- Environment is openai_hosted. No local executor.
- If the path is a local git checkout, pass it to the script; it adds remote/HEAD to the agent prompt. The hosted sandbox does not mount the local disk.
- Do not edit the investigated repo unless the user explicitly asks for a fix.

