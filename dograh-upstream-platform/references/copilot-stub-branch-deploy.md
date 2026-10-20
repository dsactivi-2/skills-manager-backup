# Named fork/branch remote OSS — inspect before build

When the user points at a GitHub tree (`owner/repo/tree/<branch>`) and says deploy that, do **not** treat the tree as bootable.

## Pre-build gate

On the checkout (or via `gh`/`raw.githubusercontent.com`) **before** `DEPLOY_MODE=build` / `remote_up.sh --build`:

```bash
wc -l api/services/configuration/registry.py \
      api/services/pipecat/service_factory.py
head -3 api/services/configuration/registry.py
```

If either file is the literal token `PLACEHOLDER` (often 11 bytes) or `git diff --stat origin/main...HEAD` shows ~1k–2k lines deleted from those two files, the branch is a Copilot stub. Building it yields:

```
File "/app/api/services/configuration/registry.py", line 1, in <module>
    PLACEHOLDER
NameError: name 'PLACEHOLDER' is not defined
```

alembic imports `registry` via `ai_model_configuration` — API exits 1, nginx/ui stay `Created`.

Seen on `dsactivi-2/dograhfork`: `copilot-settings`, `feature/deepgram-2-provider`. Working siblings: `main`, `copilot/add-fish-audio-provider-again`, `Guardian-Dograh` (different overlay path — `references/guardian-dograh-vps-deploy.md`).

## Recovery (keep the named checkout)

```bash
cd /root/dograh   # or whatever setup_remote cloned
git checkout origin/main -- \
  api/services/configuration/registry.py \
  api/services/configuration/check_validity.py \
  api/services/pipecat/service_factory.py
./remote_up.sh --build
```

Do not reset the whole branch if the user asked for that tree — restore only the gutted files, then rebuild.

## Non-interactive `setup_remote.sh`

The script does **not** install Docker (docs: prerequisite). Official Ubuntu apt repo first.

It does **not** skip prompts when stdin is not a TTY. `TURN_SECRET` unset → `read -sp` hangs under `nohup` too. Preset every prompt-backed var:

```bash
SERVER_IP=<public-v4> \
DEPLOY_MODE=build \
REPO_SOURCE=clone \
FORK_REPO=dsactivi-2/dograhfork \
BRANCH=<branch> \
FASTAPI_WORKERS=4 \
CERT_MODE=auto \
TURN_SECRET="$(openssl rand -hex 32)" \
./setup_remote.sh
```

If setup dies after compose is up but before Let's Encrypt, do not re-run setup (it refuses existing `.env`). Source `scripts/lib/setup_common.sh` and call `dograh_install_certbot` + `dograh_issue_letsencrypt_webroot` + `dograh_install_cert_renewal_hook`, then `docker compose --profile remote restart nginx`.

Live check: `curl -sS https://<ip-dashed>.sslip.io/api/v1/health` → `status=ok` without `-k` once LE is in. UI `307` to `/auth/login` is live.
