# Integration Runbooks

## Contents

- Runbook A: Infobip as carrier for GOno PBX.
- Runbook B: Infobip DID to Dograh voice agent through GOno PBX.
- Runbook C: Troubleshooting-first audit.

## Runbook A: Infobip as carrier for GOno PBX

### 1. Discovery

Collect without making changes:

- GOno PBX version/commit and deployment topology.
- Current trunks, extensions, DID routes, and codec policy.
- Public reachability of the PBX SIP endpoint.
- Actual SIP and RTP ports.
- Infobip account data: trunk type, region/data center, SBC FQDN/IPs, channels, credentials or IP allowlists, DID numbers, and route requirements.
- Whether the user wants inbound, outbound, or both.

### 2. Decide trunk model

Prefer a registered trunk if the user has Infobip SIP username/password and GOno PBX can register to the provided Infobip SBC target.

Use a static trunk only if the PBX/SBC has a public, dedicated, stable IP and the user confirms IP-based authentication.

If neither model is confirmed, stop and ask for the missing Infobip account values.

### 3. Draft the mapping

Create a table with these columns:

- Infobip field or concept.
- GOno PBX/PJSIP equivalent.
- Value.
- Source.
- Status: `confirmed`, `Needs user confirmation`, or `derived from source`.

Minimum rows:

- Trunk model.
- Infobip SBC FQDN/IP.
- SIP username/password or source IP allowlist.
- Transport.
- Codecs.
- DID numbers.
- Inbound route target.
- Outbound caller ID/DID.
- RTP range and firewall rules.

### 4. Preflight

Before applying:

- Confirm GOno PBX can reach the Infobip SBC.
- Confirm Infobip can reach the public GOno PBX SIP endpoint if inbound traffic is required.
- Confirm SIP and RTP firewall/NAT rules.
- Confirm codec overlap, especially PCMU/PCMA.
- Confirm no existing trunk or DID route will be overwritten.
- When host access is available, run `scripts/gonopbx_telephony_preflight.sh` locally on the GOno PBX host or through an approved SSH workflow and attach its timestamped report.

### 5. Apply gate

Before any live change, present:

- Exact fields to be changed.
- Expected call-path effect.
- Rollback plan.
- Test numbers.
- Maintenance window or expected impact.

Wait for explicit user approval.

### 6. Post-check

Verify:

- Registered trunk: registration status is healthy.
- Static trunk: OPTIONS or test call path behaves as expected if enabled.
- Outbound call from a GOno PBX extension reaches PSTN through Infobip.
- Inbound call to Infobip DID reaches the intended GOno PBX extension.
- CDR and Infobip reports show the same call direction and timestamps.

## Runbook B: Infobip DID to Dograh voice agent through GOno PBX

Use this only after the basic Infobip to GOno PBX trunk path is understood.

### 1. Call path

Model the path explicitly:

Infobip DID -> Infobip Call Routing -> Infobip SIP trunk -> GOno PBX/Asterisk PJSIP -> Asterisk Stasis app -> Dograh ARI workflow.

### 2. Discovery

Collect:

- Which DID should reach Dograh.
- Which GOno PBX extension or dialplan target should represent the Dograh workflow.
- Whether Dograh is cloud-hosted or self-hosted.
- ARI endpoint URL.
- Stasis app name.
- WebSocket client name.
- Required Asterisk modules.
- Safe persistent config location in the GOno PBX deployment.

### 3. Preflight

Check:

- Infobip inbound route reaches GOno PBX.
- GOno PBX/Asterisk can route the called target into Stasis.
- ARI HTTP endpoint is reachable only from approved sources.
- WebSocket media path can reach Dograh.
- `ulaw` is allowed along the path.
- `scripts/gonopbx_telephony_preflight.sh` reports ARI/module visibility without exposing secrets.

### 4. Apply gate

Do not edit Asterisk ARI, HTTP, WebSocket, or dialplan configuration until the user approves the exact change set and persistence strategy.

### 5. Post-check

Verify:

- Dograh ARI configuration saves successfully.
- Dograh phone number/extension has an inbound workflow.
- A test inbound call activates the expected Dograh workflow.
- Audio is bidirectional.
- Logs can correlate Infobip Call Routing, GOno PBX/Asterisk, and Dograh workflow execution.

## Runbook C: Troubleshooting-first audit

Use when the user says calls fail, registration is down, audio is missing, inbound does not route, outbound fails, or Dograh does not answer.

1. Identify direction: outbound, inbound, Dograh inbound, or audio-only failure.
2. Build a call-path diagram with observed and unknown segments.
3. Run read-only checks first.
4. Report PASS/WARN/FAIL by segment.
5. Propose the smallest reversible change, then wait for approval.
6. If the preflight script is usable, include its report path and summarize any FAIL/WARN items.
