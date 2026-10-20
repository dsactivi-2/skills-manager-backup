# Activi: two PBX hosts (do not mix)

Live 2026-08-15. Secrets stay in env files, not here.

| Role | Host | Notes |
|---|---|---|
| **New** FreePBX 17 + Asterisk 22.10 | `ari.activi.io` / `178.105.149.160` | Box `pbx-tg400`. ARI `http://ari.activi.io:8088`. GUI HTTPS `/admin`. Skill `ownfreepbx`. |
| **Old** Gono / previous ARI | `https://pbx.activi.io` | All voiceeu `telephony_configurations` still pointed here (orgs 1–3). |

## Do not overwrite

voiceeu orgs 1/2/3 already have ARI named `dograh_eu` / `GOno PBX ARI EU` → **pbx.activi.io**.

To test the new box: **add** a new config (e.g. `pbx-tg400`), `is_default_outbound=false`, after the user picks the org. Never PUT over the Gono default.

Dograh phone-number = FreePBX extension string (e.g. `100`), plus the same number as a PJSIP extension. Per project later: own extension + own number.

## GUI vs ARI

| URL | What |
|---|---|
| `https://ari.activi.io/` | FreePBX login |
| `http://ari.activi.io:8088` | ARI for Dograh only |

Dashboard “HTTP Bind → Localhost” must not be applied. Bind SoT: `fwconsole setting HTTPBINDADDRESS 0.0.0.0` + `ENABLE_ARI 1`.

Sipgate trunk on the new box is a **test registrar** only. TG remains prod SoT. Registered ≠ a completed call.
