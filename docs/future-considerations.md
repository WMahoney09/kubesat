# Future Considerations

Potential future workstreams. These are not yet scoped — they represent ideas, deferred decisions, and natural extensions that emerged during existing workstream work.

---

## Runtime Skills Refresh

Skills are currently cloned at build time, meaning a kube can't benefit from skill improvements without an image rebuild. A natural extension: `git pull` on skill repo directories at Job startup (or on an interval in the Dispatcher). Build-time clone provides the fast baseline; runtime pull provides freshness. Enables self-improving skills kubes — a kube monitoring its own skills repo could act on feedback, update the skills, and immediately use the updated versions.

_Source: genericize-kubesat solutioning_

## Agent Definitions

Templatable agent identity and behavior config (CLAUDE.md, settings.json). Currently the agent config is generic but static. Future work could make it mission-aware — different missions might need different tool permissions, different constraints, or different agent identities.

_Source: genericize-kubesat problem statement — deferred as "not blocking"_

## Multi-Adapter Support

One adapter per kube is the current model. Some missions might benefit from watching multiple sources simultaneously — e.g., monitoring both GitHub Issues and a Google Drive folder, correlating across them. Would require the Dispatcher to poll multiple adapters and merge deltas.

_Source: genericize-kubesat problem statement — deferred as "not needed for now"_

## Webhook-Based Triggers

Polling on an orbital interval is the current model. Some sources support webhooks (GitHub, Jira, etc.) which could trigger immediate action rather than waiting for the next orbit. Would require an ingress endpoint on the Dispatcher and a different triggering model.

_Source: kubesat-infrastructure plan (out of scope), genericize-kubesat problem statement_

## Review Agents

PRs opened by Actor Jobs could be picked up by dedicated review Jobs — separate from self-review. The review agent runs code review skills, leaves structured feedback, and if revisions are needed, that feedback becomes input for new Actor Jobs. PRs authored by humans would go through the same pipeline — author-agnostic review.

_Source: vision document_

## CI/CD Pipeline

Automated image builds, testing, and deployment for KubeSAT itself. Currently image builds are manual. A CI/CD pipeline would rebuild images when skills repos change, when the Dockerfile changes, or on a schedule.

_Source: kubesat-infrastructure plan (out of scope)_

## Monitoring and Alerting

Observability for running kubes — orbit logs, Job success/failure rates, time-to-PR metrics, resource utilization. Would help operators understand whether a kube is healthy and productive.

_Source: kubesat-infrastructure plan (out of scope)_

## Bot GitHub Accounts

Dedicated GitHub bot accounts for KubeSAT Actors rather than using a human's token. Would provide cleaner audit trails, separate rate limits, and the ability to distinguish human-authored from agent-authored work in git history.

_Source: kubesat-infrastructure plan (out of scope)_

## Client-Specific Configuration

Tooling to streamline standing up new kube instances for different clients/projects — namespace creation, secret population, ConfigMap generation. Currently manual kubectl commands.

_Source: kubesat-infrastructure plan (out of scope)_

## Generic Base Image with Overlay Pattern

A two-layer build: generic base image (Claude Code, adapters, tools) cached and shared, with thin per-loadout Dockerfiles that `FROM kubesat-base` and add skills + mission. Would reduce build times for organizations running many kubes with different loadouts.

_Source: genericize-kubesat solutioning — deferred as "earn complexity when needed"_

## Adapter Plugin Registry

Community-contributed adapters discoverable and installable from a registry rather than shipping in-repo. Only relevant if KubeSAT develops an ecosystem of third-party adapters.

_Source: genericize-kubesat problem statement — deferred as "not needed"_

## Autoscaling

Cluster-level autoscaling based on workload — grow when many kubes are active, shrink during quiet periods. Standard K8s autoscaler configuration but needs tuning for the bursty, long-running nature of agent Jobs.

_Source: vision document_

## Skills Repo Pinning

Pin skills repos to specific commits or tags rather than cloning HEAD. Would provide reproducible builds and protect against breaking changes in skills. Currently unpinned for simplicity.

_Source: kubesat-infrastructure problem statement (assumption — "stable enough to clone without pinning")_
