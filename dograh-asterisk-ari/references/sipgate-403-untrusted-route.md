# Sipgate 403 Untrusted Route-Header (ari.activi.io)

Live-reproduced 2026-08-18 on `pbx-tg400`. ARI 200 ≠ Gespräch.

## Diagnose-Reihenfolge

1. Nicht `grep ERROR|WARNING` auf `/var/log/asterisk/full` — Scanner-INVITEs (`sipvicious`, `216.244.*`, `No matching endpoint`) ersäufen den echten Call.
2. Echte Originate: `grep "HTTP Request URI is /ari/channels" /var/log/asterisk/full`
3. Um die Uhrzeit: INVITE + erste Response (Request-URI, Route, From, Ziel-IP).
4. `pjsip show registrations` und `pjsip show endpoint <name>`: `outbound_proxy`, `from_domain`, `from_user`, `server_uri`.

`fwconsole mysql -e` existiert auf FreePBX 17.0.32 **nicht**. Query: `fwconsole mysql` + SQL als Argument, oder `/usr/bin/mysql`.

## Fingerprint (Trunk `Sipgate_Trunk_897`)

```
POST /ari/channels?endpoint=PJSIP/49177…@Sipgate_Trunk_897  → 200
INVITE sip:sipgate.de SIP/2.0
Route: <sip:49177…@sipconnect.sipgate.de:5060>
From: <sip:030…@sipgate.de>
→ UDP 217.10.79.9:5060
← 403 Rejected (Untrusted Route-Header)
Hangup cause 21, ~12 ms, NO ANSWER
```

REGISTER desselben Trunks: `REGISTER sip:sipgate.de` + `Route: <sip:sipgate.de>` → gleicher 403, Status **Rejected**. Contact kann trotzdem Qualify **Avail** sein.

`Trunk_898` (`sip:user@sipgate.de`, kein Proxy) kann parallel **Registered** sein und wird vom ARI-Dest nicht benutzt.

## Offiziell

| Quelle | Vorgabe |
|---|---|
| sipgate KB Asterisk-Trunking | `server_uri`/`client_uri`/`from_domain` = `sipconnect.sipgate.de`; `from_user` = SIP-ID; AOR `sip:sipconnect.sipgate.de`; identify `217.10.68.150`; **kein** Proxy nach `sipgate.de`; Dial `PJSIP/${EXTEN}@endpoint`; CLIP = `P-Preferred-Identity: <sip:49…@sipconnect.sipgate.de>` |
| Asterisk PJSIP Proxies | Wenn Proxy, dann `outbound_proxy = sip:host\;lr` — sonst wandert die Nummer in `Route` und die Request-URI wird der Proxy |

https://help.sipgate.de/trunking/wie-konfiguriere-ich-asterisk-fuer-sipgate-trunking
https://docs.asterisk.org/Configuration/Channel-Drivers/SIP/Configuring-res_pjsip/PJSIP-with-Proxies

## Fix (SoT: `asterisk.pjsip` id=2, dann `fwconsole reload`)

Live applied 2026-08-18 on `Sipgate_Trunk_897`:

| keyword | vorher | nachher |
|---|---|---|
| outbound_proxy | `sip:sipgate.de` | leer |
| from_domain | `sipgate.de` | `sipconnect.sipgate.de` |
| from_user | 030-DID | SIP-ID `3842064t1` |

Verify: `pjsip show registrations` → **Registered**. Originate `PJSIP/<e164-ohne-plus>@Sipgate_Trunk_897` → Request-URI `INVITE sip:<nr>@sipconnect.sipgate.de` → 100/183, nicht 403.

CLIP: `from_user` bleibt SIP-ID. Sichtbare DID nur über `P-Preferred-Identity: <sip:493075435897@sipconnect.sipgate.de>` in `pjsip.endpoint_custom_post.conf`. `sendrpid=no` — sonst schickt ARI `callerId=200` ein `P-Asserted-Identity: sip:200@…` und Sipgate unterdrückt/zeigt 200. `trunks.outcid=493075435897`, `keepcid=off`. Verify: INVITE hat PPI, kein PAI, From nicht Anonymous.

## Nicht verwechseln

| Symptom | Nicht das |
|---|---|
| ARI 200 + 12 ms Hangup | Dograh/Stasis-Bug |
| Scanner 401 / no matching endpoint | Euer Originate |
| Ext 200/555 Unavailable | Blocker für ARI-Originate |
| App `dograh` an voiceeu statt pre-main | Separates Routing; dieser 403 ist SIP |
