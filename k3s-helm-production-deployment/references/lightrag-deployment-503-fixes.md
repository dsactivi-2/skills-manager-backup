# LightRAG Deployment 503 Fixes (June 16 2026 session)

## Observed Failures
- 404 nginx: wrong ingress.className ("traefik" on nginx-only cluster)
- 503 Service Temporarily Unavailable: Pods in CrashLoopBackOff or not Ready
- ParserRoutingConfigError: `LIGHTRAG_PARSER: "*:mineru-iteP,*:docling-iteP,*:native-iteP"` without MINERU_LOCAL_ENDPOINT / DOCLING_ENDPOINT
- Helm `pending-upgrade`: stuck release secret
- Terminal timeout on `--wait --timeout 10m`

## Fixes Applied
1. Namespace correction: delete `perfekt`, create `lightrag`, update deploy script (NAMESPACE="lightrag", secret="lightrag-secrets", release="lightrag")
2. Ingress class: `className: "nginx"` (verified with `kubectl get ingressclass -A`)
3. Parser: change to `LIGHTRAG_PARSER: "*:native-iteP"`
4. Stuck Helm: `kubectl delete secret sh.helm.release.v1.lightrag.v2 -n lightrag`
5. Manual Ingress fallback:
   ```bash
   kubectl create ingress lightrag --class=nginx --rule="lightrag.activi.io/=lightrag:9621" -n lightrag
   ```
6. SSH alias: `ssh k3-1` (from ~/.ssh/config) instead of raw IP
7. Test command: `curl -I -H "Host: lightrag.activi.io" <node-ip>`

## Updated deploy-lightrag-prod.sh pattern
Use absolute paths, project-specific namespace, nginx class, native parser only, no long --wait in foreground.

Add this file to SKILL.md references section. This pattern now applies to all future LightRAG/k3s deploys on this cluster.