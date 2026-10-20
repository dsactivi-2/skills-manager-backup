# Projektbrief (SoT vor TAR)

Pfad-Vorschlag: `~/Downloads/Projektbrief-Yeastar-TG400.md` (oder Projektordner). Eine Datei.

## Blöcke
1. **Zweck** — wozu das Gateway (z.B. Dograh → PBX → GSM), Constraints (EU/self-host), was bewusst nicht.
2. **Entscheidungen** — nur beschlossene Punkte, Datum. Secrets = Platzhalter.
3. **Live-Ist** — System Info (Produkt, HW, FW-Zahl), aktuelle IP, Alias ja/nein. FW hier, nicht unter Entscheidungen.

## Pro Punkt
Entscheiden → in Entscheidungen schreiben → nächster Punkt. Vor dem nächsten nur prüfen, ob die neue Wahl eine alte Entscheidung bricht; dann Brief anpassen.

Abhängigkeit: Zweck → LAN → Passwort/Zeit → GSM → SIP (offen bis Host/User/Pass) → Routen → SMS → Security → Rest default nein.

TAR erst wenn Zweck + alle Pflichtpunkte geschlossen. Kein sqlite-Handbau vor Schluss.

## Zweck füllen

Nicht aus Memory/Session/Codex-Prompt übernehmen, bevor die Kandidatenliste gezeigt und freigegeben ist.

Ist-PBX (Produkt/Version) nicht erfragen, bevor ein unabhängiges Ranking steht — nur danach Keep/Replace.

Aktuelles Mac-LAN nicht als Prod-LAN schreiben, wenn der TG woanders (Home) stehen soll. WAN-Optionen: `references/home-wan-pbx.md`.
