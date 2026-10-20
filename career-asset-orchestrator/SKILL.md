---
name: career-asset-orchestrator
description: Use when a request spans LinkedIn, CV or ATS, portfolio website, case studies, cover letters, job-fit analysis, or job search, and the agent needs to choose the right career skills in the right order instead of handling each asset ad hoc.
---

# Career Asset Orchestrator

## Overview

Use this skill as the routing and sequencing layer for career work.
Its job is to decide which installed skill to use, in what order, and with what minimum inputs.

This skill does not replace the specialist skills.
It chooses among them and prevents messy, inconsistent, or duplicated work.

## When To Use

Use this skill when the user asks for any of the following:

- improve or rewrite LinkedIn
- optimize CV, resume, or ATS readiness
- create or improve a portfolio website
- turn project evidence into case studies
- tailor applications to specific job descriptions
- generate cover letters
- analyze job fit
- search for relevant jobs
- align multiple public career assets at once
- build a career setup from scattered reports, notes, or source material

Use this skill especially when:

- the request spans more than one career surface
- facts are scattered across reports and files
- the user wants a best-practice workflow
- the user wants sequencing, not just one isolated rewrite

## Routing Rules

Route to the smallest useful skill set.
Do not load every installed career skill by default.

### 1. Cross-platform career requests

If the task affects more than one of:

- LinkedIn
- CV or resume
- portfolio website
- case studies
- job search materials

Then start here and route in this order:

1. `agentkit-seo`
2. `agentkit-seo-cv-ats` or `agentkit-seo-linkedin` or `agentkit-seo-web-portfolio`
3. targeted support skills only if needed

### 2. LinkedIn only

Primary:

- `agentkit-seo-linkedin`

Secondary:

- `linkedin-profile-optimizer`

Use the secondary skill only for extra LinkedIn-specific phrasing and section shaping.
Prefer the AgentKit skill as the main authority.

### 3. CV or resume only

Primary:

- `agentkit-seo-cv-ats`

Secondary:

- `resume-ats-optimizer`
- `resume-bullet-writer`
- `resume-tailor`

Use:

- `resume-ats-optimizer` for parser-safe cleanup
- `resume-bullet-writer` for stronger bullet rewrites
- `resume-tailor` when a specific job description is present

### 4. Portfolio website only

Primary:

- `agentkit-seo-web-portfolio`

Secondary:

- `portfolio-case-study-writer`
- `cloudflare-deploy`

Use:

- `portfolio-case-study-writer` for turning raw project facts into portfolio pages
- `cloudflare-deploy` only when the user wants the site published

### 5. Cover letters or application packages

Primary:

- `job-description-analyzer`

Secondary:

- `resume-tailor`
- `cover-letter-generator`

Always analyze the job description first before tailoring resume or cover letter copy.

### 6. Job search

Primary:

- `job-search-mcp`

Use it only when the task is live job discovery.
Do not use it for generic career advice.

### 7. Document generation

Primary:

- `paperjsx`

Use only when the user wants final files such as:

- DOCX
- PDF
- PPTX

Do not route to `paperjsx` during early analysis or content strategy stages.

## Standard Workflows

### A. Best-practice full career build

Use this order:

1. read source reports and evidence
2. extract strongest application claims and strongest portfolio proof
3. route to `agentkit-seo-linkedin` for profile positioning
4. route to `agentkit-seo-cv-ats` for CV structure and ATS safety
5. route to `agentkit-seo-web-portfolio` for portfolio structure
6. route to `portfolio-case-study-writer` for case-study content
7. route to `paperjsx` only if final export files are needed
8. route to `cloudflare-deploy` only if the website is ready to publish

### B. Single job application

Use this order:

1. `job-description-analyzer`
2. `resume-tailor`
3. `resume-bullet-writer` if bullets are weak
4. `cover-letter-generator` if a cover letter is needed

### C. LinkedIn refresh from existing source material

Use this order:

1. `agentkit-seo-linkedin`
2. `linkedin-profile-optimizer`

### D. Portfolio proof build from projects

Use this order:

1. `agentkit-seo-web-portfolio`
2. `portfolio-case-study-writer`
3. `paperjsx` if PDF or DOCX case-study exports are requested

## Input Minimums

Ask only for the smallest missing input set.

### For LinkedIn

- current headline and about text, or profile export
- target roles
- target geographies

### For CV

- current CV or resume text
- target role
- job description if tailoring is requested

### For portfolio

- project list
- strongest proof artifacts
- source files or current site URL if available

### For job search

- role keywords
- target locations
- remote preference
- full-time or freelance preference

## Common Mistakes

- loading every career skill at once
- writing LinkedIn, CV, and portfolio independently so they drift
- generating a cover letter before analyzing the job description
- using `paperjsx` too early instead of after content is ready
- using job search skills before positioning and proof assets are strong enough
- inventing metrics or claims to fill gaps

## Response Shape

For broad career requests, return:

1. selected skills
2. order of use
3. inputs used
4. missing inputs
5. next concrete output to produce

For narrow requests, route quickly and do not over-explain orchestration.
