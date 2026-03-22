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

**2. Run a single actor (simplest test)**

```bash
docker compose run --rm actor
```

Builds the image and runs one Actor — a single Claude session that reads your `mission.md` and executes it against the target repo. Good for validating your mission works before running the full loop.

**3. Run the dispatcher (full orbital loop)**

```bash
docker compose up dispatcher
```

Starts the Dispatcher, which dispatches an Actor every `ORBIT_INTERVAL` seconds (default 600 = 10 minutes). If you've configured an adapter, it only dispatches when deltas are detected.
