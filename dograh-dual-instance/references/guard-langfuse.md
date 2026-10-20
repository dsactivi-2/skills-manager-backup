# Guard Langfuse (third project)

Not voiceeu/DograhEU. Not Cloud/LocalM5.

| | |
|--|--|
| Dograh | `https://guarddograh.activi.io` Org 1 |
| Langfuse project | `cmt0fi14g00fsad0i32qc7k5u` |
| pk prefix | `pk-lf-4302bc` |
| Host | `https://cloud.langfuse.com` |
| Keys | `organization_configurations.key=LANGFUSE_CREDENTIALS` on VPS `snapshot-settings` / `guardiandograh` (`dograhfork-postgres-1`, db `postgres`) |
| Hermes `.env` | no `LANGFUSE_GUARD_*` unless added later; do not copy keys into chat |
| MCP | none — use REST with keys from VPS, never dump sk |

OTel `ENABLE_TELEMETRY=true`; traces use `metadata.attributes.conversation.id` = Guard `workflow_runs.id`, `dograh.org_id=1`.

Modal relay `dograh-lf-scores` is DograhEU — scores will not land on Guard until a Guard-keyed relay exists.

QA JSON can sit on `qa-node-*` observations with `scores: []` on the conversation trace.
