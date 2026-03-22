#!/bin/bash
# ---------------------------------------------------------------------------
# KubeSAT Adapter: GitHub Issues
#
# Polls open issues on a GitHub repository and returns them as items
# with updated_at as the change indicator.
#
# Required env vars:
#   GITHUB_TOKEN  — GitHub token (also used for git auth)
#   ADAPTER_REPO  — Repository to poll (e.g., "owner/repo")
# ---------------------------------------------------------------------------

: "${GITHUB_TOKEN:?github-issues adapter requires GITHUB_TOKEN}"
: "${ADAPTER_REPO:?github-issues adapter requires ADAPTER_REPO}"

adapter_fetch_items() {
    gh api "repos/${ADAPTER_REPO}/issues" \
        --method GET \
        -f state=open \
        -f per_page=100 \
        --jq '[.[] | select(.pull_request == null) | {id: (.number | tostring), hash: .updated_at}]'
}
