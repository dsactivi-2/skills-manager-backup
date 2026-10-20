---
name: calcom
description: Use when building scheduling integrations, managing bookings and availability, creating event types, connecting calendars, setting up webhooks for automation, or building AI agents that interact with Cal.com's scheduling infrastructure. Use the API v2 for new integrations and the CLI for agent-based tasks.
metadata:
    mintlify-proj: calcom
    version: "1.0"
    source: https://cal.com/docs/.well-known/agent-skills/calcom/skill.md
---
# Cal.com Skill

## Codex wiring

This host already has two global MCP servers:

- calcom-docs at https://cal.com/docs/mcp for documentation search and page reads
- calcom at https://mcp.cal.com/mcp for live Cal.com account actions over OAuth

Use calcom-docs before guessing API fields or headers. Use the calcom MCP or @calcom/cli for bookings, event types, schedules, and webhooks. Never print API keys or OAuth tokens.

## Product summary

Cal.com is an open-source scheduling platform that provides APIs and components for managing bookings, availability, event types, and calendar integrations. Agents use Cal.com to create and manage meetings, check availability, reschedule bookings, and automate scheduling workflows. The primary entry point is the **API v2** at `https://api.cal.com/v2/` with comprehensive REST endpoints for bookings, schedules, event types, teams, organizations, and webhooks. Key files and commands: API key generation at `Settings → Developer → API Keys`, OAuth client setup at `https://app.cal.com/settings/developer/oauth`, CLI installation via `npm install -g @calcom/cli`, and the required header `cal-api-version: 2024-08-13` for all v2 requests. See [API v2 Reference](https://cal.com/docs/api-reference/v2/introduction) for complete documentation.

## When to use

Reach for this skill when:

- **Creating or managing bookings** — Schedule meetings on behalf of users, reschedule existing bookings, or cancel appointments
- **Checking availability** — Query available time slots for users or teams before booking
- **Managing event types** — Create, update, or delete event types with custom booking fields and configurations
- **Setting up schedules** — Create or modify user availability schedules with time zones and overrides
- **Connecting calendars** — Integrate Google, Outlook, or Apple calendars to sync events
- **Automating workflows** — Set up webhooks to trigger actions when bookings are created, cancelled, rescheduled, or when meetings start/end
- **Building AI agents** — Use the API to enable agents to book meetings, check slots, and manage scheduling on behalf of users
- **Managing teams and organizations** — Create teams, manage memberships, and configure team-level event types and workflows
- **Handling payments** — Accept Stripe payments for bookings through event types
- **Tracking credits** — Check and charge credits for agent interactions on the Cal.com platform

## Quick reference

### Authentication methods

| Method | Use case | Header |
|--------|----------|--------|
| API Key | Server-to-server, agents, CLI | `Authorization: Bearer cal_live_xxxx` |
| OAuth | Third-party apps, user-delegated access | `Authorization: Bearer <access_token>` |
| Platform OAuth | Deprecated; existing customers only | `x-cal-client-id` + `x-cal-secret-key` |

### Required headers for all v2 requests

```
Authorization: Bearer <token>
cal-api-version: 2024-08-13
Content-Type: application/json
```

### Common endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/v2/slots` | GET | Check available time slots |
| `/v2/bookings` | POST | Create a booking |
| `/v2/bookings/{uid}/reschedule` | POST | Reschedule a booking |
| `/v2/bookings/{uid}/cancel` | POST | Cancel a booking |
| `/v2/event-types` | GET/POST | List or create event types |
| `/v2/schedules` | GET/POST | Manage availability schedules |
| `/v2/webhooks` | GET/POST | Create and manage webhooks |
| `/v2/teams` | GET/POST | Manage teams |
| `/v2/organizations/{orgId}/users` | GET/POST | Manage organization users |
| `/v2/credits/available` | GET | Check credit balance |
| `/v2/credits/charge` | POST | Charge credits for usage |

### Webhook triggers

Common triggers: `BOOKING_CREATED`, `BOOKING_CANCELLED`, `BOOKING_RESCHEDULED`, `BOOKING_REQUESTED`, `BOOKING_PAID`, `MEETING_STARTED`, `MEETING_ENDED`, `RECORDING_READY`, `FORM_SUBMITTED`, `BOOKING_NO_SHOW_UPDATED`, `BOOKING_LOCATION_UPDATED`, `BOOKING_REASSIGNED`

### Rate limits

- **API Key**: 120 requests per minute (can be increased; contact support for higher limits)
- **OAuth**: Same as API key
- **No auth**: 120 requests per minute

## Decision guidance

| Scenario | Use API v2 | Use CLI | Use Atoms |
|----------|-----------|---------|-----------|
| Building a scheduling integration | ✓ | | |
| AI agent booking meetings | ✓ | ✓ | |
| Embedding booking UI in React app | | | ✓ |
| Server-side automation | ✓ | | |
| Command-line scheduling tasks | | ✓ | |
| Managing user availability in app | | | ✓ |
| Checking slots programmatically | ✓ | ✓ | |
| Creating webhooks for events | ✓ | | |

| Authentication choice | When to use |
|----------------------|------------|
| API Key | Server-to-server, agents, internal tools, CLI |
| OAuth | Third-party integrations, user-delegated access, "Continue with Cal.com" flows |
| Platform OAuth | Only for existing platform customers (deprecated) |

## Workflow

### 1. Create a booking (most common agent task)

1. **Get available slots** — Query `/v2/slots?username=bailey&eventSlug=15min&startTime=...&endTime=...` to check availability
2. **Verify slot is available** — Confirm the desired time appears in the response
3. **Fetch event type details** — Call `GET /v2/event-types?username=bailey` to discover required booking fields
4. **Prepare booking payload** — Include attendee name, email, time zone, and any required `bookingFieldsResponses`
5. **Create booking** — POST to `/v2/bookings` with event type slug, username, start time, and attendee details
6. **Handle response** — Extract booking UID from response for future reschedule/cancel operations

### 2. Reschedule a booking

1. **Retrieve booking details** — Use the booking UID from creation or previous queries
2. **Check new availability** — Query slots for the new time window
3. **POST reschedule request** — Call `/v2/bookings/{bookingUid}/reschedule` with new start time and optional reason
4. **Verify status** — Confirm response shows `status: "accepted"` or `status: "pending"` (if confirmation required)

### 3. Set up a webhook for automation

1. **Identify trigger events** — Decide which events to listen for (e.g., `BOOKING_CREATED`, `BOOKING_CANCELLED`)
2. **Prepare subscriber URL** — Must be HTTPS (SaaS) or HTTP (self-hosted); no private IPs or localhost on SaaS
3. **Create webhook** — POST to `/v2/webhooks` with `subscriberUrl`, `triggers` array, and optional `secret`
4. **Verify receipt** — Implement endpoint to receive and validate webhook payloads using the secret
5. **Process payload** — Extract booking data and trigger downstream actions (send email, update CRM, etc.)

### 4. Manage team availability

1. **Create a schedule** — POST to `/v2/schedules` with name, time zone, availability windows, and `isDefault: true`
2. **Set overrides** — Add date-specific exceptions (e.g., holidays, special hours) in the `overrides` array
3. **Link to event type** — Update event type to point to the schedule via `scheduleId`
4. **Verify availability** — Query `/v2/slots` to confirm schedule is reflected in available slots

### 5. Check credits before agent action

1. **Query balance** — GET `/v2/credits/available` to check `hasCredits` and `balance`
2. **Verify sufficient credits** — Compare `monthlyRemaining` + `additional` against required credits
3. **Perform action** — If credits available, proceed with booking or other operation
4. **Charge credits** — POST to `/v2/credits/charge` with `credits`, `creditFor: "AI_AGENT"`, and unique `externalRef`
5. **Handle insufficient credits** — Return error to user if balance is zero

## Common gotchas

- **Missing `cal-api-version` header** — All v2 requests require `cal-api-version: 2024-08-13` or they return 404. This is not optional.
- **Booking creation is public** — The `POST /v2/bookings` endpoint does not require authentication. Anyone can book if they know the username and event slug. This is intentional for public booking pages.
- **Required booking fields** — If an event type has custom questions marked as required, omitting them in `bookingFieldsResponses` returns 400. Always fetch event type details first to discover required fields.
- **Time zone handling** — Always specify `timeZone` in attendee objects. Omitting it can cause slot calculation errors. Use IANA time zone strings (e.g., `America/New_York`, not `EST`).
- **Seated event types** — For events with multiple attendees per slot, webhook payloads only include the attendee for the specific seat that triggered the event, not all attendees.
- **Webhook URL validation** — SaaS only accepts HTTPS URLs. Private IPs, localhost, and HTTP are blocked. Self-hosted allows HTTP and private IPs.
- **Rescheduling constraints** — Only bookings with status `accepted` or `pending` can be rescheduled. Cancelled or rejected bookings cannot be rescheduled; create a new booking instead.
- **Rate limit exhaustion** — Default 120 requests/minute. Implement exponential backoff for retries. Contact support for higher limits if needed.
- **OAuth token expiry** — Access tokens expire in 60 minutes; refresh tokens last 1 year. Store both and refresh before expiry.
- **Atoms are in maintenance mode** — `@calcom/atoms` package receives fixes but no new features. New integrations should use API v2 directly.
- **Platform endpoints deprecated** — Avoid platform OAuth and managed user endpoints; they are deprecated as of December 2025.

## Verification checklist

Before submitting work with Cal.com:

- [ ] All API requests include `cal-api-version: 2024-08-13` header
- [ ] Authentication header is present and valid (API key or OAuth token)
- [ ] Time zones are specified in ISO format (e.g., `America/New_York`)
- [ ] Booking payloads include all required `bookingFieldsResponses` fields
- [ ] Webhook subscriber URL is HTTPS (SaaS) or valid HTTP (self-hosted)
- [ ] Webhook secret is stored securely and used to validate payloads
- [ ] Retry logic implements exponential backoff for rate-limited requests
- [ ] Credit checks are performed before agent actions that charge credits
- [ ] Booking UIDs are stored for future reschedule/cancel operations
- [ ] Error responses are logged with full status code and message body
- [ ] Time slot availability is verified before attempting to create a booking
- [ ] Team and organization IDs are correctly passed in path parameters

## Resources

- **Comprehensive page listing**: [Cal.com llms.txt](https://cal.com/docs/llms.txt) — Full navigation of all documentation pages
- **API v2 Reference**: [Introduction and authentication](https://cal.com/docs/api-reference/v2/introduction) — Core API concepts, rate limits, and auth methods
- **AI Agents Guide**: [Building agents with Cal.com](https://cal.com/docs/agents) — Workflows for agents, credit management, and best practices
- **Webhooks Guide**: [Automation with webhooks](https://cal.com/docs/developing/guides/automation/webhooks) — Webhook setup, payload reference, and trigger events

---

> For additional documentation and navigation, see: https://cal.com/docs/llms.txt