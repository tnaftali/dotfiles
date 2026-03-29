# Cursor Agent Configuration (global fallback)

Personal Cursor config, used when a project has no own `.cursor`. Symlinked to `~/.cursor` by `setup.sh`.

## Layout

- **commands/** – Command pointers (may reference project `.agents/commands/` or dotfiles)
- **rules/** – Generic rule templates; project-specific rules live in the repo
- **agents/** – Shared agent definitions
- **hooks/** – Optional post-edit hooks (e.g. Elm validation)
- **config.json** – Generic context
- **settings.json** – Permissions and MCP note

## When to use

- **In a project with its own `.cursor`** (e.g. core): that project’s config takes precedence.
- **In a project without `.cursor`**: Cursor may use this global config from `~/.cursor`.
- **MCP**: Configure in the project that runs the tools (e.g. core has `.mcp.json`); worktrees symlink to main repo’s `.mcp.json`.

## Setup

From dotfiles repo: `./setup.sh` creates `~/.cursor` → `~/dotfiles/.cursor`.
