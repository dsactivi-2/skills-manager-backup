---
name: linkedin-profile-optimizer
description: Use when the user explicitly asks to audit, rewrite, or improve a LinkedIn profile, headline, About section, experience bullets, recruiter visibility, client attraction, thought-leadership positioning, or AI-search discoverability. Do not use for generic social-media advice, unrelated job search tasks, or automated LinkedIn actions.
---

# LinkedIn Profile Optimizer

## Overview

Audit and rewrite a LinkedIn profile so the right people can quickly understand who the user helps, what proof they have, and what action to take next. Base the workflow on the verified ClawHub skill `@brianrwagner/brw-linkedin-profile-optimizer`, but add privacy-first intake before requesting profile content.

## Verified Source Metadata

- Source page: `https://clawhub.ai/brianrwagner/skills/brw-linkedin-profile-optimizer`
- ClawHub owner: `Brian Wagner` / `@brianrwagner`
- ClawHub version: `1.0.0`
- ClawHub install command: `openclaw skills install @brianrwagner/brw-linkedin-profile-optimizer`
- ClawHub security summary: text-only LinkedIn profile rewriting helper; static scan clean; verdict benign.
- ClawHub issue to address: add privacy notice before intake because users may paste sensitive profile, employer, client, or business details.

## When To Use

Use this skill when the user asks for:

- LinkedIn profile optimization.
- Headline rewrites.
- About section rewrites.
- Experience bullet rewrites.
- Recruiter visibility or client-attraction positioning.
- LinkedIn profile fit for job seeking, client attraction, thought leadership, or all three.
- AI visibility across tools such as ChatGPT, Perplexity, Claude, and web search.

Do not use this skill to scrape LinkedIn, send messages, auto-apply, automate engagement, or modify the user's account directly unless a separate verified tool and explicit user approval are available.

## Privacy-First Intake

Before asking the user to paste profile content, warn them to minimize sensitive data:

```text
Before you paste anything, redact details you do not want processed here: private contact info, confidential employer/client names, internal metrics, unreleased products, exact revenue numbers, compensation details, or anything under NDA. You can replace names and numbers with placeholders like [Company A], [Client], or [metric]. Share only what you are comfortable using for profile optimization.
```

Then ask for the minimum useful profile inputs in one message:

1. Current headline.
2. Current About section.
3. Top 1-3 Experience entries with title, company placeholder if needed, dates if useful, and bullets.
4. Featured section or portfolio links, if relevant.
5. Target audience: who should find or trust the profile.
6. Desired action: recruiter outreach, client call, follow, DM, hiring conversation, or another single action.
7. Positioning goal: job seeker, client attraction, thought leadership, or all three.

If the user has already provided enough information, do not ask again. If target audience or desired action is vague, ask one clarifying question before rewriting.

## Workflow

1. Scan the profile for generic or low-trust language before scoring.
2. Score the key sections honestly from 1-10 and prioritize fixes.
3. Rewrite the headline with three positioning variants.
4. Rewrite the About section in the user's likely voice, without inventing proof.
5. Rewrite the strongest Experience bullets with outcome-first phrasing.
6. Add an AI Visibility Checklist that assesses whether the profile can be surfaced and understood by AI search systems.
7. End with concrete next options: refine a section, write matching posts, or finish.

## Buzzword Scan

Flag and replace vague phrases such as:

- results-driven or results-oriented
- passionate about
- dynamic professional
- synergy
- robust or comprehensive when unsupported
- visionary leader
- thought leader when self-applied
- seasoned professional
- proven track record
- strategic thinker without proof
- detail-oriented
- team player
- cutting-edge or game-changing

Every flag needs a specific replacement, not just a note.

## Output Contract

Deliver these sections in one dense response unless the user asked for only one section.

### 1. Profile Audit

Include a table with:

- Headline score and one-sentence diagnosis.
- About section score and one-sentence diagnosis.
- Experience score and one-sentence diagnosis.
- Featured section score and one-sentence diagnosis.
- Overall profile fit score and one-sentence diagnosis.
- Total score out of 50.
- Priority order for fixes from highest leverage to lowest.

Scoring standard:

- `1-3`: confusing, missing, or actively hurting the goal.
- `4-6`: present but forgettable.
- `7-8`: clear and functional with sharpening needed.
- `9-10`: genuinely specific, compelling, and hard to copy.

Do not soften low scores with empty encouragement.

### 2. Headline Rewrite

Write three variants:

- `Authority-forward`: role plus specific outcome for a specific audience.
- `Outcome-forward`: result first, role second.
- `Niche-specific`: audience, method, and outcome combined into a distinct category.

After the variants, recommend which one to test first and why. Keep each headline within LinkedIn's 220-character limit.

### 3. About Section Rewrite

Write a complete About rewrite, maximum 220 words, using:

- Hook: a specific claim or end-result-first opening.
- Credibility: concrete contexts, industries, roles, clients, products, or systems.
- Proof: numbers if provided; otherwise flag where metrics would strengthen the copy.
- CTA: one clear next step aligned with the user's desired action.

Do not start with "I am" or "I've". Do not invent clients, metrics, credentials, media, or outcomes.

### 4. Experience Optimization

Rewrite bullets for the top 1-2 roles. Use this format:

```text
[Company or Placeholder] | [Title] | [Dates if provided]

BEFORE:
- [Original bullet]

AFTER:
- [Rewritten bullet]
```

Bullet rules:

- Start with the outcome where possible.
- Use metrics only when provided or clearly marked as a placeholder to verify.
- Include searchable keywords naturally.
- Keep bullets scannable.
- Replace passive phrasing such as "responsible for" or "helped with".

### 5. AI Visibility Checklist

Assess each item as `Pass`, `Needs work`, or `Missing`:

- Entity clarity: name, role, and niche are clear quickly.
- Niche specificity: audience, method, and outcome are specific.
- Third-party mentions: credible external proof is present.
- Content consistency: profile language matches public content themes.
- Direct-answer language: profile copy answers likely search questions.
- Recency signals: current role, dates, or recent activity are visible.
- URL/name match: custom LinkedIn URL supports discoverability.
- Cross-platform footprint: same positioning appears on website, GitHub, X, Substack, talks, podcasts, or portfolio.

Provide an AI Visibility Score out of 8 and the top 3 moves to improve it.

## Close

End a full optimization package with:

```text
That's your full LinkedIn optimization package.

What's next?

A) Refine any section - tell me which one and what direction
B) Write 5 LinkedIn posts that match the new positioning
C) Done - you're good to go

Which one?
```

If the user chooses B, write five LinkedIn posts that reinforce the new positioning: personal story, numbered list, contrarian take, result/pattern, and direct CTA.

## Common Mistakes

- Asking for unredacted private data.
- Giving generic profile advice that could apply to anyone.
- Inventing metrics, clients, credentials, or media mentions.
- Optimizing for recruiters when the stated goal is client attraction, or vice versa.
- Treating AI visibility as SEO keyword stuffing instead of entity clarity and proof.
- Making direct LinkedIn account changes without explicit permission and a verified safe tool.
