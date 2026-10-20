# GonoPBX Keep/Replace (Repo 2026-08-15)

Ist-PBX-Repo: `ankaios76/gonopbx` HEAD `ae0e753` (2026-03-24), Release v2.1.1. Nur GitHub, keine Live-Instanz.

| | GonoPBX | FreePBX 17 + Ast ≥22.6 |
|---|---|---|
| Steuerung | AMI :5038 | AMI + ARI möglich |
| `ari.conf` / Stasis / WS | fehlen | nach Install Module prüfen |
| Image | `andrius/asterisk:20` unpinned | Skript Default 22 |
| Dograh-Kette | nicht SoT | Replace-Ziel |

Keep nur mit Image ≥22.6 + selbst ARI+WS. Sonst Replace. Siehe `pbx-gui-and-ari.md` + `pbx-ansible-vicidial.md`.
