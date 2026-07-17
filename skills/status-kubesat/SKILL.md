---
name: status-kubesat
description: >-
  Mission Control status board for KubeSAT satellites already in orbit. Use
  when the user wants to "check on", "get status of", "see the orbits of", or
  "is my kubesat still flying" — for one satellite or the whole constellation.
  Reports dispatcher health, recent orbit history, the active mission, orbital
  period, fuel type, and whether a satellite is paused. Read-only: never
  launches, retasks, or deorbits.
---

# KubeSAT Status

Report the health and recent activity of satellites already in orbit. This
skill is **read-only** — it inspects, it never changes a satellite. For
changes see `launch-kubesat` (launch/retask) and `deorbit-kubesat`
(pause/resume/deorbit).

## Step 1 — Find the satellites

Every KubeSAT namespace carries `app.kubernetes.io/part-of=kubesat`:

```
kubectl get namespaces -l app.kubernetes.io/part-of=kubesat
```

- **No namespaces** — nothing is flying. Mention `~/.kubesat/` may still hold
  loadouts for satellites that were deorbited (they can be relaunched); list
  it if the user is looking for one.
- **The user named a satellite** — scope to that namespace.
- **One namespace** — report on it.
- **Several** — give a one-line-per-satellite constellation summary first
  (Step 3), then offer to drill into any one.

The namespace *is* the satellite name (`kubesat-<repo>`). Use it as `<ns>`
below.

## Step 2 — Gather (one satellite)

Read-only kubectl, one command per step:

- **Dispatcher pod** — is the flight computer up?
  `kubectl get pods -n <ns> -l app.kubernetes.io/component=dispatcher`
  - `Running` → flying. `0/1` replicas or no pod → **paused** (see deorbit).
    `CrashLoopBackOff` / `Error` → surface the last logs.
- **Dispatcher log tail** — mode and current orbit number:
  `kubectl logs -n <ns> deployment/kubesat-dispatcher --tail=20`
  - A healthy dispatcher logs its mode (`no adapter` / `adapter: …`), the
    orbit interval, and `[orbit N] Starting…` lines.
- **Orbit history** — Actor Jobs (TTL keeps ~1 day):
  `kubectl get jobs -n <ns> -l app.kubernetes.io/component=actor`
  - `COMPLETIONS 1/1` = a clean orbit; `0/1` with age past
    `activeDeadlineSeconds` = an actor that failed or timed out.
- **What the latest actor did** — logs of the most recent job:
  `kubectl logs -n <ns> job/<job-name> --tail=40`
- **Active mission** — what it's flying right now:
  `kubectl get configmap kubesat-mission -n <ns> -o jsonpath='{.data.mission\.md}'`
- **Orbital period** — `kubectl get configmap kubesat-config -n <ns> -o jsonpath='{.data.ORBIT_INTERVAL}'` (seconds).
- **Fuel type** — which fuel key is loaded, **without reading its value**.
  `kubectl describe secret kubesat-secrets -n <ns>` lists key *names* and byte
  counts only. `ANTHROPIC_API_KEY` present → API billing;
  `CLAUDE_CODE_OAUTH_TOKEN` present → subscription billing. Never
  `kubectl get secret -o yaml`/`-o jsonpath='{.data...}'` — that base64-dumps
  the secret value into the conversation.

## Step 3 — Report

For a single satellite, a compact readout:

```
🛰  kubesat-acme  —  FLYING (orbit 42, no adapter)
    repo      github.com/acme/acme
    period    600s (10 min)
    fuel      subscription (CLAUDE_CODE_OAUTH_TOKEN)
    mission   PR review — skips PRs already tagged <!-- kubesat-reviewed -->
    orbits    last 3: ✅ ✅ ✅   (latest 4m ago)
```

For a constellation, one line each — name, state, orbit number, last-orbit
result — then offer to drill in.

Call out anything off explicitly: paused, crash-looping dispatcher, a run of
failed orbits, an actor that's been active longer than the orbit interval
(possible stuck orbit — the overlap guard will skip the next orbit while it
runs). Don't prescribe fixes unless asked; point at `deorbit-kubesat` for
pause/resume and `launch-kubesat` for retask.
