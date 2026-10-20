# When the user named Soniox TTS (not Fish)

`livekit-voice-build` Fish allow-list is **not** the Soniox list.

- Fish: `[joyful]` not `[happy]` / `[calm]` (those are Dograh leftovers on Fish).
- Soniox: `[happy]` and `[calm]` **are** official English audio tags.
- Mixing lists → unknown `[…]` get **spoken**.

If the brief is Deepgram Nova 3 + GPT-4.1 + Soniox: load
`soniox-voice-platform`, use
https://soniox.com/docs/tts/concepts/emotion-and-tone, put a strip-wrapper
between GPT and `tts.say` (`references/strip-wrapper.md` on that skill).

Do not recommend ElevenLabs/Fish/Retell tag videos as the teaching path.
