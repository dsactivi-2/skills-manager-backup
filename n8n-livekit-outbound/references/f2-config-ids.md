# F2 Config-IDs (n8n ← LiveKit outbound)

CreateSIPParticipant braucht `sip_trunk_id` = LiveKit-Outbound-Trunk-ID (`ST_…`), nicht SIP-URI, nicht PBX.

| Was der User sieht | Wohin |
|---|---|
| `https://<projekt>.livekit.cloud` | n8n `livekitHttpUrl` |
| `wss://<projekt>.livekit.cloud` | umschreiben, nicht so speichern |
| Agent-Kartenname (`Michaela`) | n8n `agentName` |
| `CA_…` | LiveKit Agent-ID, nicht n8n |
| `sip:<host>.sip.livekit.cloud` | Inbound-URI, nicht Trunk-ID |
| FreePBX-Nebenstelle / Trunk-Name | nur auf `ari.activi.io`, nicht n8n |
| LiveKit Cloud → Telephony → Outbound trunk → **ID** | n8n `sipTrunkId` |

Reihenfolge: PBX-Endpoint (GUI) → LiveKit Outbound-Trunk (address = PBX) → `ST_…` nach n8n.
