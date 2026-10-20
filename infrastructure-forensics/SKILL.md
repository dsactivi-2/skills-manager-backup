---
name: infrastructure-forensics
description: Analyze AWS EC2 filesystem dumps, Docker volumes, EFS mounts, and cross-reference with live dashboards to assess completeness and data integrity.
---

# Infrastructure Forensics

Systematic analysis of server filesystem dumps (AWS EC2 snapshots, tarballs, rsync copies) to determine what data is present, what's missing, and whether a server could be reconstructed from the dump alone.

## Trigger Conditions

- User has filesystem dumps of servers (folders named like `i-0cc4ad5c665ce9302 (CRM Prod)`)
- User asks "was ist in dem Ordner", "fehlt etwas", "ist das vollständig"
- User shows live Docker dashboards (Dockhand, Portainer) alongside dumps
- User needs to know if EFS/NFS data survived a backup

## Analysis Workflow

### 0. Classify the Export Before Deep Scanning

Start with a shallow inventory before recursing. Determine whether the folder is a full filesystem dump, an application repository, or an agent-state export (for example: `config.yaml`, `SOUL.md`, `skills/`, `plugins/`, `cron/`). Report its size, top-level directories, and likely purpose first.

For agent-state exports, read the central configuration, persona files, job manifest, plugin manifest/source, and SQLite schema before opening historical output. Treat `jobs.json` or an equivalent manifest as the current intended schedule; treat output folders, execution databases, and audit logs as historical evidence that can retain deleted jobs.

Redact credentials, recipient identifiers, private endpoints, and raw personal data in the report. If secrets appear in configuration or logs, state that the export is sensitive and recommend rotation after sharing; never reproduce the value.

### 1. Identify the Server

```bash
# Check OS and kernel
ls <dump>/boot/
cat <dump>/etc/os-release 2>/dev/null
cat <dump>/etc/hostname 2>/dev/null

# Check AWS metadata (if .json file exists alongside dump)
cat <dump>.json  # Instance type, launch time, AZ, security groups, IP
```

### 2. Check Filesystem Mounts

```bash
cat <dump>/etc/fstab
cat <dump>/proc/mounts 2>/dev/null  # Often empty in dumps
```

### 3. Check for EFS/NFS Data (CRITICAL PITFALL)

EFS (AWS Elastic File System) is a NETWORK filesystem. When you dump a server's local disk, EFS mount points appear as EMPTY directories. The actual data lives on AWS and is NOT captured.

```bash
# EFS mount logs reveal what was mounted
cat <dump>/var/log/amazon/efs/mount.log
cat <dump>/var/log/amazon/efs/mount-watchdog.log

# Check if mount points have any data
ls -la <dump>/home/<user>/crm_files/
ls -la <dump>/home/<user>/pdf_contracts/
# → Empty = data was on EFS, not local disk
```

### 4. Find Application Code and Configuration

```bash
# Common locations
ls <dump>/home/*/
ls <dump>/opt/
find <dump>/home -name "docker-compose*"
find <dump>/home -name "Dockerfile"
```

### 5. Check Docker Volumes

Docker named volumes live under `/var/lib/docker/volumes/`. These ARE captured in filesystem dumps (unlike EFS).

```bash
ls <dump>/var/lib/docker/volumes/
# Check volume content
for vol in $(ls <dump>/var/lib/docker/volumes/ | grep -v metadata.db); do
  echo "=== $vol ==="
  ls <dump>/var/lib/docker/volumes/$vol/_data/ | head -5
done

# Count files per volume
for vol in $(ls <dump>/var/lib/docker/volumes/ | grep -v metadata.db); do
  count=$(find "<dump>/var/lib/docker/volumes/$vol/_data/" -type f 2>/dev/null | wc -l)
  echo "$vol: $count files"
done
```

### 6. Check Database Dumps

```bash
find <dump>/home -name "*.sql" -o -name "*.sql.gz" -o -name "*.tar.gz"
ls -lh <dump>/home/<user>/<app>/databaseDump/
```

### 7. Cross-Reference with Live Dashboards

When the user provides Dockhand/Portainer screenshots:
- Match IP addresses and hostnames between dumps and screenshots
- Compare container lists (running vs. what docker-compose defines)
- Note exited containers (may indicate abandoned services)
- Check if EFS mount points shown in docker-compose are actually populated

## Completeness Assessment

For each server dump, assess:

| Check | How |
|---|---|
| OS + config | `/etc/`, `/boot/` present |
| Application code | Source in `/home/` or `/opt/` |
| Docker config | `docker-compose.yml` with correct env vars |
| Database | SQL dump file with reasonable size (>100 MB for production) |
| Docker volumes | `/var/lib/docker/volumes/` has data |
| EFS data | **Almost always MISSING** — check mount logs |
| LXD containers | Check `/var/snap/lxd/common/lxd/containers/` |

### 8. Analyze systemd Journal Logs (for LXD/empty servers)

When a server dump has no application code but has large journal logs, extract clues:

```bash
# List journal files
ls -lhS "<dump>/var/log/journal/<machine-id>/"

# Extract human-readable strings and search for services
strings "<dump>/var/log/journal/<machine-id>/system.journal" | grep -iE "lxc|lxd|docker|nginx|apache|php|mysql|postgres|node|python" | sort -u | head -50

# Find all executed commands (what was actually run on the server)
strings "<dump>/var/log/journal/<machine-id>/system.journal" | grep -iE "COMM=|_EXE=|_CMDLINE=" | grep -v "sshd\|cron\|systemd\|dbus" | sort -u

# Check for snap packages (LXD often installed via snap)
strings "<dump>/var/log/journal/<machine-id>/system.journal" | grep -iE "snap\.|snapd" | grep -v "SHA256\|AuthorizedKeys" | sort -u
```

**Interpretation**: If logs show only `lxd` snap, `amazon-ssm-agent`, and SSH brute-force attempts — the server was a bare Ubuntu host with LXD installed. The actual application ran inside LXD containers whose storage pools were NOT captured in the filesystem dump.

### 9. Docker Volume vs Bind Mount Analysis

When analyzing docker-compose files, distinguish:

| Mount Type | In compose | Data location | In filesystem dump? |
|---|---|---|---|
| Named volume | `- dbdata:/var/lib/mysql` | `/var/lib/docker/volumes/<name>/_data/` | **YES** |
| Bind mount (EFS) | `- ../crm_files:/var/www/html/files` | Host path (often EFS) | **NO** if EFS |

Verify with `docker inspect` output from live containers:
```json
"Mounts": [
  {"Type": "volume", "Name": "crm_dbdata", "Source": "/var/lib/docker/volumes/crm_dbdata/_data"},
  {"Type": "bind",   "Source": "/home/ec2-user/crm_files", "Destination": "/var/www/html/files"}
]
```

**nginx-proxy `html` volume pitfall**: The `html` volume in nginx-proxy setups contains only `index.html` and `50x.html` — NOT the CRM application files. The app code is baked into the container image or mounted via bind mounts. Don't mistake this for application data.

### 10. Read-Only Local MySQL Inventory

When a local MySQL container is available but SQL credentials are unavailable, separate what is live-verified from what is inferred from its mounted SQL dump:

1. Inspect the container without exposing environment values: state, image, localhost port mapping, mount types, and volume size.
2. Read the mounted `.sql` dump for its declared database name, table definitions, and `AUTO_INCREMENT` values.
3. Report the result as a schema/import inventory, not as a live query result. Label `AUTO_INCREMENT` as the next generated ID, never an exact row count: deleted rows and failed inserts leave gaps.
4. Explain large table differences by cardinality: one candidate can have many contacts, qualifications, status changes, project assignments, and notes.

Do not print database credentials, access tokens, or raw candidate data merely to prove access. If authentication fails, do not reset users, change passwords, or restart with grant tables disabled during an inspection; that changes the evidence and risks the database.

### 11. Local Restoration from Dump

When the user wants to run the dumped system locally (Orbstack/Docker Desktop):

#### Architecture Pitfall
MySQL InnoDB data files (`ibdata1`, `*.ibd`) are **architecture-specific**. Files from x86_64 servers CANNOT be directly mounted on ARM64 (Apple Silicon). Use the SQL dump instead.

#### Restoration Workflow
1. Copy project to working directory: `rsync -a <dump>/home/<user>/<app>/ ~/local-app/`
2. Create empty directories for EFS bind mounts (they'll be empty but must exist)
3. Write a `docker-compose.local.yml` that:
   - Uses `mysql:8.0` image (multi-arch, works on ARM64)
   - Mounts `./databaseDump/` as `/docker-entrypoint-initdb.d` for auto-import
   - Removes nginx-proxy/ACME (not needed locally)
   - Maps app ports to localhost (8081, 8082, etc.)
   - Uses named volumes for DB data (not bind mounts to x86_64 InnoDB files)
4. Build and start: `docker compose -f docker-compose.local.yml up -d --build`
5. MySQL auto-imports the SQL dump on first start (can take 10+ minutes for 1.3 GB)

#### Dockhand Backup Scripts (avoiding /tmp full)
When `/tmp` in the container is full, avoid intermediate copies. Write tar directly to the target:

```sh
# EFS files backup (no /tmp)
cd /var/www/html && B="/var/www/html/files/db_dumps/crm-files-$(date +%Y%m%d_%H%M%S).tar.gz" && tar czf "$B" files jobstep_pp/files online-viza/files tcpdf-main/ugovori && ls -lh "$B"

# Database backup (separate, no /tmp)
B="/var/www/html/files/db_dumps/crm-db-$(date +%Y%m%d_%H%M%S).sql.gz" && mysqldump -h mysql -u crmadmin -p<PASSWORD> --all-databases --single-transaction --quick | gzip > "$B" && ls -lh "$B"
```

## CRM-Specific Reference

See `references/crm-local-login.md` for the CRM authentication architecture (idk_employees vs users table, MD5 vs bcrypt, password reset workflow, known accounts).

## Common Pitfalls

- **CRM login table confusion**: The CRM web login at `/login.php` authenticates against `idk_employees` (MD5 hashes), NOT the `users` table (bcrypt hashes). Looking at `users` for admin accounts is a dead end. See `references/crm-local-login.md`.
- **EFS data is never in filesystem dumps.** The mount points are empty directories. Data lives at AWS.
- **Docker images are not in dumps** unless explicitly saved. `docker-compose.yml` with `build:` directives means images must be rebuilt.
- **Timestamp loss**: Dumps often show all files dated "Nov 29 1979" — this is normal for tar/rsync without timestamp preservation.
- **LXD containers**: If an app runs in LXD, the container storage may not be in the host filesystem dump. Journal logs can confirm LXD was installed but won't contain container data.
- **temp-efs-mount-instance** named servers are disposable — they were created only to mount EFS and copy data. They contain no application code.
- **Dockhand container selection**: When verifying EFS mounts via Dockhand Shell, connect to the APP container (e.g. JobstepCRM, php-apache), NOT the Hawser agent. The Hawser agent runs in a separate Docker network and cannot see app mount points or run `docker ps` against the host's other containers. Use Shell → select app container → Bash → root.
- **MySQL InnoDB cross-architecture**: InnoDB data files from x86_64 cannot be mounted on ARM64 (Apple Silicon). Use SQL dumps instead — they are architecture-independent.
- **nginx-proxy `html` volume is NOT the app**: The `html` volume in nginx-proxy setups contains only `index.html` and `50x.html` — NOT the CRM application files. The app code is baked into the container image or mounted via bind mounts.

## Communication

- User is German-speaking. Explain in German, simple terms.
- When the user asks "erkläre mir in einfachen Worten", avoid technical jargon.
- Use analogies: "wie eine externe Festplatte", "wie ein Schnappschuss".
- Present findings as tables for clarity.
