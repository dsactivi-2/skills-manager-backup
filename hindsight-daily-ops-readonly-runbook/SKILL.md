---
name: hindsight-daily-ops-readonly-runbook
description: "Run the Hindsight Daily Ops automation safely with read-only Kubernetes evidence, report generation, gate interpretation, and alert handling. Use this skill when running the Hindsight Daily Ops automation for activi K3s or interpreting its FAIL/ALERT_REQUIRED report."
trigger: "Use this skill when running the Hindsight Daily Ops automation for activi K3s or interpreting its FAIL/ALERT_REQUIRED report."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019f6480-12db-7020-b1ce-92f21d32b468
  - activi_dsactivi's Organization_default_019f5f58-8c25-72c0-a0dc-b74f41869810
  - activi_dsactivi's Organization_default_019f5a32-7e65-78f1-a191-455ae8ef4ffc
  - activi_dsactivi's Organization_default_019ef32c-e775-7e81-8298-45d4e4b94778
  - activi_dsactivi's Organization_default_019ee3b9-3c7a-79c3-95fa-b6b4e7dbc938
  - activi_dsactivi's Organization_default_019ede93-89d4-7ec1-9ca2-5a7798453181
  - activi_dsactivi's Organization_default_019ebf7d-af33-7050-9795-b71b96ab7c30
  - activi_dsactivi's Organization_default_019ebfac-befa-7ce2-ae85-9c38e5ae0007
  - activi_dsactivi's Organization_default_019ebf9f-f662-7d60-b311-0fa3e37844ea
  - activi_dsactivi's Organization_default_019ebf9e-19e4-7a52-9d42-0faa60006194
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-07-16T06:54:29.751Z
updated_at: 2026-07-16T06:54:29.751Z
---

# Hindsight Daily Ops read-only runbook

## When to use

Use for the recurring Hindsight Daily Ops automation in `/Users/activi/Documents/activi K3s`, especially when the prompt asks for `docs/apps/hindsight-daily-ops-report-YYYY-MM-DD.md`, `ALERT_REQUIRED`, `run-hindsight-deploy-gate.sh`, or `run-baseline-gates.sh`.

This is a diagnostic runbook only. It must not apply manifests, restart workloads, rerun CronJobs, decode Secrets, run migrations, or repair production automatically.

## Workflow

1. Create a dated report file using the Europe/Sarajevo local date:

```bash
mkdir -p docs/apps
REPORT=docs/apps/hindsight-daily-ops-report-$(TZ=Europe/Sarajevo date +%F).md
```

Keep raw command logs under `/private/tmp/hindsight-daily-ops/<timestamp>/` or `/tmp/`, and reference those paths in the report.

2. Collect only low-risk read-only Kubernetes evidence. Avoid `kubectl describe` unless needed, and never print full Secret objects or environment values.

```bash
kubectl get ns hindsight
kubectl -n hindsight get deploy hindsight-api hindsight-worker hindsight-ui hindsight-ollama -o wide
kubectl -n hindsight get pods -o wide
kubectl -n hindsight get events --sort-by=.lastTimestamp | tail -n 50
kubectl -n hindsight get cnpg
kubectl -n hindsight get cronjob,job
kubectl -n hindsight get ingress,cert,svc
```

Summarize whether the namespace exists, all four required Deployments are ready, pods are Running/Ready or Completed, there are no `CrashLoopBackOff` or `Failed` pods, and restart counts are not increasing.

3. Check app-level health from behavior, not secrets:

```bash
curl -fsS https://<hindsight-api-host>/health || true
curl -fsSI https://<hindsight-ui-host> || true
```

For Ollama, confirm the required `bge-m3:latest` model by safe service/API output. For Postgres, record CloudNativePG health such as `3/3 healthy`; do not decode database credentials.

4. Verify backup and recovery signals without triggering changes:

- pg_dump backup CronJob exists and recent successful Job evidence is present.
- Restore-test evidence reports gzip/SHA checks passing when available.
- Velero schedule exists and is enabled.
- Longhorn recurring jobs are visible.
- Groq health-check CronJob exists and recent success is visible.

5. Run gates as diagnostics and interpret them separately from app health:

```bash
RUN_BASELINE=0 ./run-hindsight-deploy-gate.sh
timeout 600 ./run-baseline-gates.sh
```

If `run-hindsight-deploy-gate.sh` fails on `public Ingress exists before separate public-access approval`, keep the overall result `FAIL` even if the live Hindsight stack is healthy. If `run-baseline-gates.sh` fails on Server-2 OS/Restic checks or `audit-recent-stack-claims.sh` only returns `PASS_WITH_WARNINGS`, report that as a baseline failure, not as an application outage.

6. Alert handling:

If any check fails or requires attention, set `ALERT_REQUIRED=true`. Do not invent a notifier. If the repo lacks a documented safe notification channel, report `NOTIFICATION_CHANNEL_MISSING` and do not send an alert.

## Reporting

Final report must include:

- Overall status: `PASS`, `PASS_WITH_GAPS`, or `FAIL`
- `ALERT_REQUIRED=true|false`
- Live stack health summary: namespace, deployments, pod counts, CNPG, API, UI, worker, Ollama
- Backup/recovery evidence: pg_dump, restore test, Velero, Longhorn, Groq CronJob
- Gate results and exact failure reasons
- Notification status, especially `NOTIFICATION_CHANNEL_MISSING`
- Log paths, for example `/private/tmp/hindsight-daily-ops/<timestamp>/main.log`, `/tmp/hindsight-deploy-gate-*.log`, `/tmp/k3s-baseline-gates-*.log`

## Anti-patterns

- Marking the run green because workloads are healthy while deploy or baseline gates fail
- Treating sandbox-limited evidence as a live cluster finding; rerun read-only live checks when needed and label the invalid run
- Printing kubeconfigs, Secret data, tokens, passwords, `.env` values, or decoded credentials
- Auto-repairing failures, restarting pods, applying YAML, rerunning CronJobs, or changing database state
- Sending alerts through an undocumented channel
- Omitting the report file or log paths from the final response
