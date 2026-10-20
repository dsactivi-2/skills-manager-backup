# Soniox docs MCP (public HTTP)

## Endpoint
- URL: `https://soniox.com/docs/api/mcp/mcp`
- Auth: none
- Hermes name: `soniox-docs`

## Install (agent-safe)
```bash
hermes mcp add soniox-docs --url "https://soniox.com/docs/api/mcp/mcp" <<'EOF'
n
Y
EOF
hermes mcp test soniox-docs
```

First interactive prompt = auth Y/n → `n`. Second = enable all tools → `Y`.
Without stdin, the CLI can cancel mid-prompt and leave nothing saved.

## Tools
| Tool | Use |
|------|-----|
| soniox_search_docs | NL search first |
| soniox_read_page | full page by relative or absolute docs URL |
| soniox_read_section | page + heading/anchor |
| soniox_docs_toc | broad nav |
| soniox_docs_summary | llms.txt overview |
| soniox_full_docs | last resort, huge |

Prefer search → section/page. Avoid full_docs unless offline bulk needed.

## Session caveat
`hermes mcp test` green ≠ tools in **current** chat. Need `/reload-mcp` or new session.

## Related product skill
`soniox-voice-platform` — BS/EU/TTS voices/clone/LiveKit for telesales stack pick.
