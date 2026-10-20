# Infobip SIP Trunking Reference

## Which Infobip pages to use

Use these direct pages for carrier setup:

- SIP trunking overview: <https://www.infobip.com/docs/voice-and-video/sip-trunking>
- SIP trunk setup: <https://www.infobip.com/docs/voice-and-video/sip-trunking/set-up-sip-trunk>
- Call Routing: <https://www.infobip.com/docs/voice-and-video/call-routing>

The broad Voice and Video overview is a valid entry point, but it is not precise enough by itself for GOno PBX carrier configuration.

## Trunk type selection

Infobip supports multiple trunk models. For GOno PBX, evaluate these two first:

- Registered trunk: PBX/SBC registers to Infobip with username and password. This usually matches GOno PBX's documented registration-based SIP trunk mode.
- Static trunk: Infobip trusts declared customer IPs and routes SIP traffic to declared destinations. This requires public, dedicated IP addresses for the PBX/SBC endpoint.

Authenticated trunks in the retrieved Infobip page are described for external platforms with DIGEST/header-based authentication and TLS-only connectivity, especially AI platforms. Do not select this model for GOno PBX unless the user provides source evidence or Infobip account guidance that says it is appropriate.

## Infobip account limits and planning values

The setup page describes default account limits such as trunk count, trunks per data center, IP addresses per trunk, data centers per account, and channels per trunk. Do not rely on those defaults as contractual values; confirm them in the user's Infobip account.

Collect:

- Trunk provider/type.
- Data center/region.
- Channel count and billing plan.
- Whether a service address is required for the jurisdiction.
- Infobip-generated SBC FQDN or static SBC IPs.
- SIP username and password for registered trunks.
- Source IPs for traffic from GOno PBX to Infobip.
- Destination IPs/FQDNs for traffic from Infobip to GOno PBX.
- Transport mode.
- Codec policy.
- DID numbers and inbound routing target.

## SBC addressing

Infobip may provide either:

- A unique FQDN for newer accounts/trunks.
- Static SBC IP addresses for accounts with existing trunks under the documented Infobip behavior.

Do not hardcode SBC addresses from examples. Use the exact FQDN/IPs returned by the user's Infobip account.

## Technical requirements relevant to GOno PBX

The Infobip SIP trunking page lists support for common SIP methods such as INVITE, ACK, BYE, CANCEL, OPTIONS, reINVITE, and REFER in certain contexts.

Transport options include UDP and TLS/SRTP. Codecs in the retrieved source include G.711a/PCMA, G.711u/PCMU, and G.729. DTMF support includes RFC2833 and inband; fax support includes T.38 and inband.

For a simple GOno PBX integration, start with `ulaw`/PCMU and `alaw`/PCMA unless the user confirms a different codec policy. Keep `ulaw` available if Dograh is also in the call path.

## Inbound calling through Call Routing

For Infobip DID inbound calls to GOno PBX:

1. Create or select an Infobip SIP trunk that points to the GOno PBX reachable SIP endpoint.
2. Create an Infobip Call Routing route with a SIP trunk destination.
3. Assign the Infobip voice number/DID to forward to Call Routing.
4. Use static DID route selection when one DID should always use one route.
5. Use filter-based route selection when routing depends on caller, called number, SIP trunk, SIP header, or regular expression criteria.
6. Allow for propagation time after route changes.

Call Routing destinations are evaluated by priority/weight and can advance to the next destination on failures or timeouts. SIP trunk destinations can be skipped if administratively down or considered out of service.

## Testing and observability

Use the Infobip Route Simulator before sending live traffic when changing routes. For live troubleshooting, retrieve detailed reports and inspect Call Routing records for route, SIP trunk, correlation ID, direction, duration, billed duration, and status.

## Runtime values to request

- Exact Infobip trunk type.
- Exact Infobip data center/region.
- Exact Infobip SBC FQDN/IPs.
- SIP credentials or source/destination IPs.
- DID numbers and number format expected on the GOno PBX side.
- Whether the user's Infobip account has route simulator/reporting access.

If one of these values is missing during a task, label it `Needs user confirmation` and continue only where safe.
