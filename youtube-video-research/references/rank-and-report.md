# Rank and report (user corrections, 2026-08)

**Passung vor Reichweite.** Views ≠ das gesuchte Problem.

## Answer shape

1. One sentence first, then the table. No `yt-dlp` path / MCP / Whisper dump.
2. Put **every** notable hit on the list. Viral off-topic clips =
   **Kategorie D: hohe Views, falsches Thema** with views, likes, and why
   they miss. Examples: Jeff Su = general agents; n8n / Ed Hill = no-code
   build, not spoken-prompt / emotion tags. Never a “nicht auf die Liste”
   footnote.
3. Start order = only stack-matching clips, never the view kings.
4. **No analog-vendor tutorials.** This search class assumes LiveKit +
   Deepgram Nova 3 + GPT-4.1 + **Soniox TTS**. Do not put ElevenLabs / Fish /
   Retell tag videos in the start order “nur fürs Prinzip” — GPT emits those
   tags and Soniox **speaks the brackets**. Docs:
   https://soniox.com/docs/tts/concepts/emotion-and-tone
   Skill: `soniox-voice-platform` (`references/strip-wrapper.md`).
5. Name jargon when you introduce it. Strip-Wrapper = allow-list filter
   between GPT text and `tts.say`, not a new model.

## Likes

`--flat-playlist` leaves `like_count` as NA. Re-fetch shortlist IDs with
`--skip-download` (no flat) and print `view_count` + `like_count`.
