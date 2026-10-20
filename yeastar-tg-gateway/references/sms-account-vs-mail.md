# SMS Account Setting ≠ Mail-Empfänger

Live UI (2026-08-18): **SMS → SMS Account Setting** hat nur Enable SMS + User Name + Password.

Das ist ein HTTP-Login, damit ein Programm **auf dem TG** SMS schickt. Nicht SMTP, nicht Resend, nicht `sms@activi.io`.

Enable SMS **aus** lassen, solange niemand im LAN per HTTP sendet. Empfänger suchen → Cancel, nicht Save.

Empfänger SMS→Mail: **Gateway → Mobile List → Stift am Port mit SIM → Add Email**.

SMTP-Konto: **SMS → SMS Settings**. Ein Password für SMTP+POP3. Details: `sms-ui.md`, Resend: `sms-resend-smtp.md`.
