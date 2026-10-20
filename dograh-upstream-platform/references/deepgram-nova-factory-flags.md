# Deepgram Nova factory flags (dograh-devshift / dograhV2)

Verified 2026-08 against `/Users/activi/Projects/dograh-devshift` factory + Pipecat submodule `DeepgramSTTSettings` + official Deepgram endpointing docs. Not an org-UI field.

## Effective Nova path (US + EU share one dict)

Factory builds `settings_kwargs` then `DeepgramSTTSettings(**settings_kwargs)`. EU only adds `extra.tag=["dograh","eu"]` + `base_url=api.eu.deepgram.com`. US sends no usage tags.

Pipecat `FishAudioTTSService`/`DeepgramSTTService` `apply_update` copies **only given** fields. Omitted keys keep the service `__init__` defaults (`punctuate=True`, `smart_format=False`, `diarize=False`).

## String-replace scripts

Match the **live** Nova block (kwargs dict vs keyword `DeepgramSTTSettings(...)`). Insert helpers **before** `@_report_service_factory_failures` + `def create_stt_service`, never between them (decorator theft → all STT loses failure metadata). Abort if the exact block is missing. Do not overwrite a filled vocab file on re-run.

## Endpointing (not UI)

Deepgram `endpointing` = ms of silence until `speech_final`. Official default 10ms; official examples use 300. This fork hardcoded 100 until the Nova helper. dograhV2 `DEEPGRAM_3` used 400. Not in `PUT /user/configurations/user`. Tune from live cut-off vs dead-air, one value per image.

`utterance_end_ms` is a different lever (≥1000, needs `interim_results`). Flux uses `eot_timeout_ms`, not `endpointing`.

## Diarize

Labels words `speaker: 0/1`. Does **not** drop a second talker. Pipecat pushes `alternatives[0].transcript` only. Telephony is mono ulaw — room/shouting still lands in the same string unless extra filter code exists. Leave off unless that filter is written.

Sources: https://developers.deepgram.com/docs/endpointing · https://developers.deepgram.com/docs/diarization · https://developers.deepgram.com/docs/multichannel-vs-diarization
