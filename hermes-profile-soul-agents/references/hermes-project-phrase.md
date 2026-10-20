# Phrase „projekt X“ → Hermes project primary folder

User: „projekt LiveKit“ means work only in the Hermes project primary folder.

```bash
hermes project create "LiveKit" /Users/activi/Code/Projects/LiveKit --slug livekit --use
hermes project list    # * = active
hermes project show livekit
```

| Phrase | Path | Slug |
|---|---|---|
| projekt LiveKit | `/Users/activi/Code/Projects/LiveKit` | `livekit` |

On session start: `cd` that path (or `hermes --in <path>`). Load that repo’s `AGENTS.md`. Do not use other LiveKit folders (`livekit-telesales`, `Documents/ChatGPT/LiveKit`, `hermes-livekit-infra`) unless asked.

New project AGENTS.md is ops, not a profile SOUL. Profile SOUL still needs Freigabe.
