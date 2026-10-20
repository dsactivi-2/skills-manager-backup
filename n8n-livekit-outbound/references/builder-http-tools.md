# Agent Builder HTTP-Tools (n8n Webhooks)

MCP kann den Builder nicht klicken. User: copy-paste Feld für Feld. Nicht „ich kann nicht klicken“ ohne die Felder.

## Verify unpublished vs live

| Test | Bedeutung |
|---|---|
| Browser **GET** URL | immer 404 wenn nur POST existiert. Kein Test. |
| POST ohne Header, unpublished | 404 |
| POST ohne Header, published + Header-Auth | **403** „Authorization data is wrong“ = live |

Tools erst speichern nach 403 (oder 200 mit Key). GET-404 ignorieren.

## Method / Header

- Method **POST**. GET im Formular = falsch.
- Ein Auth-Header: Name `X-Energy-Key`, Value **genau** `{{secrets.ENERGY_WEBHOOK_KEY}}`.
- Klartext-Key nicht ins Tool.
- Secret zuerst anlegen, Name bytegleich. Sonst: „Field contains unrecognized variables“.
- Platzhalter `MY_API_KEY` umbenennen.
- `Content-Type` im Builder oft **Invalid**. Ganze Header-Zeile löschen, nicht umbenennen. POST+JSON-Parameter reichen.
- Alle Tools dasselbe Secret. Kein zweites für `book_termin`.

## Call ending (Data Collection)

Builder **erzwingt** oft eine Endpoint-URL zum Speichern. Leer geht dann nicht.

- Kein Platzhalter (`platzhaket.com`).
- Dump: derselbe `energy-call-result` wie `save_result` + Header `X-Energy-Key`.
- Body ≠ Tool-Body. n8n darf 200+Fehler-JSON. Kein Kalender.
- Eigener `call-summary`-Webhook fehlt weiter. Summary ändert `outcome` nicht.

## Vier Tools (Energy)

`get_termine` `book_termin` `get_kunde` `save_result`. Client-Tools/MCP leer. Silent: get_* / book_* NO; `save_result` YES.
