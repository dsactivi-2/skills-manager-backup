---
name: youtube-video-research
description: "Use when finding YouTube videos by theme."
---

# YouTube video research

Class-level finder for this user. Transcripts still go through
`yt-dlp-transcript-pipeline` (`~/.hermes/bin/yt-transcript.sh` + `kurz_` files
in `Documents/Youtube Tranksipt`). This skill covers the step **before** that:
the user describes themes, you find candidates.

Bundled `youtube-content` is transcript-only via `youtube-transcript-api`. Do
not use it for discovery.

## When to use

- User describes topics/themes/language/length and wants videos found
- User asks "kannst du Videos suchen" / "welche Videos zu X"
- User asks whether a YouTube connector/MCP/CLI exists — answer the **job**,
  not a tool dump

Do **not** open with binary paths, MCP lists, or Whisper status.

## Default sequence

1. Search immediately if theme is clear. Ask only for missing theme/language/length.
2. Run **both**:
   - `yt-dlp --print "%(id)s | %(title)s | %(channel)s | %(duration_string)s | %(view_count)s | https://youtu.be/%(id)s" "ytsearch8:<query>" --no-download`
   - `web_search` query `site:youtube.com <theme>`
3. Return a short list: title, channel, duration/views if known, URL.
4. **Verify titles match the query.** `ytsearch` can return unrelated hits. Drop
   mismatches; prefer the web-search set if ranking is junk.
5. Wait for a pick unless they said find **and** transcribe. Then follow
   `yt-dlp-transcript-pipeline`.

No YouTube MCP/connector is required for this. Composio is optional and only
needed for account-scoped API (comments, own channel, Data API). Do not start
Composio OAuth unless the user is signing in.

## Captions vs Whisper (mention only when a pick has no subs)

`yt-dlp` reads YouTube captions. No captions = no transcript. `whisper-cpp` is
not a ready fallback (tiny test model only). Offer a real ggml model only if
they ask.

## Overlap

`yt-dlp-transcript-pipeline` owns file convention, `--sub-langs` regex, `kurz_`
batches, and `yt-index.py`. Keep discovery rules here until that skill is
adopted/patched to include them.
