# GOno PBX Reference

## Contents

- What GOno PBX provides.
- Architecture facts.
- Ports from retrieved documentation.
- SIP trunks.
- Infobip-to-GOno PBX field mapping.
- DID routing.
- Config-generation rule.
- GOno PBX values to collect.

## What GOno PBX provides

GOno PBX is a browser-based management UI for Asterisk. The retrieved sources describe support for SIP extensions, SIP trunks, DID routing, voicemail, CDR, call forwarding, codec management, audit logs, real-time status, and Docker deployment.

## Architecture facts

- PBX engine: Asterisk with PJSIP.
- Backend: FastAPI.
- Frontend: React/TypeScript.
- Database: PostgreSQL.
- Asterisk management path described by the technical documentation: backend to Asterisk through AMI on port 5038.
- Generated Asterisk config is written to a shared Asterisk config volume.

## Ports from retrieved documentation

- Web UI: `3000`.
- Backend API: `8000`.
- SIP: `5060` over UDP/TCP.
- AMI: `5038`.
- RTP range in the README: `10000-20000`.
- RTP range in the technical documentation: `10000-10100`.

Treat the RTP range mismatch as a documentation gap. Mark the actual RTP range as `Needs user confirmation` until the deployed compose/config files are inspected.

## SIP trunks

The documentation describes SIP trunks as external SIP lines for inbound and outbound telephony.

Relevant configurable concepts:

- Provider selection includes built-in templates and support for custom providers.
- Authentication modes include registration with username/password and fixed-IP authentication without registration.
- A DID number block defines numbers available on the trunk.
- Codecs are configurable; the documented default set includes `ulaw`, `alaw`, and `g722`.
- GOno PBX generates PJSIP sections for endpoint, auth, AOR, registration, and identify.

## Infobip-to-GOno PBX field mapping

Use this as a source-grounded planning map. The retrieved documentation describes trunk concepts, and the inspected GOno PBX code exposes the current trunk fields used by the database model, API model, UI form, and PJSIP generator. Confirm the live deployed version before applying because the user's server may run a different commit.

| Infobip concept | GOno PBX field or generated PJSIP concept | Notes |
|---|---|---|
| Carrier display name | `name` | Human-facing trunk name. Use a descriptive label such as `Infobip Registered`. |
| Provider type | `provider` | Use `custom` for Infobip unless the deployed GOno PBX version adds a native Infobip provider. |
| Registered trunk | `auth_mode=registration` plus generated `type=registration` and `type=auth` sections | Required when Infobip provides SIP username/password. |
| Static trunk | `auth_mode=ip` plus generated endpoint/AOR without auth block | Use only when Infobip account-side IP authentication and stable public PBX IP are confirmed. |
| Infobip SBC FQDN/IP | `sip_server`; generated `server_uri`, `contact`, `from_domain`, and AOR contact | Use the exact Infobip account value, not an example host. |
| SIP username | `username`; generated PJSIP auth username and registration/contact user | Treat as secret-bearing account data in reports. |
| SIP password | `password`; generated PJSIP auth password | Do not print or decode it. Store only through the approved GOno PBX path. |
| Outbound caller ID | `caller_id` | Confirm Infobip caller-ID policy before setting it. |
| DID range/block | `number_block` | GOno PBX expands available DIDs from trunk number blocks for assignment. Confirm exact number format. |
| Dialplan context | `context`, default `from-trunk` | Keep default unless there is a reviewed Asterisk-level reason to change it. |
| Codec policy | `codecs`, default `ulaw,alaw,g722`; generated as `allow=...` | Keep PCMU/`ulaw` and PCMA/`alaw` available unless account policy says otherwise. |
| From user / access number | `from_user`; generated `from_user=` and contact user when set | Use only if the live provider/account requires a separate From-User value. |
| Trunk enabled state | `enabled` | Ensure the trunk is enabled before expecting registration or call routing. |
| Infobip Call Routing destination | GOno PBX public SIP endpoint plus matching DID route | Requires firewall/NAT and SIP/RTP reachability. |

If live GOno PBX UI labels differ from these API/model names, keep the source-grounded mapping but record the live label observed during discovery.

## DID routing

GOno PBX supports DID routing from external numbers to internal extensions. Outbound calling can use assigned DIDs and trunk routing.

For Infobip inbound carrier setup, map the Infobip DID to an Infobip Call Routing route, then map the route destination to the GOno PBX SIP trunk. Inside GOno PBX, map the received DID to the intended extension or internal call path.

## Config-generation rule

Prefer the GOno PBX UI/API for trunks, extensions, DID routes, and normal PBX call paths because the system regenerates PJSIP and dialplan files from application state. Manual edits to generated files may be overwritten.

If a requested integration requires Asterisk config not represented in GOno PBX UI/API, label it as an Asterisk-level extension and plan a persistence strategy before changing anything.

## GOno PBX values to collect

- Deployment URL and access method.
- Installed GOno PBX version or commit.
- Asterisk version inside the PBX container.
- Actual exposed SIP/RTP/ARI/AMI ports.
- Existing trunks, extensions, DID routes, and codec policy.
- Whether custom provider fields are available for Infobip.
- Whether generated config files can be extended safely without being overwritten.
- Public IP/FQDN that Infobip can reach, if using static inbound traffic.
- Firewall/NAT topology.
