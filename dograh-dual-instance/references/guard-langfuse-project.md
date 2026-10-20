# Guard Dograh Langfuse project

Not voiceeu, not Cloud. Guard OTel + scores belong **only** here.

| | |
|--|--|
| Dograh | `https://guarddograh.activi.io` Org 1 |
| Langfuse project | `cmt0fi14g00fsad0i32qc7k5u` |
| Public key prefix | `pk-lf-4302bc` |
| Host | `https://cloud.langfuse.com` |
| Keys live | Postgres `organization_configurations.key=LANGFUSE_CREDENTIALS` on VPS `snapshot-settings` / `guardiandograh` |
| Hermes MCP | none (`langfuse-voiceeu` / `langfuse-dograh-cloud` are other projects) |

## Do

- Score configs / prompts for Guard WF → this project (read pk/sk from org JSON on the VPS; never print sk).
- STT/TTS observations: **no host URL** in Langfuse. `GET https://api.deepgram.com/v1/projects` in API logs is **key check US**, not inference.

## Do not

- Create Guard scores on DograhEU or LocalM5.
- Treat VoiceOps `list_langfuse_traces` as Guard SoT (those keys may be another project).
- Claim Modal `dsactivi-2--dograh-lf-scores` writes Guard scores (secret is DograhEU).
