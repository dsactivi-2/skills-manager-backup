# Fish s2.1-pro delivery tags

Source: Fish Studio MCP `studio_help` topic `tags` (2026-08). Unknown `[tokens]` may be spoken aloud.

## Allowlist

Emotion/manner (start of sentence, at most one):  
`[excited] [joyful] [sad] [angry] [nervous] [sarcastic] [tired] [soft] [loud] [whispering] [shouting]`

Reactions (inline):  
`[laughing] [chuckling] [giggle] [sighing] [gasping] [sobbing] [crying] [sniffling] [groan] [moaning] [clears throat] [coughing] [panting]`

Pacing: `[breath] [deep breath] [short pause] [pause] [long pause]`

Emphasis: `[emphasis]` immediately before the word. No close tag.

Density: ~one tagged block in three sentences.

## Dograh leftovers → official

| Do not write | Use |
|--------------|-----|
| `[happy]` | `[joyful]` |
| `[calm]` | `[soft]` |
| `[empathetic]` | `[soft]` |
| `[serious]` | no tag or `[soft]` |
| `[happy, calm]` | one tag only |

No SSML `<break>` on Fish. No round `(excited)`.

LiveKit Inference `fishaudio/s2.1-pro` language table has no `bs`; custom clones need the **plugin** + `FISH_API_KEY`. `normalize` is EN/ZH only — leave false for Bosnian.

Project copies: `/Users/activi/Code/Projects/LiveKit/docs/voice/FISH_TAGS.md`
