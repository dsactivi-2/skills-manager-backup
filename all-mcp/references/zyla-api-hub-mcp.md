# Zyla Api Hub Tools Reference

## account_status

Check the current user's account status, billing, and usage. Returns plan info, API call count, whether a credit card is on file, and any failed/pending payments. Use this to diagnose why API calls are blocked (missing card or failed payment). Requires the user's API key in the Authorization header.

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py account_status '{}'
```

---

## browse_catalog

Browse the full Zyla API Hub catalog with pagination. Use this to explore ALL public APIs beyond the top 500. Supports filtering by category and search keyword. Returns paginated results with total count and page info.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| category | string | No | Filter by category name (use list_categories to see available categories) |
| include_params | boolean | No | If true, include full endpoint parameters in the response (default: false, to keep responses compact) |
| page | number | No | Page number (default: 1) |
| per_page | number | No | Results per page (default: 20, max: 100) |
| search | string | No | Search keyword to filter APIs by name or description (server-side search across ALL public APIs) |
| sort | string | No | Sort order: "popularity", "newest", or "name" (default: popularity) |

### Example

```bash
python3 scripts/call-tool.py browse_catalog '{"category":"...","include_params":true,"page":0,"per_page":0,"search":"...","sort":"..."}'
```

---

## call_api

Call an API endpoint on Zyla API Hub. Requires the user's API key and a credit card on file. Billing is pay-per-successful-request: you only pay for 2xx responses. Each API has its own price per call (shown in get_api_info). There are no monthly subscriptions or minimums — charges appear on your credit card at the end of each billing cycle. If a 402 error is returned with a payment_url, the user MUST open that URL in their browser to add a credit card before retrying. Pass the api_id, endpoint_id, HTTP method, and parameters.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| api_id | number | Yes | The numeric API ID |
| endpoint_id | number | Yes | The numeric endpoint ID within the API |
| method | string | No | HTTP method: GET or POST (default: GET) |
| params | object | No | Key-value parameters to send with the request |

### Example

```bash
python3 scripts/call-tool.py call_api '{"api_id":0,"endpoint_id":0,"method":"...","params":{}}'
```

---

## get_api_info

Get full details of a specific Zyla API by its numeric ID. Returns the API name, description, category, and all endpoints with their parameters and example values.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| api_id | number | Yes | The numeric API ID (e.g. 781) |

### Example

```bash
python3 scripts/call-tool.py get_api_info '{"api_id":0}'
```

---

## get_payment_url

Get a Stripe Checkout URL so the user can add or update their credit card. REQUIRED after registration and whenever a 402 error occurs. The user must open the returned URL in their browser to add/update their card. Billing is pay-per-successful-request: no subscriptions, no monthly fees, no minimums. You are only charged for successful API responses (2xx). Prices vary per API (see get_api_info). API calls are blocked until a valid credit card is on file.

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py get_payment_url '{}'
```

---

## list_categories

List all available API categories on Zyla API Hub with the real count of public APIs in each. Use the category names returned here as the "category" parameter in browse_catalog to filter APIs by category. Example categories: Sports, Finance, Data, Science, etc.

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py list_categories '{}'
```

---

## register

Register a new Zyla API Hub account directly from the AI agent. Returns an API key AND a payment_url. The user MUST open the payment_url in their browser to add a credit card before making any API calls. Billing model: pay-per-successful-request with no monthly fees or minimums. Each API has its own per-call price. The credit card is only charged at the end of the billing cycle for actual usage. No authentication required to call this tool.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| email | string | Yes | Email address (must be unique) |
| name | string | Yes | Full name of the user |
| password | string | Yes | Password (min 8 characters) |

### Example

```bash
python3 scripts/call-tool.py register '{"email":"...","name":"...","password":"..."}'
```

---

## search_catalog

Search the Zyla API Hub catalog for APIs by keyword. Searches the cached top-500 first; if not enough results, automatically searches ALL public APIs server-side. Returns matching APIs with their ID, name, description, category, and endpoints summary.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| limit | number | No | Max results to return (default: 10) |
| query | string | Yes | Search keyword (e.g. "weather", "currency", "email validation") |

### Example

```bash
python3 scripts/call-tool.py search_catalog '{"limit":0,"query":"..."}'
```

---

