# EFS Backup from Dockhand Container Shell

## Context
When EC2 instances use EFS (Elastic File System) for persistent data, local filesystem dumps (tar/rsync) do NOT include EFS data. EFS mount points appear as empty directories. The data must be backed up separately from within a running container that has the EFS bind-mounted.

## Dockhand Access Pattern
1. Open Dockhand for the target server
2. Navigate: Containers → app container (e.g., JobstepCRM) → Shell
3. Select: Shell=Bash, User=root
4. The Hawser agent container does NOT have access to app EFS mounts — use the app container

## Verifying EFS Data is Live
```bash
ls -la /var/www/html/files/ | head -20
ls -la /var/www/html/jobstep_pp/files/ | head -10
ls -la /var/www/html/online-viza/files/ | head -10
ls -la /var/www/html/tcpdf-main/ugovori/ | head -10
```

## Backup Commands

### EFS Files Only (no /tmp — write directly to target)
```bash
sh -c 'cd /var/www/html && B="/var/www/html/files/db_dumps/crm-files-$(date +%Y%m%d_%H%M%S).tar.gz" && echo "Starte: $B" && tar czf "$B" files jobstep_pp/files online-viza/files tcpdf-main/ugovori && ls -lh "$B" && echo "FERTIG"'
```

### Database Dump (separate — avoids giant single archive)
```bash
sh -c 'B="/var/www/html/files/db_dumps/crm-db-$(date +%Y%m%d_%H%M%S).sql.gz" && echo "Starte: $B" && mysqldump -h mysql -u crmadmin -pdvRATihRkMQ2Qx --all-databases --single-transaction --quick | gzip > "$B" && ls -lh "$B" && echo "FERTIG"'
```

## Pitfalls
- **Container /tmp is small**: Never `cp` EFS data to `/tmp` before archiving. Write tar directly to the target path.
- **Single giant archive fails**: EFS data (1-3 GB) + DB dump (1+ GB) can exceed available space or timeout. Split into two commands.
- **"File exists" errors during cp**: Harmless — means a previous run left files in `/tmp`. The cp overwrites them. But the real fix is to avoid `/tmp` entirely.
- **DB credentials in commands**: The mysqldump password is visible in the shell command. After backup, clear shell history or note that the command contains credentials.

## Download from Dockhand
After backup completes:
1. Containers → app container → Files (folder icon)
2. Navigate to `files/db_dumps/`
3. Download the `.tar.gz` and `.sql.gz` files

## Cross-Referencing with Local Dumps
When comparing local instance dumps against live servers:
- Local dump EFS mount points: always 0 files
- Live container EFS mount points: hundreds/thousands of files
- Local dump has: source code, Docker volumes (DB data), config files
- Local dump lacks: EFS data (must be backed up separately)

## Verifying Mounts via docker inspect
`docker inspect <container>` returns JSON with two key sections for mount verification:
- `HostConfig.Binds`: array of `"host_path:container_path:rw"` strings — shows bind mounts from docker-compose
- `Mounts`: array of objects with `Type` (bind/volume), `Source`, `Destination`, `Mode`, `RW`, `Propagation`
Use this to cross-reference against docker-compose.yml and confirm which host paths (EFS) are mapped into the container.

## Dockhand Shell UI Pattern
Dockhand's Shell view requires selecting a container — there is no direct host shell:
1. **Shell** in left sidebar → search/select container from dropdown
2. **Hawser agent container** (`hawser-agent-aws-*`): has `docker ps` access (Docker socket mounted), good for listing all containers
3. **App container** (e.g., JobstepCRM): has EFS bind mounts, good for verifying/backing up EFS data
4. Shell type: Bash, User: root
5. The Hawser agent container does NOT have access to app EFS mount paths

## Common Misconceptions
- **`crm_html` Docker volume is NOT the CRM application**: In nginx-proxy setups, the `html` volume maps to `/usr/share/nginx/html` (nginx fallback pages: `index.html`, `50x.html`). The actual CRM application code is baked into the container image or bind-mounted from the host. Check `docker-compose.yml` to confirm which service owns each volume.
- **"File exists" errors during cp are harmless**: When `/tmp` has leftover files from a previous backup attempt, `cp` shows "File exists" but continues copying. The real fix is to avoid `/tmp` entirely and write tar directly to the target path.
