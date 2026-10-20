# Banner anatomy & matching transcripts to sessions

## What the top line is

```
Hermes Agent v0.19.0 (2026.7.20) · upstream d71033a4
```

- Product name + semver + build date
- `upstream <shortsha>` = git tip of the install dir (often `~/.hermes/hermes-agent`) at process start
- Live check: `hermes --version` and `git -C ~/.hermes/hermes-agent rev-parse --short HEAD`
- **Never** pass this SHA to `--resume`

## Where the real session id is

In the welcome / status panel, left column under model and cwd:

```
│     grok-4.5 · Nous Research
│           /Users/…
│  Session: 20260727_131223_d436e8
```

Format: `YYYYMMDD_HHMMSS_` + 6 hex (example: `20260727_121757_cf4797`).

CLI list column **ID** is the same value:

```text
Title                     …   ID
gh global für AI-Agents   …   20260727_121757_cf4797
```

## SQL fingerprint match (when banner Session line missing)

Default profile:

```python
import sqlite3
from pathlib import Path
db = Path.home() / ".hermes" / "state.db"
con = sqlite3.connect(db)
con.row_factory = sqlite3.Row
needle = "%unique user phrase%"  # typo-rich is good
rows = con.execute(
    """
    SELECT m.session_id, s.title, s.message_count, s.ended_at, s.end_reason,
           substr(m.content,1,160) AS snippet
    FROM messages m
    JOIN sessions s ON s.id = m.session_id
    WHERE m.content LIKE ?
    ORDER BY m.id DESC
    LIMIT 10
    """,
    (needle,),
).fetchall()
```

Good needles from dumps: first user turn, rare product strings, distinctive typos.

Then list user turns for the candidate id to confirm chronological fit.

## Answer shape (user style)

```
Session-ID: 20260727_121757_cf4797
Title: …
Status: open | beendet (cli_close)
Resume: hermes --resume 20260727_121757_cf4797
```

One table of alternatives only if multiple candidates match.

## Related confusion table

| User says | Reality |
|-----------|---------|
| "session id upstream d71033a4" | Git commit of Hermes install |
| "this chat" while pasting old scrollback | Match paste → old id; current session is different |
| "continue the dograh guide chat" | Search title/content; e.g. get_voice_prompting_guide → its id |
