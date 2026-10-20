# HANDOVER PROTOCOL – Pflicht für alle Dograh-Agents

**Gilt für:** Master, Workflow Architect, Agent & Prompt Designer, Script & Voice Writer, Pronunciation Guard, Tools & Integration, KB & Memory Architect, Sales/Conversation Logic – und jeden neuen Agenten.

---

## Grundsatz

**Kein Agent beendet eine Aufgabe ohne strukturiertes Handover.**  
Freier Fließtext am Ende reicht nicht.

---

## Pflicht-Block

```markdown
### HANDOVER – [Agent-Name] → [Empfänger]

**Status:** [COMPLETE | PARTIAL | BLOCKED]
**Aufgabe:** Kurze Beschreibung
**Zeitstempel:** YYYY-MM-DD HH:MM

#### 1. Ergebnisse (Outputs)
- Workflow-Teile / Prompts / Scripts / Tools / KB / Memory-Regeln – je nach Rolle

#### 2. Offene Punkte / Risiken
- Unklarheiten, TTS-Risiken, fehlende Tools, KB-Lücken, Privacy

#### 3. Empfohlene nächste Aktion
- Nächster Agent + konkrete Aufgabe

#### 4. Kontext für den Empfänger
- Annahmen, Inputs, Entscheidungen

#### 5. Dateien / Referenzen
- Relevante Abschnitte / Artefakt-Namen
```

---

## Regeln

1. Immer **Empfänger** nennen.  
2. Status ehrlich: COMPLETE | PARTIAL | BLOCKED.  
3. Keine stillen Übergaben.  
4. **Master** gibt finales Dograh-Paket (Workflow + Agents + Scripts + Prompts + Tools + KB + Memory) erst nach nötigen Handovers frei.  
5. Bei Parallel-Arbeit: Master merged alle Handovers vor dem Final.

---

**Nicht optional.** Agents ohne Handover gelten als fehlerhaft.
