---
name: live-stack-verification
category: devops
description: Verify deployment and system status by probing the live environment first, then diffing against documentation.
---

# Live Stack Verification

## Trigger
Use this skill when the user asks to check the status of a setup, deployment, or system, or asks "what is the current state of X" or "is Y running".

## Core Rules
1. **Live First, Docs Second**: DO NOT start by reading local project files, runbooks, or documentation alone. Local files represent *desired* state, which is often stale. Always probe the actual environment first.
2. **Probe the Live Stack**: Immediately query the live environment using direct tools:
   - Web/API: `curl -sI https://<domain>/health` or equivalent public endpoints.
   - Containers: `docker ps --filter name=<service>` or `kubectl get pods`.
   - Processes/Ports: `lsof -i :<port>` or `systemctl status <service>`.
3. **Verify the URL/Endpoint**: Explicitly confirm the correct live URL or domain before probing. Check `.env` files, `compose.yaml`, or DNS records if the URL is unknown. Never guess the endpoint.
4. **Generate a Diff Report**: After gathering live data, compare it directly against the local documentation (e.g., `README.md`, checklists, runbooks). Present the findings as a clear "Live Status vs. Documentation" diff, highlighting missing configs, unapplied changes, or running services not reflected in the docs.

## Pitfalls
- **Stale Local Data Trap**: Reading `workflow.json`, `.env.example`, or a checklist and assuming it reflects the live system. Always `curl` or check running processes first.
- **Auth Redirects are Success**: If a live endpoint returns 401/403 or redirects to `/login` (e.g., via Cloudflare), treat this as a *positive* signal that the service is live and routing correctly, not as a failure.
- **Silent Failures**: A timeout or connection refused means the service is down or the URL is wrong. Report this explicitly as the primary finding.
- **EFS / Network Filesystem Trap**: When verifying filesystem dumps (tar/rsync copies of EC2 instances), EFS/NFS mount points appear as EMPTY directories. The data lives on the network filesystem, not the local disk. Do NOT conclude data is lost — verify live via container shell or SSH. For Docker-based setups managed via Dockhand/Hawser: connect to the app container (not the Hawser agent), check mount paths with `ls -la`, and compare against local dumps. EFS data must be backed up separately from the instance filesystem.
- **Docker Volume Misidentification**: In nginx-proxy setups, the `html` volume maps to nginx fallback pages (`index.html`, `50x.html`), NOT the application. Always check `docker-compose.yml` to confirm which service owns each volume before claiming it contains app data.
- **Container /tmp Space**: Container `/tmp` is often small (a few hundred MB). Never `cp` EFS data to `/tmp` before archiving — write `tar` directly to the target path. Split EFS and DB backups into separate commands to avoid giant single archives that may fail mid-way.
- **Dockhand Shell is Container-Only**: Dockhand's Shell view requires selecting a container — there is no direct host shell. The Hawser agent container has `docker ps` access (Docker socket mounted) but NOT app EFS mount paths. Use the app container for EFS verification and backup. Use the Hawser agent container only for `docker ps` to list all running containers.
- **"File exists" errors during cp**: When `/tmp` has leftover files from a previous backup attempt, `cp` shows "File exists" but continues copying. The real fix is to avoid `/tmp` entirely and write tar directly to the target path.

## Example Workflow
1. User: "Check if the dograh setup is running."
2. Agent: Probes `https://dograh.example.com/api/health` and runs `docker ps`.
3. Agent: Reads local `PRELAUNCH_CHECKLIST.md` to understand expected state.
4. Agent: Reports: "✅ Live API is responding (v1.28.0). ❌ Local checklist says Stripe backend is configured, but live `curl` to the backend URL shows it is unreachable. Diff: ..."

## EFS / Network Filesystem Verification
When comparing local filesystem dumps against live servers:
1. **EFS mount points are ALWAYS empty in dumps** — EFS is a network filesystem, not a local disk. tar/rsync copies only the mount directory, not the mounted data.
2. **Verify live via container shell**: Connect to the app container (e.g., JobstepCRM), not the management agent (Hawser). Run `ls -la <mount-path>` to confirm data exists.
3. **Backup EFS separately**: EFS data requires its own backup process — either `cp -a` from within the container to a local path, or AWS EFS backup policies.
4. **Dockhand workflow**: Containers → app container → Shell (Bash, root) → run verification commands. The Hawser agent container may not have access to app mount points.
5. **Docker inspect for mount verification**: `docker inspect <container>` shows bind mounts under `HostConfig.Binds` and `Mounts`, confirming which host paths (EFS) are mapped into the container. Use this to cross-reference against docker-compose.yml.
6. **EFS backup from container — avoid /tmp**: Container `/tmp` is often small. When backing up EFS data, write `tar` directly to the target path (e.g., `/var/www/html/files/db_dumps/`) without intermediate copies to `/tmp`. Use `tar czf <target> -C <source-dir> <paths>` to avoid `cp`-then-`tar` patterns that fill `/tmp`.
7. **Separate EFS from DB backup when space is tight**: Run EFS file backup and `mysqldump` as two separate commands. This avoids a single giant archive that may fail mid-way. Download both files from Dockhand's Files browser.
8. **Local dump vs live comparison workflow**: When the user has multiple EC2 instance dumps locally, systematically compare each against the live server: (a) list all dump directories, (b) for each, check EFS mount points for file count, (c) verify live via container shell, (d) produce a table: Server | Code present | DB dump | EFS files | Runnable?.