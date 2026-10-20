# Artemis (momori777/Artemis) → Hermes profile s-ella

Source: https://github.com/momori777/Artemis (OpenClaw + local GPU girlfriend stack).
Target: myhermi profile `s-ella` (Hermes Telegram + Wiro images + beats/hooks).

## Take (high value)

| Artemis | Into s-ella | Notes |
|---------|-------------|-------|
| `skills/behavior-engine/` | New skill `ella-behavior` + hook | relationship scores, hormones, conflict, stages; portable Python |
| `memory/role_play/*/relationship.json` schema | `memories/` or `scenarios/` | Calibrate age/vibe to Ella (48, hunter); do not copy demo char values |
| `AGENTS_roleplay_EN.md` concepts | Patch `AGENTS.md` | RP-first, MEDIA discipline, full outputs — **strip** sessions_spawn/ps1/llama kill |
| `skills/Violence NSFW/languate custom/*` | `ella-roleplay/references/` | Style only; keep `ella-nsfw-guard` as hard bounds |
| `skills/comfyui/prompt_template.md` ideas | ella-image-gen prompts | Backend stays Wiro MCP, not ComfyUI core |

## Skip on this VPS

- Root `SOUL.md` / `IDENTITY.md` (tool mode — would wipe Ella)
- `comfyui_core/`, TTS, ASR, Live2D, desktop pet (Windows/GPU)
- OpenClaw bridge, llama headroom, QQ bot, setup-*.ps1
- Demo harem personas (atori/natsume/enola/sakura) as Ella replacement
- Full-repo dump into `skills/`

## Keep s-ella as SoT for identity

Already strong: `SOUL.md`, `skills/ella/ella-roleplay`, beat hooks, `ella_wiro_mcp`, nsfw-guard.
Artemis adds **dynamic relationship/hormone state**, not a new persona.

## Phase order

1. Port behavior-engine + relationship.json + inject/update hooks (like beat-enforcer).
2. Merge selected AGENTS_roleplay rules + 1–2 style references.
3. Optional: Wiro prompt templates from ComfyUI prompt style.

Never install whole Artemis tree on myhermi without GPU plan + Freigabe.
