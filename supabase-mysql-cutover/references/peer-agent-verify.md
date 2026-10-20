# Peer-agent CRM change: verify, don’t re-apply

When the user pastes another agent’s “I applied X / next I’ll do Y”:

1. Live-check with MCP SQL (`pg_proc`, `pg_policy`, grants, counts). Do not trust the paste.
2. Document deltas in `dsactivi-2/jobstep-crm-status-mcp` (`docs/NN_*.md` + backlog ticks).
3. Commit + push. No secrets.
4. Do **not** re-run the pasted SQL. Do **not** start the offered next step (RLS, smoke, healthcheck, seed, GRANT) without a Freigabe line.
5. If they ask “commit und” plus the same paste: add missing docs if any; no empty commit.

## Jobstep facts that keep coming back

- English UUID/`public.candidates`/`new→hired`/`crm_api.set_candidate_status` UUID snippets are **wrong**. IDs are integer `kandidat_id`; prijave 1–27.
- `authorize()` uses `auth.uid()` + `user_roles`. Empty map → always forbidden. Pooler role `activi` is not a JWT user.
- After DEFINER hardening, grant EXECUTE to `activi` on anything the stdio MCP must call — or it only works as `authenticated`.
- `*_safe` and `smoke_test_*` were authenticated/service_role only; old `set_candidate_status` still had `activi`.
- Two people stacks: `idk_kandidati` vs DIPL `idk_nd_kandidata`. PDFs = hash names on the PHP host (`private/<subdomain>_files/`), not bytea.
