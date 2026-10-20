# TG400 SMS → Mail via Resend (kein Mail→SMS)

Resend ist nur SMTP raus. Der TG hat **ein** Password für SMTP+POP3. Resend-Key ≠ Gmail-POP. Mail→SMS damit unmöglich.

## Resend UI

| Klick | Zweck |
|---|---|
| Domains | `activi.io` muss Verified/grün sein |
| API keys | Sending access, Domain einschränken |
| Broadcasts | Newsletter — nicht für den TG |

Keine Mailbox anlegen. From ist irgendeine Adresse @verifizierter Domain (live: `notifysms@activi.io`). Empfänger bleibt ein echtes Postfach (`sms@activi.io`) am **Port**, nicht in Resend.

API-Key (`re_…`) nie in Chat/Screenshot. Leak → revoke, neuen Key nur ins TG-Feld Password.

## TG → SMS → SMS Settings

| Feld | Wert |
|---|---|
| Email Address | `notifysms@activi.io` (From, Domain grün) |
| Password | Resend API key |
| SMTP | `smtp.resend.com` **587** |
| TLS + STARTTLS | an |
| POP3 | Dummy `pop.resend.com` **995** damit Save geht |
| Email To SMS | **No** |
| Test | nur SMTP. POP3 darf rot sein |

Username bei Resend ist `resend`. Dieses TG-Formular hat oft kein User-Feld — Key = Password.

Empfänger: Gateway → Mobile List → Stift am Port mit SIM → Add Email → `sms@activi.io`. Nicht SMS Account Setting.

## Gmail (wenn kein Resend)

`smtp.gmail.com:587` + `pop.gmail.com:995` + App-Passwort + POP in Gmail an. Port **25/110** zuerst prüfen, bevor „App-Passwort geht nicht“.

## SMS Account Setting

Anderes Formular: Enable SMS + User/Pass = HTTP-API-Login auf dem TG. Nicht SMTP, nicht Empfänger. Aus lassen.

## Nicht

- Port-Forward für TG-API ohne Freigabe
- Resend From = `@gmail.com`
- Key ins Chat
- Dummy-POP3 als „Mail→SMS funktioniert“
