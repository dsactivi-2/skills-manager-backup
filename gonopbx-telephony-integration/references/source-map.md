# Source Map

This skill is grounded in the following sources and user-confirmed scope.

## User-confirmed scope

- Build one skill named `gonopbx-telephony-integration`.
- Primary priority: installation and integration.
- Secondary priority: troubleshooting and audit.
- Use the precise Infobip SIP trunking pages as direct carrier references. The broad Infobip Voice and Video page is useful only as a product-area entry point.

## User-confirmed example tasks

- Check whether GOno PBX can connect to Dograh through Asterisk ARI.
- Create a step-by-step plan for using Infobip as a SIP trunk/carrier in GOno PBX.
- Identify which credentials and PBX configuration values are needed for Infobip.
- Diagnose why outbound calls through Infobip are not working.
- Build a reusable source-grounded GOno PBX telephony integration runbook or skill.
- Produce redacted mapping/report templates without inventing account-specific values.

## Source URLs

- GOno PBX repository: <https://github.com/ankaios76/gonopbx>
- GOno PBX README: <https://raw.githubusercontent.com/ankaios76/gonopbx/main/README.md>
- GOno PBX technical documentation: <https://raw.githubusercontent.com/ankaios76/gonopbx/main/DOKUMENTATION.md>
- GOno PBX trunk database model: <https://github.com/ankaios76/gonopbx/blob/main/backend/database.py>
- GOno PBX trunks API router: <https://github.com/ankaios76/gonopbx/blob/main/backend/routers/trunks.py>
- GOno PBX trunk UI form: <https://github.com/ankaios76/gonopbx/blob/main/frontend/src/pages/ExtensionsPage.tsx>
- GOno PBX PJSIP generation: <https://github.com/ankaios76/gonopbx/blob/main/backend/pjsip_config.py>
- Dograh Asterisk ARI: <https://docs.dograh.com/integrations/telephony/asterisk-ari>
- Infobip Voice and Video overview: <https://www.infobip.com/docs/voice-and-video>
- Infobip SIP trunking: <https://www.infobip.com/docs/voice-and-video/sip-trunking>
- Infobip SIP trunk setup: <https://www.infobip.com/docs/voice-and-video/sip-trunking/set-up-sip-trunk>
- Infobip Call Routing: <https://www.infobip.com/docs/voice-and-video/call-routing>

## Relevant retrieved facts

- GOno PBX is a web GUI for Asterisk PBX and manages extensions, SIP trunks, DID routing, voicemail, CDR, and monitoring.
- GOno PBX uses Asterisk with PJSIP and generates PJSIP and dialplan configuration from application data.
- GOno PBX supports SIP trunks via registration or fixed-IP authentication, DID routing, and configurable codecs.
- GOno PBX trunk fields verified from code include `name`, `provider`, `auth_mode`, `sip_server`, `username`, `password`, `caller_id`, `number_block`, `context`, `codecs`, `from_user`, and `enabled`.
- Dograh connects to Asterisk through ARI, routes calls through Stasis, and uses external media over WebSocket.
- Dograh requires Asterisk ARI and WebSocket-related modules to be available and loaded.
- Infobip supports SIP trunking for PBX/SBC environments through static and registered trunk models, with authenticated trunks intended for specific external AI platforms.
- Infobip SIP trunk setup requires account-specific values such as trunk type, data center, SBC FQDN/IP, channels, authentication, source/destination IPs, codecs, DIDs, and routes.
- Infobip Call Routing can forward Infobip DIDs to SIP trunk destinations and includes route selection, destination ordering, route simulation, and detailed reporting.

## Known documentation gaps

- No source directly documents a GOno PBX + Infobip carrier setup.
- No source directly documents a GOno PBX + Dograh setup.
- GOno PBX documentation found here describes AMI/PJSIP and generated config, but not ARI as a supported UI feature.
- The current GOno PBX code exposes trunk fields, but a live deployment may run a different commit; confirm live UI/API labels during discovery.
- Infobip account values cannot be inferred from public documentation.
- Whether the user's GOno PBX Asterisk container includes `chan_websocket` and `res_websocket_client` is environment-specific.
- The bundled preflight script can verify local/container visibility, but it cannot verify Infobip account-side settings without user-provided account values or approved authenticated access.

## Terms to keep explicit

- `Needs user confirmation`: required value not present in the sources or current conversation.
- "Source-grounded": traceable to one of the URLs above or to user-confirmed facts.
- "Approval gate": a point where the agent must wait before making live changes.
