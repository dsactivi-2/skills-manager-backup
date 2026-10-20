# TG backup TAR

Device: System → Backup and Restore → Create / Upload. Ext `.tar`.
Limit: 8 MB from FW 91.3.0.21 (UG 91.3.0.23 still says 1.8 MB).

Members (factory sample): `ysdisk/etc/network/interfaces`, `ysdisk/var/lib/asterisk/db/MyPBX.sqlite`, `astdb`, wav prompts, firewall sqlite.

LAN IP only in `interfaces` (`address`/`gateway`) and `nicsetting` eth0 (`ipaddress`,`netmask`,`gateway`,`dns1`,`dns2`,`type=staticip`).
Optional: `sipsettings.localnetadd` = `192.168.100.0/255.255.255.0`.

Firmware `.bin` is separate. Device HTTP-Feld: **http nicht https**.
V3: `http://image.yeastar.com/Yeastardownload/91.3.0.37.bin` (71 872 368 B, 2026-06-02). TG400W EOL stays on 91.3.0.21.
Werk-GW 192.168.5.1 oft ohne Internet → Flash lokal oder erst LAN.

Factory-E-Mail nach Reset: `emailsettings.email=mypbx@sina.com` / `smtp.sina.com` = Yeastar-Demo. `ajt@debian.org` nur in `services`. Prüfen vor Restore.

Do not pack previous-owner `voiptrunk`. Walkthrough first, then one TAR.
