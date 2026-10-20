# Local Simulation for Dograh Voice Agents

## Purpose
Simulate training dialogues locally with the production LLM before running expensive Dograh test calls. Finds prompt weaknesses in minutes instead of hours.

## Script
`scripts/simulate_dialogues.py` in the project directory.

## How it works
1. Loads all dialogues from `data/training_dialogues.jsonl`
2. For each dialogue: feeds customer turns to GPT-4.1, collects agent responses
3. Evaluates each conversation on 5 dimensions (1-10):
   - opening: short, clear entry
   - flow: logical conversation flow
   - objection_handling: handling of objections
   - closing: clear next step or conclusion
   - naturalness: natural Bosnian language
4. Outputs `data/simulation_results.jsonl` with full conversations and scores
5. Reports top 3 and bottom 3 dialogues

## Evaluation rubric
- 1.0-2.9: critical — agent fails basic conversation
- 3.0-4.9: weak — major issues in multiple dimensions
- 5.0-6.9: average — functional but rough
- 7.0-8.4: good — solid performance, minor issues
- 8.5-10.0: excellent — near-human quality

## Common failure patterns (from real simulation runs)
- **Closing weakness (score 6.8 avg)**: Agent forgets to establish a clear next step. Fix: add explicit closing instructions in the prompt.
- **Objection handling (score 7.1 avg)**: Sometimes too pushy, sometimes ignores objections. Fix: add structured objection-handling rules.
- **Repetitive/mechanical speech**: Agent repeats phrases or sounds scripted. Fix: add "ne ponavljaj iste recenice" rule.
- **Ignoring customer answers**: Agent pushes product without responding to what customer said. Fix: add "prvo odgovori na ono sto je osoba rekla" rule.

## Simulation → analysis → prompt-fix loop
After running simulations, follow this loop to systematically improve the prompt:
1. **Run simulation**: 50 dialogues, collect scores and full conversations.
2. **Identify bottom 3**: Read the full conversation transcripts of the worst-scored dialogues.
3. **Find patterns**: Look for recurring failure modes (e.g. "ignores rejection signals", "no clear closing", "repeats questions 4+ times").
4. **Encode as explicit rules**: Add a `## KRITICNE GRESKE` section to the globalNode prompt with numbered, concrete rules. Each rule must state: (a) what to detect, (b) what to do, (c) what NOT to do.
5. **Re-simulate**: Run the simulation again and verify scores improve.
6. **Only then run real Dograh test calls** on the 3-5 worst cases.

### Example KRITICNE GRESKE rules (from Aquaphor Smile project)
```
1. PREPOZNAJ ODBIJANJE ODMAH: "ne", "nisam", "smorio sam se" → SOFORT beenden. Kein Nachfragen.
2. SVAKI ODGOVOR MORA IMATI JASAN ZAVRSETAK: Nur 3 Optionen: Kauf-Frage, konkreter nächster Schritt, oder "Hvala, ugodan dan".
3. SLUSAJ, NE PRATI SKRIPTU: Erst auf das antworten was der Kunde sagt, dann weitermachen.
4. TRI PUTA JE MAKSIMUM: Gleiche Frage max. 3x, dann "nije pravi trenutak" und Ende.
```

## When to use
- After any prompt change to the workflow
- Before running real Dograh test calls
- When adding new training dialogues
- When switching LLM models

## Cost
~$0.50-1.00 for 50 dialogues with GPT-4.1 (vs $5-15 for 50 real Dograh test calls)
