# Builder start + Freigabe

## Freigabe phrases that allow apply (with backup)
- richte ein / setze um / installiere für Profil X
- erstelle und richte SOUL/Skills/MCP ein
- erstelle ein Profil namens X / erstelle eine hermes profil namens X
  → `hermes profile create <lowercase-hyphen>` (no clone) + backup stock SOUL + write live SOUL/AGENTS

Still: backup live files, draft under handoff, no workflow IDs in SOUL.

## Not Freigabe alone
- was schlägst du vor / erkläre / design talk

## Scoped Ja
„Ja, mach das“ only covers the last concrete offer. If create was explicitly later, drafts or a sysdiagnose copy are not `hermes profile create`. Ask again for create after the user reads the pack.

## Review pack before create
New specialized profile: SOUL.draft + AGENTS.full/draft + PROFILE_SPEC + SESSION_RESUME + HANDOFF + NEXT_ACTIONS + INDEX. Copy to `~/Downloads/` when the user will review. Stubs-only fail the quality bar.

## After apply
User must open **new** session: `hermes -p <profile>` with project workdir.
Default-profile chat does not load the specialized SOUL.
