# Sequential ingest + conductor (user corrections)

Live project: `/Users/activi/Code/Projects/hermes-meta-builder`

## Do not skip modules

After the engine exists, finish the current module before the next:

transcript + `sources/masterclass/m0N/WISSEN.md` + `playbooks/m0N-*.yaml` + catalog `status: ingested`.

`python3 scripts/next_module.py` prints the only allowed next id. Jump (e.g. m05 while m02 is open) = exit 1.

Jumping to “the videos that match the job” (Skills/Kanban/Security while 2 is open) was rejected. Same folder cut every time: `VORLAGE.md`.

Stale facts from an older video stay in that module’s WISSEN under “veraltet”. Do not delete the old sheet.

Optional `m01u` does not block `m02` unless the user asked to refresh install knowledge first.

## Simple German recap

If the user says they did not understand: short German, one table, no new strategy. Do not add scope.

## Conductor picker

Use `clarify` with `choices`. Recommended option first. Do not list the options inside the question string.

Empty timeout → do not invent answers. If they ask for the picker again, call `clarify` again (a markdown table is not the Auswahlfunktion).

## Draft filenames

Desktop may block `SOUL.md` and `AGENTS.md`. Write `SOUL.draft.md` / `OPS.draft.md`. Timeout ≠ consent. Do not retry via terminal.

## Second lane

LiveKit / Dograh / SIP / voice tests are **not** in the Tonbi chain. Do not silently add them to this repo. Second catalog or later repo after the user chooses.

## Graph note

`kanban` as how-we-work does not require job=`run_team`. Job can stay “build”; worker profile drafts satisfy the board.

Tonbi OpenRouter = he already had a key. MiMo = cheaper than default Opus, not “the Hermes model”.
