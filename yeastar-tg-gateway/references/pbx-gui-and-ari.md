# Asterisk+GUI + ARI (live 2026-08-15)

Dograh-Register (`dograh-hq/dograh` `origin/main`): `ari` + CPaaS. Self-Host-PBX = nur ARI.
ARI = nur Kabel Dograh↔Asterisk. TG/SIP/SIM und später Telnyx sind andere Leitungen.

`chan_websocket` laut docs.asterisk.org erst ab **20.16 / 21.11 / 22.6 / 23.0**.
Dograh-Doku: 22+ oder 20 LTS mit `chan_websocket` + `res_websocket_client`, Media ulaw.

GUI-Ranking (Nebenstellen nicht in Dograh):

| Paket | Urteil |
|---|---|
| FreePBX 17 + Asterisk **≥22.6** auf Debian 12 | 1. OSS-GUI. Offizielles Skript: `FreePBX/sng_freepbx_debian_install` |
| VitalPBX 4.5.2 (Asterisk 20.17) | 2. GUI ja; WS-Trunk in der GUI unklar. Install: `VitalPBX/VPS` |
| Asterisk 22.6 pur | keine Nebenstellen-UI |

Nach Install: `module show like chan_websocket` und `res_websocket_client` = Running.

VICIdial = optionale Schicht **auf** ARI (Hangup/Transfer/Lead), kein Ersatz.

Telnyx = anderer Dograh-Provider, nicht in die TG-VoIP-Kette.

Repos (gh): `FreePBX/sng_freepbx_debian_install`, `FreePBX/sngfd12`; Vital: `VitalPBX/VPS`. Kein volles PBX-Git.
