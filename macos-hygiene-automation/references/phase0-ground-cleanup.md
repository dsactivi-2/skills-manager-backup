# Phase 0 — Ground Complete Cleanup

Run **once** before enabling hygiene crons so monitoring baselines a clean machine.

## Order
1. **Save** open editors/docs (BBEdit, TextEdit, markdown, PDF markups).
2. **Browser:** close excess *loaded* tabs (tab groups may stay); quit extra browsers — one main browser.
3. **Idle AI:** quit Codex/Claude/Gemini/Ollama/LM Studio/llama-server if unused.
4. **Hermes:** keep one work session; end old CLI sessions via Ctrl+C or Activity Monitor on **hermes parent**; leave gateway if messaging/cron needed.
5. **Autostart skim:** System Settings → General → Login Items & Extensions.
6. **Optional CleanMyMac:** only familiar safe maintenance — no system-file experiments.
7. **Reboot** (real swap clear).
8. **Baseline after ~10 min:** `vm.swapusage`, count `hermes` parents, count Hivemind `server.js`, short note "Tag 0".

## Done when
- [ ] Docs saved
- [ ] Reboot done
- [ ] Swap low again
- [ ] Hermes load intentional
- [ ] Baseline numbers written to `~/Logs/mac-hygiene/logs/baseline-YYYY-MM-DD.md`
