# Longhorn PVC Multi-Attach & Readiness Probe Fixes (LightRAG June 2026)

## Problem
- replicaCount: 2 + RWO PVCs → Multi-Attach error ("Volume is already used by pod(s) ...")
- Readiness probe on :9621/health → "connection refused" (342x) → Back-off restarting (63x)
- 503 from nginx Ingress (no healthy backend)

## Root Cause
- Longhorn default is RWO for many claims.
- LightRAG app does not immediately listen on 9621 (parser config, DB init, VLM, embedding binding).
- values.yaml had `className: "traefik"` but cluster only has `nginx` IngressClass.

## Fixed Pattern (embed in every deploy-*.sh and values.*.prod.yaml)

```yaml
persistence:
  enabled: true
  storageClassName: "longhorn"          # mandatory
  accessModes: ["ReadWriteMany"]        # critical for replica > 1
  size: 200Gi
replicaCount: 1                         # safest for RAG until StatefulSet
ingress:
  enabled: true
  className: "nginx"                    # cluster default
  hosts:
    - host: lightrag.activi.io
tls:
  - hosts: [lightrag.activi.io]
    secretName: lightrag-tls
annotations:
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
env:
  LIGHTRAG_PARSER: "*:native-iteP"      # avoid mineru/docling without endpoints
```

## Readiness Probe Workaround
Add to values or Deployment:
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 9621
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 20   # higher tolerance during startup
```

## SSH Alias Discipline
Always use `ssh k3-1` (defined in ~/.ssh/config). Never raw IP.

## Execution Style (User Preference)
- German only.
- Zero pleasantries or explanations unless explicitly asked.
- Tool-first: Run command immediately when user says "mach du es".
- Never "I will...", never restate plan after approval.
- Just execute + show real output.

## Verification Command
```bash
ssh k3-1 "kubectl get pods,ingress,pvc -n lightrag -o wide && kubectl logs -n lightrag -l app.kubernetes.io/name=lightrag --tail=30 | tail -10"
```

This pattern eliminated the 503/404 after June 16 2026 fixes (namespace=lightrag, Longhorn RWX, nginx class, manual Ingress fallback, parser=native-iteP, cert-manager TLS).
