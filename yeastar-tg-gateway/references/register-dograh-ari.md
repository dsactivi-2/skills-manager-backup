# Register-Trunk + Dograh-ARI (Felder)

UG 91.3.0.23 sagt „create VoIP extension on PBX, then Register trunk on TG“. Live-UI 91.3.0.37: Trunk Type = **Register Trunk**.

## Reihenfolge

1. FreePBX: eigene PJSIP-Ext nur für TG (nicht Softphone-100, nicht Sipgate-200/555). Secret lokale Env.
2. TG → Gateway → VoIP Settings → VoIP Trunk → Add → **Register Trunk**.
3. Routen erst wenn PBX `pjsip show endpoint EXT` Contact **Avail**.
4. Dograh-Telephony auf **derselben** Instanz wie `websocket_client.conf` uri.

## TG Register-Felder

| Feld | Wert (diese Kette) |
|---|---|
| Trunk Type | Register Trunk |
| Type | SIP |
| Name | `pbxtg400` (kein Bindestrich) |
| Domain + Hostname | `ari.activi.io` |
| User + Auth | Ext-Nummer (`300`) |
| Password | Ext-Secret (GUI, nicht Chat) |

## Routen

| Route | Source | Destination | Simple | Hotline |
|---|---|---|---|---|
| IP to Mobile (`pbx-to-sim`) | `pbxtg400` | Mobile Group | Yes | leer |
| Mobile to IP (`sim-to-pbx`) | Mobile Group | `pbxtg400` | — | leer bis Dograh-WF |

## Dograh Telephony-Formular

| Feld | Wert |
|---|---|
| Name | `pbx-tg400` |
| ARI Endpoint | `http://ari.activi.io:8088` |
| Stasis App / WS-Name | `dograh` |
| ARI Password | User `dograh` in ari.conf — **nicht** Ext-Secret |
| Default outbound | aus, wenn andere ARI (Gono) bleiben soll |
| From Extensions | leer |
| Phone danach | Address = Ext (`300`) |

Testziel: `49177…@300` ohne `+`.

## SMS (kurz)

Send SMS ≠ Config. Mail: SMS Settings (Gmail `smtp.gmail.com:587` + `pop.gmail.com:995` nur nach User-Konto). API Settings = Login **zum** TG; Cloud-n8n erreicht Home-LAN nicht ohne Port-Freigabe (nicht öffnen ohne Freigabe). n8n-WF „SMS → n8n“ ist TG→Webhook, anderes Formular.
