# Home-WAN, Standort, PBX-Ranking

## Standort

TG400 oft zuhause (Mobilfunk), Bedienung/Office woanders. Das LAN, auf dem der Agent gerade sitzt, ist nicht automatisch Production.

- Office- sweep (`192.168.100.0/24`) nur für Zugriff jetzt.
- Prod-LAN/WAN erst am Home-Netz entscheiden.
- Alias `192.168.5.2` ist temporär für Werk-IP, kein Prod-Setting.

## Public-IP

Gerät: DHCP oder Static LAN (sqlite `nicsetting.type`). Kein Zwang zu Static im UG (Beispiel ist Static).

Feste **Public**-IP: nicht nötig.

| SIP-Modus | Public Static? | Ersatz (UG) |
|---|---|---|
| Register (TG → PBX) | meist nein | — |
| Peer | ja oder Ersatz | DDNS (dyndns/no-ip/afraid/zoneedit) oder OpenVPN-Client |
| OpenVPN am TG | nein | feste VPN-IP zur Hetzner-PBX |

Tailscale am TG: nicht dokumentiert, nicht als Plan.

## PBX-Ranking (unabhängig)

Nicht nach der laufenden PBX fragen, bevor bewertet wird.

Dograh (`dograh-hq/dograh`) hat genau 7 Telephony-Provider im Register: `ari`, `twilio`, `telnyx`, `vonage`, `plivo`, `vobiz`, `cloudonix`. Einziger Self-Host-PBX-Adapter: **Asterisk ARI**. CPaaS bricht EU/Self-Host-K.o. als Dograh-Gegenstelle.

ARI-Doku: Asterisk 20 LTS oder 22+, `chan_websocket` + `res_websocket_client`, Media **ulaw** 8 kHz, WS `externalMedia`.

Analyse-Phasen (Codex-Prompt): nach jeder Phase auf das Wort `bestätige` warten. Gegen `origin/main` arbeiten wenn lokal hinterher ist.

Kette-SoT für diese Installation nur nach Freigabe (Beispiel, nicht raten): Dograh = `https://voiceeu.activi.io/`.
