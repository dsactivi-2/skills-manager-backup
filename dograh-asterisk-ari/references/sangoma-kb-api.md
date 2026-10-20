# Sangoma FreePBX wiki (Space FP)

Docs site: `https://sangomakb.atlassian.net/wiki/spaces/FP/overview`  
REST (works with Atlassian API token + email):

- `https://sangomakb.atlassian.net/wiki/rest/api/space/FP`
- `https://sangomakb.atlassian.net/wiki/rest/api/content?spaceKey=FP&limit=…`

Env (no chat/brief): `~/.hermes/secrets/atlassian.env`  
`ATLASSIAN_URL=https://sangomakb.atlassian.net/wiki`  
Python: `~/.hermes/venvs/atlassian` (`atlassian-python-api`). Prefer **requests + REST**; `Confluence.get_space` can return HTML.

This is Sangoma’s public KB, not a private Activi Jira cloud. Token user is the Atlassian account that can read Space FP.
