# CRM-Local Verification Commands

Quick verification for the Jobstep CRM local Docker setup at `~/crm-local/`.

## Health Check

```bash
# All containers running?
docker ps --filter "network=crm-local_crm_network" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# HTTP responses
curl -s -o /dev/null -w "CRM (8081): %{http_code}\n" http://localhost:8081/
curl -s -o /dev/null -w "PhpMyAdmin (8080): %{http_code}\n" http://localhost:8080/
curl -s -o /dev/null -w "PartnerApp (8082): %{http_code}\n" http://localhost:8082/
curl -s -o /dev/null -w "Join (8083): %{http_code}\n" http://localhost:8083/
```

Expected: CRM=302, PhpMyAdmin=200, PartnerApp=200, Join=302

## DB Check

```bash
docker exec MySQL mysql -u crmadmin -pdvRATihRkMQ2Qx -e \
  "SELECT table_schema, COUNT(*) AS tables, ROUND(SUM(data_length + index_length)/1024/1024, 1) AS size_mb FROM information_schema.tables WHERE table_schema='productioncrmdb' GROUP BY table_schema;"
```

Expected: 179 tables, ~1.5 GB

## Login Test

```bash
curl -c /tmp/crm_cookies.txt -X POST http://localhost:8081/do.php?form=login \
  -d "login_email=d.selmanovic@job-step.com&login_password=Jobstep2024!" \
  -o /dev/null -w "%{http_code}" -L
```

Expected: 200 (logged-in dashboard)

## Start/Stop

```bash
cd ~/crm-local && docker compose -f docker-compose.local.yml up -d    # start
cd ~/crm-local && docker compose -f docker-compose.local.yml down     # stop
cd ~/crm-local && docker compose -f docker-compose.local.yml down -v  # stop + delete DB volume
```

## Credentials

| Service | URL | User | Password |
|---|---|---|---|
| CRM | http://localhost:8081 | d.selmanovic@job-step.com | Jobstep2024! |
| PhpMyAdmin | http://localhost:8080 | root | auighnsiugnyotu3ntao2utanwfsyng |
| MySQL | localhost:3306 | crmadmin | dvRATihRkMQ2Qx |

## Password Reset (MD5!)

Login uses `idk_employees` table with MD5 hashes (NOT bcrypt):

```bash
docker exec MySQL mysql -u crmadmin -pdvRATihRkMQ2Qx productioncrmdb \
  -e "UPDATE idk_employees SET employee_password = MD5('NEWPASS'), employee_reset_password = 0, employee_last_password_change = NOW() WHERE employee_id = 20;"
```

## Pitfalls

- First start imports 1.3 GB backup.sql — takes 5-10 min, watch `docker logs MySQL`
- EFS volumes (crm_files, js_files, visa_files, pdf_contracts) are empty locally
- PHP 7.1 from ppa:ondrej/php — ARM64 needs Rosetta emulation
- Login is via `idk_employees` table, NOT `users` table
