---
title: <TRIGGER> LoRA Demo
emoji: "\U0001F3A8"
colorFrom: purple
colorTo: pink
sdk: gradio
sdk_version: 5.50.0
app_file: app.py
short_description: FLUX.1-dev + <TRIGGER> LoRA text-to-image demo
python_version: "3.12"
startup_duration_timeout: 1h
---

# <TRIGGER> — FLUX.1-dev LoRA Demo

Demo-Space, der das LoRA `<owner>/<lora-repo>` auf Basis von
`black-forest-labs/FLUX.1-dev` lädt und Text-zu-Bild generiert.

**Trigger-Wort:** `<TRIGGER>` — muss im Prompt stehen, damit der LoRA-Stil aktiv wird.

## Verwendung
1. Prompt eingeben (inkl. `<TRIGGER>`).
2. `Generate` klicken.
3. Ergebnisbild erscheint rechts.

Parameter: Steps (28 Default), Seed, Guidance Scale (3.5 Default, flowmatch).

## Hinweise / Voraussetzungen
- **FLUX.1-dev ist ein gated Modell.** Der HF-Account, unter dem dieser Space läuft,
  muss dessen Lizenz akzeptiert haben: https://huggingface.co/black-forest-labs/FLUX.1-dev
- Hardware: ZeroGPU (`zero-a10g`, large / 48 GB) — FLUX.1-dev bf16 passt hinein.

---

### ⚠️ Content-Hinweis (Sensitive Content)
<If this LoRA is adult/NSFW-oriented: state that here, mark the Space as Sensitive Content
in its HF settings before making it public, and prefer PRIVATE. Generated content is
subject to the Hugging Face Content Policy.>

Quelle: https://huggingface.co/<owner>/<lora-repo>
