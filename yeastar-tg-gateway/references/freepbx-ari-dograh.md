# FreePBX 17 + Dograh ARI (kein Commercial)

Dograh Self-Host ohne CPaaS: nur **Asterisk ARI**. TG hängt per SIP an der PBX, nicht an Dograh. Telnyx = andere Dograh-Leitung.

## Version

`chan_websocket` erst ab Asterisk **20.16 / 21.11 / 22.6 / 23**. Linie: FreePBX **17** + Asterisk **≥22.6** auf Debian 12. Official-Skript `FreePBX/sng_freepbx_debian_install` mit `--opensourceonly` (kein DAHDI). Default `ASTVERSION=22`.

GonoPBX (`ankaios76/gonopbx`): Docker-GUI, Image `andrius/asterisk:20`, Steuerung **AMI :5038**, keine `ari.conf`/`http.conf`/`Stasis`. Nicht SoT für diese Kette.

## `--opensourceonly` knallt oft harmlos

Skript: `fwconsole ma list | awk '/Commercial/' | xargs fwconsole ma -f remove` — **Exit 123** wenn ein Modul-Uninstall fehlschlägt (`oracle_connector` gesehen). OSS ist dann schon da.

Resume (nicht neu installieren):

```
fwconsole ma list | awk '/Commercial/ {print $2}'
fwconsole ma -f remove oracle_connector || true
fwconsole ma -f remove firewall || true   # hängt an sysadmin
fwconsole ma installlocal
fwconsole ma upgradeall
fwconsole reload && fwconsole restart
apt-get purge -y sysadmin17 ioncube-loader-82 || true
asterisk -rx "core show version"
asterisk -rx "module show like chan_websocket"
asterisk -rx "module show like res_websocket_client"
```

UCP-Upgrade kann an fehlendem `g++` scheitern — nicht Kette. Sangoma-Firewall-Modul weg = Hetzner-FW + fail2ban statt dessen.

## ARI so, dass FreePBX Reload es nicht zerlegt

Nicht `http.conf` / `ari.conf` / `http_additional.conf` editieren (generated).

`http_custom.conf` mit zweitem `[general] bindaddr=0.0.0.0` **überschreibt den Bind nicht**. SoT:

```
fwconsole setting HTTPBINDADDRESS 0.0.0.0
fwconsole setting ENABLE_ARI 1
fwconsole reload
asterisk -rx "http show status"   # Bound to 0.0.0.0:8088
```

User + WS + Dialplan in **custom**:

- `ari_additional_custom.conf` — `[dograh] type=user read_only=no password=…`
- `ari_general_custom.conf` — `enabled=yes` (additional steht oft `enabled=no`)
- `websocket_client.conf` `[dograh]` — `wss://<voiceeu>/api/v1/telephony/ws/ari`, `protocols=media`, `tls_enabled=yes`, `ca_list_file=/etc/ssl/certs/ca-certificates.crt`
- `extensions_custom.conf` Context `from-dograh-stasis` → `Stasis(dograh)` — **nicht** an from-pstn hängen bevor SIP-Trunk steht

Passwort nicht in Projektbrief. Dograh-UI: URL `http://ari.<domain>:8088`, App + WS-Name `dograh`.

## Ports (Hetzner-FW, nicht nur iptables)

| In | Quelle | Wozu |
|---|---|---|
| TCP 22, 80, 443 | any | SSH / GUI |
| UDP+TCP 5060 | any | SIP TG (Home-WAN dynamisch) |
| UDP 10000–20000 | any | RTP |
| TCP 8088 | **nur voiceeu A/32** | Dograh ARI |
| 5038 / 3306 | zu | AMI/DB |

Media-WS ist **outbound** PBX→Dograh. AAAA für ARI-Hostname unnötig wenn voiceeu kein AAAA hat. DNS **grau** (kein Orange-Cloud) — sonst SIP/ARI/RTP tot.

Verify: von voiceeu `curl -u dograh:… http://ari…:8088/ari/asterisk/info` → 200. Vom Laptop timeout = FW ok.

## Mobile Group (TG)

Strategy nur **Rauswahl**: Balance = wenigste Minuten; Sequence = erste Selected; Default undokumentiert — nicht nehmen. Nicht mit VoIP Trunk Group verwechseln. Call Control = Umleitung **im Mobilnetz**, nicht Mobile-to-IP.
