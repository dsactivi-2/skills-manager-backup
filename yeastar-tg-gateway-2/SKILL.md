---
name: yeastar-tg-gateway
description: "Use when locating or recovering Activi Yeastar TG400 on LAN."
---

# Yeastar TG400 — LAN finden, nicht raten

Nur das GSM-Gateway. FreePBX bleibt `ownfreepbx`. Nebenstellen nicht hier. Home-LAN ≠ Office-LAN; nie IP erfinden.

OUI: `f4:b5:49` (Xiamen Yeastar). Letzte Home-Adresse oft `192.168.31.150` — nur Kandidat, kein SoT.

## Locate (immer so)

1. Alle IPv4-Ifaces lesen, nicht nur WLAN `en0`:

```
ifconfig | awk '/^[a-z0-9]+:/{iface=$1} /inet /{print iface,$2}'
```

Jedes `/24` mit `inet` sweepen (USB-C-LAN oft `en8` Realtek, z. B. `192.168.5.10`). Niemals `192.168.31.0/24` oder `.150` aus Memory sweepen, wenn die Live-Ifaces andere Netze haben — Mac wechselt Home/Office; USB-Direktlink ist ein eigenes Subnetz.
2. Pro Subnetz:

```
nmap -sn -T4 --max-retries 1 --host-timeout 3s <SUBNET>/24
arp -a | grep -i f4:b5:49
```

Nur `-sn` (ICMP/ARP). Nicht `-Pn` auf Xiaomi (`192.168.31.1`, nginx/MiWiFi): der Router droppt, nmap markiert jedes Host als up + Ports filtered — keine Yeastar-Evidenz.
3. Live nur wenn ARP **complete** (echte MAC, nicht `(incomplete)`) **und** OUI `f4:b5:49`. Dann IP **und** Iface nennen. Typisch USB-Direkt: `192.168.5.150` auf `en8`; WLAN-Home-Kandidat war `.31.150` — kein SoT.
4. Kein Match auf einer Iface: TG auf **diesem** Link nicht online. WLAN-only Sweep verpasst das USB-TG. Keine zweite IP erfinden. Xiaomi-Geräteliste braucht Router-Login; ohne Token nicht raten.

## Recovery-UI (Titel Upgrade / „system is damaged”)

Firmware-Recovery, keine SIP-Einrichtung. Browse-Upload ist im HTML auskommentiert; nur TFTP oder HTTP-URL. Isoliertes USB-LAN: TG hat kein Internet — Datei vom Mac auf **derselben** Iface serven.

1. SN auf dem Gehäuse. Beginnt mit `331` → 91.x (V3); sonst 53.x. 91.x auf Non-V3 bricked. Ohne SN nicht flashen.
2. Offizielle `.bin` von https://www.yeastar.com/firmware-download (TG Series). Yeastar-`.bin` kann ein passwortgeschütztes Zip sein — so an das Gerät geben, nicht entpacken.
3. Reset to Default aus, solange „data is intact”.
4. HTTP auf Port **80** der Mac-IP am TG-Link (oft `192.168.5.10`). Port 8080: CGI `WebCGI?1274` liefert `result=-1`. Port 80/69 brauchen sudo — Befehl im **Terminal.app** des Users, nicht im Agent-PTY (dort sieht er kein Passwortfeld):

```
cd <ordner-mit-bin>
sudo python3 -m http.server 80 --bind <MAC-IP-AM-TG-LINK>
```

Fenster offen lassen. Danach POST `resetcfg=no` `updatetype=HTTP` `httpurl=http://<MAC-IP>/<datei.bin>` an `http://<TG-IP>/cgi/WebCGI?1274` oder im UI Type HTTP + dieselbe URL, Download.
5. Während Flash: TG-Port 80 tot, Ping kann bleiben. Strom nicht trennen.
6. Erfolg nach Firmware (kein Factory): `http://<TG-IP>` → 301 auf `https://<TG-IP>` Login (`favicon_ico_login`), nicht Titel Upgrade. HTTP-Date-Header 1970 = Uhr ungesetzt, kein Fehlschlag.

## Factory-Reset / TG ins Heim-LAN

Werkseinstellung setzt LAN fest auf `192.168.5.150` (kein WLAN, oft nur HTTP:80, SSH aus). Xiaomi-Heimnetz ist `192.168.31.0/24`. Stecker in denselben Router reicht nicht — gleiches Kabel, anderes Subnetz, keine Firewall.

`en8` `media` lesen: `100baseTX` = typisch Direktkabel am TG; `1000baseT` plus zweite `inet 192.168.31.x` auf `en8` = Kabel am Router. Zwei `inet` auf einer Iface (`192.168.5.10` Rest + DHCP `.31`) ist derselbe Fall: nicht Direktlink.

Direktlink: nur `192.168.5.10` auf `en8`, WLAN `en0` aus (sonst Dual-Home: ARP `f4:b5:49` an `.5.150` kann complete sein, Ping/HTTP trotzdem tot). Dann `http://192.168.5.150` — nicht https, nicht `.31.150`.

LAN-IP im TG nur nach Web-Login ändern (Factory oft `admin` / `password`). Ziel Home: `192.168.31.150`, Gateway `192.168.31.1`. Speichern, dann Kabel in den Router. Ohne Login-Seite keine IP setzen. SSH-Port **8022**, nach Reset oft zu.

## Pitfalls

- Stale ARP als Reachable behandeln — negativer `expire`, Flag `REJECT`, oder MAC ohne ICMP/HTTP heißt Cache, nicht Host. Nach Sweep muss die Zeile complete sein.
- ICMP-Timeout als „nicht Yeastar“ werten — TG kann Ping filtern; L2-complete + OUI entscheidet, Ports sind Zusatz.
- TG-Web-UI von FreePBX-SSH aus öffnen — TG ist LAN-Gerät am Standort des Mac, nicht `ari.activi.io`.
- Erinnerte Home-IP als Sweep-Ziel nutzen — Live-Ifaces können `192.168.1.0/24` (WLAN) und gleichzeitig `192.168.5.0/24` (USB-LAN) sein, während Memory noch `.31` kennt.
- Nur `en0` scannen — USB-C-Ethernet (`en8`) ist der Direktlink zum TG; WLAN-Isolation oder anderes Subnetz macht `en0` leer, während `f4:b5:49` auf `en8` complete ist.
- Recovery-Formular als Gateway-Setup behandeln — Seitentitel Upgrade heißt Firmware fehlen; ohne SN und offizielle `.bin` nicht flashen.
- HTTP-Firmware auf Port 8080 serven — TG-CGI lehnt ab (`result=-1`); nur Port 80 auf der Mac-IP des TG-Links.
- sudo-Passwort im Agent-PTY erwarten — User sieht das Prompt nicht; Server in Terminal.app starten, Agent erst nach „Serving HTTP on … port 80“ posten.
- Factory-Reset als Firewall/HTTPS-Problem behandeln — Default ist HTTP auf `192.168.5.150`; ohne USB-LAN-Iface (`en8`) ist das TG vom WLAN aus unerreichbar.
- Mac-LAN und TG am gleichen Router als „gleiches Netz“ werten — nach Reset bleibt das TG auf `.5.150`, der Router vergibt `.31.x`; L2-Switch ändert das Subnetz nicht.
- `en8` 1000baseT oder zweite `inet 192.168.31.x` als Direktlink zum TG behandeln — das ist der Router; TG-Direkt ist 100baseTX und nur `192.168.5.10`.
- WLAN anlassen während USB-Direkt — Dual-Home (`en0` `.31` + `en8` `.5`) lässt ARP complete erscheinen, HTTP bleibt tot; WLAN aus bis Login.
- ARP-complete ohne HTTP als „erreichbar, IP setzen“ — ohne Login-Seite keine LAN-IP ändern.
- SSH auf Port 22 prüfen — TG-SSH ist 8022; filtered 22 sagt nichts über SSH-Status.
- SSH-Passwort raten oder bruteforcen — nicht. Passwort nur in der Web-UI setzen, nachdem Login geht.
