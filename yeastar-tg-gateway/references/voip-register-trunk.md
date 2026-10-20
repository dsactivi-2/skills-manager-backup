# TG400 VoIP Register-Trunk (UG + live)

User wählt Register vs Peer **explizit**. Home-WAN dynamisch → Register vorschlagen, nicht still setzen.

UG „Connect TG to PBX (Register Trunk)“:

1. Auf der **PBX eine Nebenstelle** anlegen (nicht einen Provider-Trunk recyceln).
2. TG: Gateway → VoIP Settings → **VoIP Trunk** → Add.
3. Routen erst wenn der Trunk **Registered** ist.

## TG-Felder (Register)

| Feld | Wert-Muster |
|---|---|
| Trunk Type | Trunk |
| Type | SIP |
| Provider Name | Label, z.B. `pbx-tg400` |
| Domain + Hostname/IP | PBX-Host (`ari.activi.io`) |
| User Name + Authorization Name | **dieselbe** Nebenstellen-Nummer |
| Password | Secret der Nebenstelle — GUI/Env, nicht Chat |

Nicht: IAX, US-Outbound-Wizard (NPA/NXX), Blacklist/Callback/AutoCLIP Tag 1.

## PBX-Nebenstelle

Nicht Ext für Softphone-Test und nicht Ext/Trunks, die Sipgate-DIDs heißen. Eigene Ext (z.B. `300` / `tg400`), Codec ulaw (+ alaw).

Kette: SIM → Mobile-to-IP → dieser Trunk → PBX → Stasis. Call Control am Port bleibt **aus**.
