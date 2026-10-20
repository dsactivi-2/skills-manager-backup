# Hetzner Cloud Rescue — SSH key injection reference

Exact command set for the procedure in SKILL.md. All calls use `Authorization: Bearer $TOKEN`.

## 1. Verify token + locate server
```bash
curl -s -H "Authorization: Bearer $TOKEN" https://api.hetzner.cloud/v1/servers \
  | python3 -c "import sys,json;d=json.load(sys.stdin);[print(s['id'],s['name'],s['public_net']['ipv4']['ip'],s['status']) for s in d['servers']]"
```
Match the public IPv4 to the target. Note the server `id`.

## 2. Register the local public key
```bash
PUB=$(cat ~/.ssh/id_ed25519_vps_2_28_111_167.pub)
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "{\"name\":\"idk2-hermes\",\"public_key\":\"$PUB\"}" https://api.hetzner.cloud/v1/ssh_keys
# -> note the returned "id" (key id) and "fingerprint"
```

## 3. Enable rescue (omit `type`)
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "{\"ssh_keys\":[<KEYID>]}" https://api.hetzner.cloud/v1/servers/<SERVERID>/actions/enable_rescue
# -> returns action (status running) + root_password (informational)
```

## 4. Power cycle into rescue
```bash
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"type":"poweroff"}' https://api.hetzner.cloud/v1/servers/<SERVERID>/actions/reset
# poll GET /servers/<SERVERID> until status == "off"
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"type":"poweron"}' https://api.hetzner.cloud/v1/servers/<SERVERID>/actions/reset
```

## 5. Connect to rescue with the registered key
```bash
ssh -i ~/.ssh/id_ed25519_vps_2_28_111_167 -o IdentitiesOnly=yes -o IdentityAgent=none \
  -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null root@<IP>
```

## 6. Mount OS disk + append key (run on the rescue shell)
```bash
for d in /dev/sda*; do mount "$d" /mnt 2>/dev/null && [ -d /mnt/root ] && break; umount /mnt 2>/dev/null; done
mkdir -p /mnt/root/.ssh
grep -qxF "$(cat ~/.ssh/id_ed25519_vps_2_28_111_167.pub)" /mnt/root/.ssh/authorized_keys 2>/dev/null \
  || cat ~/.ssh/id_ed25519_vps_2_28_111_167.pub >> /mnt/root/.ssh/authorized_keys
chmod 700 /mnt/root/.ssh; chmod 600 /mnt/root/.ssh/authorized_keys
umount /mnt; reboot
```

## 7. Reboot to normal + verify
```bash
# rescue consumes itself; after reboot ssh <alias> works with key auth
ssh -o BatchMode=yes <alias> 'whoami; hostname'
```

## Reusable injection script (scripts/inject_ssh_key_via_rescue.py)

Parameterized, stdlib-only. Run: `HETZNER_TOKEN=... python3 inject_ssh_key_via_rescue.py --server <id> --key ~/.ssh/id_ed25519`

```python
#!/usr/bin/env python3
import os, sys, time, socket, base64, subprocess, argparse, json, urllib.request, urllib.error
API = 'https://api.hetzner.cloud/v1'

def api(token, method, path, data=None, tries=5):
    req = urllib.request.Request(API+path, data=(json.dumps(data).encode() if data is not None else None), method=method)
    req.add_header('Authorization', 'Bearer '+token)
    req.add_header('Content-Type', 'application/json')
    for _ in range(tries):
        try:
            with urllib.request.urlopen(req) as r:
                return json.load(r), r.status
        except urllib.error.HTTPError as e:
            if e.code == 423:
                time.sleep(5); continue
            raise
    raise SystemExit('action locked')

def status(token, sid):
    return api(token,'GET',f'/servers/{sid}')['server']['status']

def wait_off(token, sid):
    for _ in range(40):
        if status(token, sid) == 'off':
            return True
        time.sleep(3)
    return False

def wait_port(ip, n=50):
    for _ in range(n):
        s = socket.socket(); s.settimeout(2)
        try:
            s.connect((ip, 22)); s.close(); return True
        except Exception:
            s.close()
        time.sleep(5)
    return False

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--server', required=True); ap.add_argument('--key', required=True)
    ap.add_argument('--ip', help='target IP (defaults to server public ipv4)')
    args = ap.parse_args()
    token = os.environ['HETZNER_TOKEN']
    key = os.path.expanduser(args.key); pub = open(key+'.pub').read().strip()
    sid = args.server
    r,_ = api(token,'POST','/ssh_keys',{'name':'hermes-rescue','public_key':pub})
    kid = r['ssh_key']['id']
    api(token,'POST',f'/servers/{sid}/actions/enable_rescue',{'ssh_keys':[kid]})
    api(token,'POST',f'/servers/{sid}/actions/reset',{'type':'poweroff'}); wait_off(token, sid)
    api(token,'POST',f'/servers/{sid}/actions/reset',{'type':'poweron'})
    ip = args.ip or api(token,'GET',f'/servers/{sid}')['server']['public_net']['ipv4']['ip']
    assert wait_port(ip), 'port 22 never opened'
    rem = f"""set -e
for d in $(ls /dev/sda* 2>/dev/null); do mkdir -p /mnt; if mount "$d" /mnt 2>/dev/null; then [ -d /mnt/root ] && break; umount /mnt 2>/dev/null || true; fi; done
mkdir -p /mnt/root/.ssh
grep -qxF '{pub}' /mnt/root/.ssh/authorized_keys 2>/dev/null || echo '{pub}' >> /mnt/root/.ssh/authorized_keys
chmod 700 /mnt/root/.ssh; chmod 600 /mnt/root/.ssh/authorized_keys; umount /mnt 2>/dev/null || true
echo KEY_ADDED_OK
"""
    b64 = base64.b64encode(rem.encode()).decode()
    cmd = f"ssh -i {key} -o IdentitiesOnly=yes -o IdentityAgent=none -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null -o ConnectTimeout=20 root@{ip} 'echo {b64} | base64 -d | bash'"
    out = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=120)
    if 'KEY_ADDED_OK' not in out.stdout:
        raise SystemExit('rescue shell failed: '+out.stderr[:300])
    api(token,'POST',f'/servers/{sid}/actions/reset',{'type':'reboot'})
    print('Key injected; server rebooting to normal OS. Verify: ssh -o BatchMode=yes root@'+ip+' whoami')

if __name__ == '__main__':
    main()
```
