---
name: calcomhelp
description: Use when helping users set up and manage scheduling workflows, create
  event types (booking links), configure availability, automate workflows and notifications,
  integrate with calendars and third-party apps, route bookings to team members, embed
  booking forms on websites, or troubleshoot booking and availability issues.
metadata:
  mintlify-proj: calcomhelp
  version: '1.0'
  source: https://cal.com/help/.well-known/agent-skills/calcomhelp/skill.md
---
# Cal.com Skill Playbook

## Product Summary

Cal.com is a scheduling platform that lets users create shareable booking links (called "event types"), manage availability across calendars, automate workflows, and route meetings to team members. Users access it via the web app at `app.cal.com` or the help documentation at `cal.com/help`. Key workflows include creating event types, connecting calendars, setting up workflows (trigger → action automations), configuring webhooks for integrations, and embedding booking forms on websites. The platform supports personal scheduling, team coordination (round-robin, collective, managed events), and enterprise features like routing forms, delegation credentials, and audit logs.

## When to Use

Reach for this skill when:
- A user needs to create or configure a booking link (event type) for scheduling
- Availability, conflicts, or slot visibility issues occur on booking pages
- Workflows or automations need to be set up (reminders, confirmations, notifications)
- Webhooks or integrations with third-party apps are required
- Team scheduling, routing, or load balancing needs configuration
- Booking forms need to be embedded on a website or prefilled with data
- Calendar connections (Google, Outlook, Apple) are not syncing or showing conflicts
- Booking limits, restrictions, or policies need to be enforced
- Analytics or tracking needs to be added to booking pages
- Users need to troubleshoot why bookings aren't appearing or slots are hidden

## Quick Reference

### Core Concepts

| Term | Definition |
|------|-----------|
| **Event Type** | A shareable booking link (e.g., `cal.com/username/30min-call`). Defines duration, availability, location, and booking rules. |
| **Availability Schedule** | A set of working hours that event types reference. Can be multiple schedules per account. |
| **Workflow** | Trigger → Action automation (e.g., send email when booking created). Runs on specific event types. |
| **Webhook** | HTTP callback that fires on booking events (created, cancelled, rescheduled, etc.). Requires HTTPS URL on SaaS. |
| **Routing Form** | A form that collects data and routes bookings to different event types or team members based on rules. |
| **Round Robin** | Team event type where bookings rotate among team members based on weight/availability. |
| **Collective** | Team event type where all selected members must attend the same meeting. |
| **Managed Event** | Parent event type that creates child event types for each team member (used with routing). |

### Essential Settings Locations

| Task | Path |
|------|------|
| Create/edit event type | Event Types → New Event Type (or click existing) |
| Set availability | Availabilities → Create/Edit Schedule |
| Create workflow | Workflows → New → Select trigger & action |
| Add webhook | Settings → Developer → Webhooks |
| Connect calendar | Settings → Calendars → Add Calendar |
| Install app | Apps → App Store → Install |
| View bookings | Bookings → Filter by date/status |
| Embed booking form | Event Type → Embed → Copy snippet |
| Create routing form | Routing → New Form |

### Common Workflow Triggers & Actions

**Triggers:**
- Booking Created, Cancelled, Rescheduled, Rejected, Requested
- Booking Paid, Payment Initiated, No-Show Updated
- Before Event Starts, After Event Ends
- Meeting Started, Meeting Ended
- Recording Ready, Transcription Generated
- Routing Form Submitted

**Actions:**
- Send Email (to host, attendee, or specific address)
- Send SMS or WhatsApp (requires credits)
- Call Attendee (Cal.ai voice agent, requires credits)

### Dynamic Variables for Workflows & Webhooks

Use these in email/SMS templates:
- `{EVENT_NAME}`, `{EVENT_DATE}`, `{EVENT_TIME}`, `{EVENT_END_TIME}`
- `{ORGANIZER_NAME}`, `{ATTENDEE}`, `{ATTENDEE_EMAIL}`, `{ATTENDEE_FIRST_NAME}`
- `{TIMEZONE_VARIABLE}`, `{LOCATION_VARIABLE}`, `{ADDITIONAL_NOTES_VARIABLE}`
- `{MEETING_URL}`, `{CANCEL_URL}`, `{RESCHEDULE_URL}`, `{RATING_URL_VARIABLE}`

### Embed Types

| Type | Use Case |
|------|----------|
| **Inline** | Show booking form directly on webpage |
| **Pop-up on Click** | Trigger modal when user clicks element |
| **Floating Button** | Add customizable floating button that opens modal |

## Decision Guidance

### When to Use Round Robin vs Collective vs Managed Events

| Scenario | Use This | Why |
|----------|----------|-----|
| Distribute bookings among team members (one person per meeting) | **Round Robin** | Balances load, rotates hosts, supports weights/attributes |
| All team members must attend same meeting | **Collective** | Finds common availability, ensures full team presence |
| Route prospects to different reps based on criteria (Salesforce, attributes) | **Managed Event** | Creates child event types per member, integrates with routing forms |
| Simple team scheduling without routing logic | **Round Robin** | Easiest setup, no routing form needed |

### When to Use Workflows vs Webhooks

| Need | Use This | Why |
|------|----------|-----|
| Send automated emails/SMS reminders, confirmations | **Workflows** | Built-in, no coding required, supports dynamic variables |
| Integrate with external apps (Zapier, custom systems) | **Webhooks** | Sends raw booking data to your URL, full control |
| Trigger actions in Salesforce, HubSpot, Pipedrive | **Webhooks** (or Apps) | Apps handle OAuth; webhooks give raw data |
| Call attendee with AI voice agent | **Workflows** (Cal.ai action) | Dedicated action, requires credits |

### When Slots Are Hidden or Unavailable

| Symptom | Check This First |
|---------|------------------|
| No slots showing but availability is set | Connected calendar has events marked as "free" instead of "busy" |
| Slots hidden for specific times | Date overrides, buffers, or booking frequency limits active |
| Slots not showing far in the future | "Limit Future Bookings" setting restricting range |
| Slots hidden for specific event type only | Event-type-specific conflict checking enabled on wrong calendar |
| Slots show when host is unavailable | Calendar not connected or not toggled to check for conflicts |

## Workflow

### Creating an Event Type

1. **Navigate to Event Types** → Click "New Event Type"
2. **Enter basics:** Title, URL slug, description, duration (in minutes)
3. **Set availability:** Choose which availability schedule to use (or create new)
4. **Configure location:** Select video conferencing app (Cal Video, Zoom, Google Meet, etc.) or in-person location
5. **Add booking questions:** Collect name, email, notes, custom fields (if needed)
6. **Set policies:** Booking limits, buffers, reschedule/cancel rules, minimum notice
7. **Enable payments** (if needed): Set price, currency, payment provider
8. **Add workflows:** Set up reminders, confirmations, follow-ups
9. **Test the link:** Preview and book a test slot
10. **Share:** Copy link and distribute via email, website, social media

### Troubleshooting Missing Slots

1. **Check availability schedule:** Availabilities → Verify hours are set for the day/time
2. **Check connected calendar:** Settings → Calendars → Ensure calendar is toggled "on" for conflict checking
3. **Review calendar events:** Open connected calendar (Google, Outlook, Apple) and verify events are marked "busy" (not "free")
4. **Check date overrides:** Availabilities → Edit Schedule → Review date overrides for that day
5. **Check event-type settings:** Event Type → Availability → Verify no event-type-specific conflict checking is blocking slots
6. **Check booking limits:** Event Type → Limits & Buffers → Verify booking frequency, buffer times, and future booking limits
7. **Check team availability** (if team event): Availabilities → Team Availability → Ensure all team members have availability set
8. **Test with different date/time:** Try booking a different day to isolate the issue
9. **Clear browser cache:** Hard refresh the booking page (Ctrl+Shift+R or Cmd+Shift+R)

### Setting Up a Workflow

1. **Go to Workflows** → Click "New"
2. **Name the workflow** (e.g., "Booking Confirmation")
3. **Select trigger:** Choose when workflow fires (e.g., "Booking Created")
4. **Select event types:** Choose which event types this applies to
5. **Add action:** Select action type (Email, SMS, WhatsApp, Cal.ai call)
6. **Compose message:** Use dynamic variables like `{ATTENDEE}`, `{EVENT_TIME}`, `{MEETING_URL}`
7. **Configure recipient:** Host, attendee, or specific email/phone
8. **Enable auto-translate** (if on Organization plan): Automatically translate to attendee's language
9. **Save and test:** Create a test booking to verify workflow fires

### Embedding a Booking Form

1. **Open event type** → Click "Embed" tab
2. **Choose embed type:** Inline, Pop-up on Click, or Floating Button
3. **Copy snippet:** Select code and copy to clipboard
4. **Paste on website:** Add to HTML/React component where you want form to appear
5. **Customize (optional):** Modify button text, colors, or positioning in code
6. **Prefill fields (optional):** Add URL parameters to auto-fill attendee info:
   - `?email=user@example.com&name=John+Doe&notes=Custom+note`
7. **Test:** Visit website and verify form loads and booking works

### Connecting a Calendar

1. **Go to Settings** → Calendars tab
2. **Click "Add Calendar"** → Choose provider (Google, Outlook, Apple, etc.)
3. **Authenticate:** Log in with calendar account credentials
4. **Select calendar:** Choose which calendar to sync
5. **Verify conflict checking:** Ensure calendar is toggled "on" in Installed Calendars
6. **Test:** Create a test event in calendar and verify it blocks slots on booking page

## Common Gotchas

- **Calendar events marked "free" instead of "busy":** Google Calendar defaults all-day events to "free." Change to "busy" or use Cal.com date overrides instead.
- **Webhooks fail on SaaS:** Only HTTPS URLs accepted; HTTP, localhost, and private IPs (10.x, 192.168.x, 127.0.0.1) are blocked. Use a public HTTPS endpoint.
- **Webhook secret not verified:** If you set a secret, verify the `X-Cal-Signature-256` header matches your HMAC-SHA256 hash of the payload.
- **Workflows not firing:** Verify workflow is saved, event type is selected, and trigger matches the action (e.g., "Booking Created" fires after booking confirmed, not during form submission).
- **SMS/WhatsApp messages stop sending:** Account ran out of credits. Check Billing → Messaging Credits and top up.
- **Slots hidden after setting up team event:** Team members may not have availability set. Go to Availabilities → Team Availability and add schedules for each member.
- **Routing form not routing correctly:** Verify attributes are assigned to team members, routing rules match those attributes, and fallback is configured.
- **Embed not loading on website:** Check that domain is not blocked by CORS. Use the Embed Snippet Generator to get the latest snippet.
- **Prefill fields not working:** URL parameters must match exact field identifiers (found in Event Type → Booking Questions → Advanced). Use `&` to separate multiple parameters.
- **Managed events not creating child event types:** Ensure "Add all team members, including future members" is enabled on the parent event type.
- **Booking confirmation email not sent:** Check that default reminder workflow is enabled (Free plan) or custom workflow is created (Team+ plans).
- **Calendar sync not updating availability:** Calendar app may need re-authentication. Reinstall the calendar app from App Store.

## Verification Checklist

Before considering a scheduling setup complete:

- [ ] Event type created with correct title, URL, and duration
- [ ] Availability schedule set and hours verified for the week
- [ ] Calendar connected and toggled "on" for conflict checking
- [ ] Test booking created successfully and appears on calendar
- [ ] Booking confirmation email received by attendee
- [ ] Booking appears in Bookings list with correct details
- [ ] Workflow(s) configured and tested (if using custom automations)
- [ ] Webhook(s) verified if integrating with external systems
- [ ] Booking form embedded on website (if applicable) and tested
- [ ] Prefill parameters working (if using URL parameters)
- [ ] Team members have availability set (if team event type)
- [ ] Routing rules configured and tested (if using routing form)
- [ ] Booking limits and policies enforced as intended
- [ ] Analytics or tracking installed (if needed)

## Resources

**Comprehensive Navigation:**
- [Cal.com Help llms.txt](https://cal.com/help/llms.txt) — Full page-by-page index for agent navigation

**Critical Documentation Pages:**
1. [Welcome & Quick Start](https://cal.com/help/welcome) — Overview and getting started
2. [Event Types](https://cal.com/help/event-types/event-types) — Core concept and setup
3. [Workflows Overview](https://cal.com/help/workflows/workflowsoverview) — Automation triggers and actions
4. [Webhooks](https://cal.com/help/webhooks) — Integration and custom payloads
5. [Embedding](https://cal.com/help/embedding/adding-embed) — Booking form embedding
6. [Routing Overview](https://cal.com/help/routing/routing-overview) — Team routing and attributes
7. [Availabilities](https://cal.com/help/availabilities/availability-dashboard-overview) — Scheduling and conflict management

**For Developers:**
- [Cal.com Developer Docs](https://cal.com/docs) — API references, self-hosting, app building
- [GitHub Repository](https://github.com/calcom/cal.com) — Source code and community

---

> For additional documentation and navigation, see: https://cal.com/help/llms.txt