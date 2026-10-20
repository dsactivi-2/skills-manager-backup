# Telesales Training Datasets for Voice Agents

Live-verified on 2026-07-10. All datasets are English — no Bosnian telesales dataset exists publicly. Strategy: use these for structure, then generate Bosnian variants with GPT-4.1.

## 1. CallCenterEN (AIxBlock 92k) — GOLD STANDARD

- **Source**: `huggingface.co/datasets/AIxBlock/92k-real-world-call-center-scripts-english`
- **Size**: 91,706 transcripts, ~10,500 audio hours
- **Type**: Real-world inbound + outbound calls (sales + support)
- **Accents**: Indian, American, Filipino English
- **License**: CC BY-NC 4.0 (non-commercial research)
- **Paper**: arXiv 2507.02958
- **Use for**: Studying real call structure, turn-taking patterns, objection handling, closing techniques

## 2. TeleSalesCorpus — TELESALES-SPECIFIC

- **Source**: `huggingface.co/datasets/ICIP/TeleSalesCorpus`
- **Type**: Real telemarketing dialogues + LLM-generated simulations
- **Annotation**: Sub-dialogue level — Opening, Pitch, Objection, Closing
- **Paper**: "AI-Salesman" (AAAI 2025)
- **Use for**: Understanding sales phase transitions, training phase-aware agents

## 3. SalesTalk Dataset — USER WILLINGNESS

- **Source**: `github.com/CyberAgentAILab/salestalk-dataset`
- **Size**: 109 dialogues, 3,289 utterances
- **Type**: Wizard-of-Oz (human playing agent)
- **Annotation**: User willingness — to engage, to provide info, to accept objective
- **Paper**: COLING 2025
- **Use for**: Teaching agent to detect lead temperature (hot/warm/cold)

## 4. Synthetic Datasets (Hugging Face)

- `goendalf666/sales-conversations` — Generated sales dialogues
- `DeepMostInnovations/saas-sales-conversations` — SaaS sales, 100k+ conversations
- `goendalf666/sales-conversations-instruction-base` — Instruction-tuning format
- **Use for**: Quick prompt engineering tests, NOT production training

## Bootstrapping a Bosnian Telesales Agent

1. Download CallCenterEN and TeleSalesCorpus
2. Extract conversation structure (phases, turn patterns, objection types)
3. Use GPT-4.1 to generate 50-100 Bosnian example dialogues with Aquaphor Smile context
4. Include variants: interested, hesitant, rejecting, wrong number, direct purchase
5. Cover all phases: Opening → Needs Assessment → Objection Handling → Qualification → Callback → Closing
6. Embed 5-8 best as few-shot examples in the system prompt
7. After 100+ live calls: build own Bosnian dataset from Deepgram Nova-3 (`bs`) transcripts
8. Label manually: Conversion / No-Conversion, objection type, call outcome

## Dograh MCP Setup (added 2026-07-12)

Dograh MCP ist als nativer Hermes MCP-Server konfiguriert. NIE Browser-Login fuer Dograh-Workflow-Arbeiten — immer MCP.

```bash
hermes mcp add dograh --url https://api.dograh.com/api/v1/mcp/ --auth header
```

Workflow 8107 = Aquaphor Smile Telesales (Bosnisch, Outbound).
Lesen: `get_workflow(workflow_id=8107)`, Speichern: `save_workflow(workflow_id=8107, code=...)`.
