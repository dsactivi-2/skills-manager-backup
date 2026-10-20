---
name: implement
description: "Implement a piece of work based on a spec or set of tickets."
disable-model-invocation: true
---

Implement the work described by the user in the spec or tickets.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

Commit only when the session is bound to an existing git repo and the user did not choose work-without-project. Never `gh repo create` or push because a spec names `owner/repo` — `gh repo view` first; missing remote stays local until Freigabe.

Probe the spec port with `lsof -nP -iTCP:<port> -sTCP:LISTEN` before binding or telling the UI the URL. Port 8000 on this Mac is often OrbStack/dograh; pick a free PORT and report the live URL, do not claim localhost:8000 if connect_ex succeeds for another process.
