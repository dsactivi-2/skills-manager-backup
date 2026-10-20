# Hetzner Cloud: Zugang bei verlorener SSH-Erreichbarkeit

## Grundsatz

Bei `Connection refused` erst die externe Beobachtung sauber formulieren: Name/IP sind erreichbar, aber der jeweilige Port wird aktiv abgelehnt. Das allein beweist weder eine bestimmte Firewall noch einen gestoppten Dienst. Zeitliche Reihenfolge vom Nutzer erfragen bzw. beachten; ein später angewendetes Firewall-Ereignis ist nicht die ursprüngliche Ursache.

## Offiziell verifizierter Zugangspfad

Hetzner Cloud bietet eine VNC-Konsole für Notfälle. Wenn der Server nur mit SSH-Key erstellt wurde oder das Passwort nicht mehr bekannt ist:

1. Im Server-Menü `Rescue` öffnen.
2. Unter `ROOT PASSWORD` `RESET ROOT PASSWORD` wählen.
3. Das einmalig angezeigte Passwort in der VNC-Konsole als `root` verwenden.

Der SSH-Key wird dadurch nicht entfernt. Wenn Konsolen-Zugang nicht reicht, kann Rescue aktiviert werden; dies startet das System neu und ist daher eine bewusste, zustandsändernde Eskalation.

## VNC-Interaktion

Web-VNC ist für Notfälle, nicht für normale Administration. Bei Nutzerführung zuerst einen einzelnen kurzen, ausschließlich lesenden Befehl geben und um einen Screenshot der Ausgabe bitten. Nicht mehrere lange Befehlsblöcke voraussetzen, da Zwischenablage-Unterstützung in Browser-Konsolen nicht verlässlich ist.

Beispiel erster Check:

```text
systemctl status ssh
```

Danach je nach Ausgabe Listener (`ss`) und Host-Firewall prüfen.

## Quellen

- Hetzner Docs: "Using the console"
- Hetzner Docs: "Using Rescue"
- Hetzner Docs: "Changing the SSH key"
