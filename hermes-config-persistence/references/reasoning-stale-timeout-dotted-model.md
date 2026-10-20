# Reasoning stale timeout + dotted model IDs

## Symptom
```
API call failed after 3 retries: [Errno 32] Broken pipe
The model's thinking phase exceeded the upstream proxy's idle timeout
before the first content token arrived.
```
Seen with `model.provider: xai-oauth`, `model.default: grok-4.5`. Hermes
appends workaround text from `agent/thinking_timeout_guidance.py`.

## Cause
Reasoning models think before the first content token. Hermes non-stream stale
detector + upstream idle caps kill the pipe mid-think → Broken pipe / errno 32.
Default floors: `agent/reasoning_timeouts.py` (`grok-4.5` = 300s). Config can
raise via provider/model timeout keys.

## Correct keys (`hermes_cli/timeouts.py`)
- Model stale: `providers.<id>.models.<model>.stale_timeout_seconds`
- Model request: `providers.<id>.models.<model>.timeout_seconds`  ← not request_*
- Provider stale: `providers.<id>.stale_timeout_seconds`
- Provider request: `providers.<id>.request_timeout_seconds`

Docs: Configuration → Provider Timeouts
(`providers.<id>.request_timeout_seconds`, `stale_timeout_seconds`,
model overrides).

## Known-good snippet (xai-oauth / grok-4.5)
```yaml
providers:
  xai-oauth:
    stale_timeout_seconds: 900
    request_timeout_seconds: 1800
    models:
      "grok-4.5":
        stale_timeout_seconds: 900
        timeout_seconds: 1800
```

## Trap: `hermes config set` + dots in model slug
```bash
hermes config set providers.xai-oauth.models.grok-4.5.stale_timeout_seconds 900
# → WRONG tree:
# models:
#   grok-4:
#     '5':
#       stale_timeout_seconds: 900
```
Fix: edit YAML so the key is literally `grok-4.5` (quoted). Then:
```bash
hermes config get providers.xai-oauth
~/.hermes/hermes-agent/venv/bin/python -c \
  'from hermes_cli.timeouts import get_provider_stale_timeout,get_provider_request_timeout as r; print(get_provider_stale_timeout("xai-oauth","grok-4.5"), r("xai-oauth","grok-4.5"))'
```
Expect `900.0 1800.0`. New CLI/session required after edit.

## Secondary mitigations
- `/reasoning medium` or `low` if provider supports it
- Faster / non-reasoning model for light tasks
- If still fails after 900s: upstream idle shorter than Hermes wait
