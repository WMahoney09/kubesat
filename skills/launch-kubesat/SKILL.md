---
name: launch-kubesat
description: >-
  Mission Control for KubeSAT — autonomous Claude agent satellites that orbit a
  repo on Kubernetes. Use when the user wants to "launch a kubesat", "put a
  satellite on this repo", or "deploy an agent that does X on a loop" (PR
  review, issue triage, dependency upgrades, any recurring mission), and also
  to retask, check on, or deorbit a satellite that is already flying.
  Interviews the user for mission, orbital period, fuel (billing), adapter,
  and skills, then assembles the loadout and runs the launch sequence.
---

# Launch a KubeSAT

A KubeSAT is an autonomous agent satellite: a Dispatcher (non-agentic shell
loop) runs in its own Kubernetes namespace and, every orbit (a polling
interval), spins up an Actor Job — a fresh headless Claude session that reads
`mission.md`, clones the target repo onto a `kubesat/<timestamp>/<slug>`
branch, executes the mission, and exits. Optionally an adapter gives the
Dispatcher delta detection so Actors only launch when something changed.

This plugin's root (`${CLAUDE_PLUGIN_ROOT}`) is a full checkout of the KubeSAT
repo: `Dockerfile`, `k8s/` manifests, `adapters/`, entrypoints. Everything
needed to launch ships with the plugin.

**One satellite per namespace, one image per satellite.** The stock `k8s/`
base uses `kubesat-dev` and `kubesat:latest`; each launch is a thin Kustomize
overlay over that base that sets its own namespace and image tag
(`kubesat:<satellite-name>`), so a constellation can coexist without colliding.
Skills loadouts are baked into the image, and a shared tag would let one launch
silently change another satellite's loadout — so each satellite gets its own
tag. The Dispatcher launches its Actors with its *own* image, so the tag only
has to be set once (the overlay's `images:` entry); the namespace transformer
rewrites `kubesat-dev` everywhere — including RBAC subjects — with no
hand-substitution.

## Flight plan

1. Establish mission parameters (interview)
2. Draft the mission and get sign-off
3. Assemble the loadout in `~/.kubesat/<satellite-name>/`
4. Fuel it (user fills in secrets — never read their values)
5. Preflight checks
6. Launch sequence
7. Confirm orbit

Walk these in order. Do not skip the mission sign-off or the preflight.

## Step 1 — Establish mission parameters

Harvest everything already stated in the user's request first — never ask for
something they already told you. "Launch a kubesat that does PR review for
this project" already gives you the mission concept and the target repo.

Defaults:

- **Target repo** — the `origin` remote of the current working directory
  (`git remote get-url origin`). Confirm only if there is no remote or the
  user seems to mean a different repo.
- **Satellite name / namespace** — `kubesat-<repo-name>` slugified to a valid
  DNS label (lowercase alphanumerics and hyphens).

Ask (AskUserQuestion works well; one round, don't drip-feed):

1. **Orbital period** — how often the satellite wakes. Common choices:
   300s (5 min), 600s (10 min, default), 1800s (30 min), 3600s (hourly).
   Longer orbits burn less fuel; match the cadence to how fast the source
   changes.
2. **Fuel (billing)** — how Claude inside the satellite is paid for:
   - **API billing** — a metered `ANTHROPIC_API_KEY`. Pay per token.
   - **Subscription billing** — a `CLAUDE_CODE_OAUTH_TOKEN` generated with
     `claude setup-token` (Pro/Max subscription). Flat-rate, subject to the
     subscription's rate limits — note that an aggressive orbital period can
     eat a subscription's 5-hour windows.
3. **Adapter** — delta detection, or act every orbit?
   - **None** — an Actor launches every orbit unconditionally; the mission
     itself must be idempotent (survey first, act only on what's new).
   - **`github-issues`** — Dispatcher polls issues on `ADAPTER_REPO` and only
     launches an Actor when issues change. Check `${CLAUDE_PLUGIN_ROOT}/adapters/`
     for the current roster; if the mission wants a source with no adapter
     (e.g. PRs), use no adapter + idempotent mission, and mention that a new
     adapter is a small shell script (see `adapters/README.md`).
4. **Skills loadout** (optional) — git URLs of skill repos to bake into the
   image at build time (cloned into the Actor's `~/.claude/skills/`). Public
   repos need no token; private repos need a BuildKit secret.

## Step 2 — Draft the mission

Write `mission.md` from the interview. A good mission is written to a fresh
Claude session with no memory of prior orbits, so it must be:

- **Self-contained** — the Actor gets only this file plus orbit number,
  target repo, and branch name.
- **Idempotent** — every orbit starts by surveying current state (open PRs,
  existing comments, prior branches) and acts only on what hasn't been
  handled. Give it a concrete marker to check, e.g. "only review PRs that
  have no comment containing `<!-- kubesat-reviewed -->`".
- **Bounded** — say what done looks like for one orbit, and what to do when
  there's nothing to do (report and exit).

Constraints already enforced by the baked-in agent config (don't restate,
but don't contradict): work on `kubesat/<timestamp>/<slug>` branches, never
push to main, never tag, self-review before merge.

Example shape (PR-review mission):

```markdown
# Mission: PR Review for <owner>/<repo>

Each orbit:
1. List open PRs: `gh pr list --state open`
2. Skip any PR whose comments contain `<!-- kubesat-reviewed -->` for its
   latest commit SHA.
3. For each remaining PR: review the diff for correctness, security, and
   test coverage. Post one review comment (comment-mode, never approve or
   request changes) that starts with `🤖 Claude:` and embeds
   `<!-- kubesat-reviewed --> <sha>`.
4. If no PRs need review, log "nothing to review this orbit" and exit.
```

Show the drafted mission to the user and iterate until they sign off.

## Step 3 — Assemble the loadout

The loadout is a Kustomize overlay over the plugin's `k8s/` base. The base
(`${CLAUDE_PLUGIN_ROOT}/k8s/kustomization.yml`) owns the manifest roster and
RBAC; the overlay carries only what's unique to this satellite — namespace,
image tag, mission, secrets, config. You never edit or enumerate the base
manifests, and you never hand-substitute the namespace — the base's
`namespace:` transformer rewrites it everywhere, RBAC subjects included.

Create `~/.kubesat/<satellite-name>/` containing:

1. **`k8s/`** — a recursive copy of the base:
   `cp -r ${CLAUDE_PLUGIN_ROOT}/k8s ~/.kubesat/<satellite-name>/k8s`. The copy
   keeps the loadout self-contained for relaunch and needs no edits; a manifest
   added upstream is picked up automatically (it's listed in the base's own
   `kustomization.yml`, not here).
2. **`mission.md`** — the signed-off mission. The overlay generates the
   `kubesat-mission` ConfigMap from it.
3. **`launch.env`** — secrets only, placeholder values (see Step 4). Becomes
   the `kubesat-secrets` Secret.
4. **`kustomization.yml`** — the overlay. Set the namespace, the image tag
   (`<satellite-name>`), the target repo, the orbital period, and — if an
   adapter was chosen — `KUBESAT_ADAPTER` / `ADAPTER_REPO` in the config patch:

   ```yaml
   apiVersion: kustomize.config.k8s.io/v1beta1
   kind: Kustomization

   namespace: <satellite-name>

   resources:
     - k8s

   images:
     - name: kubesat
       newTag: <satellite-name>

   # Stable names — the Dispatcher creates Actor Jobs at runtime that mount
   # these by fixed name, outside kustomize's reference rewriting.
   generatorOptions:
     disableNameSuffixHash: true

   secretGenerator:
     - name: kubesat-secrets
       envs:
         - launch.env

   configMapGenerator:
     - name: kubesat-mission
       files:
         - mission.md=mission.md

   patches:
     - target:
         kind: ConfigMap
         name: kubesat-config
       patch: |-
         apiVersion: v1
         kind: ConfigMap
         metadata:
           name: kubesat-config
         data:
           TARGET_REPO: <target-repo-url>
           ORBIT_INTERVAL: "<seconds>"
           # KUBESAT_ADAPTER: github-issues
           # ADAPTER_REPO: <owner>/<repo>
   ```

   Leave `ACTOR_IMAGE` out — the Dispatcher defaults Actors to its own image,
   which the `images:` transformer already sets. The generators replace
   `secrets.yml` and `mission-configmap.yml`, so don't add those to the overlay.

## Step 4 — Fueling (secrets)

The user fills in `launch.env` themselves. **Never ask the user to paste
secrets into the conversation, and never read the filled-in file back.**
Suggest they run `! $EDITOR ~/.kubesat/<satellite-name>/launch.env` (the `!`
prefix runs it in-session). Have them **delete the unused fuel line** rather
than leaving it empty — the file becomes the k8s Secret verbatim, and an
empty `ANTHROPIC_API_KEY=` ships an empty env var into every pod. To verify
readiness without exposing values, count non-empty lines per key
(`grep -c "^GITHUB_TOKEN=..*" launch.env`): `GITHUB_TOKEN` must be filled,
and **exactly one** of the two fuel keys — the entrypoints refuse to fly
with zero or two fuel sources, so billing is never ambiguous.

## Step 5 — Preflight checks

- `kubectl config current-context` — a cluster must be reachable, and it
  should be **local** (docker-desktop, minikube, kind): the image is built
  locally as `kubesat:<satellite-name>` with `imagePullPolicy: IfNotPresent`.
  A remote cluster needs a registry push, which is outside this skill — warn
  and stop if the context looks remote.
- `docker version` — the daemon must be up.
- Namespace not already in use (`kubectl get namespace <ns>`) — if this
  satellite is already flying, the user probably wants **retask** (below),
  not a second launch.
- **Suborbital test (recommended)** — one shot, no Kubernetes, validates
  mission + fuel before committing to orbit. Requires the image, so run the
  `docker build` from the launch sequence first (a relaunch later hits the
  layer cache):

  ```
  docker run --rm --env-file ~/.kubesat/<name>/launch.env --env TARGET_REPO=<url> -v ~/.kubesat/<name>/mission.md:/home/agent/mission.md:ro kubesat:<satellite-name>
  ```

  Review what the Actor did (branches, PRs, comments) with the user before
  proceeding.

## Step 6 — Launch sequence

Build the image, then apply the overlay — two commands:

```
docker build -t kubesat:<satellite-name> <plugin-root>
```

(with skills: add `--build-arg SKILLS_REPOS=$'url1\nurl2'`; private skill
repos additionally need `--secret id=gh_token,src=<tokenfile>`)

```
kubectl apply -k ~/.kubesat/<satellite-name>/
```

One `apply -k` renders the overlay and creates the namespace, RBAC, config,
secret, mission, storage, quota, network policy, and Dispatcher together.
Preview exactly what will hit the cluster first with
`kubectl kustomize ~/.kubesat/<satellite-name>/` (no cluster needed — good for
a final sanity check on the namespace and image tag).

## Step 7 — Confirm orbit

```
kubectl get pods -n <ns>
kubectl logs -n <ns> deployment/kubesat-dispatcher --tail=20
```

A healthy Dispatcher logs its mode and `[orbit 1] Starting…`. Report the
satellite's name, namespace, orbital period, fuel type, and how to watch it.

## Flight operations

**Retask** (change mission mid-flight — takes effect next orbit, no restart):
edit `~/.kubesat/<name>/mission.md`, then re-apply the overlay:

```
kubectl apply -k ~/.kubesat/<name>/
```

Kustomize regenerates the `kubesat-mission` ConfigMap (stable name) with the
new content, and the next Actor Job mounts it. Everything else re-applies
idempotently, so this is safe to run repeatedly.

**Status, pause, resume, and deorbit** are handled by sibling skills so each
operation lives in one place:

- **`status-kubesat`** — dispatcher health, orbit history, active mission,
  fuel type (read-only).
- **`deorbit-kubesat`** — pause (scale to zero), resume, or permanently
  deorbit (delete the namespace). The loadout under `~/.kubesat/<name>/`
  survives a deorbit, so a satellite can always be relaunched from here.
