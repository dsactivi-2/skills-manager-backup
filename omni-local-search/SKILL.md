---
name: omni-local-search
description: "Semantic search over the user's own files - text, code, PDFs, images, audio and video - through the Omni app on this Mac. Use it when the user asks to find, locate or recall their own files by content: find my notes about X, that invoice from February, photos of the beach."
---

# Omni - local semantic file search

Search the user's local files by meaning. Files of every kind - text, code, PDFs, images, audio, video - share one embedding space, so describe the CONTENT you want in natural language (any language). `search` finds files across the whole index; `search_inline` ranks the best passages WITHIN a specific set of files or folders you already know; `file_status` reports whether given files are indexed and whether the index is still fresh for them. `ocr` transcribes a scanned PDF or an image to Markdown, page by page. Results are file paths with scores, snippets, and media metadata (resolution, duration, size); read the files yourself if you need their full contents.

Omni only finds what it has indexed. If a search comes back empty for something the user says is on their Mac, check `list_sources` before concluding the file is not there - the folder may simply not be a source yet. Linked Macs (other Macs running Omni that this one is linked with) are searched too, and their results are listed under each Mac's name: get_linked_file copies one here to read. `add_source` adds a folder (or the Apple Photos library, whole or by album) and indexing starts immediately; `pause_source` stops work on one without losing what it already indexed; `remove_source` drops it and its rows. These change what the user sees in the app, so treat add and especially remove as actions to take on request rather than on your own initiative.

## Using it

One command: `/Applications/Omni.app/Contents/Helpers/omni`. It talks to the running Omni app, and starts the app when it is not running, so the model is never loaded twice. The CLI subcommands are the same ten tools as Omni MCP. If Hermes lists `omni` as an HTTP MCP but `tool_search` has no Omni tools, search with the CLI. Prove access with `omni list_sources` (or `--json`), not with MCP tool counts.

```
  search           Search local files by meaning
  search_inline    Search within specific files
  file_status      Check whether files are indexed
  tag_image        Describe an image with open-vocabulary tags
  ocr              Transcribe a scanned document or image to Markdown
  list_sources     List what Omni indexes
  add_source       Index a folder or photo album
  pause_source     Pause or resume a source
  remove_source    Stop indexing a source and drop its results
  get_linked_file  Get a file from a linked Mac
```

```
/Applications/Omni.app/Contents/Helpers/omni search 'invoice from anthropic in february'
/Applications/Omni.app/Contents/Helpers/omni search 'photos of a red sports car' --kinds image --top-k 5
/Applications/Omni.app/Contents/Helpers/omni search 'meeting notes about the launch' --ext md --modified-after 2026-09-01
/Applications/Omni.app/Contents/Helpers/omni search_inline 'termination clause' --paths /Users/me/Documents/contract.pdf
/Applications/Omni.app/Contents/Helpers/omni file_status /Users/me/Documents/report.pdf /Users/me/Desktop/notes.md
/Applications/Omni.app/Contents/Helpers/omni tag_image /Users/me/Pictures/IMG_0001.jpg
/Applications/Omni.app/Contents/Helpers/omni ocr /Users/me/Downloads/scan.pdf
/Applications/Omni.app/Contents/Helpers/omni list_sources
/Applications/Omni.app/Contents/Helpers/omni add_source --path /Users/me/Projects
/Applications/Omni.app/Contents/Helpers/omni pause_source /Users/me/Downloads
/Applications/Omni.app/Contents/Helpers/omni remove_source '/Users/me/Old Projects'
/Applications/Omni.app/Contents/Helpers/omni get_linked_file /Users/me/Documents/tax-2025.pdf --mac Studio
```

- `/Applications/Omni.app/Contents/Helpers/omni <command> --help` shows its usage, examples and options; `--help-all` gives every option in full.
- stdout is the answer, one result per line; stderr is everything about it - an empty result, a page range, a mistake and its fix. Add `--json` for structured output, the same fields as Omni's HTTP API.
- Exit codes: 0 done, 1 the command needs fixing (stderr says how), 2 Omni is unavailable, 130 interrupted.
