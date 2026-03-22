# KubeSAT

**Kubernetes Survey-Act-Triage** — general-purpose containerized infrastructure for autonomous agent loops.

The name reflects the infrastructure (Kubernetes), the core loop (Survey, Act, Triage), and the metaphor — like CubeSats orbiting in space, KubeSAT agents float in the cluster, providing value on the ground.

---

## Vision

Launch autonomous agents into orbit to do... anything. A kube is bare metal you program — give it a mission, optionally load skills and adapters, and launch it. It monitors whatever you point it at, reasons about what it finds, and takes action.

One kube might monitor GitHub issues and ship code fixes. Another might watch a data feed and send alerts. Another might monitor a competitor's pricing page and update a spreadsheet. The platform doesn't care — it provides the infrastructure for the loop. You provide the mission.

---

## Architecture

### Dispatcher (K8s Deployment)

A non-agentic shell script that runs the orbital loop. No Claude, no tokens — just a timer that creates Jobs.

- **Without an adapter:** dispatches an Actor Job every orbit unconditionally. Claude handles all surveying.
- **With an adapter:** polls an external source via the adapter, detects deltas, and only dispatches when something changed. Saves tokens by not waking Claude when nothing's new.

### Actor (K8s Job)

An autonomous agent — this is where Claude enters the picture. Receives a mission and orbit context, then handles the full SAT loop:

1. **Survey** — fetch content from external sources, explore the codebase, gather context
2. **Triage** — evaluate what matters according to the mission
3. **Act** — implement changes, open PRs, send notifications, or whatever the mission requires

Each Actor is an isolated, ephemeral Job. Start, do the work, exit. Resources are freed for the next orbit.

### Adapters (Optional)

Shell scripts that teach the Dispatcher how to poll an external source. Each adapter implements a single function (`adapter_fetch_items`) that returns a list of items with change indicators. The Dispatcher compares these against its orbit log to detect deltas.

Built-in adapters:
- `github-issues` — polls open issues on a GitHub repository

Writing a new adapter is a single shell function.

---

## The Loadout

A kube is defined by its loadout:

| Component | Required? | What it is |
|-----------|-----------|------------|
| **Mission** | Yes | Natural language instructions (`mission.md`) — the only irreducible piece |
| **Adapter** | No | Pluggable source interface for delta detection |
| **Skills** | No | BYO skill repos cloned at build time |
| **Secrets** | Depends | API keys, tokens for whatever you connect it to |

---

## The Loop

```
    Source (adapter or direct)
            ↓
      ┌── Survey ←─────────────────────┐
      │    (gather & explore)          │
      │         ↓                      │
      │   Triage                       │
      │    (evaluate & prioritize)     │
      │         ↓                      │
      │   Act                          │
      │    (implement & deliver) ──────┘
      │         ↓
      └── Output (PRs, alerts, logs, etc.)
```

The three phases are unordered in practice — the mission determines the flow. Some missions survey then triage then act. Others triage first. The SAT loop is a vocabulary, not a prescription.

---

## One KubeSAT per concern

Each concern — a project, a repository, a data feed — gets its own **Kubernetes Namespace**. Standing up a new kube means:

1. Create a namespace
2. Populate its **Secrets** — API keys, tokens
3. Populate its **ConfigMaps** — target repo, orbit interval, adapter config
4. Mount a **mission.md**
5. Deploy the Dispatcher template

The infrastructure is shared across every instance. The namespace config makes each one specific. One kube can't see another kube's secrets, repos, or data.

Tearing down a kube is just deleting the namespace.

---

## Key Principles

- **Mission is the interface.** Natural language instructions define what the kube does. No DSL, no config schema — just tell it what to do.
- **Fail forward.** Lower environments are for iteration, not perfection. Ship, learn, ship again.
- **Isolation by default.** Every agent runs in its own container with strict resource limits and namespace isolation.
- **Humans decide what's ready.** The staging-to-production boundary is the quality gate, and it's a human decision.
- **Earn complexity.** Start simple. Add adapters when you need delta detection. Add skills when you need specialized capabilities. The simplest kube is just a mission.

---

## Dependencies

| Component            | Purpose                                                                 |
| -------------------- | ----------------------------------------------------------------------- |
| **Docker / Compose** | Container runtime and local orchestration                               |
| **Kubernetes**       | Cluster orchestration, scaling, isolation                               |
| **GitHub**           | Code hosting, PRs, issue tracking                                       |
| **Anthropic API**    | Agent intelligence (Claude)                                             |
| **Adapters**         | Optional: pluggable source polling (GitHub Issues, custom)              |
| **Skills**           | Optional: BYO skill repos for specialized agent capabilities            |
