# Sandbox — CrewRig adoption fork (ACME Corp)

A throwaway Ubuntu container for experimenting with this fork **without
polluting your personal Claude Code / CrewRig / gh installation**.

## What it gives you

- **Ubuntu 24.04** with the full toolchain baked in: `node` + `npm`,
  `@anthropic-ai/claude-code`, **`gh`** (GitHub CLI, for the harness
  engineering loop), `yq` (mikefarah) and `jq` (the build's prerequisites),
  `fzf` (the interactive setup scripts' picker), `git`, `python3`, and comfort
  tools.
- A small **dev tree under `/workspace`**:

  ```text
  /workspace/
  ├── crewrig-acme/                 # this fork, bind-mounted (mirrors the host both ways)
  └── games/                        # sample open-source games, baked into the image
      ├── android/2048-android/     # uberspot/2048-android (native Java) — fresh git repo
      └── web/hextris/              # Hextris/hextris (HTML5 arcade) — fresh git repo
  ```

  Only the fork is bind-mounted; edits inside `crewrig-acme/` land on the host
  and vice versa. The games are baked in as **fresh git repos** (one import
  commit each, upstream remote dropped) so the dev loop can branch and commit
  on them out of the box.
- An **isolated `~/.claude` and `gh` config** stored in a dedicated Docker
  volume (`crewrig-sandbox-home`). Logging into Claude Code or `gh` inside the
  sandbox never touches your host home.

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

**Claude Code** — export your key on the host before launching (forwarded), or
run `claude` inside and `/login`:

```bash
export ANTHROPIC_API_KEY=sk-ant-...
sandbox/run.sh
```

**GitHub CLI** — export a token before launching (forwarded), or run
`gh auth login` inside:

```bash
export GH_TOKEN=ghp_...
sandbox/run.sh
```

Both credentials are written to the isolated volume and survive across runs.

## Typical flow inside the sandbox

```bash
cd crewrig-acme
bash scripts/build-components.sh            # Step 5 — compile CLI outputs
bash scripts/setup-claude-interactive.sh    # Step 6 — deploy rules into the sandbox's ~/.claude
claude                                       # drive the fork; use the games under ../games as targets
```

To reset the sandbox completely, remove the volume:

```bash
docker volume rm crewrig-sandbox-home
```
