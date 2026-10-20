# Review evidence

## Tags

| Tag | Supports | Does not support |
|---|---|---|
| `GRAPH` | Current node configuration and connections | Runtime behavior |
| `EXEC` | A concrete execution's observed behavior | Untested paths |
| `PIN` | The tested pinned path | External effects and other inputs |
| `LIVE` | An explicitly approved real run | General behavior beyond that run |

Use `ANNAHME` only for an inferred intended contract, never as proof of actual
behavior.

## Verdicts

| Verdict | Meaning |
|---|---|
| `PASS` | Expected behavior is observed and evidenced |
| `TEIL` | Main path works but a relevant path fails or lacks evidence |
| `FAIL` | Expected behavior is contradicted by evidence |
| `UNGETESTET` | A relevant case has no safe evidence yet |
| `BLOCKIERT` | Access, permissions, tool support, or required input is missing |

## Pin-test limits

Pin data must be synthetic and follow the schema returned by
`prepare_workflow_pin_data`. Pin tests do not prove external authentication,
database writes, mail delivery, payments, SIP calls, or carrier/media behavior.
Non-pinned Code, file, Data Table, Execute Command, and sub-workflow nodes can
still run, so disclose them before asking for test approval.

## Data minimization

Inspect execution data in stages: metadata first, then only the necessary node
names and a small sample. Redact tokens, credentials, JWTs, email addresses,
phone numbers, addresses, and free text before reporting.
