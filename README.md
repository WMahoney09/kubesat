# KubeSAT

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
| **Agents** | No        | BYO agent definitions for specialized workflows  |
| **Skills**  | No        | BYO skill repos for specialized capabilities    |
| **Secrets** | Depends   | API keys, tokens for whatever you connect it to |

The simplest kube is just a mission. Claude's built-in capabilities handle the rest.

_**A KubeSAT is only as good as it's loadout, for evolving a loadout that you trust, checkout [Sandbox Derby](https://github.com/WMahoney09/sandbox-derby/blob/main/README.md#sandbox-derby)**_

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

Orbit requires Kubernetes. You can use Docker Desktop's built-in K8s (Settings > Kubernetes > Enable) or stand up a cluster with minikube or kind.

**Prep the launchpad:**

```bash
# Create the namespace
kubectl apply -f k8s/namespace.yml

# Load secrets (comment out non-secret vars in .env first, then restore after)
kubectl create secret generic kubesat-secrets \
  --namespace=kubesat-dev \
  --from-env-file=.env

# Apply the config (edit k8s/configmap.yml with your TARGET_REPO and ORBIT_INTERVAL first)
kubectl apply -f k8s/configmap.yml

# Load your mission
kubectl create configmap kubesat-mission \
  --namespace=kubesat-dev \
  --from-file=mission.md=mission.md

# Apply RBAC, storage, quotas, and network policy
kubectl apply -f k8s/rbac.yml
kubectl apply -f k8s/orbit-pvc.yml
kubectl apply -f k8s/resource-quota.yml
kubectl apply -f k8s/network-policy.yml

# Build the image
docker build -t kubesat:latest .
```

**Launch:**

```bash
kubectl apply -f k8s/dispatcher-deployment.yml
```

The Dispatcher enters its orbital loop and dispatches Actor Jobs on the configured interval.

**Monitor:**

```bash
kubectl get pods -n kubesat-dev
kubectl logs -f -n kubesat-dev <dispatcher-pod-name>
```

**Retask — change the mission mid-flight:**

```bash
kubectl create configmap kubesat-mission \
  --namespace=kubesat-dev \
  --from-file=mission.md=mission.md \
  --dry-run=client -o yaml | kubectl apply -f -
```

The new mission takes effect on the next orbit — no restart needed. The mission is mounted as a volume, so the next Actor Job picks up the updated ConfigMap automatically.

**Re-entry:**

```bash
kubectl delete -f k8s/dispatcher-deployment.yml
```
