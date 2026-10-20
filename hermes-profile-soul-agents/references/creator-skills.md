# SOUL / AGENTS creator skills (skills.sh)

**Primary authoring skill for Hermes: this umbrella (`hermes-profile-soul-agents`).**
Hub skills supply structure ideas only. Prefer domain skill installs (Dograh, voice latency) over hub "soul-*" packages.

## Queries
```bash
npx skills find "AGENTS.md"
npx skills find soul
npx skills find "create soul agents persona system prompt"
npx skills find "dograh workflow voice"
npx skills find "voice agent prompt"
hermes skills search soul    # hub; noisy — verify domain
```

## Vetted for structure (counts change)
| Skill | Why |
|-------|-----|
| github/awesome-copilot@create-agentsmd | AGENTS.md as agent-facing README; agents.md format |
| getsentry/skills@agents-md | ≤60–100 lines; actionable; not a changelog |
| callicrate/skills@agents-md | behavioral, scoped, evidence-backed |
| madteacher/…/agents-md-generator | progressive disclosure root+nested |
| larashero3-dotcom/soul.skill@create-soul | identity distillation (lower installs) |
| garrytan/gbrain@soul-audit | interview-style identity phases (lower installs) |

## Domain installs (when building a platform specialist)
| Skill | Why |
|-------|-----|
| dograh-hq/skills@dograh | official Dograh workflow/API concepts → profile `voice-ai/dograh-official` |
| davila7/…@voice-agents | cascaded vs S2S latency architecture notes |

Copy into `~/.hermes/profiles/<profile>/skills/…` when `npx skills add` lands outside Hermes home.

## Skip (domain mismatch — do not install for SOUL authoring)
- **higgsfield-soul-id** — https://skills.sh/higgsfield-ai/skills/higgsfield-soul-id — **video/face character ID**, not agent persona SOUL
- soul-guardian — prompt security product
- wallet / agent-identity payment skills
- DeFi / Salesforce Agentforce personas unless that is the task
- Chinese social "Soul" assistants

## Rule
Do not auto-install hub soul skills for Hermes profiles. Extract structure → write local drafts with this umbrella → Freigabe → apply.
