# Fuel validation — sourced by both entrypoints so the rule lives in one place.
#
# Fuel: API billing (ANTHROPIC_API_KEY) or subscription billing
# (CLAUDE_CODE_OAUTH_TOKEN from `claude setup-token`). Exactly one source —
# mixed fuel makes billing ambiguous. Empty strings count as unset, so an
# empty env var shipped by the Secret does not slip past these gates.
if [ -z "${ANTHROPIC_API_KEY:-}" ] && [ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
    echo "ERROR: No fuel — set ANTHROPIC_API_KEY (API billing) or CLAUDE_CODE_OAUTH_TOKEN (subscription billing)"
    exit 1
fi
if [ -n "${ANTHROPIC_API_KEY:-}" ] && [ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
    echo "ERROR: Two fuel sources — set exactly one of ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN so it is unambiguous how this satellite is billed"
    exit 1
fi
