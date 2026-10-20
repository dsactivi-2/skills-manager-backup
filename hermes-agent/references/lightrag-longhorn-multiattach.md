# LightRAG + Longhorn Multi-Attach Debugging

## Problem
Pod stays `Pending` / `ContainerCreating` with events:
```
Warning  FailedAttachVolume  Multi-Attach error for volume "pvc-..." 
Volume is already exclusively attached to one node and can't be attached to another
```

## Root Cause
Longhorn RWX PVCs are attached to one node (k3s default behavior for some workloads). When scheduler places pod on different node (`activi-k3-3`), attach fails.

## Fix Pattern (Dry-Run first)
1. Check current attachments: `kubectl get volumeattachments -o wide`
2. Check Longhorn volume: `kubectl get lhvolume -n longhorn-system`
3. Force re-attach or add Pod Anti-Affinity to keep pod on same node as volume.
4. StorageClass must have `ReadWriteMany` + correct `fsType` + `numberOfReplicas: 3`.
5. Alternative: Use `volumeMode: Block` or dedicated node selector for stateful workloads.

## Verification
- `kubectl get pods -n lightrag -w`
- `kubectl describe pod ... | grep -A 20 Events`
- Longhorn UI → Volumes → Attachment tab

Add to agent.json or deployment YAML:
```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app.kubernetes.io/name
          operator: In
          values: [lightrag]
      topologyKey: "kubernetes.io/hostname"
```

Never delete PVCs without backup. Always test with `kubectl apply --dry-run=server`.
