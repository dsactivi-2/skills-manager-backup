# Official usage endpoints

Source of truth for `api_cost.py`. Re-check docs if a call 404s.

## OpenRouter

- Key spend: `GET https://openrouter.ai/api/v1/key` Bearer `OPENROUTER_API_KEY`
  - `data.usage`, `usage_daily`, `usage_weekly`, `usage_monthly`, `limit`, `limit_remaining`
- Account credits: `GET https://openrouter.ai/api/v1/credits` Bearer management key
  - `data.total_credits`, `data.total_usage`
  - Regular keys return 403 "Only management keys"

## OpenAI

- `GET https://api.openai.com/v1/organization/costs?start_time=<unix>&bucket_width=1d&limit=N`
- Header: `Authorization: Bearer $OPENAI_ADMIN_API_KEY`
- User keys fail with missing scope `api.usage.read`

## xAI

Base: `https://management-api.x.ai`

- Prepaid: `GET /v1/billing/teams/{team_id}/prepaid/balance` — `total.val` is USD cents
- Usage: `POST /v1/billing/teams/{team_id}/usage`

```json
{
  "analyticsRequest": {
    "timeRange": {
      "startTime": "YYYY-MM-DD 00:00:00",
      "endTime": "YYYY-MM-DD 23:59:59",
      "timezone": "Etc/GMT"
    },
    "timeUnit": "TIME_UNIT_DAY",
    "values": [{"name": "usd", "aggregation": "AGGREGATION_SUM"}],
    "groupBy": ["description"],
    "filters": []
  }
}
```

Needs `XAI_MANAGEMENT_KEY` + `XAI_TEAM_ID`. Console: Settings / Users (management key), team in top bar.

Older collectors that POST `{start_date, end_date, granularity}` are stale.

## Deepgram

- `GET https://api.deepgram.com/v1/projects` — `Authorization: Token <key>`
- `GET /v1/projects/{id}/usage?start=YYYY-MM-DD&end=YYYY-MM-DD` — hours + requests
- `GET /v1/projects/{id}/balances` — prepaid if allowed
- STT member keys often 403 on usage

## ElevenLabs

- `GET https://api.elevenlabs.io/v1/user/subscription`
- Header: `xi-api-key`
- `character_count` / `character_limit` / `tier` / `current_overage`

## Related code

- CLI: `/Users/activi/Code/Projects/api-cost/api_cost.py`
- Heavier collectors (OpenRouter activity, OpenAI admin, xAI): `~/openclaw-mission-control/src/lib/provider-billing/`
