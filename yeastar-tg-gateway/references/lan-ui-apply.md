# LAN-Apply in der TG-UI (kein TAR)

Einzelner LAN-Punkt: Werte in die Brief, dann UI. Kein Restore-TAR.

## Form

- Frame: `iframe#mainscreen` / `name=mainscreen`
- URL: `/cgi/WebCGI?122111`
- Safari JS: `do JavaScript … in current tab` — Tab vorher auf `192.168.5.150` (oder neue IP) setzen; `current tab` kann ein anderer Tab desselben Fensters sein.

Felder (eth0 / LAN):

| name | Rolle |
|---|---|
| `ltype` | radio `staticip` (nicht `dhcp`) |
| `lipaddress` | z.B. Home `192.168.31.150` |
| `lnetmask` | `255.255.255.0` |
| `lgateway` | Router, z.B. `192.168.31.1` |
| `ldns1` | gleicher DHCP-DNS wie `ipconfig getpacket` `domain_name_server` |
| `ldns2` | leer wenn DHCP nur einen Server gibt |

Save: `#btn-lan-save` → `onSaveUpdate()`. Banner „Changes Saved“. Modal: Restart nötig. Dann `#btn-reboot` + Confirm „Are you sure you would like to reboot?“.

## Verify

1. Alte Werk-IP tot, neue IP ping + ARP gleiche Yeastar-OUI.
2. `curl` `:80` → Boa + Yeastar/NeoGate Login-HTML.
3. Alias `192.168.5.2` danach überflüssig.

Nicht: Tailscale-DNS `100.100.100.100` auf den TG. Nicht Office-`.137`. Nicht Firmware anfassen.
