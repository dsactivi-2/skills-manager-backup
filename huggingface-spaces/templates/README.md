---
title: LoRA Demo
emoji: "\U0001F3A8"
colorFrom: purple
colorTo: pink
sdk: gradio
sdk_version: 5.50.0
app_file: app.py
short_description: FLUX.1-dev + LoRA text-to-image demo
python_version: "3.12"
startup_duration_timeout: 1h
---

# LoRA Demo

Demo-Space, der ein LoRA auf Basis von `black-forest-labs/FLUX.1-dev` lädt.
**Trigger-Wort:** im Prompt angeben, damit der LoRA-Stil aktiv wird.

## Hinweise
- **FLUX.1-dev ist gated.** Der HF-Account, unter dem dieser Space läuft, muss dessen
  Lizenz akzeptiert haben: https://huggingface.co/black-forest-labs/FLUX.1-dev
- Hardware: ZeroGPU (`zero-a10g`, large / 48 GB).

### ⚠️ Content-Hinweis (Sensitive Content)
Bei adult/NSFW-Inhalten: Space als **Sensitive Content** markieren und (empfohlen) **privat**
setzen. Generierte Inhalte unterliegen der Hugging Face Content Policy.
