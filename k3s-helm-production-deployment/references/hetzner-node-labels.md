# Hetzner Node Labeling for k3s

## Recommended Labels
When setting up the k3s node, apply a stable hostname label:

```bash
kubectl label node <node-name> \
  kubernetes.io/hostname=hetzner-88-99-215-210
```

## Usage in values.yaml
```yaml
nodeSelector:
  kubernetes.io/hostname: "hetzner-88-99-215-210"
```

This ensures workloads land on the intended physical server when multiple Hetzner VPS are in the cluster.

Established during Perfekt! LightRAG deployment on 88.99.215.210.