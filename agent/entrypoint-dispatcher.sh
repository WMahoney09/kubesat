#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# KubeSAT Dispatcher Entrypoint
#
# Three modes, selected automatically:
#
#   Workspace mode: Keeps the container alive for human interaction via
#       docker exec. Detected when NOT running in K8s.
#
#   K8s no-adapter mode (default): Unconditionally creates an Actor Job
#       every orbit. Claude handles all surveying via the mission.
#
#   K8s adapter mode: Sources an adapter script, polls for changes via
#       adapter_fetch_items, and only dispatches when deltas are detected.
#       Activated when KUBESAT_ADAPTER is set.
#
# The Dispatcher is NOT agentic — no Claude, no tokens. It's a shell script
# polling loop that creates Actor Jobs.
# ---------------------------------------------------------------------------

# Validate required environment variables
: "${ANTHROPIC_API_KEY:?ANTHROPIC_API_KEY is required}"
: "${GITHUB_TOKEN:?GITHUB_TOKEN is required}"

# Set up GitHub CLI auth
echo "${GITHUB_TOKEN}" | gh auth login --with-token 2>/dev/null

# Configure git identity
git config --global user.name "${GIT_USER_NAME:-KubeSAT Dispatcher}"
git config --global user.email "${GIT_USER_EMAIL:-kubesat[bot]@noreply.github.com}"

K8S_TOKEN="/var/run/secrets/kubernetes.io/serviceaccount/token"
ORBIT_INTERVAL="${ORBIT_INTERVAL:-600}"
ORBIT_LOG="/home/agent/orbit-state/orbit-log.json"
JOB_TEMPLATE="/home/agent/actor-job-template.yml"
ADAPTER_MODE="false"

# Source adapter if configured
if [ -n "${KUBESAT_ADAPTER:-}" ]; then
    ADAPTER_SCRIPT="/home/agent/adapters/${KUBESAT_ADAPTER}.sh"
    if [ ! -f "${ADAPTER_SCRIPT}" ]; then
        echo "ERROR: Adapter script not found: ${ADAPTER_SCRIPT}"
        exit 1
    fi
    source "${ADAPTER_SCRIPT}"
    ADAPTER_MODE="true"
fi

# ---------------------------------------------------------------------------
# Adapter-mode functions (delta detection)
# ---------------------------------------------------------------------------

init_orbit_log() {
    if [ ! -f "${ORBIT_LOG}" ]; then
        mkdir -p "$(dirname "${ORBIT_LOG}")"
        echo "{}" > "${ORBIT_LOG}"
    fi
}

detect_deltas() {
    local current_items="$1"

    echo "${current_items}" | python3 -c "
import json, sys

items = json.load(sys.stdin)
with open('${ORBIT_LOG}', 'r') as f:
    orbit_log = json.load(f)

changed = []
for item in items:
    item_id = str(item.get('id', ''))
    item_hash = str(item.get('hash', ''))
    if item_id and (item_id not in orbit_log or orbit_log[item_id] != item_hash):
        changed.append(item_id)

print(' '.join(changed))
" 2>/dev/null || echo ""
}

update_orbit_log() {
    local current_items="$1"

    echo "${current_items}" | python3 -c "
import json, sys

items = json.load(sys.stdin)
with open('${ORBIT_LOG}', 'r') as f:
    orbit_log = json.load(f)

for item in items:
    item_id = str(item.get('id', ''))
    item_hash = str(item.get('hash', ''))
    if item_id and item_hash:
        orbit_log[item_id] = item_hash

with open('${ORBIT_LOG}', 'w') as f:
    json.dump(orbit_log, f, indent=2)
" 2>/dev/null
}

# ---------------------------------------------------------------------------
# K8s mode functions
# ---------------------------------------------------------------------------

has_active_actor() {
    local active
    active=$(kubectl get jobs -n "${NAMESPACE:-kubesat-dev}" \
        -l app.kubernetes.io/component=actor \
        --field-selector=status.active=1 \
        -o name 2>/dev/null | head -1)
    [ -n "${active}" ]
}

create_actor_job() {
    local args="$1"

    sed "s/ACTOR_ITEM_IDS/${args}/" "${JOB_TEMPLATE}" \
        | kubectl apply -f - 2>/dev/null
}

run_orbit_no_adapter() {
    local orbit_num="$1"
    echo "[orbit ${orbit_num}] Starting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

    if has_active_actor; then
        echo "[orbit ${orbit_num}] Actor Job still running, skipping"
        return
    fi

    if create_actor_job "${orbit_num}"; then
        echo "[orbit ${orbit_num}] Actor Job created"
    else
        echo "[orbit ${orbit_num}] Failed to create Actor Job"
    fi
}

run_orbit_with_adapter() {
    local orbit_num="$1"
    echo "[orbit ${orbit_num}] Starting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

    if has_active_actor; then
        echo "[orbit ${orbit_num}] Actor Job still running, skipping"
        return
    fi

    # Fetch current items from the adapter
    local current_items
    current_items=$(adapter_fetch_items) || {
        echo "[orbit ${orbit_num}] Failed to fetch items from adapter, skipping"
        return
    }

    # Detect deltas
    local deltas
    deltas=$(detect_deltas "${current_items}") || {
        echo "[orbit ${orbit_num}] Failed to detect deltas, skipping"
        return
    }

    if [ -z "${deltas}" ]; then
        echo "[orbit ${orbit_num}] No deltas detected"
        return
    fi

    echo "[orbit ${orbit_num}] Deltas detected: ${deltas}"

    if create_actor_job "${deltas}"; then
        echo "[orbit ${orbit_num}] Actor Job created"
        update_orbit_log "${current_items}"
    else
        echo "[orbit ${orbit_num}] Failed to create Actor Job"
    fi
}

# ---------------------------------------------------------------------------
# Mode selection
# ---------------------------------------------------------------------------

if [ -f "${K8S_TOKEN}" ]; then
    # -------------------------------------------------------------------
    # K8s mode: automated orbit loop
    # -------------------------------------------------------------------
    if [ "${ADAPTER_MODE}" = "true" ]; then
        echo "KubeSAT Dispatcher — K8s mode (adapter: ${KUBESAT_ADAPTER})"
    else
        echo "KubeSAT Dispatcher — K8s mode (no adapter)"
    fi
    echo "Orbit interval: ${ORBIT_INTERVAL}s"

    # Copy job template from k8s directory if available
    if [ -f "/home/agent/k8s/actor-job-template.yml" ]; then
        cp /home/agent/k8s/actor-job-template.yml "${JOB_TEMPLATE}"
    fi

    if [ "${ADAPTER_MODE}" = "true" ]; then
        init_orbit_log
    fi

    orbit=1
    while true; do
        if [ "${ADAPTER_MODE}" = "true" ]; then
            run_orbit_with_adapter "${orbit}"
        else
            run_orbit_no_adapter "${orbit}"
        fi
        orbit=$((orbit + 1))
        sleep "${ORBIT_INTERVAL}"
    done
else
    # -------------------------------------------------------------------
    # Workspace mode: keep container alive for human interaction
    # -------------------------------------------------------------------
    echo "KubeSAT Dispatcher — workspace mode"
    echo "Environment ready. Use 'docker exec' to interact."
    echo ""
    echo "Available tools: claude, git, gh, curl"
    echo ""
    echo "Waiting for interaction..."
    exec tail -f /dev/null
fi
