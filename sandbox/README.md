# Sandbox — CrewRig adoption fork (ACME Corp)

A throwaway Ubuntu container for experimenting with this fork **without
polluting your personal Claude Code / CrewRig installation**.

## What it gives you

- **Ubuntu 24.04** with the full toolchain baked in: `node` + `npm`,
  `@anthropic-ai/claude-code`, `yq` (mikefarah) and `jq` (the build's
  prerequisites), `fzf` (the interactive setup scripts' picker), `git`,
  `python3`, and comfort tools.
- The **fork bind-mounted at `/workspace`**, mirroring this repository both
  ways — edits inside the container land on the host and vice versa.
- An **isolated `~/.claude`** stored in a dedicated Docker volume
  (`crewrig-sandbox-home`). Deploying rules with the setup scripts or logging
  into Claude Code inside the sandbox never touches your host home.

## Usage

```bash
# Build (first run, cached afterwards) and open a shell:
sandbox/run.sh

# Force a fresh image build:
sandbox/run.sh --rebuild

# Run a single command instead of an interactive shell:
sandbox/run.sh claude --help
```

### Authentication

Either export your key on the host before launching (it is forwarded):

```bash
export ANTHROPIC_API_KEY=sk-ant-...
sandbox/run.sh
```

…or just run `claude` inside the container and `/login`. The credential is
written to the isolated volume and survives across runs.

## Typical flow inside the sandbox

```bash
bash scripts/build-components.sh            # Step 5 — compile CLI outputs
bash scripts/setup-claude-interactive.sh    # Step 6 — deploy rules into the sandbox's ~/.claude
claude                                       # drive the fork with Claude Code
```

To reset the sandbox completely, remove the volume:

```bash
docker volume rm crewrig-sandbox-home
```
