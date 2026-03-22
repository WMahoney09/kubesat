# KubeSAT :construction: work-in-progress :construction:

```
░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓█████████████       *     ·
░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓████████████    ·         *
░░░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓▓███████████    *         ·
░░░░░░░░░░▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▓▓█████████      ·       *        ·
░░░░░░░░▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓███████       *            ·
░░░░░░▒▒▒▒▒▒▓▓▓▓▓██████              ·         *

   *     ·       ┌──────────┐ ╔══╗ ┌──────────┐         *
       ·         │▒▒▒▒▒▒▒▒▒▒├─╢██╟─┤▒▒▒▒▒▒▒▒▒▒│  ·          *
  ·          *   └──────────┘ ╚══╝ └──────────┘      ·

   ██╗  ██╗██╗   ██╗██████╗ ███████╗   ███████╗ █████╗ ████████╗
   ██║ ██╔╝██║   ██║██╔══██╗██╔════╝   ██╔════╝██╔══██╗╚══██╔══╝
   █████╔╝ ██║   ██║██████╔╝█████╗     ███████╗███████║   ██║
   ██╔═██╗ ██║   ██║██╔══██╗██╔══╝   · ╚════██║██╔══██║   ██║
   ██║  ██╗╚██████╔╝██████╔╝███████╗   ███████║██║  ██║   ██║
   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝   ╚══════╝╚═╝  ╚═╝   ╚═╝

              Kubernetes · Satellite Agent Teams

        *         ·              ·            *          ·
   ·          *          ·    *          ·         *
              ·       *              ·          *       ·
```

> _Autonomous Agents in Space!_

General-purpose containerized infrastructure for deploying autonomous agent teams on Kubernetes. Give each satellite a mission, optionally load skills and adapters, and launch it into orbit.

---

## The Name

**Kube** — the infrastructure backbone. Kubernetes provides the isolation, scheduling, and orchestration. Each satellite gets its own namespace — same templates, different config.

**SAT — Satellite Agent Teams** — autonomous agents that orbit your systems. Like CubeSats in space, each one is small, self-contained, and purpose-built. They survey, act, and report back on their own cycles. Deploy a constellation of them to cover different concerns, or launch a single satellite for a focused mission.

---

## The Orbit

At the heart of KubeSAT is The Orbit — a polling interval. Every orbit, the satellite's dispatcher spins up a Kubernetes Job with a fresh Claude session to fulfill its mission, either as a single agent or a coordinated team. Do the work, report back, sleep, repeat. The Orbit is a loop.

What you point it at is up to you:

- **Issue Responder** — monitor GitHub issues, implement fixes, and open PRs before your morning coffee
- **Requirements Analyst** — watch product requirement documents, break them down into actionable stories
- **Dependency Sentinel** — scan your repos for outdated or vulnerable dependencies and ship upgrade PRs
- **Surf Report** — check the local surf forecast every morning and text me when it's super clean with a really stoked message

---

## The Loadout

A kube is defined by what you load onto it:

| Component   | Required? | What it is                                      |
| ----------- | --------- | ----------------------------------------------- |
| **Mission** | Yes       | Natural language instructions (`mission.md`)    |
| **Adapter** | No        | Pluggable source polling for delta detection    |
| **Skills**  | No        | BYO skill repos for specialized capabilities    |
| **Secrets** | Depends   | API keys, tokens for whatever you connect it to |

The simplest kube is just a mission. Claude's built-in capabilities handle the rest.

---

## Getting Started

**1. Configure your environment**

```bash
cp .env.example .env
```

Fill in `ANTHROPIC_API_KEY`, `GITHUB_TOKEN`, and `TARGET_REPO`.

**2. Suborbital — launch a single actor**

```bash
docker compose --profile actor run --rm actor
```

One shot. Runs a single Actor — a fresh Claude session that reads your `mission.md` and executes it against the target repo. The container exits when the work is done. Good for validating your mission before committing to orbit.

**3. Workspace — enter the cockpit**

```bash
docker compose up
```

Starts the Dispatcher in workspace mode — engines on, nothing launched. You have manual control via `docker exec`:

```bash
docker exec -it kubesat-dispatcher-1 claude -p "your prompt here"
```

Same satellite, same loadout, but you're flying it by hand.

**4. Orbit — launch into autonomous operation**

Orbit requires Kubernetes. Deploy the k8s manifests to a local cluster (minikube, kind) or a hosted cluster (EKS). The Dispatcher loops on the orbital interval and dispatches Actor Jobs automatically.
