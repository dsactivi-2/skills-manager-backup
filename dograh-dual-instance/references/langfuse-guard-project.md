# Guard Langfuse project (not DograhEU)

User 2026-08-21: Guard is *our* Langfuse instance. Do not write scores/prompts to DograhEU or LocalM5 when the work is Guard Ready-to-Voice.

| | |
|--|--|
| Dograh | `https://guarddograh.activi.io` Org 1 |
| Langfuse project | `cmt0fi14g00fsad0i32qc7k5u` |
| pk prefix | `pk-lf-4302bc` |
| Host | `https://cloud.langfuse.com` |
| UI | `https://cloud.langfuse.com/project/cmt0fi14g00fsad0i32qc7k5u` |
| Key SoT | `organization_configurations` key `LANGFUSE_CREDENTIALS` |
| SSH | `snapshot-settings` / host `guardiandograh` |
| Postgres | database `postgres` (not `dograh`); `dograhfork-postgres-1` |
| Hermes MCP | none (`langfuse-voiceeu` and `langfuse-dograh-cloud` are other projects) |
| Modal `dograh-lf-scores` | DograhEU keys — wrong for Guard |

```sql
SELECT value::jsonb->>'project_id',
       left(value::jsonb->>'public_key', 12),
       value::jsonb->>'host'
FROM organization_configurations WHERE key='LANGFUSE_CREDENTIALS';
```

Never print `secret_key`. OTel: `dograh.org_id=1`, `conversation.id` = workflow_run_id. QA JSON in observations can exist while `scores: []`.

Ready-to-Voice: Fish `[calm]` in `greeting` leaks into TTS; keep tags in globalNode only. STT `nova-3-general` is not Bosnian. `create_workflow` needs `const x = wf.addTyped(...)`. `save_workflow` = draft; publish REST.
