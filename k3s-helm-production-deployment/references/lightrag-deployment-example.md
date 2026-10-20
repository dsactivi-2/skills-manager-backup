# LightRAG Production Deployment Example (Perfekt!)

## values.perfekt.prod.yaml (key excerpts)
```yaml
replicaCount: 2
image:
  repository: ghcr.io/hkuds/lightrag
  tag: latest
ingress:
  enabled: true
  className: "traefik"
  hosts:
    - host: lightrag.activi.io
env:
  DEFAULT_QUERY_MODE: "mix"
  ENABLE_LLM_RERANKER: "true"
  KV_STORAGE: "PG"
  VECTOR_STORAGE: "PG"
  GRAPH_STORAGE: "NEO4J"
  DOC_STATUS_STORAGE: "PG"
  MAX_ASYNC_LLM: "8"
  VLM_PROCESS_ENABLE: "true"
  LIGHTRAG_PARSER: "*:mineru-iteP,*:docling-iteP,*:native-iteP"
resources:
  limits:
    cpu: "4"
    memory: "8Gi"
nodeSelector:
  kubernetes.io/hostname: "hetzner-89-167-102-241"
persistence:
  enabled: true
  storageClassName: "local-path"
  size: 200Gi
existingSecret: "lightrag-perfekt-secrets"
monitoring:
  enabled: true
```

## deploy-perfekt-prod.sh
```bash
#!/bin/bash
set -e
NAMESPACE="perfekt"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
kubectl create secret generic lightrag-perfekt-secrets \
  --from-env-file="./secrets.env" -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install perfekt ../../k8s-deploy/lightrag \
  --namespace $NAMESPACE -f values.perfekt.prod.yaml --wait --timeout 10m
kubectl get pods,svc,ingress -n $NAMESPACE
```

## SSH + SCP Pattern (when user says "mach du es")
1. `ssh-add ~/.ssh/dokploy` (or correct key from Termius)
2. `scp {deploy-*.sh,values.*.prod.yaml,secrets.env} root@88.99.215.210:/root/perfekt/`
3. `ssh root@88.99.215.210 "cd /root/perfekt && chmod +x *.sh && ./deploy-perfekt-prod.sh"`

**Pitfall**: ssh-add does not persist across sessions. Always check with `ssh-add -l` before scp/ssh. IP 88.99.215.210 maps to hostname "hetzner-89-167-102-241". Use exact nodeSelector.

This pattern was validated in June 2026 LightRAG rollout for 100k+ document corpus with mix-mode + reranker.