---
name: deorbit-kubesat
description: >-
  Mission Control for taking KubeSAT satellites out of active orbit — pause,
  resume, or permanently deorbit (delete). Use when the user wants to "pause",
  "stop", "resume", "deorbit", "delete", "take down", or "bring home" a
  kubesat. Pause/resume are reversible and cheap; deorbit is destructive and
  always requires explicit confirmation.
---

# Deorbit a KubeSAT

Three operations, increasing in severity:

- **Pause** — stop flying, keep everything. Reversible in one command.
- **Resume** — put a paused satellite back in orbit.
- **Deorbit** — permanently remove the satellite from the cluster.

Pick the lightest operation that meets the user's intent. If they say "stop"
or "turn it off," they almost always mean **pause**, not deorbit — confirm
which before doing anything destructive.

## Step 1 — Identify the satellite

```
kubectl get namespaces -l app.kubernetes.io/part-of=kubesat
```

The namespace is the satellite name (`kubesat-<repo>`); use it as `<ns>`.
If the user didn't name one and several are flying, list them and ask which.
Confirm the target satellite by name before any change.

## Pause (reversible)

Scale the dispatcher to zero — the flight computer sleeps, no new orbits
launch, and all state (PVC, mission, secrets, orbit log) stays intact. An
Actor Job already mid-orbit finishes on its own; only *new* orbits stop.

```
kubectl scale deployment/kubesat-dispatcher -n <ns> --replicas=0
```

Confirm it parked: `kubectl get pods -n <ns> -l app.kubernetes.io/component=dispatcher`
(no dispatcher pod). Tell the user it's paused and how to resume.

## Resume

```
kubectl scale deployment/kubesat-dispatcher -n <ns> --replicas=1
```

The dispatcher restarts its orbit counter at 1 (the counter is in-memory, not
persisted) — note this if the user is watching orbit numbers. The adapter's
delta log on the PVC survives, so an adapter-mode satellite won't reprocess
items it already handled.

## Deorbit (destructive — confirm first)

Deleting the namespace removes **everything** for that satellite: dispatcher,
any running actor, mission, config, secrets, RBAC, network policy, and the
orbit-state PVC (the adapter delta log goes with it).

**Before deleting:**

1. **Confirm explicitly.** State the satellite name and that this permanently
   removes it, and get a clear yes. Do not infer consent from "stop"/"pause"
   language.
2. **Check for in-flight work.** `kubectl get jobs -n <ns> -l app.kubernetes.io/component=actor`
   — if an actor is `active`, it's mid-orbit and may have an open branch/PR;
   mention it so the user isn't surprised when it's killed.
3. **Offer to preserve the loadout.** `~/.kubesat/<name>/` holds the mission,
   manifests, and config — everything needed to relaunch. It lives on the
   user's machine and is untouched by the delete, so a deorbited satellite can
   be brought back with `launch-kubesat`. Only mention removing it if the user
   wants a truly clean sweep (and never delete `launch.env` for them — it's
   theirs).

Then:

```
kubectl delete namespace <ns>
```

Confirm it's gone: `kubectl get namespace <ns>` should report NotFound.
Report what was removed and that the loadout under `~/.kubesat/<name>/`
remains for a future relaunch.
