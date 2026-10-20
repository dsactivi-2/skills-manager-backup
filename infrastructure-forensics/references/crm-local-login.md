# CRM Local Login Architecture

## Authentication System

The CRM uses **two separate tables** for different purposes:

| Table | Purpose | Password Hash |
|---|---|---|
| `idk_employees` | **CRM Backend Login** (Mitarbeiter-Login) | **MD5** (plain MD5, no salt) |
| `users` | Mobile App Users (Kandidaten) | bcrypt (`$2y$10$...`) |

**Critical pitfall**: The `users` table has bcrypt hashes and looks like the login system, but the actual CRM web login at `/login.php` authenticates against `idk_employees`. Looking at `users` for admin accounts will lead nowhere.

## Login Flow

1. User visits `http://localhost:8081/login.php`
2. Form POSTs to `do.php?form=login` with `login_email` + `login_password`
3. Query: `SELECT ... FROM idk_employees WHERE employee_email = :email AND employee_status != 0`
4. Password check: `md5($login_password) == $user['employee_password']`
5. Session cookie: `idk_session` = `employee_key`

## Finding Admin Users

```sql
-- List all employees (CRM backend users)
SELECT employee_id, employee_firstname, employee_lastname, employee_email, employee_position, employee_status
FROM idk_employees ORDER BY employee_id;

-- Employees with position data (likely active)
SELECT employee_id, employee_firstname, employee_lastname, employee_email, employee_position
FROM idk_employees WHERE employee_position != '' AND employee_status != 0;
```

## Resetting an Employee Password

```sql
-- Reset password and clear reset flag
UPDATE idk_employees
SET employee_password = MD5('NewPassword123!'),
    employee_reset_password = 0,
    employee_last_password_change = NOW()
WHERE employee_id = <id>;
```

**Requirements enforced by the app** (from `password_reset_page.php`):
- Minimum 12 characters
- At least one digit
- At least one lowercase letter
- At least one uppercase letter

## Verifying Login Works

```bash
# Test login via curl
curl -s -c /tmp/crm_cookies.txt -X POST \
  http://localhost:8081/do.php?form=login \
  -d "login_email=<email>&login_password=<password>" \
  -o /dev/null -w "%{http_code}" -L

# Check if dashboard loads (should contain "dashboard" or "odjava")
curl -s -b /tmp/crm_cookies.txt http://localhost:8081/ | grep -c "dashboard\|odjava"
```

## Known Employee Accounts (from production dump)

| ID | Name | Email | Notes |
|---|---|---|---|
| 2 | Denis Selmanovic | denis@jobstep.ba | |
| 7 | Denis Selmanovic | ds.selmanovic@gmail.com | |
| 10 | Emina Pelak | e.pelak@jobstep.ba | |
| 20 | Denis Selmanovic | d.selmanovic@job-step.com | Has position data |

## PhpMyAdmin Access

- URL: `http://localhost:8080`
- Server: `mysql` (pre-filled)
- Username: `root`
- Password: from `docker-compose.local.yml` → `MYSQL_ROOT_PASSWORD`
