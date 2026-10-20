# Open-Weight & Foundry LLM Selection for Bosnian Voice Agents

Research-verified 2026-07-31. Complements the LLM section of SKILL.md. Focus:
which brain to put behind STT→LLM→TTS for a **Bosnian telesales** agent, and
the real decision criterion.

## The real decision criterion: diacritic output, not MMLU

For voice, the LLM does NOT need to *understand* Bosnian (STT already did that) —
it needs to **write** clean idiomatic Bosnian with full diacritics
(č, ć, š, ž, đ). Missing/wrong diacritics = wrong TTS pronunciation, audible
**instantly** in the `bs-BA` voice. This is the true A/B test, not benchmark
scores. Test method: identical system prompt → each candidate → pipe output
through `bs-BA-VesnaNeural`/`GoranNeural` → compare pronunciation.

System prompt clause that matters:
> "Antworte ausschließlich in korrektem Bosnisch mit vollständiger Diakritik
> (č, ć, š, ž, đ). Kurze, natürliche Sätze für Sprachausgabe."

## Azure Voice Live API model constraint (CRITICAL)

Azure AI Foundry **Voice Live API** bundles STT→GenAI→TTS in one low-latency
pipeline (140+ locales incl. bs-BA), but the built-in "brain" is restricted to
OpenAI + Phi models only:

| Tier | Models |
|------|--------|
| Pro | GPT-Realtime, GPT-4.1, GPT-4o, GPT-5 (preview) |
| Standard | GPT-4o-mini, GPT-4.1-mini, GPT-4o-mini-Realtime, GPT-5-mini |
| Lite | Phi-4-MM-Realtime, GPT-5-Nano, Phi-4-Mini |

**Implication:** any open-weight LLM (Mistral, Gemma, Qwen, Llama) is NOT usable
inside Voice Live. Choosing one forces a **self-built cascade** (Speech STT →
your Foundry endpoint → Speech TTS), adding a network hop and losing Voice Live's
integrated turn-taking / barge-in / VAD. Set TTS voice explicitly to
`bs-BA-VesnaNeural`/`GoranNeural` — the "MultilingualNeural" voices do NOT cover
bs-BA natively.

## South Slavic ranking of open-weights (Slovene arXiv proxy)

Slovene is the closest well-benchmarked South Slavic neighbor. Ranking of
*general* open-weights on South Slavic tasks (arXiv 2603.01691):

| Rank | Model | Note |
|------|-------|------|
| 1 | **Gemma 3 27B** | best general open-weight for South Slavic |
| 2 | Bielik-11B | surprisingly good (primarily Polish-trained) |
| 3 | Gemma 3 12B | smaller usable variant |
| 4 | Qwen3-30B-A3B | solid but NOT a South Slavic strength |
| 5 | EuroLLM-22B | disappointing despite EU focus |

Key correction: **Qwen is broad (119 langs) but its strengths are
Chinese/Japanese/Korean/Arabic, NOT South Slavic.** For BCMS among open-weights,
**Gemma 3 leads**.

## YugoGPT — the BCMS specialist (aging)

- YugoGPT 7B (Aleksa Gordić): explicitly trained for Bosnian/Croatian/Serbian/
  Montenegrin; "best open-source for HBS" **at its release**.
- ⚠️ Mistral-7B base, ~2 years old; author warns "don't expect GPT-4 quality".
- ⚠️ Base model → weak instruction-following out-of-the-box; needs your own
  instruction-tuning for voice turn-taking.
- ⚠️ NOT in Foundry catalog → self-host only (Managed Compute / own GPU).
- Verdict: historical/reference value only; not a production voice brain in 2026.

## Mistral Large 3 for telesales — verdict

Foundry catalog "Direct from Azure", Apache-2.0, open-weight. MoE 673B total /
39B active, 128 experts. Optimized for **instruction-reliability + long-context**,
explicitly NOT for math/reasoning peaks or realtime voice.

- **Latency (K.O. factor):** heavy frontier MoE. Serverless TTFT realistically
  ~600 ms–1.5 s + STT endpointing (~300–500 ms) + TTS first-chunk (~150–300 ms).
  Cascaded → **1.5–2.5 s per turn**. Humans perceive >~800 ms telephone pauses as
  "hakelig". Too slow for snappy sales rapport as a **live brain**.
- **Sales quality:** strong at holding a sales-playbook system prompt across many
  turns (phases, objection handling, not drifting). But **BCMS/Bosnian is a
  relative weakness** vs Gemma 3 27B and GPT-4.1/GPT-5 — not first choice for
  natural idiomatic Bosnian with correct cases/diacritics.
- **Not reasoning-heavy:** predictable dialogue quality, not a GPT-5-class thinker.

### Two better patterns than "Large 3 as live brain"
- **A) Voice Live native (best latency):** Speech STT (bs-BA) → GPT-4.1 or
  GPT-5-mini in Voice Live → Speech TTS (bs-BA-Vesna/Goran). Best balance of
  Bosnian quality + sales/reasoning + low latency.
- **B) Dual-model (use Large 3 as background "thinker"):** fast model
  (GPT-4o-mini / GPT-4.1-mini) runs the live turn; Large 3 does async heavy
  planning (offer logic, CRM reasoning, objection strategy) and feeds the live
  model cues. Exploits Large 3's instruction strength without paying its latency
  in-conversation.

## Overall LLM ranking for Bosnian voice (production 2026)

1. **gpt-4.1** — best diacritic + dialogue-steering balance, native Voice Live.
2. **Mistral Large 3** — best *open-weight* Foundry-serverless pick (Apache-2.0,
   EU) IF open-source/sovereignty is a hard requirement — but cascade-only + heavy.
3. **Gemma 3 27B** — best South Slavic *understanding* among open-weights; verify
   Foundry deployability (often Managed Compute only).
4. **gpt-4.1-mini** — cost/latency telephony setup (validate Bosnian first).
5. **Qwen3 30B+** — broad multilingual, South Slavic not a core strength.
6. **YugoGPT 7B** — BCMS specialist but aging base model, self-host only.

## Foundry deployability check (real, not catalog theory)
Catalog visibility ≠ deployable. To verify per subscription/region:
`az cognitiveservices account list-models` against the Foundry resource; open
each model card and check for a **Serverless API (Pay-as-you-go)** offer vs
**Managed Compute** only. Needs the user's Azure region + Foundry/Speech
resource name.
