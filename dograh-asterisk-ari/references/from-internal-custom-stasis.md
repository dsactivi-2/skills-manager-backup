# from-internal-custom → Guarddograh Stasis

Ext-local for a TG-registered ext (`Gosub(macro-exten-vm…)`) **rings the gateway**. Guarddograh inbound needs Stasis first.

`from-internal-xfer` includes `from-internal-custom` before generated extras. In `extensions_custom.conf` only:

```
[from-internal-custom]
exten => 310,1,NoOp(Guarddograh ext 310 to stasis)
 same => n,Goto(from-guarddograh-stasis,${EXTEN},1)
```

Then `dialplan reload`. Do not edit `extensions_additional.conf`. Do not reuse Custom Dest `dest-1` (`stasis-dograh` / old `dograh` app).

# Ext exists before TG Secret

`fetchAllExtensions` + `pjsip show endpoint N`. A TG-typed number with no FreePBX row (e.g. 330) has no password — do not invent one.

GUI: `https://ari.activi.io/admin/config.php?display=extensions&extdisplay=<EXT>`

# TG form ≠ ARI

Yeastar Register Trunk → `ari.activi.io:5060`, User/Auth = FreePBX ext, Secret from that GUI. Never `guarddograh.activi.io`, never `:8088`, never ARI user `guarddograh`.

310 can be both TG Register and Dograh From. 300 remains the old `tg400` identity unless the user retires it.
