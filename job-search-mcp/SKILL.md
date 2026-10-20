---
name: job-search-mcp
description: Search for job listings through a JobSpy MCP server across boards such as Indeed, LinkedIn, Glassdoor, ZipRecruiter, Google Jobs, Bayt, Naukri, and BDJobs. Use when the user wants to find openings by role, location, company, remote status, recency, salary hints, easy-apply availability, or board-specific coverage, and when Codex has access to JobSpy MCP tools or needs to explain the required setup.
---

# Job Search MCP

# Overview

Use the JobSpy MCP tools to search multiple job boards through one interface. Prefer this skill when the user wants live job discovery rather than general career advice.

## Workflow

1. Check whether JobSpy MCP tools are available.
2. If they are not available, say so plainly and point to [references/jobspy-mcp.md](references/jobspy-mcp.md) for setup.
3. Clarify only the missing filters that materially change the search:
   role or keywords, location, remote or on-site, result count, recency, job type, and preferred sites.
4. Run the narrowest search that satisfies the request.
5. If the first search is empty or weak, broaden one constraint at a time:
   simpler keywords, larger radius, fewer boards, fewer filters, or longer recency window.
6. Summarize results in a user-friendly shortlist with direct links and the most decision-relevant fields.

## Search Strategy

- Prefer `indeed` for reliability and broad coverage.
- Use `linkedin` when the user specifically wants LinkedIn or needs richer company context, but expect rate limits.
- Use `google` or `zip_recruiter` as fallback boards when primary boards are sparse.
- Keep `results_wanted` modest at first, usually `10` to `25`.
- Use `hours_old` only when the user explicitly cares about freshness.
- Use `easy_apply` only when that filter matters because it can reduce result count sharply.
- For international Indeed searches, set `country_indeed` explicitly.
- Fetch full LinkedIn descriptions only when the user needs deeper qualification details.

## Output Rules

- Lead with the best matches, not raw dumps.
- Include title, company, location, remote status, source site, posting link, and salary when present.
- Mention when salary, job type, or posting date is missing instead of inferring.
- Call out when results are limited by rate limits or strict filters.
- Offer one sensible next refinement after the shortlist, for example broader radius or more boards.

## Troubleshooting

- If LinkedIn rate-limits, retry without LinkedIn and tell the user why.
- If zero jobs are returned, broaden the query before concluding there are no openings.
- If the user gives an unsupported country for Indeed, consult the reference and either map it correctly or ask for a supported country.
- If the user asks for setup or schema details, read [references/jobspy-mcp.md](references/jobspy-mcp.md).

## Reference

Read [references/jobspy-mcp.md](references/jobspy-mcp.md) when you need setup guidance, parameter names, supported sites, supported job types, or common failure handling.
