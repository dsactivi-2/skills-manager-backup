# Builder starten — plain DE (Barbarez)

## Was es NICHT ist
- Kein separates „Builder“-Programm
- Kein `apt install`
- Kein manuelles Starten aller Skill-Namen

## Was es IST
Neue Hermes-Session im Profil **barbares** im Aquaphor-Projekt:

```bash
cd ~/Code/Tools/dograh-aquaphor-telesales
hermes -p barbares
```

| Geladen | Inhalt |
|---------|--------|
| SOUL.md | Wer Barbarez ist, Ziel voiceeu, 3-Wege |
| config.yaml | Modell, MCP dograh-voiceeu, Memory |
| .env (Profil) | API-Keys |
| skills/ | three-lanes, dograh, … |
| AGENTS.md (Projekt) | Ops wenn Workdir = Projekt |

## Warum neue Session
SOUL wird beim Start in den System-Prompt gebacken. Ein Chat als **default** bleibt default.

## Skills-Liste in Verify-Reports
Namen wie `barbarez-three-lanes`, `german-voice-prompts` = **Vorrat im Profil**. Agent lädt bei Bedarf via skill_view — User muss sie nicht tippen zum Starten.
