# SIP twirp path and retry after wait

Docs: SIP API is `POST /twirp/livekit.SIP/<MethodName>`. CreateSIPParticipant needs JWT grant `sip.call`.

Wrong: `livekit.SIPService`. Right: `livekit.SIP/CreateSIPParticipant`.

In n8n HTTP Request keep:

```
={{ $('Config…').item.json.livekitHttpUrl.replace('wss://','https://').replace(/\/$/, '') + '/twirp/livekit.SIP/CreateSIPParticipant' }}
```

Do not paste the resolved `https://<project>.livekit.cloud/…` into the node. Config holds the host.

Path check without a call: POST JSON `{}` no Authorization. Twirp `not_found` / `access key is not found` = host+path live. Empty browser GET is expected.

Retry (tech fail only: 5xx, timeout, no SIP ACK — not busy/no-answer):

1. First CreateSIP error output → Wait 15s (Dispatch fail → Wait 5s).
2. Wait → **second** HTTP CreateSIP (same URL/body/JWT from the Code node).
3. Second success → status calling. Second fail → Lücke, not "nicht erreicht".

Do not Wait → Lücke. Do not Wait → first SIP (loop).
