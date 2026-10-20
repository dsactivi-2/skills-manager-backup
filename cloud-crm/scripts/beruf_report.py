#!/usr/bin/env python3
"""One-shot Berufs-Report gegen denselben Cloudflare-Worker (Hyperdrive -> MySQL).

Zaehlt eindeutige, nicht archivierte Kandidaten in einem MCP-tools/call.
Kein Neon, kein lokales MySQL. Token aus ~/.codex/crm-remote-mcp.token.
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

TOKEN_FILE = Path.home() / ".codex" / "crm-remote-mcp.token"
URL = "https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp"
UA = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
)

BAU_SQL = r"""
SELECT part, k, n
FROM (
  SELECT 'total' AS part, 'all' AS k, COUNT(DISTINCT k.kandidat_id) AS n
  FROM idk_kandidati k
  WHERE k.kandidat_status <> 3
    AND EXISTS (
      SELECT 1 FROM idk_kandidat_radno_iskustvo w
      WHERE w.kri_kandidat_id = k.kandidat_id
        AND (
          w.kri_pozicija LIKE '%građev%'
          OR w.kri_pozicija LIKE '%gradev%'
          OR w.kri_pozicija LIKE '%gradjev%'
          OR w.kri_pozicija LIKE '%bauarbeiter%'
          OR w.kri_pozicija LIKE '%bauhelfer%'
          OR w.kri_pozicija LIKE '%tiefbau%'
          OR w.kri_pozicija LIKE '%niskograd%'
          OR w.kri_pozicija LIKE '%visokograd%'
          OR w.kri_pozicija LIKE '%asfalt%'
          OR w.kri_pozicija LIKE '%bagerist%'
          OR w.kri_pozicija LIKE '%bagger%'
          OR w.kri_pozicija LIKE '%baumaschinen%'
          OR w.kri_pozicija LIKE '%bautechniker%'
          OR w.kri_pozicija LIKE '%bauingenieur%'
          OR (w.kri_pozicija LIKE '%cestar%' AND w.kri_pozicija NOT LIKE '%cestarin%')
          OR (w.kri_pozicija LIKE '%putar%' AND w.kri_pozicija NOT LIKE '%putarin%')
          OR w.kri_pozicija LIKE '%ophodnja cesta%'
          OR w.kri_pozicija LIKE '%održavanje cesta%'
          OR w.kri_pozicija LIKE '%odrzavanje cesta%'
          OR w.kri_pozicija LIKE '%izgradnja%cesta%'
          OR w.kri_pozicija LIKE '%izgradnji puteva%'
        )
    )
  UNION ALL
  SELECT 'lang' AS part, COALESCE(lv.niveau, 'kein Deutsch erfasst') AS k, COUNT(*) AS n
  FROM (
    SELECT DISTINCT k.kandidat_id
    FROM idk_kandidati k
    JOIN idk_kandidat_radno_iskustvo w ON w.kri_kandidat_id = k.kandidat_id
    WHERE k.kandidat_status <> 3
      AND (
        w.kri_pozicija LIKE '%građev%'
        OR w.kri_pozicija LIKE '%gradev%'
        OR w.kri_pozicija LIKE '%gradjev%'
        OR w.kri_pozicija LIKE '%bauarbeiter%'
        OR w.kri_pozicija LIKE '%bauhelfer%'
        OR w.kri_pozicija LIKE '%tiefbau%'
        OR w.kri_pozicija LIKE '%niskograd%'
        OR w.kri_pozicija LIKE '%visokograd%'
        OR w.kri_pozicija LIKE '%asfalt%'
        OR w.kri_pozicija LIKE '%bagerist%'
        OR w.kri_pozicija LIKE '%bagger%'
        OR w.kri_pozicija LIKE '%baumaschinen%'
        OR w.kri_pozicija LIKE '%bautechniker%'
        OR w.kri_pozicija LIKE '%bauingenieur%'
        OR (w.kri_pozicija LIKE '%cestar%' AND w.kri_pozicija NOT LIKE '%cestarin%')
        OR (w.kri_pozicija LIKE '%putar%' AND w.kri_pozicija NOT LIKE '%putarin%')
        OR w.kri_pozicija LIKE '%ophodnja cesta%'
        OR w.kri_pozicija LIKE '%održavanje cesta%'
        OR w.kri_pozicija LIKE '%odrzavanje cesta%'
        OR w.kri_pozicija LIKE '%izgradnja%cesta%'
        OR w.kri_pozicija LIKE '%izgradnji puteva%'
      )
  ) bau
  LEFT JOIN (
    SELECT j.kj_kandidatid,
      CASE MAX(
        CASE
          WHEN j.kj_slusanje = 'C2' THEN 6
          WHEN j.kj_slusanje = 'C1' THEN 5
          WHEN j.kj_slusanje = 'B2' THEN 4
          WHEN j.kj_slusanje = 'B1' THEN 3
          WHEN j.kj_slusanje LIKE 'A2%' THEN 2
          WHEN j.kj_slusanje IN ('A1','A') THEN 1
          ELSE 0
        END
      )
        WHEN 6 THEN 'C2'
        WHEN 5 THEN 'C1'
        WHEN 4 THEN 'B2'
        WHEN 3 THEN 'B1'
        WHEN 2 THEN 'A2'
        WHEN 1 THEN 'A1'
        ELSE 'ohne Kenntnisse'
      END AS niveau
    FROM idk_kandidat_jezici j
    WHERE j.kj_naziv LIKE '%Njemački%'
       OR j.kj_naziv LIKE '%Njemacki%'
       OR j.kj_naziv LIKE '%Nemački%'
       OR j.kj_naziv LIKE '%Nemacki%'
       OR j.kj_naziv LIKE '%Deutsch%'
    GROUP BY j.kj_kandidatid
  ) lv ON lv.kj_kandidatid = bau.kandidat_id
  GROUP BY COALESCE(lv.niveau, 'kein Deutsch erfasst')
) x
ORDER BY part, n DESC
""".strip()


def parse_sse(text: str):
    text = text.strip()
    if not text:
        return None
    if text.startswith("{") or text.startswith("["):
        return json.loads(text)
    data = []
    for line in text.splitlines():
        if line.startswith("data:"):
            part = line[5:].strip()
            if part and part != "[DONE]":
                data.append(json.loads(part))
    if not data:
        return {"raw": text[:2000]}
    return data[0] if len(data) == 1 else data


class Mcp:
    def __init__(self, token: str):
        self.token = token
        self.session = None
        self._id = 0

    def rpc(self, method, params=None, notify=False, timeout=70):
        payload = {"jsonrpc": "2.0", "method": method}
        if not notify:
            self._id += 1
            payload["id"] = self._id
        if params is not None:
            payload["params"] = params
        hdr = Path("/tmp/crm_beruf_report.hdr")
        body = Path("/tmp/crm_beruf_report.body")
        cmd = [
            "curl", "-sS", "-D", str(hdr), "-o", str(body),
            "--max-time", str(timeout),
            "-H", "Authorization: Bearer " + self.token,
            "-H", "Content-Type: application/json",
            "-H", "Accept: application/json, text/event-stream",
            "-H", "User-Agent: " + UA,
            "-H", "MCP-Protocol-Version: 2025-03-26",
        ]
        if self.session:
            cmd.extend(["-H", "Mcp-Session-Id: " + self.session])
        cmd.extend(["-d", json.dumps(payload, ensure_ascii=False), URL])
        proc = subprocess.run(cmd, capture_output=True, text=True)
        h = hdr.read_text(errors="replace") if hdr.exists() else ""
        b = body.read_text(errors="replace") if body.exists() else ""
        for line in h.splitlines():
            if line.lower().startswith("mcp-session-id:"):
                self.session = line.split(":", 1)[1].strip()
        parsed = None
        try:
            parsed = parse_sse(b)
        except Exception as e:
            parsed = {"parse_error": str(e), "raw": b[:1500]}
        return {
            "curl": proc.returncode,
            "status": h.splitlines()[0] if h else None,
            "err": (proc.stderr or "")[-400:],
            "body": parsed,
            "raw": b[:1500],
        }


def tool_text(body):
    if not isinstance(body, dict):
        return body
    result = body.get("result") or {}
    if isinstance(result, dict) and result.get("content"):
        return result["content"][0].get("text")
    if body.get("error"):
        return json.dumps(body["error"], ensure_ascii=False)
    return json.dumps(body, ensure_ascii=False)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--preset", default="bau", choices=["bau"])
    ap.add_argument("--sql-only", action="store_true", help="SQL drucken, nicht ausfuehren")
    args = ap.parse_args()
    sql = BAU_SQL
    if args.sql_only:
        print(sql)
        return 0
    token = TOKEN_FILE.read_text().strip() if TOKEN_FILE.exists() else ""
    if not token:
        print("missing token file", TOKEN_FILE, file=sys.stderr)
        return 1
    t0 = time.time()
    mcp = Mcp(token)
    init = mcp.rpc("initialize", {
        "protocolVersion": "2025-03-26",
        "capabilities": {},
        "clientInfo": {"name": "cloud-crm-beruf-report", "version": "1.0"},
    }, timeout=25)
    if init["curl"] != 0 or not mcp.session:
        print(json.dumps({"ok": False, "step": "initialize", **{k: init[k] for k in ("curl","status","err","raw")}}, ensure_ascii=False))
        return 2
    mcp.rpc("notifications/initialized", {}, notify=True, timeout=15)
    call = mcp.rpc("tools/call", {"name": "crm_query", "arguments": {"sql": sql}}, timeout=70)
    elapsed = round(time.time() - t0, 2)
    text = tool_text(call.get("body"))
    parsed = None
    if isinstance(text, str):
        try:
            parsed = json.loads(text)
        except json.JSONDecodeError:
            parsed = {"unparsed": text[:4000]}
    out = {
        "ok": True,
        "preset": args.preset,
        "worker": URL,
        "elapsed_seconds": elapsed,
        "http": call.get("status"),
        "scope": "nicht archiviert, COUNT DISTINCT kandidat_id, Deutsch=Horen",
        "result": parsed,
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0 if call.get("curl") == 0 else 3


if __name__ == "__main__":
    raise SystemExit(main())
