---
name: yeastar-tg-gateway
description: "Use when TG/NeoGate commission. LAN find, FW then TAR."
---

# Yeastar TG / NeoGate Gateway

## Trigger

User has a Yeastar TG200 / TG400 / TG800 / TG1600 (NeoGate) and wants access, factory reset, LAN IP, backup/restore, or SIP/GSM config. Also when a device is "on the same network" but the Web-UI does not open.

## User style

- German, direct, short. Live verify before theory.
- Destructive steps (factory reset, restore upload) only after the user understands what is erased.
- Screenshot answers: describe **only** the Yeastar window they asked about. Do not narrate other desktop windows.
- **Projektbrief vor TAR.** Zweck zuerst in eine SoT-MD (`Projektbrief-Yeastar-TG400.md`): Blöcke Zweck | Entscheidungen | Live-Ist. Pro Punkt entscheiden → schreiben → erst dann nächster Punkt. Vor dem nächsten nur Konflikte zu schon Entschiedenem prüfen. Secrets als Platzhalter. TAR erst wenn die Brief geschlossen ist. Kein erfundenes SIP/PBX. Firmware flash vor Restore.
- **Memory nicht still in den Zweck kippen.** Was aus alter Session/Memory/Codex-Prompt kommen könnte, zuerst als Kandidatenliste zeigen („übernehmen ja/nein?“). Erst nach Freigabe in die Brief. Vorbesitzer-SIP, Office-LAN, Ist-PBX nie als Zweck.
- **Ist-PBX nicht vor dem Ranking fragen.** Sonst Bias. Erst unabhängig Dograh-Code + TG-UG; Ist-System erst danach Keep/Replace. Ranking-Gate: Codex-Prompt verlangt `bestätige` nach jeder Phase.

## Factory defaults (official TG Series UG 91.3.0.23)

| Item | Value |
|---|---|
| Web | `http://192.168.5.150` (HTTP :80, Boa) |
| User / pass | `admin` / `password` |
| LAN | 1× 10/100, static `.5.150/24` gw `.5.1` |
| Reset button | hold **10 s** → factory defaults |
| Backup | `.tar` via System → Backup and Restore. **≤8 MB** from FW 91.3.0.21; older UG still says 1.8 MB |

OUI (IEEE): `F4-B5-49`, `80-C2-F0` = Xiamen Yeastar.

## Phase 0 — Live LAN (always first)

Do **not** wait on hub/skills.sh network skills. They are mostly pentest/cloud and low-fit.

1. Mac iface + subnet: `ifconfig` / `networksetup -getinfo Wi-Fi` (this house LAN is often `192.168.100.0/24`, gw `.1`).
2. Ping factory `192.168.5.150` **and** the last known LAN IP.
3. If factory IP is a different subnet: add a **temporary alias**, do not change DHCP:
   `sudo ifconfig en0 alias 192.168.5.2 netmask 255.255.255.0`
   Undo: `sudo ifconfig en0 -alias 192.168.5.2`
4. Host discovery: `nmap -sn -n -T4 <subnet>` — **never `-Pn` for "is it up"** (`-Pn` always prints Host is up).
5. Identify Yeastar by MAC OUI, then `nmap -sV -p 80,443,5060,8022 <ip>` and `curl` `:80` (login HTML contains `yeastar` / `NeoGate TG`).

Detail: `references/lan-access.md`

## Factory reset

Two equivalent official paths. Both **wipe all config** (SIP, routes, LAN IP, password). Mac/router untouched.

| Path | How | After |
|---|---|---|
| Web | System → System Preferences → Reset and Reboot → Reset to Factory Defaults | IP becomes `192.168.5.150` |
| Hardware | front Reset 10 s, wait until RUN blinks | same |

- Do **not** power-cycle mid-reset (UG: can damage the system).
- A spinner on the **old** URL is normal: the device has already moved. Verify with ping/curl on `.5.150`.
- After reset: log in at factory IP, then set LAN to this subnet (DHCP or static) **before** removing the alias.
- **Office-LAN ≠ Prod.** TG400 sitzt oft zuhause (besser Mobilfunk). `192.168.100.0/24` vom aktuellen Mac nicht in die Prod-TAR, solange Standort nicht Home-LAN ist.

## Backup / restore file

Firmware is **not** in the TAR. Flash first (HTTP/TFTP `.bin`), then config.

| Rule | Detail |
|---|---|
| Family | V3 = FW **91.x** or SN starts with **331**. System Info immer live lesen (nicht alte Session-Zahl) |
| Latest V3 | yeastar.com/firmware-download → `91.3.0.37` (2026-06-02) |
| TG400W EOL | last official FW **91.3.0.21** — do not flash 91.3.0.37 |
| Flash URL | Gerät will **http nicht https**. `http://image.yeastar.com/Yeastardownload/91.3.0.37.bin` (71 872 368 B, inner ZIP `firmware-tg_series.tar`, gleicher ETag wie HTTPS) |
| Flash | System → Firmware Update. Reset-Haken aus. Nie 91.x auf Nicht-V3. Nicht ausstecken. |
| Netz | Werk-GW `192.168.5.1` hat oft kein Internet. HTTP-Flash scheitert dann. Lokal: `python3 -m http.server 8080 --directory ~/Downloads` und URL `http://192.168.5.2:8080/91.3.0.37.bin` (Alias muss sitzen). Verify: GET von `.150` im Server-Log. |

Official restore is a **device-generated `.tar`**. Size ≤8 MB on 91.3.0.21+.

**In TAR:** LAN, passwords, SIP/GSM/routes, firewall, email, VPN, prompts.
**Not in TAR:** firmware, physical SIMs, live registration, call logs, SMS inbox.

- Use a **fresh factory backup** as format template only. Do not re-upload previous-owner backups.
- Factory-E-Mail in frischem Reset-TAR: `mypbx@sina.com` / `smtp.sina.com` = Yeastar-Demo, kein Vorbesitzer. `ajt@debian.org` in `services` = Debian-Kommentar. `voiptrunk` leer. Restore-TAR immer sqlite-prüfen (`emailsettings`, `voiptrunk`, `nicsetting`) bevor Upload.
- LAN IP lives in `ysdisk/etc/network/interfaces` and `MyPBX.sqlite` `nicsetting` (eth0). `astdb` has no LAN IP.
- Brief-Reihenfolge (Abhängigkeit): Zweck → LAN → Passwort/Zeit → GSM → SIP (offen bis Host fest) → Routen → SMS → Security → Rest default nein. Firmware ist Live-Ist, kein Config-Punkt.
- Leave `voiptrunk` empty until the user supplies SIP. No leftover screenshot peers. No hand-rolled sqlite TAR before the brief is closed.
- Public-WAN: TG braucht **keine** feste Public-IP. LAN darf DHCP oder Static. Ob die PBX den TG erreichen muss, hängt vom SIP-Modus (Register meist Outbound-NAT; Peer braucht DDNS oder Tunnel). Offiziell: DDNS + OpenVPN-Client. Tailscale am TG nicht in der UG — nicht annehmen.

Detail: `references/backup-tar-format.md`, `references/projektbrief.md`, `references/home-wan-pbx.md`, `references/dograh-chain.md`, `references/antennas.md`

## Antennen

WLAN-Router-Stäbe nicht nutzen. TG = **SMA** (Stift), GSM/LTE-MHz, 4 Stück. Suche/Shops/FME: `references/antennas.md`.

## Pause / Handover

Config unterbrochen: `~/Downloads/HANDOVER-Yeastar-TG400.md` (nur TG, kein Dograh-Fork) + kopierbarer Agent-Prompt mit `@session:default/<id>` und SoT-Brief. Nächster Agent: Skill + Brief + Handover, dann Live ping/curl `.150` / Alias, dann offener Punkt. Mac-LAN kann wechseln — Brief-Zeile nicht als Ist übernehmen.

## Dograh-Kette (wenn Zweck voiceeu)

Bestätigt 2026-08-14: Dograh = `https://voiceeu.activi.io/` (curl 307 → `/auth/login`, Title Dograh).
Native Self-Host-Telefonie im Dograh-Code: nur Asterisk ARI. TG400 hängt per SIP an der PBX, nicht an Dograh.
PBX-Ranking und Fork-vs-Original-ARI: Skill `dograh-upstream-platform` → `references/ari-live-diff.md` (live git, nicht Doku).

## What not to do

- Do not install skills.sh "network" / nmap pentest packs as a substitute for the live sweep.
- Do not factory-reset when the device is already reachable on LAN unless the user wants previous-owner config gone.
- Do not tell the user the Web-UI is "stuck resetting" without pinging both IPs.
- Do not put secrets from a previous owner into a new restore tar.
