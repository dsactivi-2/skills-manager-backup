# TurnDetector + Telesales (Amina / BiH)

## TurnDetector — nicht „Bosnisch aus“

Audio-`inference.TurnDetector()` **funktioniert** ohne `bs` in der 14er-Schwellen-Liste. Unmapped = Werks-Default. Nicht abschalten.

„bs bauen“ = **eine Zahl** `unlikely_threshold` (Scalar, Amina spricht nur bs). Kein neues Modell.

```python
TurnDetector(unlikely_threshold=float(os.getenv("AMINA_TURN_BS_THRESHOLD", "0.55")))
# Höher = wartet länger. Jederzeit Env, Worker neu.
# Nicht {"bs": 0.55} — Dict-Key kann intern unmapped bleiben.
```

`TurnHandlingOptions` in Agents 1.6 = **TypedDict** (`turn_detection`, `endpointing`, `interruption`). `min_consecutive_speech_delay` hängt an `AgentSession`.

Soniox-Tags (`[pause]`) ≠ LiveKit-Endpointing. Beides nötig. Tags fest lang = Metronom.

## Verkauf (User-Korrekturen)

- Satz 1: wer + **Produkt/Bokal**, nicht 3 Sätze Checkliste ohne Thema
- Weiches Nein / „keine Zeit“ ≠ Auflegen. Hart nur DNC / „nicht anrufen“
- Auf **letzte Kundenworte** eingehen (Flaschen → Flaschen)
- Wissen: eine Faktenkarte, kein RAG zuerst. NSF/Preis nicht erfinden
- Nicht bauen bis User **so bauen**; Deploy extra OK
- Jargon-Tabellen auf Nachfrage **in einfachen Worten** erklären

Langfuse-OTLP-Code lokal ≠ Cloud-Secrets. eu-central am Agent-ID prüfen (`lk agent list`), nicht nur toml-Dateiname. Drei leere us-east-IDs nicht für Amina nutzen.
