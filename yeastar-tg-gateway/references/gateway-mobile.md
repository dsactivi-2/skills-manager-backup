# Gateway-UI: Mobile, Gruppe, VoLTE

UG 91.3.0.23 (PDF `tg200-tg400-tg800-tg1600-user-guide-en.pdf`, read_file extrahiert Text). Sidebar-Erklärungen auf Deutsch, kurz, eine Tabelle pro Block.

## Pfad Name/PIN/VoLTE

`Gateway > Mobile List > Mobile List` → Stift am **Port** (nicht am Namen). Feld Name (Werk `Trunk1`…`Trunk4`) ≠ physischer Slot. User kann „Sim 2“ auf Port 3 meinen — Slot zählt, Name nur Label.

PIN: UG Unlock = PIN eingeben. PIN-Dienst an/aus geht am TG nicht. 3× falsch → PUK nur am Handy.

## VoLTE

UI-Haken **Enable VoLTE**, DB `gsmtrunk.volte` = `yes`/`no`, Werk `no`. Tabelle: nur `ja`/`nein`.

UG-Voraussetzung: LTE-Modul + 4G-SIM + 4G-Netz. Schritte: Advanced Settings → Network Type **LTE Only** → Haken Enable VoLTE → Save → ~1 min → Apply Changes.

Unsicher → `nein`. 2G/3G = Circuit-Sprache. 4G ohne VoLTE = kein eigenes Telefon (Fallback 2G/3G wenn Netz das kann). 4G+VoLTE = Sprache über LTE.

## Mobile Group (UG „Group Mobile Trunks“)

Pfad: `Gateway > Mobile List > Mobile Group` → Add New Mobile Group → Name, **outgoing Strategy**, Trunks Selected → Save/Apply.

Gruppe ≠ eine Nummer. Jede SIM behält ihre MSISDN.

| Richtung | Route | Gruppe macht |
|---|---|---|
| Raus | IP to Mobile, Destination = Gruppe | TG wählt freie SIM nach Strategy |
| Rein | Mobile to IP, Source = eine SIM oder Gruppe | Anruf trifft immer die gewählte Nummer/SIM. Gruppe als Source = **gleiche** Weiterleitung für alle Mitglieder, **kein** Umlegen auf freie SIM |

Strategy-Text UG: nur wenn Gruppe auf einer **IP to Mobile**-Route liegt.

Anlegen: nach GSM-Ports, mit/vor Routen. SIP-Host nicht nötig zum Anlegen, Route braucht die Gruppe.

## Sidebar (einfach, nur Gateway)

| Block | Punkt | Eine Zeile |
|---|---|---|
| Mobile List | Mobile List | 4 SIM-Schächte |
| | Mobile Group | Bündel für Rauswahl |
| VoIP Settings | VoIP Trunk | Leitung zur PBX |
| | Trunk Group | VoIP-Bündel |
| | SIP Settings | SIP-Fein |
| | IAX Settings | nicht SIP — ignorieren bis Auftrag |
| | General Preferences | Allgemein |
| Routes Settings | Mobile to IP | Handy → PBX |
| | IP to Mobile | PBX → SIM |
| | Blacklist | Nummern sperren |
| | Callback / AutoCLIP | später, mit Routen |

Nach LAN-Umzug alte Safari-URL `.5.150` ist tot. Web = neue LAN-IP.
