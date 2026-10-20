# Dograh ↔ TG400

Dograh spricht nicht SIP mit dem TG. Self-Host ohne CPaaS: nur Provider `ari` im Register (`providers/__init__.py`: ari + 6 CPaaS).

Kette: voiceeu --ARI/WS ulaw 8 kHz--> Asterisk --SIP--> TG400 --GSM--> Mobil.

Instanz dieser Kette (Freigabe): `https://voiceeu.activi.io/`.

PBX-Ranking unabhängig vom Ist-System. Live-Diff Fork/Original: `dograh-upstream-platform` / `references/ari-live-diff.md`.
