# CrewRig adoption fork — experimentation sandbox.
#
# Minimal Ubuntu image with every dependency the fork needs to build, deploy,
# and be driven with Claude Code — so you can experiment with this fork
# WITHOUT touching your personal Claude Code / CrewRig installation.
#
# Layout inside the container (a small dev tree under /workspace):
#
#   /workspace/
#   ├── crewrig-acme/              <- the fork, bind-mounted at runtime (see run.sh)
#   └── games/                     <- sample open-source games, baked into the image
#       ├── android/2048-android/  <- uberspot/2048-android (native Java)
#       └── web/hextris/           <- Hextris/hextris (HTML5 arcade)
#
# Only the fork is bind-mounted (mirroring the host directory both ways); the
# games live in the image so the harness engineering loop has real targets to
# work on.

FROM ubuntu:24.04

ARG NODE_MAJOR=22
ARG YQ_VERSION=v4.53.3
ARG TASK_VERSION=v3.51.1
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# --- System dependencies (build + deploy + comfort) ---
#   git/bash      : version control + scripts require bash 4+
#   jq            : required by scripts/build-components.sh
#   fzf           : required by the interactive setup scripts (team/expertise/level pickers)
#   python3       : harness-curator helper scripts
#   curl/ca-certs : fetching node, yq, gh, and Claude Code
#   sudo/less/vim : interactive comfort inside the sandbox
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl git bash jq fzf less vim sudo \
        python3 python3-pip python3-venv pipx python-is-python3 gnupg xz-utils \
    && rm -rf /var/lib/apt/lists/*

# --- GitHub CLI (gh) — needed for the harness engineering loop demo ---
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/* \
    && gh --version

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

# --- go-task (Task runner — the project drives everything via Taskfile.yml) ---
RUN curl -fsSL https://taskfile.dev/install.sh \
        | sh -s -- -b /usr/local/bin "${TASK_VERSION}" \
    && task --version

# --- uv / uvx (Astral) — system-wide, for installing Python apps like MemPalace ---
RUN curl -LsSf https://astral.sh/uv/install.sh \
        | env UV_INSTALL_DIR=/usr/local/bin INSTALLER_NO_MODIFY_PATH=1 sh \
    && uv --version && uvx --version

# --- Claude Code + a couple of always-useful global CLIs ---
# Installed in the image so the sandbox is ready to drive the fork immediately.
RUN npm install -g @anthropic-ai/claude-code markdownlint-cli \
    && npm cache verify || true

# --- Non-root sandbox user ---
# On Docker Desktop (macOS) bind-mount ownership maps transparently to this
# user, so host files stay editable both ways without uid juggling.
RUN useradd -m -s /bin/bash dev \
    && echo 'dev ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev \
    && mkdir -p /workspace/crewrig-acme /workspace/games/android /workspace/games/web \
    && chown -R dev:dev /workspace

USER dev
ENV HOME=/home/dev
# pipx and `uv tool install` drop app shims into ~/.local/bin. Set this on PATH
# via ENV (not a shell rc) because the runtime HOME volume shadows any rc file
# written at build time — ENV is image config and survives the volume mount.
ENV PATH="/home/dev/.local/bin:${PATH}"

# --- Sample open-source games (baked in, shallow clones to stay small) ---
# Short/fast arcade games — on-theme with the ACME Corp demo fork. Each is
# re-initialised as a FRESH git repo with a single import commit, so the
# harness engineering loop can branch/commit locally on them out of the box
# (the upstream history and remote are intentionally dropped).
RUN git clone --depth 1 https://github.com/uberspot/2048-android.git \
        /workspace/games/android/2048-android \
    && git clone --depth 1 https://github.com/Hextris/hextris.git \
        /workspace/games/web/hextris \
    && for g in /workspace/games/android/2048-android /workspace/games/web/hextris; do \
         rm -rf "$g/.git" \
         && git -C "$g" -c init.defaultBranch=main init -q \
         && git -C "$g" -c user.email=dev@acme.example -c user.name="ACME dev" add -A \
         && git -C "$g" -c user.email=dev@acme.example -c user.name="ACME dev" \
                commit -q -m "📦 Import sample game (upstream history dropped)"; \
       done

WORKDIR /workspace

# Friendly banner so a first-time user knows the available moves.
COPY --chown=dev:dev entrypoint.sh /usr/local/bin/sandbox-entrypoint.sh
RUN sudo chmod +x /usr/local/bin/sandbox-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/sandbox-entrypoint.sh"]
CMD ["bash"]
