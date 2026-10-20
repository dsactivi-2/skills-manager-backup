# Flow And Objections

Use this file when building conversation states and objection handling.

## Default State Flow

1. Opener
2. Permission to continue
3. Relevance check
4. Qualification
5. Objection handling
6. Booking or handoff
7. Wrap-up

Do not collapse all of this into one freeform prompt paragraph. Name the states clearly.

## State Guidance

### Opener

Goal:
Explain who is calling and why in one short turn.

Good:
- identify company
- state reason briefly
- sound low-pressure

Bad:
- long pitch
- multiple benefits stacked together
- hidden identity

### Permission To Continue

Goal:
Earn a few more seconds without sounding weak.

Good examples:
- `Passt es gerade fuer 20 Sekunden, damit ich kurz den Anlass nennen kann?`
- `Ich mache es kurz: ...`

### Relevance Check

Goal:
Find out whether the person or company is in scope before deeper qualification.

Typical checks:
- role
- current process
- rough fit

### Qualification

Ask only what is needed for the next step.

Typical areas:
- pain or trigger
- ownership
- urgency
- current setup
- buying relevance

### Objection Handling

Pattern:

1. acknowledge briefly
2. diagnose the real cause
3. answer in one compact turn
4. either continue or exit

Do not argue in loops.

## Common Objections

### Kein Interesse

Likely causes:
- poor timing
- unclear relevance
- real mismatch

Response pattern:
- acknowledge
- restate relevance in one line
- ask one light qualifier or exit

Stop when:
- repeated rejection
- explicit do-not-call

### Schicken Sie eine Mail

Likely causes:
- wants low-friction escape
- curious but not ready

Response pattern:
- agree briefly
- ask one question to qualify whether a mail is worth sending
- if fit is weak, send or note follow-up and end

### Kein Budget

Likely causes:
- no priority
- not owner
- real budget issue

Response pattern:
- avoid debating
- ask whether the topic matters enough for a short exploratory meeting
- if not, end politely

### Wer sind Sie

Response pattern:
- answer directly
- name company and purpose
- do not hide AI identity if disclosure is required

### Ist das eine KI

Response pattern:
- answer clearly and briefly
- return to the purpose only if the prospect stays engaged

Example:
- `Ja, ich bin ein KI-gestuetzter Telefonassistent von {{company}}. Ich kann kurz erklaeren, warum ich anrufe, und wenn Sie lieber mit einer Person sprechen moechten, stelle ich gern um.`

## Qualification Rules

By default, book only when these are true:

- the contact is relevant or can route correctly
- there is a plausible business fit
- there is at least light interest or pain acknowledgement
- the next step is accepted explicitly

Do not book when:

- the contact is clearly outside ICP
- the prospect is confused about the reason for the call
- the objection remains unresolved
- the person only wants basic information with no buying signal

## Booking Rules

When booking:

1. propose the next step plainly
2. confirm time
3. confirm timezone if relevant
4. confirm email or callback path
5. restate what will happen next

When not booking:

- offer follow-up only if allowed
- hand off to a human if that is the correct policy path
- end cleanly without lingering persuasion
