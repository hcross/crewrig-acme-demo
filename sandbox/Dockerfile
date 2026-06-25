# CrewRig adoption fork — experimentation sandbox.
#
# Minimal Ubuntu image with every dependency the fork needs to build, deploy,
# and be driven with Claude Code — so you can experiment with this fork
# WITHOUT touching your personal Claude Code / CrewRig installation.
#
# The fork itself is NOT copied in: it is bind-mounted at runtime (see run.sh),
# mirroring the host directory both ways. Only the toolchain lives in the image.

FROM ubuntu:24.04

ARG NODE_MAJOR=22
ARG YQ_VERSION=v4.53.3
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# --- System dependencies (build + deploy + comfort) ---
#   git/bash      : version control + scripts require bash 4+
#   jq            : required by scripts/build-components.sh
#   fzf           : required by the interactive setup scripts (team/expertise/level pickers)
#   python3       : harness-curator helper scripts
#   curl/ca-certs : fetching node, yq, and Claude Code at runtime/build
#   sudo/less/vim : interactive comfort inside the sandbox
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash jq fzf less vim sudo \
        python3 python3-pip gnupg xz-utils \
    && rm -rf /var/lib/apt/lists/*

# --- Node.js (NodeSource) + npm ---
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && node --version && npm --version

# --- yq (mikefarah, Go build — the variant build-components.sh expects) ---
RUN ARCH="$(dpkg --print-architecture)" \
    && curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCH}" \
        -o /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && yq --version

# --- Claude Code + a couple of always-useful global CLIs ---
# Installed in the image so the sandbox is ready to drive the fork immediately.
RUN npm install -g @anthropic-ai/claude-code markdownlint-cli \
    && npm cache verify || true

# --- Non-root sandbox user ---
# On Docker Desktop (macOS) bind-mount ownership maps transparently to this
# user, so host files stay editable both ways without uid juggling.
RUN useradd -m -s /bin/bash dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

USER dev
ENV HOME=/home/dev
WORKDIR /workspace

# Friendly banner so a first-time user knows the available moves.
COPY --chown=dev:dev entrypoint.sh /usr/local/bin/sandbox-entrypoint.sh
RUN sudo chmod +x /usr/local/bin/sandbox-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/sandbox-entrypoint.sh"]
CMD ["bash"]
