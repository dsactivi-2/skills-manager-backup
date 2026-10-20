# Full YouTube channel / playlist inventory

Use when the user wants **every** video on a channel or playlist, not a
theme search. `ytsearchN` is the wrong tool.

## Tabs are separate

| URL | What it is |
|---|---|
| `https://www.youtube.com/@handle/videos` | Long-form Videos tab |
| `https://www.youtube.com/@handle/shorts` | Shorts |
| `https://www.youtube.com/@handle/streams` | Live / premieres |

Inventory the tab they named. If they said "der ganze Kanal", run Videos,
then report Shorts + Streams counts and offer to pull those too. Do not
silently mix tabs.

`web_extract` / in-app URL attach on `/videos` often returns a YouTube 401
HTML shell. Ignore that page. `yt-dlp` is the source.

## Commands

Count / IDs only (fast, no likes, no description):

```bash
yt-dlp --flat-playlist --print "%(id)s	%(title)s	%(duration_string)s	%(view_count)s	%(upload_date)s" \
  --no-download --no-warnings "https://www.youtube.com/@handle/videos"
```

Full metadata for every video (needed for `like_count` + `description`):

```bash
yt-dlp --skip-download --ignore-errors --no-warnings -j \
  "https://www.youtube.com/@handle/videos" > /tmp/yt-channel.jsonl
```

Verify `wc -l` of the jsonl equals the flat-playlist count before building
the table. Sort by `timestamp` descending (newest first). `upload_date` is
`YYYYMMDD`.

Useful fields: `id`, `title`, `description`, `duration`, `duration_string`,
`view_count`, `like_count`, `timestamp`, `upload_date`, `webpage_url`.

`duration_string` for clips under 60s may be just `"43"` — format as `0:43`.

## Short description

Do not dump the raw YouTube description. First 1–2 sentences, strip URLs
and trailer blocks (Subscribe / Docs / Chapters / timestamps). If the
description is only hashtags, write one line from the title.

## Output

- Full markdown table in the reply (user said no skips — do not sample).
- Also write Desktop `.md` + `.csv` when N is large; HTML preview is optional.
- State the live pull date: views/likes move.

Do not open with a tool inventory. Do not fall back to `youtube-content`
(transcript-only) for discovery or catalogs.
