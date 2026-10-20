# LightRAG Postgres Connection & Chart PVC Quirks (Session 2026-06-17)

## Observed Errors
- `socket.gaierror: [Errno -2] Name or service not known`
- Repeated WARNING: PostgreSQL transient connection issue on attempt 1/10... (retries for postgres-perfekt, neo4j-perfekt, qdrant)
- PVCs remained RWO (`accessModes: - ReadWriteOnce`) despite values specifying ReadWriteMany and Longhorn.
- PVCs stuck in `Terminating` after delete → finalizers still present.
- Relative chart path `../../k8s-deploy/lightrag` failed from `deploy/k3s/perfekt/`.

## Root Causes & Fixes Applied
1. **DB Service Names**: Namespace change from "perfekt" to "lightrag" was not fully propagated. Old names (`postgres-perfekt`, `neo4j-perfekt`) remained in values.env.
   - Fix: Set `POSTGRES_HOST: "postgres.lightrag.svc.cluster.local"` (or exact internal service name). Same for NEO4J_URI and other cross-service references.
   - Lesson: After namespace rename, grep all values/*.yaml and env files for old service suffixes.

2. **Chart PVC Behavior**: The lightrag chart has dedicated templates (`templates/pvc.yaml` for lightrag-inputs and lightrag-rag-storage). Top-level `persistence.accessModes` is partially ignored.
   - Fix: Use sub-keys in values:
     ```yaml
     persistence:
       ragStorage:
         storageClassName: "longhorn"
         accessMode: ReadWriteMany
         size: 10Gi
       inputs:
         storageClassName: "longhorn"
         accessMode: ReadWriteMany
         size: 5Gi
     ```
   - Or patch the chart's pvc.yaml templates directly.

3. **Terminating PVCs on Longhorn**:
   ```bash
   kubectl patch pvc lightrag-inputs lightrag-rag-storage -n lightrag -p '{"metadata":{"finalizers":null}}'
   ```
   Run after delete before new Helm install. This was required twice in this session.

4. **Deploy Script Hygiene**:
   - Use absolute paths for CHART_PATH and VALUES_PATH.
   - Always include `--dry-run=client` in the secret creation and initial Helm command.
   - Rename deploy-perfekt-prod.sh → deploy-lightrag-prod.sh when namespace stabilizes.
   - Add explicit `--wait=false` to avoid timeout loops on slow DB init.

## Dry-Run Sequence Used This Session (embed in future deploys)
1. Helm secret delete (with --dry-run=client -o name)
2. PVC delete (with --dry-run=client -o name)
3. Finalizer patch (show command, get explicit "ja")
4. Helm upgrade with --dry-run=client --debug (full manifest review)
5. Only then real `helm upgrade --install` without dry-run.

## Verification Checklist
- `kubectl get pvc -n lightrag -o wide` → must show ReadWriteMany + Bound + longhorn
- `kubectl logs -n lightrag deploy/lightrag --tail=30` → no gaierror, "Started server process", successful PostgreSQL connection
- `curl -I -H "Host: lightrag.activi.io" <ingress-ip>` → 200 OK (no 503)

This file captures the exact failure modes and command sequence from the 2026-06-17 session where Longhorn migration was completed but DB resolution and chart PVC quirks surfaced. Add to SKILL.md references section.