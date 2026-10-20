# Resume live-check (kein UI)

Bei jedem Wiederaufsetzen, bevor Config:

1. `date`; `ifconfig en0` / `networksetup -getinfo Wi-Fi` — DHCP **und** Alias getrennt notieren.
2. `ping` Werk-IP `192.168.5.150` und letzte bekannte LAN-IP.
3. `curl -m 5 -D - -o /tmp/tg-login.html http://<ip>/` — `Server: Boa`, Login-HTML `yeastar` / `NeoGate TG`.
4. `arp -n <ip>` — OUI `F4-B5-49` / `80-C2-F0`.
5. HTTP-Header `Date: 1 Jan 1970` = Geräteuhr/NTP nicht gesetzt.

## Labeln

| Block | Darf enthalten |
|---|---|
| Frisch diese Session | ping, curl, ARP, Mac-IP, Alias, HTTP-Date |
| Letzte System-Info-UI | Produkt, HW, FW — nur mit Datum, nur wenn UI **dieselbe** Session gelesen |

Nicht mischen. Alte Brief-Zeile „LAN Mac …“ ersetzen. Aktuelles Mac-DHCP ≠ Home-Prod (Home nur nach Freigabe).

Handover-`session_id` fehlend: `session_search` per Topic, gefundene Parent/Fortsetzung nennen — IDs nicht erfinden.
