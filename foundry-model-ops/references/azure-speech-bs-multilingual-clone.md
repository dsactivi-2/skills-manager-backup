# Azure Speech: BS multilingual + Personal Voice (live 2026-07-30)

Resource: `vesna` / `rg-dsselmanovi` / `germanywestcentral` / SpeechServices S0.  
Sister: `mujo` / `xhhh` / `westeurope`.

## Voice list facts (GET …/tts.speech…/voices/list)

- Total neural voices seen: 556
- Native BS: `bs-BA-VesnaNeural` (F), `bs-BA-GoranNeural` (M) — GA, ~135 wpm, **no StyleList**, 48 kHz
- EN Multilingual with `bs-BA` in SecondaryLocaleList: **29** (e.g. Ava, Andrew, Emma, Brian, Ada/Ollie GB, William AU, *TurboMultilingual*)
- Andrew Multilingual StyleList example: `empathetic`, `relieved`
- DragonHD / Omni / HDLatest short names on this list: **0**

## SSML language switch (Multilingual)

Required for reliable BS:

```xml
<voice name="en-US-AvaMultilingualNeural">
  <lang xml:lang="bs-BA">…bosanski tekst…</lang>
</voice>
```

Without `<lang>`, autodetect may still speak BS but can drop brand/content (live Ava auto vs lang on Aquaphor line).

## Prosody only on Vesna (no express-as styles)

```xml
<voice name="bs-BA-VesnaNeural">
  <prosody rate="+8%" pitch="+4%">Dobar dan!</prosody>
  <break time="250ms"/>
  <prosody rate="-5%">…</prosody>
</voice>
```

Dograh often maps org `speed` → SSML `rate` only; do not assume agent-emitted full SSML survives Pipecat escape.

## Quality probe recipe

1. Synth MP3 24 kHz via REST SSML.
2. Convert to 16 kHz mono WAV for STT (`ffmpeg -ac 1 -ar 16000`).
3. Azure conversation STT: **mp3 body often empty transcript**; use WAV.
4. `language=bs-BA` conf can be low/noisy; **`hr-HR` STT** was a stronger intelligibility proxy on the same BKS samples (live).
5. Compare Vesna vs Ava+lang on same script (native phonetics vs livelier multi + EN brands).

## Personal Voice

- Docs: personal voice target locales include **`bs-BA`** (language support TTS tab).
- Overview: ~1 min speech + verbal statement; gated API; multilingual output after `speakerProfileId`.
- Live list empty on `vesna` — profiles not created; endpoint healthy.
- Intake: https://aka.ms/customneural (and Speech Studio Personal Voice demo on S0).

## Foundry catalog (SE same day)

`tts`, `tts-hd` Standard only — **no clone**. Prefer Speech for BS persona work.

## Activi defaults

| Goal | Choice |
|------|--------|
| BiH prod EU | Vesna/Goran GWC + speed/prosody/text pacing |
| Less monotone, still Azure EU | A/B EN Multilingual + `lang bs-BA` |
| Own warm BS voice | Personal Voice (consent) → synth BS |
| Foundry model deploy | never for sample clone |