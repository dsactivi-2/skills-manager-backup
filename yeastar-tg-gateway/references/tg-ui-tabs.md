# TG400 UI-Reiter (live 2026-08-15)

Screenshot: nur den gefragten Reiter erklären. Eine Tabelle pro Block.

## Save vs Apply vs Reboot Module

| Aktion | Wirkung |
|---|---|
| Save | legt ab |
| Apply Changes (gelb) | führt aus — nach Port-Save nötig |
| Reboot Module | nur dieser Funkschacht, SIM bucht neu. Andere Ports bleiben. Gespräch auf dem Port bricht ab. Nicht nach bloßem Umbenennen |

## General (Stift)

Trunk Name = Anzeigename (`SIM1`/`SIM2` ohne Leerzeichen). Mobile Number = merken, ändert die Netz-Nummer nicht. Rx/Tx 40 %, Single Call Max 0.

## Call Duration

Zählt Minuten **im TG**, nicht die Anbieterrechnung. Talk Time 0 = kein Limit. Alarm/Clear nur wenn Talk Time > 0. Ohne Limit alles Werk lassen.

## Advanced Settings

Oben nur Anzeige (IMEI/IMSI/Module Type/Carrier/Signal). `Module Type GSM` = kein LTE-Chip, **kein** Enable VoLTE.

| Feld | Jetzt |
|---|---|
| SMS Center | von der SIM, nur ändern wenn SMS nicht geht |
| SMS Receipt | an lassen wenn SMS genutzt |
| PIN Code | leer wenn PIN aus. 3× falsch → PUK, TG kann kein PUK |
| DTMF / USSD / Echo / Network / Carrier / Band | Werk (Software / Little-endian / an / Automatic) |

## Call Control = Netz-Umleitung

Nicht verwechseln mit Mobile-to-IP. Always Forward = Anruf kommt **nicht** mehr am TG-Port an. No Answer / Busy / Unreachable = nur wenn niemand rangeht / besetzt / tot — **nicht** „alle Outbound-Nummern zum Inbound-Agent“.

CLIR-Haken **an** = Nummer unterdrücken. Aus = anzeigen.

## Leere Ports

Port ohne SIM: keinen Stift speichern, nicht in die Mobile Group. Höchstens Outbound OFF.

## Mobile Group Strategy (Dropdown live)

Nur Rauswahl (IP to Mobile). Inbound bleibt pro SIM-Nummer.

| Strategy | Nutzen |
|---|---|
| Balance | gleichmäßig — vorschlagen bei gleichwertigen SIMs |
| Sequence | immer erste Selected, Rest Reserve |
| Default | UG/FAQ nicht erklärt — nicht nehmen |

Gruppe anlegen: Gateway → Mobile List → Mobile Group, nicht VoIP Trunk Group.
