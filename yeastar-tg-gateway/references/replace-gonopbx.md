# Keep/Replace (Freigabe 2026-08-15)

**Replace.** `ankaios76/gonopbx` ist nicht SoT für voiceeu→ARI→TG.

GonoPBX = AMI-GUI auf `andrius/asterisk:20`, keine `ari.conf`/Stasis/`chan_websocket`. Dograh braucht ARI + WS-Module (ab Asterisk 20.16 / 22.6).

Neue Linie: FreePBX 17 + Asterisk ≥22.6. Ablauf: `references/hetzner-freepbx-box.md`. Repo-Diff: `references/gonopbx-keep-replace.md`.
