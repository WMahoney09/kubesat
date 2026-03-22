# syntax=docker/dockerfile:1
FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        gnupg \
        python3 \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl (needed by Dispatcher in K8s mode to create Actor Jobs)
RUN curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl" \
        -o /usr/local/bin/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash agent

USER agent
WORKDIR /home/agent

# Install Claude Code via official install script
RUN curl -fsSL https://claude.ai/install.sh | bash
ENV PATH="/home/agent/.local/bin:${PATH}"

# Clone skills repos (BuildKit secret — never use a build arg for tokens)
# SKILLS_REPOS: newline-delimited list of git repo URLs (can be empty)
ARG SKILLS_REPOS=""
RUN --mount=type=secret,id=gh_token \
    mkdir -p .claude/skills \
    && if [ -n "${SKILLS_REPOS}" ]; then \
        echo "${SKILLS_REPOS}" | while IFS= read -r repo_url; do \
            [ -z "${repo_url}" ] && continue; \
            repo_name=$(basename "${repo_url}" .git); \
            git clone "https://$(cat /run/secrets/gh_token)@${repo_url#https://}" \
                ".claude/skills/${repo_name}"; \
        done; \
    fi

# Copy adapters (used by Dispatcher for optional delta detection)
COPY --chown=agent:agent adapters/ adapters/

# Copy agent configuration
COPY --chown=agent:agent agent/CLAUDE.md .claude/CLAUDE.md
COPY --chown=agent:agent agent/settings.json .claude/settings.json

# Copy entrypoint scripts
COPY --chown=agent:agent agent/entrypoint-actor.sh entrypoint-actor.sh
COPY --chown=agent:agent agent/entrypoint-dispatcher.sh entrypoint-dispatcher.sh
RUN chmod +x entrypoint-actor.sh entrypoint-dispatcher.sh

# Default to Actor role (overridden by Compose/K8s for Dispatcher)
ENTRYPOINT ["./entrypoint-actor.sh"]
