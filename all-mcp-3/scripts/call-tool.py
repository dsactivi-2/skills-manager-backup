#!/usr/bin/env python3
"""
MCP2Skill MCP Tool Caller

Usage:
    python3 call-tool.py <tool_name> [arguments_json]

Examples:
    python3 call-tool.py resolve-library-id '{"libraryName": "react", "query": "hooks"}'
    python3 call-tool.py query-docs '{"libraryId": "/vercel/next.js", "query": "routing"}'

Environment Variables:
    MCP2SKILL_ENDPOINT  - Override the gateway base URL (e.g. http://192.168.1.100:3571)
    MCP2SKILL_API_KEY   - API key for gateway authentication
"""

import json
import os
import sys
import urllib.request
import urllib.error

# MCP2Skill Gateway base URL (override via MCP2SKILL_ENDPOINT env var)
_DEFAULT_BASE_URL = "http://localhost:3571"
# Endpoint path for this skill (not overridable)
_ENDPOINT_PATH = "/all"

BASE_URL = os.environ.get("MCP2SKILL_ENDPOINT", _DEFAULT_BASE_URL).rstrip("/")
ENDPOINT = BASE_URL + _ENDPOINT_PATH
API_KEY = os.environ.get("MCP2SKILL_API_KEY", "")


def call_tool(tool_name: str, arguments: dict) -> dict:
    """Call an MCP tool via MCP2Skill Gateway."""
    payload = json.dumps({
        "jsonrpc": "2.0",
        "method": "tools/call",
        "params": {
            "name": tool_name,
            "arguments": arguments
        },
        "id": 1
    }).encode("utf-8")

    headers = {"Content-Type": "application/json"}
    if API_KEY:
        headers["Authorization"] = f"Bearer {API_KEY}"
    headers["X-Title"] = "Hermes Agent"


    req = urllib.request.Request(
        ENDPOINT,
        data=payload,
        headers=headers,
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return {"error": f"HTTP {e.code}: {e.reason}"}
    except urllib.error.URLError as e:
        return {"error": f"Connection failed: {e.reason}. Is MCP2Skill Gateway running?"}
    except Exception as e:
        return {"error": f"Unexpected error: {e}"}


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    tool_name = sys.argv[1]
    arguments = {}

    if len(sys.argv) > 2:
        try:
            arguments = json.loads(sys.argv[2])
        except json.JSONDecodeError as e:
            print(f"Error: Invalid JSON arguments: {e}", file=sys.stderr)
            sys.exit(1)

    result = call_tool(tool_name, arguments)
    print(json.dumps(result, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
