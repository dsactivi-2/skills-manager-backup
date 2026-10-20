# Model-switch stale base_url trap — session trace

## Symptom
User switched model via `/model` in the TUI (to `anthropic/claude-opus-4.8`
on OpenRouter) and saw:

```
Prompt caching: enabled
    (session only — add --global to persist)
```

User asked to persist it and to explain what the message means.

## What the message actually is
- Emitted by the `/model` switch handler in cli.py (~L8468-8490), NOT a cache
  toggle.
- "Prompt caching: enabled" — auto-enabled because base_url host matches
  openrouter.ai AND model contains "claude" (cli.py L8468-8473). Informational.
- "(session only — add --global to persist)" — refers to the MODEL SWITCH:
  without --global the switch is session-scoped; config.yaml keeps the old model.
- With --global the handler persists: model.default, model.provider,
  model.base_url, model.api_mode (cli.py L8476-8488).

## The trap that bit this session
Before persisting, config.yaml held the OLD model:
```
model.default  = deepseek-v4-pro
model.provider = ollama-cloud
model.base_url = https://ollama.com/v1
```
Setting only `model.default` + `model.provider = openrouter` left
`model.base_url = https://ollama.com/v1`. The guard at
hermes_cli/models.py:4349 —
```python
if normalized == "openrouter" and base_url and "openrouter.ai" not in base_url:
    normalized = "custom"
```
— would silently downgrade the provider to "custom" and hit the wrong endpoint.

## Correct fix applied
```
hermes config set model.default "anthropic/claude-opus-4.8"
hermes config set model.provider "openrouter"
hermes config set model.base_url "https://openrouter.ai/api/v1"
# verify:
hermes config get model.base_url   # -> https://openrouter.ai/api/v1  ✓
```
OPENROUTER_API_KEY was already present in ~/.hermes/.env.

## Secondary mistake (and correction)
First attempted `hermes config set prompt_caching.enabled true`. Hermes warned:
"'prompt_caching.enabled' is not a recognized config key — saved anyway, but
Hermes may not read it." That warning = the key does nothing. Corrected with
`hermes config unset prompt_caching.enabled` and persisted the real intent (the
model switch) instead. Under `prompt_caching:` only `cache_ttl` is meaningful.

## Lesson
1. "session only — add --global to persist" on a /model switch = persist the
   model, and you MUST also sync base_url (+ api_mode) to the new provider.
2. Always `get model.base_url` after a provider change and confirm host matches.
3. A "not a recognized config key" warning means the key is a no-op — find the
   real key from source, don't leave the guessed one in place.
