# Hetzner dedicated labels (Hermes box)

| Tag | Meaning | Hermes |
|---|---|---|
| **INIC** | Intel NIC, often 10 Gbit extra | Overkill; 1 Gbit I210 is enough |
| **ECC** | RAM that corrects bit flips | Good if little extra cost |
| **NVMe** | Fast PCIe SSD | Good to have; vs SATA SSD the daily chat difference is small |

CPU: sweet **8-core Ryzen 7**. i7-7700 = 4c/2017, auction test only. EPYC/16-core = overkill for chat+gateway.

Do not assign Hermes-only by wiping **Kube3-1/2/3** (existing k3s HA). Prefer myhermi or a fourth box.
