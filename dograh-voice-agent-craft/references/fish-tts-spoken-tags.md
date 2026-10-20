# Fish TTS: tags must not be spoken (Guard, 2026-08-21)

Live: Ready-to-Voice on `guarddograh` WF5/WF6. TTS model `s2.1-pro`. Bot text `[calm] Dobar dan ... ovdje Amina.` was the TTS **input**. Ellipsis became `.. .`.

## Do
- `greeting`: plain speech only (`Dobar dan, ovdje Amina.`).
- `#GOVOR`: the sentence the caller should hear, never “eine Frage: hat die Person…”.
- globalNode may **name** Fish tags (`[calm]` …) only with “never put brackets in spoken text”.
- Pause = period/comma, not `...`.
- `save_workflow` = draft. User publishes. Ready-to-Voice = published version.

## Do not
- Put `[calm]`/`[happy]`/`[empathetic]` in `greeting` or LLM spoken turns.
- Auto-`POST /workflow/{id}/publish` after a prompt save.
