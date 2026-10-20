# Troubleshooting Checklist

Use PASS/WARN/FAIL. Keep checks read-only unless the user approves changes.

When host access is available, run `scripts/gonopbx_telephony_preflight.sh` first to collect a timestamped baseline. Use its output as evidence, not as a substitute for source-grounded reasoning.

## Contents

- Common value checks.
- Registered trunk does not register.
- Static trunk cannot send or receive.
- Outbound call fails.
- Inbound Infobip DID does not reach GOno PBX.
- Dograh cannot connect to ARI.
- Calls do not reach Dograh.
- No audio or one-way audio.
- Reporting format.

## Common value checks

- PASS/WARN/FAIL: Infobip trunk type is known.
- PASS/WARN/FAIL: Infobip SBC FQDN/IP is known and matches the account.
- PASS/WARN/FAIL: GOno PBX trunk authentication mode matches Infobip trunk type.
- PASS/WARN/FAIL: SIP credentials are present in the system but not displayed.
- PASS/WARN/FAIL: DID number format expected by GOno PBX is known.
- PASS/WARN/FAIL: Codec overlap exists between Infobip, GOno PBX, and Dograh when applicable.
- PASS/WARN/FAIL: Firewall/NAT allows SIP signaling and RTP media.

## Registered trunk does not register

Likely domains:

- Wrong Infobip SBC FQDN/IP or data center.
- Wrong username/password.
- GOno PBX trunk configured as fixed-IP instead of registration.
- Firewall blocks outbound SIP.
- Transport mismatch.

Evidence to collect:

- Registration status from GOno PBX/Asterisk.
- Redacted trunk target and auth mode.
- Infobip trunk status.
- Asterisk logs around registration attempt.

## Static trunk cannot send or receive

Likely domains:

- Source IP not declared in Infobip.
- Destination IP/FQDN not declared or unreachable.
- PBX endpoint is behind unsupported dynamic/shared NAT for static mode.
- OPTIONS behavior marks trunk out of service.
- Firewall blocks inbound SIP or RTP.

Evidence to collect:

- Public PBX IP/FQDN.
- Infobip configured source/destination entries.
- SIP OPTIONS or test-call status.
- Firewall/NAT path.

## Outbound call fails

Check in order:

1. Extension can place internal calls.
2. Extension has an outbound DID/caller ID assignment if GOno PBX requires it.
3. GOno PBX selects the Infobip trunk for the dialed pattern.
4. Infobip accepts the outbound INVITE.
5. Caller ID and destination format match Infobip/account policy.
6. Codec negotiation succeeds.

## Inbound Infobip DID does not reach GOno PBX

Check in order:

1. Infobip number is voice-enabled and assigned to Forward to Call Routing.
2. Call Routing route exists and is enabled.
3. Route destination is the intended SIP trunk.
4. Route change propagation time has passed.
5. Route Simulator selects the expected route.
6. Infobip sends the call to the expected GOno PBX endpoint.
7. GOno PBX has a DID route for the received number format.
8. The target extension or internal route is active.

## Dograh cannot connect to ARI

Likely domains:

- ARI HTTP server disabled or port not exposed.
- ARI module not loaded.
- Dograh ARI endpoint URL wrong.
- Firewall blocks Dograh to Asterisk ARI.
- Stasis app name or password mismatch.

Evidence to collect:

- Redacted ARI endpoint URL.
- Module status for ARI.
- Firewall exposure design.
- Dograh telephony configuration fields without secrets.

## Calls do not reach Dograh

Check:

- Asterisk dialplan routes the called extension to `Stasis(<app-name>)`.
- Dograh has that extension added as a phone number under the Asterisk ARI configuration.
- The extension has an inbound workflow assigned.
- ARI WebSocket events are visible.
- GOno PBX did not overwrite the required dialplan change.

## No audio or one-way audio

Check:

- RTP firewall/NAT path.
- Codec overlap.
- `ulaw` available when Dograh is in the path.
- `chan_websocket` is loaded.
- `res_websocket_client` is loaded.
- `websocket_client.conf` points to the correct Dograh URI.
- WebSocket client name in Dograh matches the Asterisk section name.
- TLS mode and certificates match the Dograh endpoint scheme.

## Reporting format

Use this compact report:

```text
Status: PASS_WITH_GAPS | WARN | FAIL

Call path:
Infobip -> GOno PBX -> Extension/Dograh

Findings:
- PASS: ...
- WARN: ...
- FAIL: ...

Unknowns:
- Needs user confirmation: ...

Next safe step:
...
```
