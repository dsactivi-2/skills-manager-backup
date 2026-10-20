# LiveKit docs pages → local txt

Use when the user wants selected `docs.livekit.io` pages saved as files. Not a substitute for MCP / `lk docs` while coding.

## Destination

`/Users/activi/AI Bibliothek/LiveKit llms`

Never write `llms.txt` / `llms-full.txt` into `/Users/activi/Code/Projects/LiveKit`.

## Fetch

LiveKit serves markdown at `https://docs.livekit.io/<path>.md` (e.g. `/agents/models/stt/deepgram.md`).

Working request:

- Browser `User-Agent`
- **No** `Accept` header override

Broken request:

- `Accept: text/markdown` (also `text/markdown, text/plain, */*`)
- Vercel `vary: Accept` rewrites to `/api/markdown/<slug>.md` (double `.md`) → **HTTP 404**

curl without `-H Accept` returns `200` + `content-type: text/markdown; charset=utf-8`. urllib works the same if you omit `Accept`.

## URLs

`#inference`, `#plugins`, `#provider-tools` are the same page. Collapse to unique path before writing files.

Filename: path with `/` → `-`, drop `.md`, add `.txt`  
Example: `/agents/models/llm/openai.md` → `agents-models-llm-openai.txt`

Keep a `_INDEX.txt` with source URL + byte size.

Parallel ~6 workers is enough; retry 3–4× on transient errors.
