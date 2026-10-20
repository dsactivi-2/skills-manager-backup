# Strip-wrapper (GPT-4.1 → Soniox TTS)

Not a new model. A small filter on the TTS call.

```
Deepgram Nova 3 → GPT-4.1 → strip-wrapper → Soniox TTS
```

## Why

Soniox treats unknown `[brackets]` as words and **speaks them**. GPT-4.1
invents vendor tags (`[happy, calm]`, `[empathetic]`, ElevenLabs/Fish forms)
unless constrained. Retrain is the wrong fix.

## Allow-list (sales phone, Amina 2026-08)

Keep: `[warm] [calm] [curious] [sincerely] [reassuringly] [softly] [pause]`

Broader Soniox English tags exist (docs `/tts/concepts/emotion-and-tone`) —
test before adding. Tags stay **English** even when the sentence is BS/DE.

## Strip

- Keep an exact allow-list match (case-insensitive, single purpose).
- Delete every other `[…]` including compounds (`[happy, calm]`).
- Do not touch spoken words or punctuation (`...`, `!`, `*stress*`, `Hmm`).

Before: `[happy, calm] Super, das mache ich gern. [pause] Einen Moment.`
After: ` Super, das mache ich gern. [pause] Einen Moment.`

## Do not

- Teach tags from ElevenLabs / Fish / Retell videos.
- Stamp `[warm]` on every turn (ear hears no variation).
- Call this a YouTube step — it is LiveKit code between `generate` and `tts`.
