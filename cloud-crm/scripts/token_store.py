#!/usr/bin/env python3
"""Gegenspeichern für das Cloud-CRM Worker-Token."""
from __future__ import annotations

import argparse
import json
import os
import stat
import subprocess
import sys
from datetime import datetime
from pathlib import Path

HOME = Path.home()
TOKEN_FILE = HOME / ".codex" / "crm-remote-mcp.token"
BACKUP_DIR = HOME / ".codex" / "backups" / "crm-remote"
CODEX_CONFIG = HOME / ".codex" / "config.toml"
KIMI_MCP = HOME / ".kimi-code" / "mcp.json"
ZSHRC = HOME / ".zshrc"
ENV_SCRIPT = HOME / ".codex" / "bin" / "set-codex-manifest-env.sh"
KEYCHAIN_SERVICE = "crm_remote_mcp_token"
ENV_NAME = "CRM_REMOTE_MCP_TOKEN"
WORKER_URL = "https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp"
ZSH_EXPORT = (
    f'export {ENV_NAME}="$(cat {TOKEN_FILE} 2>/dev/null)"'
)
ENV_SCRIPT_LINE = (
    f"set_env_from_keychain {ENV_NAME} {KEYCHAIN_SERVICE} 0"
)
TOML_BLOCK = (
    "[mcp_servers.crm-remote]\n"
    "enabled = true\n"
    "type = \"http\"\n"
    f"url = \"{WORKER_URL}\"\n"
    f"bearer_token_env_var = \"{ENV_NAME}\"\n"
)


def last4(token: str) -> str:
    token = token.strip()
    if not token:
        return ""
    return token[-4:] if len(token) >= 4 else token


def read_file_token() -> str:
    if not TOKEN_FILE.exists():
        return ""
    return TOKEN_FILE.read_text(encoding="utf-8").strip()


def keychain_token() -> str:
    try:
        out = subprocess.run(
            [
                "security",
                "find-generic-password",
                "-w",
                "-a",
                os.environ.get("USER", ""),
                "-s",
                KEYCHAIN_SERVICE,
            ],
            capture_output=True,
            text=True,
            check=False,
        )
    except OSError:
        return ""
    if out.returncode != 0:
        return ""
    return out.stdout.strip()


def launchctl_token() -> str:
    try:
        out = subprocess.run(["launchctl", "getenv", ENV_NAME], capture_output=True, text=True, check=False)
    except OSError:
        return ""
    if out.returncode != 0:
        return ""
    return out.stdout.strip()


def kimi_has_bearer() -> bool:
    if not KIMI_MCP.exists():
        return False
    try:
        data = json.loads(KIMI_MCP.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return False
    headers = data.get("mcpServers", {}).get("crm-remote", {}).get("headers", {})
    auth = str(headers.get("Authorization", ""))
    return auth.startswith("Bearer ") and len(auth) > 8


def codex_has_server() -> bool:
    if not CODEX_CONFIG.exists():
        return False
    text = CODEX_CONFIG.read_text(encoding="utf-8")
    return "[mcp_servers.crm-remote]" in text and ENV_NAME in text


def zshrc_has_export() -> bool:
    if not ZSHRC.exists():
        return False
    return ENV_NAME in ZSHRC.read_text(encoding="utf-8")


def env_script_has_line() -> bool:
    if not ENV_SCRIPT.exists():
        return False
    return ENV_SCRIPT_LINE in ENV_SCRIPT.read_text(encoding="utf-8")


def cmd_status() -> int:
    file_tok = read_file_token()
    key_tok = keychain_token()
    env_tok = os.environ.get(ENV_NAME, "").strip()
    lc_tok = launchctl_token()
    present = bool(file_tok or key_tok or env_tok or lc_tok)
    shown = last4(file_tok or key_tok or env_tok or lc_tok)
    print("present:", "yes" if present else "no")
    print("last4:", shown if present else "-")
    print("file:", "yes" if file_tok else "no")
    print("keychain:", "yes" if key_tok else "no")
    print("env:", "yes" if env_tok else "no")
    print("launchctl:", "yes" if lc_tok else "no")
    print("codex_config:", "yes" if codex_has_server() else "no")
    print("kimi_mcp:", "yes" if kimi_has_bearer() else "no")
    print("zshrc:", "yes" if zshrc_has_export() else "no")
    print("env_script:", "yes" if env_script_has_line() else "no")
    return 0 if present else 2


def backup_existing():
    BACKUP_DIR.mkdir(parents=True, exist_ok=True)
    src = read_file_token()
    if not src:
        return None
    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    dest = BACKUP_DIR / f"token-{stamp}"
    dest.write_text(src + "\n", encoding="utf-8")
    os.chmod(dest, stat.S_IRUSR | stat.S_IWUSR)
    return dest


def write_token_file(token: str) -> None:
    TOKEN_FILE.parent.mkdir(parents=True, exist_ok=True)
    TOKEN_FILE.write_text(token + "\n", encoding="utf-8")
    os.chmod(TOKEN_FILE, stat.S_IRUSR | stat.S_IWUSR)


def write_keychain(token: str) -> None:
    subprocess.run(
        [
            "security",
            "add-generic-password",
            "-a",
            os.environ.get("USER", ""),
            "-s",
            KEYCHAIN_SERVICE,
            "-w",
            token,
            "-U",
        ],
        check=False,
        capture_output=True,
        text=True,
    )


def write_launchctl(token: str) -> None:
    subprocess.run(["launchctl", "setenv", ENV_NAME, token], check=False)


def upsert_zshrc() -> None:
    text = ZSHRC.read_text(encoding="utf-8") if ZSHRC.exists() else ""
    if ENV_NAME in text:
        return
    if not text.endswith("\n"):
        text += "\n"
    ZSHRC.write_text(text + ZSH_EXPORT + "\n", encoding="utf-8")


def upsert_env_script() -> None:
    if not ENV_SCRIPT.exists():
        return
    text = ENV_SCRIPT.read_text(encoding="utf-8")
    if ENV_SCRIPT_LINE in text:
        return
    if not text.endswith("\n"):
        text += "\n"
    ENV_SCRIPT.write_text(text + ENV_SCRIPT_LINE + "\n", encoding="utf-8")


def upsert_codex_config() -> None:
    if not CODEX_CONFIG.exists():
        raise SystemExit(f"missing {CODEX_CONFIG}")
    text = CODEX_CONFIG.read_text(encoding="utf-8")
    if "[mcp_servers.crm-remote]" in text:
        return
    marker = '[projects."/Users/activi"]'
    block = TOML_BLOCK.strip() + "\n\n"
    if marker in text:
        text = text.replace(marker, block + marker, 1)
    else:
        if not text.endswith("\n"):
            text += "\n"
        text += "\n" + block
    CODEX_CONFIG.write_text(text, encoding="utf-8")


def upsert_kimi(token: str) -> None:
    if not KIMI_MCP.exists():
        data = {"mcpServers": {}}
    else:
        data = json.loads(KIMI_MCP.read_text(encoding="utf-8"))
    servers = data.setdefault("mcpServers", {})
    servers["crm-remote"] = {
        "url": WORKER_URL,
        "headers": {"Authorization": f"Bearer {token}"},
    }
    KIMI_MCP.write_text(
        json.dumps(data, indent=1, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )


def cmd_save(token: str) -> int:
    token = token.strip()
    if not token:
        print("empty token", file=sys.stderr)
        return 1
    if token.lower().startswith("bearer "):
        token = token[7:].strip()
    bak = backup_existing()
    write_token_file(token)
    write_keychain(token)
    write_launchctl(token)
    upsert_zshrc()
    upsert_env_script()
    upsert_codex_config()
    upsert_kimi(token)
    print("saved:", "yes")
    print("last4:", last4(token))
    print("backup:", str(bak) if bak else "-")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Cloud CRM token stores")
    sub = parser.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status")
    save = sub.add_parser("save")
    save.add_argument("--token", required=True)
    args = parser.parse_args()
    if args.cmd == "status":
        return cmd_status()
    if args.cmd == "save":
        return cmd_save(args.token)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
