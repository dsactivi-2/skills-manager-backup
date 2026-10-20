# Disk Phase A — measure only (macOS APFS)

User signal: disk jumped hundreds of GB in 1–2 days, “loop/backup loop” suspicion.

## SoT volumes

```bash
df -h / /System/Volumes/Data /System/Volumes/VM
diskutil apfs list | head -80   # Capacity In Use / Data / VM
```

| Volume | Role |
|--------|------|
| `/System/Volumes/Data` | **User SoT** for “Mac full” |
| `/` (System) | Often ~12 GB sealed — not the growth story |
| `/System/Volumes/VM` | Swap; 20–40 GB = RAM pressure |

## Measure commands (read-only)

```bash
docker system df 2>/dev/null
docker builder du 2>/dev/null | tail -8

# Top Library buckets
du -sh ~/Library/Mobile\ Documents ~/Library/CloudStorage \
  ~/Library/Group\ Containers ~/Library/Application\ Support \
  ~/Library/Containers ~/Library/Caches ~/Library/pnpm 2>/dev/null | sort -hr

# iCloud — path may be missing (see pitfalls)
du -sh ~/Library/Mobile\ Documents/com~apple~CloudDocs 2>/dev/null
du -sh ~/Library/Mobile\ Documents/com~apple~CloudDocs/* 2>/dev/null | sort -hr | head -25
du -sh ~/Library/CloudStorage/* 2>/dev/null

# Docker / OrbStack (sizes may overlap docker system df)
du -sh ~/Library/Group\ Containers/*orbstack* \
  ~/Library/Containers/com.docker.docker 2>/dev/null

du -sh ~/.hermes ~/.ollama ~/.npm ~/Downloads ~/Code ~/Documents 2>/dev/null
ls -lh /System/Volumes/VM/ 2>/dev/null | head -20
tmutil listlocalsnapshots / 2>/dev/null | head -15
```

### Last ~48h writers (loop hunt)

```bash
# Sum mtime -2 on *targeted* trees only (not whole home)
for p in ~/.hermes/backups ~/.hermes/state-snapshots ~/.hermes/logs \
  ~/Library/Caches ~/.npm/_cacache \
  "~/Library/Application Support/Claude" \
  "~/Library/Group Containers"/*orbstack*; do
  [ -e "$p" ] || continue
  find "$p" -type f -mtime -2 -print0 2>/dev/null \
    | xargs -0 stat -f '%z' 2>/dev/null \
    | awk -v p="$p" '{s+=$1} END{printf "%.1fG  %s\n", s/1024/1024/1024, p}'
done

# Hermes backup inventory (not a loop if capped)
ls -lt ~/.hermes/backups/pre-update-*.zip 2>/dev/null | head -10
rg -n 'backup_keep|pre_update_backup|max_snapshots' ~/.hermes/config.yaml 2>/dev/null
```

Also: `cd ~/Code/Tools/mac-hygiene && python3 scripts/scan_hermes.py --save` for sessions/swap.

## Interpret

| Signal | Meaning |
|--------|---------|
| Data 90%+, System ~12 GB | Chase **Data** |
| CloudDocs 100GB+ | iCloud fully local (Takeout/Documents/Desktop folders) |
| CloudDocs path **gone**, CloudStorage stub ~KB | Cannot delete “215G iCloud”; re-measure — do not invent path |
| Build Cache reclaimable large | Heavy `docker build` (multi-stage API/UI) |
| Hermes 5× pre-update zips, `backup_keep: 5` | **Not** an infinite backup loop (~2G total) |
| OrbStack / disk-image path sums to hundreds of GB on mtime -2 | **Artifact** (image touch ≠ bytes written) |
| Claude App Support multi-GB in 48h | Real growth candidate — list before delete |
| VM 20–40 GB + multi hermes | Slow feel; pair with process Phase 0 |
| Safe prune frees ~10–25 GB only | Remaining hundreds of GB = Documents/Apps/Docker images/unscanned — report **remaining map** |

## Safe-prune catalog (low risk — still freigabe)

After Phase A, offer numbered freigabe. Default bundle “safe prune”:

| # | Action | ~GB | Notes |
|---|--------|-----|-------|
| 1 | `docker builder prune -af` | 15–25 | Low risk |
| 2 | `docker container prune -f` + dead named containers | small | |
| 3 | dangling `docker image prune -f` | varies | Avoid `-a` unless user OK losing unused images |
| 4 | `npm cache clean --force` | 2–4 | |
| 5 | `pip cache purge` | 1–2 | |
| 6 | `brew cleanup -s` | 0.1–1 | |
| 7 | Playwright / Codex / camoufox / browser caches under `~/Library/Caches` | 2–4 | Regenerable |
| 8 | Hermes old `pre-update-*.zip` keep **newest 1** | ~1–2 | trash preferred |
| 9 | `~/.hermes/hermes-agent/venv.stale.*` | ~0.3 | |

**Never auto in safe prune:** `~/Documents`, iCloud CloudDocs contents, Ollama models, CRM volumes, `~/Code`, live `.env`.

Dry-run: print paths + sizes + `df` before. Apply: then `df` after + **remaining top buckets table** (user always asks “was belegt den Rest?”).

## Report shape (DE, short)

1. Data used / free (+ VM)  
2. Top path buckets  
3. 48h writers table + backup-loop yes/no  
4. Docker reclaimable line  
5. Hermes sessions + swap (scan_hermes)  
6. Freigabe options ranked — **no apply** until pick  

After any apply: before/after free GB + remaining map (not only “freed X”).

## Never in Phase A

- `docker system prune -a` without freigabe  
- Deleting iCloud / Documents without named folder list + explicit freigabe  
- Claiming “infinite loop” without growing path + uncapped writer  
- Trusting whole-home `find -mtime` timeouts as “no growth”  
- Using OrbStack apparent mtime sum as real write volume  
