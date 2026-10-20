# macOS Ethernet / USB-LAN Diagnostics

Schnelle Diagnose wenn ein Ethernet-Adapter (USB-C, Thunderbolt, intern) keine Verbindung aufbaut.

## Diagnose-Pipeline (von schnell nach tief)

### 1. Interface finden
```bash
networksetup -listallhardwareports
```
Sucht nach "USB 10/100/1000 LAN", "Ethernet", "Thunderbolt Ethernet" etc.
Notiere Device-Name (z.B. `en8`) und Service-Name.

### 2. Link-Status prüfen
```bash
ifconfig <device> | grep -E "(status|media|inet)"
```
- `status: active` + `inet X.X.X.X` → Verbindung steht, DHCP hat IP vergeben
- `status: inactive` + `media: autoselect (none)` → **kein physischer Link** → Kabelproblem

### 3. Service-Konfiguration
```bash
networksetup -getinfo "<service>"
networksetup -getmedia "<service>"
networksetup -getdnsservers "<service>"
networksetup -getnetworkserviceenabled "<service>"
```

### 4. Adapter-Details (Treiber, Vendor)
```bash
system_profiler SPEthernetDataType
```
Zeigt Vendor, Product ID, Treiber (wichtig: AppleUserECM vs. Hersteller-DEXT).

### 5. System-Logs auf Link-Events
```bash
log show --predicate 'process == "ControlCenter"' --style compact --last 10m 2>/dev/null | grep -i "hasLink"
```
`hasLink: false` durchgehend = kein Signal am Kabel.

### 6. USB-Device Tree (tief)
```bash
ioreg -p IOUSB -w0 -l 2>/dev/null | grep -A 50 "USB 10/100/1000 LAN"
```
Prüft: UsbLinkSpeed (sollte 5000000000 = 5 Gb/s sein), Power State, Driver geladen.

## Häufige Ursachen für "status: inactive"

| Symptom | Ursache | Fix |
|---------|---------|-----|
| `status: inactive`, `media: none` | Kein physischer Link | Kabel prüfen, anderen Port testen |
| Interface fehlt ganz | Adapter nicht erkannt | USB-Port wechseln, Adapter neu einstecken |
| Interface da, kein DHCP | Kein DHCP-Server | `networksetup -setdhcp` erneut ausführen |
| `hasLink: true` aber keine IP | DHCP-Problem | `networksetup -setv4off; sleep 2; networksetup -setdhcp` |

## Service-Order & WLAN-Umschaltung

Service-Order bestimmt Priorität:
```bash
networksetup -listnetworkserviceorder
```

WLAN deaktivieren sobald LAN aktiv:
```bash
networksetup -setairportpower en0 off
```

macOS priorisiert kabelgebundene Verbindungen automatisch, wenn sie in der Service-Order oben stehen.

## Realtek RTL8153 Spezifisch

- Vendor: 0x0bda, Product: 0x8153
- Treiber: `com.apple.DriverKit.AppleUserECM` (eingebaut, kein DEXT nötig)
- USB 3.0 (5 Gb/s), unterstützt 10/100/1000/2500/5000
- Media-Optionen: `autoselect`, `10baseT/UTP`, `100baseTX`, `1000baseT`, `2500Base-T`, `5000Base-T`
- `networksetup -setmedia` mit diesem Treiber oft wirkungslos — `autoselect` ist der einzig funktionierende Modus
