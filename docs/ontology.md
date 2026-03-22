# KubeSAT Ontology

Shared vocabulary for the KubeSAT project. Canonical definitions — use these terms consistently across docs, code, config, and conversation.

---

## Core Concepts

### Kube
A running KubeSAT instance. General-purpose containerized infrastructure for an autonomous agent loop. A kube is bare metal you program — give it a mission, optionally load skills and adapters, and launch it into orbit.

### SAT
Satellite Agent Teams. Autonomous agents that orbit your systems. Like CubeSats in space, each one is small, self-contained, and purpose-built. They survey, act, and report back on their own cycles. Deploy a constellation of them to cover different concerns, or launch a single satellite for a focused mission.

### Mission
A natural language document (`mission.md`) that defines what a kube does. The only irreducible piece of a kube's loadout. Mounted at runtime, not baked into the image. The mission guides the agent's reasoning — it's the "why" behind every decision the agent makes during an orbit.

### Adapter
An optional shell script that provides the Dispatcher with a way to poll external sources for changes. Implements a single function (`adapter_fetch_items`). Without an adapter, the Dispatcher dispatches an Actor every orbit unconditionally. With an adapter, it only dispatches when something changed (token optimization). Adapters are a Dispatcher-only concern.

### Loadout
The configuration of a kube: mission (required), adapter (optional), skills (optional), secrets, and environment variables. Different loadouts produce different behaviors from the same infrastructure.

### Orbit
A single polling cycle. The Dispatcher sleeps for the orbital interval, then either dispatches an Actor unconditionally (no adapter) or checks for deltas via the adapter and dispatches if something changed.

---

## Infrastructure Concepts

### Dispatcher
A non-agentic shell script running as a K8s Deployment. No Claude, no tokens. Polls on an orbital interval and creates Actor Jobs. In no-adapter mode, dispatches every orbit. In adapter mode, sources the adapter script and only dispatches when deltas are detected. In earlier phases (Compose), this role is performed by a human.

### Actor
An autonomous agent running as a K8s Job. This is where Claude enters the picture and tokens are spent. Receives a mission and orbit context, then surveys, acts, and reports back. Ephemeral — start, do the work, exit.

### Namespace
A Kubernetes namespace. The isolation boundary for a KubeSAT instance. One namespace per kube. Contains the Dispatcher Deployment, Actor Jobs, Secrets, and ConfigMaps.

---

## Quality Concepts

### Fail Forward
The philosophy that lower environments are for iteration, not perfection. Imperfect output is expected. Bad code gets shipped to staging, caught, and fixed by subsequent agent iterations.

### Quality Gate
The staging-to-production boundary. The only human decision point. Everything below it is autonomous. Agents can merge to non-prod environments. Only humans promote to production.
