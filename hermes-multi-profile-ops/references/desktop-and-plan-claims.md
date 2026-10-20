# Desktop attach + plan claims

## Desktop → VPS Hermes

Mac app stays. VPS: `hermes serve` (port **9119**), keep it up. Prefer Tailscale, not naked internet.

Desktop: **Settings → Gateways → Add connection**.

| Kind | Fill |
|---|---|
| Remote gateway | Name + URL `http://<tailscale-ip>:9119` + session token or OAuth |
| SSH | `user@host:22` — app starts dashboard over tunnel |

**Test → Reachable.** One URL per install; profiles live on that host.

OS: **Ubuntu 24.04**. Not Kube3-1/2/3 (k3s HA).

## Do not say fertig

Welle 1 / Fixplan Phase 1 = code+cloud. BOTLISTE, plans, `docs/SESSION-PROMPT-ARBEITSTEAM.md` = paper. Session prompt ≠ SKILL.md.

## CPU extra

Xeon **E5-2630 v4** (10c/2016): more cores than i7-7700, still old/slow per core. Auction only if cheap.
