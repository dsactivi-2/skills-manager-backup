# JobSpy MCP Reference

## Use This Reference For

- Setup questions
- Parameter names and defaults
- Supported sites and job types
- Failure handling and query refinement

## Setup

The source skill expects a JobSpy MCP server to be installed separately. The referenced setup paths are:

- Python packages: `mcp`, `python-jobspy`, `pandas`, `pydantic`
- Prebuilt server option: `https://github.com/chinpeerapat/jobspy-mcp-server`
- Example install command from the source page: `openclaw skills install job-search-mcp`

If the current Codex environment does not expose JobSpy MCP tools, explain that limitation instead of pretending the search can run.

## Primary Tool

### `scrape_jobs_tool`

Use for nearly every live search.

Common parameters:

- `search_term`: required keywords such as `software engineer`
- `location`: city, region, or `Remote`
- `site_name`: boards to query; default boards in the source were `indeed`, `linkedin`, `zip_recruiter`, `google`
- `results_wanted`: number of results; keep early searches small
- `job_type`: `fulltime`, `parttime`, `internship`, `contract`
- `is_remote`: remote-only filter
- `hours_old`: recency window in hours
- `distance`: radius in miles
- `easy_apply`: easy-apply filter
- `country_indeed`: country selector for Indeed or Glassdoor style searches
- `linkedin_fetch_description`: fetch full LinkedIn descriptions, slower
- `offset`: pagination offset

## Helper Tools

- `get_supported_countries`: use when country handling is unclear
- `get_supported_sites`: use when the user asks which boards are covered
- `get_job_search_tips`: use for general search advice

## Supported Sites

- `indeed`
- `linkedin`
- `glassdoor`
- `zip_recruiter`
- `google`
- `bayt`
- `naukri`
- `bdjobs`

## Expected Result Fields

Common result fields include:

- `title`
- `company`
- `job_url`
- `location.country`
- `location.city`
- `location.state`
- `is_remote`
- `description`
- `job_type`
- `salary.min_amount`
- `salary.max_amount`
- `salary.interval`
- `salary.currency`
- `date_posted`

Some boards may also return company metadata, skills, experience range, rating, or vacancy count.

## Failure Handling

- LinkedIn rate limit:
  remove LinkedIn, reduce result count, or retry on other boards first.
- No results:
  simplify keywords, widen radius, remove strict filters, or add other sites.
- Invalid country:
  fetch supported countries before retrying.
