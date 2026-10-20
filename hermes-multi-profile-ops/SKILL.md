---
name: hermes-multi-profile-ops
description: Use when sizing or running several Hermes work profiles.
version: "1.0.0"
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [hermes, profiles, orchestrator, dedicated, hetzner]
    related_skills: [hermes-profile-capability-audit, hermes-profile-soul-agents, cluster-orchestrator]
---

# Hermes multi-profile ops

## When to Use

Building or running a **work team** of Hermes profiles for one plan (research, code, docs, review, dev-op). Not a 10-agent swarm. Not installing Hermes on the production k3s HA trio.

## Who orchestrates

**Hermes main (`default`) = Orchestrator + Planner.** The human is not the orchestrator. Human only: Freigabe, keys, deploy yes, Identify apply.

Do **not** rebuild `default` when “alle Bots neu außer dir”.

## Install shape

| | |
|---|---|
| **Do** | One Hermes install, many **profiles** |
| **Don’t** | Seven root installs, seven VMs, seven pods on **Kube3-1/2/3** |
| Kube3 | Existing **k3s control-plane HA** — do not wipe a node for Hermes |
| Docker | Optional one compose; not required |
| Hot processes | Orchestrator always; **1–2** workers working; rest idle/off |

## Team list hygiene

- One table. Do not drop Code/Review/Docs/dev-op by renaming.
- Code = Prompt+Test = Implement (one seat).
- MCP/Skill/Plugin is **Spur 2**, not wave-1 Amina code.
- SOUL drafts first (`hermes-profile-soul-agents`); apply per bot after Freigabe.

## Hardware (Hermes box, not LiveKit Cloud)

Sweet: **8-core Ryzen 7**, **32–64 GB** RAM, **NVMe**, ECC if cheap. **1 Gbit NIC enough** (INIC 10G overkill). i7-7700 (4c/2017) = test only. SSD→NVMe is a small jump vs HDD→SSD.

See `references/hetzner-dedicated-labels.md`.
