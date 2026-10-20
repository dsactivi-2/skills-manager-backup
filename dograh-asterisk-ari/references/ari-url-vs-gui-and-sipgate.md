# ARI-URL vs GUI, Outbound, Sipgate (Activi)

## Two URLs on the same hostname

| URL | What |
|---|---|
| `https://ari.activi.io/` | Apache / FreePBX GUI → `/admin` |
| `http://ari.activi.io:8088` | Asterisk ARI (Dograh). HTTP, not 443 |

Dograh `initiate_call` posts `{ari_endpoint}/ari/channels`. If the field is `https://ari.activi.io`, Apache returns **404 HTML** (`Failed to create ARI channel: <!DOCTYPE…>`). That is **not** a Dograh bug.

Do **not** ProxyPass `/ari` on :443 — that publishes ARI to the internet. FW: 8088 only from the Dograh host.

Live check: on the PBX `curl -u dograh:… http://127.0.0.1:8088/ari/asterisk/info` → JSON 200. Public `https://ari.activi.io/ari/…` → 404 is expected.

`tlsenable=yes` on Asterisk is localhost `:8089` only. Dograh stays on HTTP :8088.

## Originate strings

Gono leftover names (`trunk-ep-3`) do not exist on the new box → `Allocation failed` / `endpoint was not found`.

| Typed in Dograh | Asterisk |
|---|---|
| `+49…` or `+49…@trunk-ep-3` | fail |
| `49177…@sipgate-test` | `PJSIP/49177…@sipgate-test` |

Official Asterisk: `Dial(PJSIP/${EXTEN}@mytrunk)` — trunk is the endpoint, digits are the SIP user. Extension **100** is a local phone (registers **to** Asterisk). It is **not** a Sipgate member. Red 100 = no softphone.

## Sipgate

Register **200** ≠ conversation. Qualify Avail ≠ Registered.

- No `+` in the Request-URI (`sip:49…@sipgate.de`).
- `from_user` = `username` = SIP-ID. A second ID in `from_user` is wrong unless the user said so.
- Empty CLIP → `From: "Anonymous"` → Sipgate **403/480**. PAI `100@sipgate.de` is the extension, not the DID.
- Sipgate UI often **omits** 403/480. Packet log on the PBX is SoT.
- Same Sipgate account on Gono + new FreePBX: one AOR; do not assume the portal shows FreePBX calls.
- User changes SIP-ID/pass → apply **immediately**. Do not keep the old `e16` after they said it changed. New secret: env file, not chat. 401 after ID change = pass still old.

UCP / `g++` / Apache “It works!” / Debian `index.html` are **not** outbound blockers.

## Dograh tokens

ARI user/pass (`dograh`) ≠ Dograh `dgr_…` / X-API-Key. Do not put the API key in `websocket_client.conf`. Media URI is `wss://<dograh-host>/api/v1/telephony/ws/ari`. Empty `ari show apps` = no Dograh connected; Stasis then drops channels.

Do not overwrite voiceeu configs that still point at `https://pbx.activi.io` (Gono). Add a **new** config for the new box; set default only when the user says so.
