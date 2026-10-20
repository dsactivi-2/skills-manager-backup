---
name: public-quick-tunnel-hosting
description: Expose a local site/file publicly via cloudflared tunnel.
---

# Public quick-tunnel hosting

Serve a local static site or file (e.g. a download page) and make it reachable
from the public internet in one shot, using a local HTTP server plus a
cloudflared **quick tunnel** (no Cloudflare account, no DNS, no config file).

## When to use
- User wants a shareable public link to a file or a small static page **right now**.
- "make it reachable from outside / send me the link", ad-hoc demos, one-off file handoffs.
- You do NOT need a stable/permanent URL (for that, use a named tunnel / real hosting).

## Steps

1. **Lay out the web root.** Put `index.html` at the root and served assets
   under a subdir. Keep the user's file **byte-for-byte** if they asked for
   "1:1 / exactly as is" — just `cp` it, do not reformat/minify.
   ```
   mkdir -p /tmp/site/files
   cp "/path/to/original.json" /tmp/site/files/
   ```

2. **Install cloudflared if missing** (macOS): `brew install cloudflared`.
   Check first with `which cloudflared ngrok`.

3. **Start the web server** (bind loopback — the tunnel reaches it locally):
   ```
   cd /tmp/site && python3 -m http.server 8787 --bind 127.0.0.1
   ```
   Run it as a background process.

4. **Start the quick tunnel** to the local port, logging to a file:
   ```
   cloudflared tunnel --url http://127.0.0.1:8787 > /tmp/site/tunnel.log 2>&1
   ```
   Background it, then wait ~8s and extract the URL:
   ```
   grep -Eo "https://[a-z0-9-]+\.trycloudflare\.com" /tmp/site/tunnel.log
   ```

5. **Verify from the OUTSIDE before sending the link.** curl the public URL,
   not just localhost — check both the page and the actual download:
   ```
   curl -s -o /dev/null -w "%{http_code}\n" https://<sub>.trycloudflare.com/
   curl -s -o /dev/null -w "%{http_code}\n" "https://<sub>.trycloudflare.com/files/original.json"
   ```
   Both must be `200` before you deliver the link.

## Pitfalls
- **Filenames with spaces / non-ASCII (– en-dash, ü, etc.) break the raw URL.**
  `curl` to the un-encoded path returns `000`. URL-encode the path when testing
  (`%20` for space, etc.), or link to a renamed ASCII copy. The file on disk can
  keep its original name; only the URL needs encoding.
- **The URL is ephemeral.** It dies when the Mac sleeps/reboots or either
  background process exits, and a new random subdomain is minted each restart.
  Always tell the user this caveat when handing over the link.
- **Bind to `127.0.0.1`, not `0.0.0.0`** — the tunnel connects locally, so there
  is no reason to expose the raw server on the LAN.
- Background processes started without `notify_on_complete` run silently; that's
  fine here since the server/tunnel are long-lived daemons, but poll the tunnel
  log rather than assuming it's up.
- Quick tunnels are **unauthenticated and public** — anyone with the link gets
  the file. Don't use for anything sensitive; for that, gate it or use a named
  tunnel with Access.

## Permanent alternative
If the user needs a stable link: a Cloudflare **named tunnel** (`cloudflared
tunnel create`, route DNS, `config.yml`) or static hosting (Cloudflare Pages,
etc.). See the `cloudflare` / `cloudflare-one` skills for the platform side.
