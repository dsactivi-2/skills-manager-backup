# Telnyx Tools Reference

## get_api_endpoint_schema

Get the schema for an endpoint in the Telnyx TypeScript API. You can use the schema returned by this tool to invoke an endpoint with the `invoke_api_endpoint` tool.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| endpoint | string | Yes | The name of the endpoint to get the schema for. |

### Example

```bash
python3 scripts/call-tool.py get_api_endpoint_schema '{"endpoint":"..."}'
```

---

## invoke_api_endpoint

Invoke an endpoint in the Telnyx TypeScript API. Note: use the `list_api_endpoints` tool to get the list of endpoints and `get_api_endpoint_schema` tool to get the schema for an endpoint.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| args | object | Yes | The arguments to pass to the endpoint. This must match the schema returned by the `get_api_endpoint_schema` tool. |
| endpoint_name | string | Yes | The name of the endpoint to invoke. |

### Example

```bash
python3 scripts/call-tool.py invoke_api_endpoint '{"args":{},"endpoint_name":"..."}'
```

---

## list_api_endpoints

List or search for all endpoints in the Telnyx TypeScript API

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| search_query | string | No | An optional search query to filter the endpoints by. Provide a partial name, resource, operation, or tag to filter the endpoints returned. |

### Example

```bash
python3 scripts/call-tool.py list_api_endpoints '{"search_query":"..."}'
```

---

## open_number_intelligence

Open the Telnyx Number Intelligence MCP App for phone number lookup, validation, and enrichment workflows.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| action | string | No | Optional no-op app opener action; omit to open the app. |

### Example

```bash
python3 scripts/call-tool.py open_number_intelligence '{"action":"..."}'
```

---

## open_usage_cost_explorer

Open the Telnyx Usage & Cost Explorer MCP App for usage and cost analysis.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| action | string | No | Optional no-op app opener action; omit to open the app. |

### Example

```bash
python3 scripts/call-tool.py open_usage_cost_explorer '{"action":"..."}'
```

---

## open_voice_monitor

Open the Telnyx Voice Monitor MCP App for observing and troubleshooting voice traffic.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| action | string | No | Optional no-op app opener action; omit to open the app. |

### Example

```bash
python3 scripts/call-tool.py open_voice_monitor '{"action":"..."}'
```

---

