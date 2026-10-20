# Dograh ARI audio codec

## Official (asterisk-ari docs)
External media channel = **G.711 μ-law (`ulaw`)**.  
PJSIP/trunk: `allow=ulaw`.

## PBX UI codec pickers (FreePBX etc.)
| Codec | Dograh ARI media |
|-------|------------------|
| G.711 u-law | **Required** |
| G.711 a-law | Not ARI-WS codec; SIP may transcode |
| G.722 / Opus / G.729 / GSM | Not Dograh externalMedia codec |

## Ops
- Ring + no audio: check modules + WS + **ulaw**, not Opus upgrade first  
- Browser WebRTC/TURN ≠ ARI media path  
- Self-host WS URI must target voiceeu (or that deploy), not cloud unless intentional
