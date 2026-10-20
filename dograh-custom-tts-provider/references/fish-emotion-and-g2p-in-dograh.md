# Fish emotion + G2P wiring inside Dograh (three separate layers)

Verified 2026-08 against Dograh MCP docs (voice-agent/global, voice-agent/agent,
configurations/voice, get_voice_prompting_guide) + Fish Audio docs
(core-features/emotions, core-features/fine-grained-control). Fish is NOT a
built-in Dograh TTS provider — it only exists in a self-hosted checkout via the
factory branch (see SKILL.md). None of the three levers below is a Dograh UI
"emotion" field; Dograh has no such field.

## The three levers (do not conflate)
1. **Emotion regie (which emotion is appropriate)** — pure prompt logic, lives
   in the Dograh globalNode + agentNode prompts. Engine-agnostic.
2. **Fish execution (how it is spoken)** — Fish text tags + service-init prosody
   params. Fish-specific.
3. **G2P / pronunciation (name said wrong)** — static text replace before TTS +
   respelling. See sibling skill `tts-pronunciation-correction`.

## Layer 1 — emotion regie in Dograh prompts
- There is no classifier node. The "emotion detection → tag" step is the LLM
  itself, instructed in the prompt. Two robust patterns, combine them:
  - **globalNode**: add an "Emotion / tone tracking" block (detect rush, anger,
    sadness, skepticism, interest) + an **allowed-tag whitelist** + a ban on
    cheerful tags on sensitive turns. globalNode is prepended to every node with
    "Add Global Prompt" on (exactly one globalNode per workflow).
  - **agentNode / state gating**: a node handling a sensitive branch (e.g.
    "accident/claim") constrains tags to `[empathetic]`/`[serious]` in its own
    prompt. Node-specific emotion rules go in the agentNode, NOT globalNode
    (per Dograh's own global-vs-node guidance).
- The voice-prompting guide's `common_guidelines` template is the canonical
  globalNode skeleton — keep its headings; add the emotion block under `## Rules`.
- Turn-taking rule from the guide: end every turn with a question/nudge; the
  emotion ack is ≤1 short clause, then agenda step (see `dograh-human-conversation`).

## Layer 2 — Fish tags + prosody
- **Syntax depends on model generation**: S2 uses square brackets `[excited]`;
  S1 (legacy) uses parentheses `(excited)`. Match your Fish model or the tag is
  spoken/ignored. The custom-provider `model` field (e.g. `s2-pro`) decides this.
- **64+ markers**, all placed INSIDE the spoken text the LLM emits:
  - Sentence-level emotion at sentence start: `[empathetic]`, `[sad]`, `[calm]`,
    `[confident]`, `[serious]`(use `[calm]`/`[empathetic]` for gravitas), etc.
  - Tone anywhere: `[whispering]`, `[soft tone]`, `[in a hurry tone]`, `[emphasis]`.
  - Audio effects anywhere: `[laughing]`, `[sighing]`, `[chuckling]`, `[break]`,
    `[long-break]`.
  - S2 accepts free-text bracket cues too (e.g. `[warm and happy]`,
    `[slightly sad]`) — not limited to the fixed list.
- Emotion tags add **no latency** and don't count toward token limits (Fish docs).
- **Prosody params** (`prosody_speed`, `prosody_volume`, `latency`, `normalize`,
  `temperature`) are GLOBAL, set at service init in the factory branch — they set
  overall tempo/volume/stability, they do NOT do "accident vs celebration". Scene
  emotion must come from tags, not prosody.
- The tags survive to the engine: `xml_function_tag_filter` strips only XML
  function tags; round/square brackets pass through untouched.

## Layer 3 — G2P / OOV (Balkan names, e.g. "Đenite")
- Fish phoneme control `<|phoneme_start|>...<|phoneme_end|>` exists ONLY for
  English (CMU Arpabet, not IPA), Chinese (tone-number pinyin), Japanese
  (OpenJTalk romaji). **No Bosnian/Croatian/Serbian phoneme lexicon, no SSML,
  no IPA, no upload-a-dictionary** like Azure/ElevenLabs.
- Robust path for `Đ` names: static `text_filters` replace map in
  `create_tts_service` (respell `Đenite → Dženite`, add every declined surface
  form) + a prompt fallback net. Do NOT ASCII-ise correct diacritics
  (`č ć š ž`) — breaks language detection. Full method in
  `tts-pronunciation-correction`.
- `normalize` helps numbers/dates, NOT proper-name OOV.

## Fish Audio MCP (docs/tools, not a Dograh dependency)
- Server: `https://api.fish.audio/mcp` (OAuth sign-in, no API key). Gives an
  agent tools: search voice library, generate speech, transcribe.
- Fish also ships an **agent skill**: `npx skills add https://docs.fish.audio`
  (writes correct SDK/API code). Separate from the MCP.
- **Installing an MCP in Hermes**: it goes in `~/.hermes/config.yaml` under the
  `mcp_servers:` block, same shape as the existing `dograh` entry:
  ```yaml
  mcp_servers:
    fish-audio:
      url: https://api.fish.audio/mcp
      enabled: true
  ```
  PITFALL: the agent's file tools **refuse** to write `~/.hermes/config.yaml`
  ("security-sensitive configuration"). The user must edit it directly or use
  `hermes config`, then reload MCP. Hand them the YAML block; don't try to patch
  the file. The `{"mcpServers": {...}}` JSON the user may paste is the
  Claude-Code/Cursor/Codex format — translate it to the `mcp_servers:` YAML shape
  for Hermes.
