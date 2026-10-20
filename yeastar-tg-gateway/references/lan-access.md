# TG LAN access

Factory: `192.168.5.150/24` gw `.5.1` HTTP :80 Boa. Login `admin`/`password`.
This house: Wi-Fi `192.168.100.0/24` gw `.1`. After wipe the DHCP/old IP (was `.137`) is dead.

Alias (no delete): `sudo ifconfig en0 alias 192.168.5.2 netmask 255.255.255.0`
Undo: `sudo ifconfig en0 -alias 192.168.5.2`

Sweep: `nmap -sn -n -T4 192.168.100.0/24` and `192.168.5.0/24`. Never `-Pn` for liveness.
OUI `F4-B5-49` / `80-C2-F0`. Confirm: `curl -m 5 http://IP/` → NeoGate TG / yeastar.

Spinner on old URL after reset = device already on `.5.150`. Verify ping/curl there.
