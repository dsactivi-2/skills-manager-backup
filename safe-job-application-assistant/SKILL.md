---
name: safe-job-application-assistant
description: Use when the user explicitly asks to prepare, review, rank, or assist with job applications, including cautious automation support, application-form planning, cover-letter drafting, job-match scoring, or per-application review. Do not use for generic job-search advice, unsolicited automation, bulk auto-apply, or submitting applications without direct user approval.
---

# Safe Job Application Assistant

## Overview

Help the user find, rank, and prepare job applications while keeping the user in control of personal data and final submission. This skill is adapted from the verified ClawHub page for `@atharva-badgujar/auto-job-applier`, but it intentionally removes unsafe auto-submit behavior and sensitive-data persistence.

## Verified Source Metadata

- Source page: `https://clawhub.ai/atharva-badgujar/skills/auto-job-applier`
- ClawHub owner: `Atharva Badgujar` / `@atharva-badgujar`
- ClawHub display name: `Automate Job Application`
- ClawHub version: `2.1.0`
- ClawHub install command: `openclaw skills install @atharva-badgujar/auto-job-applier`
- ClawHub category/topics: `Research`, `Browser Automation`, `Web Search`
- ClawHub security status: static scan clean; VirusTotal engines clean; moderation verdict clean.
- ClawHub setup requirements: `python3`, `curl`, `requests>=2.28.0`, and `RESUMEX_API_KEY` for the original ResumeX workflow.
- ClawHub SkillSpector issues: 14 issues, including over-broad triggers, privacy notice gaps, sensitive data persistence, salary/visa/work-authorization autofill risks, and auto-submission risk.

## Non-Negotiable Rule

Never submit a job application, click a final submit button, transmit sensitive answers, or store sensitive preferences unless the user has explicitly reviewed the exact target, data, and action for that application.

## When To Use

Use this skill for explicit requests such as:

- "Help me apply to these jobs safely."
- "Rank these jobs and prepare applications."
- "Draft application answers for this role."
- "Review this job form before I submit."
- "Use browser automation to help fill, but stop before submitting."
- "Prepare cover letters and screening answers for selected jobs."

Do not use this skill for broad phrases like "job search", "find jobs", or "job hunting" unless the user explicitly asks for application preparation or controlled automation.

## Workflow

1. Confirm the operating mode before external action:

- `search-only`: find and rank jobs; no forms opened.
- `prepare-only`: draft cover letters, answers, and application data; no browser submission.
- `assisted-fill`: help fill forms only after the user approves each job; stop before final submit.

2. Minimize data before use:

- Ask the user to redact private contact details, confidential company/client names, internal metrics, compensation, identification numbers, and NDA material unless needed.
- Prefer user-provided resume/profile snippets over fetching full external profiles.
- Do not request or configure `RESUMEX_API_KEY` unless the user explicitly wants ResumeX integration and understands that resume data will be retrieved from `resumex.dev`.

3. Build a job-match profile from user-approved data:

- Target roles and adjacent titles.
- Required and preferred skills.
- Seniority and scope.
- Location, remote preference, timezone, travel, and relocation limits.
- Compensation floor, if the user chooses to share it.
- Work authorization only if the user chooses to share it for a specific country/application.

4. Search or evaluate jobs:

- Use current sources for job availability and salary claims.
- Collect source URL, company, title, location, compensation if visible, requirements, application method, and evidence of fit.
- Separate explicit facts from inference.

5. Rank jobs with a clear score:

- Skill overlap.
- Role and seniority match.
- Compensation match.
- Location/remote match.
- Domain or industry match.
- Application friction and risk.

6. Present an approval table before any form work:

- Job title and company.
- Source URL and destination domain.
- Match score with evidence.
- Data likely required.
- Automation level: manual, assisted-fill, or not supported.
- Risks such as login, CAPTCHA, unknown redirect, salary field, visa/work authorization, or upload requirement.

7. For each approved job, prepare but do not submit:

- Draft a short cover letter or answer only from verified user data.
- Map form fields to user-approved values.
- Ask before using salary, visa, sponsorship, disability, veteran, ethnicity, date of birth, address, or other sensitive fields.
- Mark uncertain answers as `needs user confirmation`.
- Stop before final submit and show the user what would be sent.

8. Summarize outcomes:

- Jobs prepared.
- Jobs requiring manual action.
- Fields needing user confirmation.
- Links to continue manually.
- What was not done because it required consent, login, CAPTCHA, upload, or final submission.

## Browser Automation Rules

- Browser automation may navigate, inspect forms, and help fill non-sensitive fields only after per-job approval.
- Always pause before clicking any final submit/apply button.
- Treat LinkedIn Easy Apply, Workday, Greenhouse, Lever, Ashby, SmartRecruiters, and unknown redirects as review-required.
- Do not bypass CAPTCHA, bot checks, paywalls, login walls, or site restrictions.
- Do not upload files automatically unless the user explicitly selects the file and confirms the upload target.
- Take screenshots only when useful and do not include secrets or sensitive fields in summaries.

## Sensitive Data Rules

Never infer or auto-fill:

- Visa status or sponsorship requirements.
- Work authorization.
- Salary expectation or current compensation.
- Disability, veteran status, ethnicity, gender, age, date of birth, address, or government identifiers.
- Background-check, drug-test, criminal-history, or protected-class questions.

For these fields, ask the user for the exact answer for the exact company/form. Do not save the answer for reuse unless the user explicitly opts in after being told where it will be stored and how to delete it.

## Output Contracts

For job ranking, output:

- `Strong fit`, `possible fit`, or `stretch fit`.
- Score out of 100.
- Evidence from the job post.
- Missing or risky requirements.
- Next action: apply, research, tailor resume, or skip.

For application preparation, output:

- Exact fields found or expected.
- Proposed values.
- Questions requiring user confirmation.
- Cover-letter or screening-answer drafts.
- A final review checklist before the user submits.

For automation requests, output:

- The scope you can safely do.
- The steps requiring approval.
- The steps you will not do, especially final submission or sensitive-field reuse.

## Common Mistakes

- Treating broad "job search" intent as consent to automate applications.
- Fetching a full external resume/profile before the user approves the data source.
- Persisting salary, visa, work authorization, or protected-class data.
- Clicking final submit after the user approved only search or form preparation.
- Assuming a job board's form is safe because the company looks legitimate.
- Submitting applications that contain generated or inferred facts the user did not approve.
