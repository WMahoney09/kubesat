#!/bin/bash
set -euo pipefail

# ---------------------------------------------------------------------------
# KubeSAT Actor Entrypoint
#
# Reads the mission from /home/agent/mission.md, constructs a prompt with
# orbit context, and invokes Claude Code to execute the mission.
# ---------------------------------------------------------------------------

ORBIT_NUM="${1:-0}"

# Validate required environment variables
# Fuel: API billing (ANTHROPIC_API_KEY) or subscription billing (CLAUDE_CODE_OAUTH_TOKEN
# from `claude setup-token`). Exactly one source is required.
if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
    echo "ERROR: No fuel — set ANTHROPIC_API_KEY (API billing) or CLAUDE_CODE_OAUTH_TOKEN (subscription billing)"
    exit 1
fi
: "${GITHUB_TOKEN:?GITHUB_TOKEN is required}"

# Read the mission
MISSION_FILE="/home/agent/mission.md"
if [ ! -f "${MISSION_FILE}" ]; then
    echo "ERROR: Mission file not found at ${MISSION_FILE}"
    echo "Mount a mission.md file to this path."
    exit 1
fi
MISSION=$(cat "${MISSION_FILE}")

# GitHub CLI uses GITHUB_TOKEN from the environment automatically — no login needed.

# Configure git identity
git config --global user.name "${GIT_USER_NAME:-KubeSAT Actor}"
git config --global user.email "${GIT_USER_EMAIL:-kubesat[bot]@noreply.github.com}"

# Clone target repo (if TARGET_REPO is set)
WORK_DIR="/home/agent/workspace"
if [ -n "${TARGET_REPO:-}" ]; then
    git clone "${TARGET_REPO}" "${WORK_DIR}"
    cd "${WORK_DIR}"

    # Create working branch with unique orbit timestamp
    ORBIT_TS=$(date -u +%Y%m%d-%H%M%S)
    BRANCH="kubesat/${ORBIT_TS}/orbit-${ORBIT_NUM}"
    git checkout -b "${BRANCH}"
fi

# Build the prompt: mission + orbit context
ORBIT_TS=$(date -u +%Y%m%d-%H%M%S)
PROMPT="You are a KubeSAT Actor dispatched for orbit ${ORBIT_NUM} at ${ORBIT_TS}.

--- MISSION ---
${MISSION}
--- END MISSION ---

Orbit number: ${ORBIT_NUM}
Working directory: ${WORK_DIR}
${TARGET_REPO:+Target repo: ${TARGET_REPO}}
${BRANCH:+Branch: ${BRANCH}}
${ADAPTER_REPO:+Adapter repo: ${ADAPTER_REPO}}

Execute your mission."

exec claude -p "${PROMPT}"
