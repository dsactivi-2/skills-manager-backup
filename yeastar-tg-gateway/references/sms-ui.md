# TG400 SMS-UI (UG 91.3.0.23 + live 2026-08-18)

Oben **SMS**, nicht Gateway. Drei verschiedene Dinge:

| Menü | Was es ist | Wann |
|---|---|---|
| Send SMS | eine SMS von Hand | kein Config |
| SMS Settings | Mail ↔ SMS (SMTP/POP3) | dauerhaft Mail |
| API Settings | Dritter loggt sich **am TG** ein | nicht der n8n-Webhook |

## Mail (SMS Settings)

UG: SMS→Mail braucht **SMTP**. Mail→SMS braucht **POP3**. POP3 **löscht** geholte Mails.

Email-to-SMS-Betreff (UG wörtlich):

```
port:[port];num:[number];code:[code];
```

| Teil | Pflicht | Bedeutung |
|---|---|---|
| `num:` | ja | Ziel. Haken Country Code an → Nummer **ohne** Ländervorwahl |
| `code:` | ja wenn Access Code gesetzt | PIN nur im Betreff, nicht Body/Chat |
| `port:` | nein | sonst erste freie SIM |
| Body | ja | SMS-Text |

An = genau **Email Address** im Formular.

`noreply@` oft kein Posteingang. Konto muss existieren und senden können.

Gmail (offiziell + UG „Gmail → SSL/TLS“):

| Feld | Wert |
|---|---|
| SMTP | `smtp.gmail.com` Port **587** |
| POP3 | `pop.gmail.com` Port **995** |
| TLS + STARTTLS | an |
| Password | Google-**App-Passwort**, nicht das Gmail-Pass |
| Gmail selbst | POP aktivieren |

Nicht speichern ohne Host+Pass. Test SMTP erst, dann Save+Apply.

`sms@` = Empfänger für SMS→Mail (Port-Stift / Add Email), **nicht** das Email-Address-Feld.

## API Settings ≠ n8n-Webhook

| | Richtung |
|---|---|
| API Settings | Client → **TG** (User/Pass, optional IP) |
| n8n `TG400 SMS -> n8n` | **TG →** öffentlicher Webhook |

TG nur Home-LAN: Cloud-n8n erreicht die API nicht. **Kein** Port-Forward ohne Freigabe. Permitted IP leer lassen, solange API nicht public ist.

Passwörter nicht in Chat/Screenshots. Nach Leak rotieren.
