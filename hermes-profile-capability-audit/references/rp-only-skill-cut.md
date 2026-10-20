# RP-only skill cut (companion profiles)

## Goal
Lean skill index for character/Telegram RP profiles so the model does not grab DevOps/ComfyUI/github skills mid-scene.

## Keep (s-ella live)
- ella-behavior (Artemis relationship/hormone engine)
- ella-roleplay
- ella-image-gen (Wiro/Zen)
- ella-nsfw-guard
- agent-rpg (optional; keep if RPG sessions used)
- humanizer (optional text polish)

## Cut
- creative/* except humanizer (especially **comfyui**)
- github/*, research/*, agent-builder/*
- Empty stubs: apple, email, media, mlops, productivity, smart-home, social-media, …
- Artemis raw dumps: behavior-engine/, harem/, violence-nsfw/ at skills root (port only via ella-behavior)

## Config
```yaml
skills:
  disabled:
    - architecture-diagram
    - arxiv
    # … all non-keep names still known to the profile
```

Plus marker file:
`profiles/<name>/.no-bundled-skills` via `hermes -p <name> skills opt-out`

## Soft conflicts to kill
| Pair | Risk | Fix |
|------|------|-----|
| comfyui + ella-image-gen | Model runs ComfyUI docs path | rm/disable comfyui; SOUL Wiro-only |
| agent-rpg + ella-roleplay | Tone mix | OK if RPG is command-gated |
| beat HARD STATE + behavior block twice | Double inject | Ensure single pre_llm path appends once |

## Verify
```bash
hermes -p s-ella skills list
# 6 enabled typical
find ~/.hermes/profiles/s-ella/skills -name SKILL.md
# no comfyui
python3 hooks/pre_llm_inject_beat.py <<<'{"message":"test"}'
# HARD count=1 BEHAVIOR count=1
```
