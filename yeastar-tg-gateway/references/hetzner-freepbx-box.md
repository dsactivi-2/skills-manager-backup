# Hetzner FreePBX-Box (Kette voiceeu → ARI → Asterisk → SIP → TG)

Replace-Linie (Freigabe 2026-08-15): GonoPBX nicht SoT. Neu = FreePBX 17 + Asterisk ≥22.6.

## Nicht diese Server

`hermes` und `dograh-vps` (voiceeu) nie mit FreePBX überschreiben. Eigenes Hetzner-Projekt kann **0 Server** zeigen, obwohl andere VPS existieren.

## hcloud

Offizielle CLI (`brew install hcloud`). Token: `hcloud context create <name>` — Token an der Prompt, nicht in die Shell-History.

Neue Box: Debian **12** x86 (nicht 13, nicht ARM), Ort DE (`fsn1`/`nbg1`), RAM ≥8 GB (`cx33`). SSH-Key muss **in diesem** Projekt liegen.

## SSH-Key-Falle

`~/.ssh/id_ed25519` oft aes256 + 1Password-Agent: Server akzeptiert den Pubkey, BatchMode kann nicht signieren (`we did not send a packet`).

Fix: eigener Key ohne Passwort nur für die Box (`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_pbx_tg400 -N ''`), `hcloud ssh-key create`, Server **mit diesem** Key anlegen. Rebuild injiziert keine nachträglich hochgeladenen Keys — delete+create.

SSH: `-o IdentityAgent=none -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519_pbx_tg400`.

## Install

Nicht 10–15 min. Official `sng_freepbx_debian_install` oft 30–90 min.

```
DEBIAN_FRONTEND=noninteractive ASTVERSION=22 bash sng_freepbx_debian_install.sh --opensourceonly
```

Log: `/var/log/pbx/freepbx17-install-*.log`. Danach Pflicht:

```
asterisk -rx "core show version"          # ≥22.6
asterisk -rx "module show like chan_websocket"
asterisk -rx "module show like res_websocket_client"
```

Beide Module **Running**. `--dahdi` nur mit Karte. Ansible/TLS/SRTP nicht Tag 1. VICIdial Phase 2.

## SIP-Host vs Modus

Zwei Felder, nicht eines.

| | Was | Wann |
|---|---|---|
| Host | IP/Name der **neuen** PBX | erst wenn Box existiert |
| Modus | Register oder Peer | jetzt entscheidbar |

Register: TG meldet sich bei Hetzner-PBX — üblich TG zuhause, dynamische Public-IP ok. Peer: beide kennen die IP — braucht feste Home-WAN/DDNS/VPN.

Telnyx = andere Dograh-Leitung, nicht in den TG-Trunk.
