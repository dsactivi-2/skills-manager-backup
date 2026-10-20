# Ansible-Blueprint + VICIdial (Korrektur 2026-08-15)

Nicht 1:1 aus generic-Prod-Text übernehmen.

## Ansible

- Install-SoT: `FreePBX/sng_freepbx_debian_install` auf Debian 12.
- Ansible darum als erstes: **nein** (1 Person, 1 Box, 4 Kanäle). Official-Skript ist einmalig, nicht idempotent.
- Kein gepflegtes Ansible-Repo gefunden. `jeffreythebuilder/ansible_freepbx17` = 0 Stars, `PermitRootLogin yes` — meiden.
- Nach Install dünn: Hetzner-FW, Fail2ban, SSH-Keys, Backup+ein Restore-Test.
- TLS/SRTP Tag 1: **nein** (Dograh ulaw ARI; TG-SIP meist Register/UDP).
- Ansible erst bei 2. Server.

## VICIdial

Phase 2 auf ARI, kein Ersatz für FreePBX. Audio bleibt Asterisk ARI.
Neueste Software: SVN trunk / nightly zip `vicidial.org/svn_trunk_nightly` — nicht GitHub, nicht r3344 (2021).
Konflikt: VICI „Asterisk 18 preferred“ vs Dograh `chan_websocket` ab 20.16/22.6. Nicht VICIbox statt FreePBX.

Siehe auch `references/pbx-gui-and-ari.md`.
