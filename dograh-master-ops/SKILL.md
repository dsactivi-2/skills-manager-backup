# Skill: dograh-master-ops

**Name:** dograh-master-ops  
**Für:** Master Orchestrator only  
**Install:** `.grok/skills/dograh-master-ops/SKILL.md`

## Wann nutzen

- Jede Installations-Session
- Jeder komplette Dograh-Paket-Build
- QC vor Final-Output

## Phase A – Self-Setup Checklist

1. Lese `MASTER_SELF_PROFILE.md` und diese Skill-Datei.
2. Schreibe Persona `dograh-master-installer.toml` nach:
   - `$TARGET/.grok/personas/`
   - `~/.grok/personas/`
3. Installiere Skills laut `SKILLS_TO_INSTALL.md`.
4. Dokumentiere/aktiviere Tools laut `TOOLS_TO_ENABLE.md`.
5. Stelle `master-orchestrator.md` unter `.grok/agents/` sicher.
6. Handover an dich selbst (logisch): Phase A COMPLETE → Phase B freigeben.

## Phase B – Pack Install Checklist

1. ZIP: `/Users/activi/AI Bibliothek/Dograh-Grok-Build-Complete-Setup.zip`
2. Entpacken nach `$TARGET/dograh-grok-setup` oder Setup-Root.
3. `bash scripts/auto-install.sh "$TARGET"` oder `python3 scripts/auto_install.py "$TARGET"`.
4. Architecture nach `$TARGET/architecture` kopieren falls nicht enthalten.
5. Models TOML nach `~/.grok/dograh-models-and-subagents.toml` + merge Hinweis.
6. `grok inspect` im Target.
7. 9 Agents listen und non-empty prüfen.

## Spawn-Reihenfolge (Betriebsmodus, nach Install)

1. workflow-architect + sales-conversation-logic (parallel)
2. agent-prompt-designer
3. script-voice-writer + tools-integration + kb-memory-architect (parallel)
4. pronunciation-guard
5. Master merge → Final

## QC Gates vor Final Paket

- Handovers COMPLETE/PARTIAL begründet
- spoken vs stored getrennt
- Tools match Memory fields
- Never-store vorhanden
- 8 Paket-Teile: Workflow, Agents/Prompts, Scripts, Tools, KB, Memory, Handover-Summary, Offene Punkte
