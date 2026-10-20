# ARI split hosts (DograhEUV2 + GonoPBX)

## Roles

| Host | Job | Tools |
|------|-----|-------|
| DograhEUV2 `167.233.126.212` (key `~/.ssh/dograh_vps`) | Dograh compose API/UI/Postgres | docker ps/logs, doctor.sh, env, `dograh-postgres-1` |
| GonoPBX `178.105.223.175` (key `~/.ssh/gonopbx_ed25519`) | Real PBX/Asterisk | docker exec asterisk -rx … |

User/org/telephony SQL: `references/voiceeu-oss-db-users.md`.

## Diagnostic blocks (read-only)

**A app host:** inventory compose containers + API logs during silent call.  
**B PBX host:** find Asterisk (docker/ps/systemd), never apt-install asterisk.

## Media

externalMedia / chan_websocket / ulaw → self-host `/api/v1/telephony/ws/ari` (voiceeu when that is the deploy).

Browser TURN ≠ ARI handset path.

## Docs

https://docs.dograh.com/integrations/telephony/asterisk-ari
