---
name: json2video
description: >-
  Use when generating, editing, validating or submitting a JSON2Video movie
  JSON, or when calling the JSON2Video API / MCP tools (render_video,
  check_status, validate_movie, list_templates, get_template, get_account,
  media_*). Covers authentication, the parallel scene rendering model, element
  types, variables, voices/connections, caching, polling, resolutions, JSON
  generation conventions, anti-patterns, error handling and validation.
---

# JSON2Video — Rules & Conventions

You are working with the JSON2Video API (https://json2video.com/docs/v2/).
Follow these rules whenever you generate, edit or submit a movie JSON, or call
the API / MCP tools.

## Authentication

- Every API request to `api.json2video.com` MUST include the `x-api-key` header.
- The user's key lives in an environment variable (`JSON2VIDEO_API_KEY`) or the
  MCP `env` block. Never inline the key in code, JSON, or example URLs.

## Rendering model

- The API renders scenes in PARALLEL. Split work into scenes whenever possible —
  it is faster and cheaper than putting everything in one scene.
- A Movie is the top-level object. It contains a `scenes` array. Each Scene
  contains an `elements` array.
- `scenes` is REQUIRED on the Movie root. It can be an empty array but the key
  must be present.

## Elements

- Every element MUST have an explicit `type` field.
- Valid element types: `image`, `video`, `text`, `audio`, `voice`, `audiogram`,
  `subtitles`, `component`, `html`.
- Do NOT use `template` as an element type — it is deprecated and removed.
- Never nest one element inside another. All elements are siblings inside
  `scene.elements`.

## Variables

- Variables use the `{{name}}` syntax (double curly braces).
- Variable names must contain only letters, numbers and underscores. No spaces,
  no dashes, no dots.
- Pass values via the `variables` object on the Movie root or on a template
  request.

## Voices and premium models

- For premium voice models (ElevenLabs, Azure neural voices, etc.) ALWAYS use a
  connection ID configured in the dashboard.
- Never paste a raw third-party API key into the movie JSON.

## Caching

- The `cache` field defaults to `true` at every level. Leave it alone unless you
  have a reason.
- Only set `cache: false` when you actually need to regenerate (e.g. the asset
  behind a URL changed but the URL did not).

## Polling

- After `POST /v2/movies` returns a `project` ID, poll
  `GET /v2/movies?project=<id>` every 5 to 10 seconds.
- Do NOT poll faster than every 5 seconds — renders take far longer than that,
  so you would just re-read the same status and waste requests.
- Stop polling when `status` is `done` or `error`.

## Resolutions

- Valid `resolution` values: `sd`, `hd`, `full-hd`, `squared`,
  `instagram-story`, `instagram-feed`, `twitter-landscape`, `twitter-portrait`,
  `custom`.
- `custom` REQUIRES both `width` and `height` to be set on the Movie.
- Do not invent resolution names.

---

# JSON generation conventions

These rules apply whenever you generate a movie JSON for the JSON2Video API.

## Anti-patterns to avoid

- DO NOT nest an element under another element. Every element is a sibling
  inside `scene.elements`.
- DO NOT put movie-level fields (`resolution`, `quality`, `cache`, `variables`,
  `client_data`) inside a scene. They belong on the Movie root only.
- DO NOT reference voice IDs, model names or template IDs you have not verified
  exist. Use the MCP tools `get_template`, `list_templates`,
  `list_featured_templates` to confirm IDs, or call the relevant catalog
  endpoint.
- DO NOT use the deprecated `template` element type. Use `component`, `html` or
  assemble explicit elements instead.
- DO NOT set `cache: false` everywhere "just in case" — it disables the cache
  for the entire render and slows things down significantly.

## Error handling

- A successful render request returns `success: true` with a `project` ID; the
  movie then shows `status: "pending"` in `GET /v2/movies` until a worker picks
  it up. You must poll.
- A render that fails comes back with `status: "error"` and a `message` field
  describing what went wrong. Read the `message` first; it tells you the
  offending path inside the movie JSON (e.g.
  `scenes[1].elements[0].src is not a valid URL`).
- A 4xx HTTP response from the submit call means the JSON is invalid before
  rendering even starts. Validate first.

## Validate before submitting

- Use the JSON Schema for Movie to validate locally. It is available at:
  https://json2video.com/docs/v2/movie-schema.json
- If you have the MCP server installed, call the `validate_movie` tool — it runs
  the same validation the API does, but locally and faster.

## When in doubt

- Fetch the raw markdown of the relevant doc page by appending `.md` to its URL.
  Example: https://json2video.com/docs/v2/reference/json-syntax/movie.md
- Or list endpoints and elements via the MCP `get_help` tool.
