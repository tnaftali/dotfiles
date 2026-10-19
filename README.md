# Dotfiles

Personal config files for macOS and Linux (Omarchy) development.

## Contents

- `.zshrc` - Zsh config
- `.tmux.conf` - Tmux config
- `.gitconfig` - Git settings (delta, lfs)
- `.aerospace.toml` - AeroSpace window manager
- `init.vim` - Neovim config
- `ghostty.config` - Ghostty terminal

## AI Tools

Shared configs in `.agents/` with tool-specific symlinks. The repo is the
single source of truth — `~/.claude` is populated entirely by symlinks back
into dotfiles.

- `~/.agents` → `.agents/` (agents, commands, hooks — e.g. format-elixir)
- `~/.claude/` — per-entry symlinks: `agents/*.md`, `commands`, `skills/*`,
  `settings.json`, `settings.local.json`, `CLAUDE.md`, `RTK.md`

Supported: Claude Code, Codex (seeded copies)

## Scripts

- `bin/` — scripts on `$PATH` (e.g. `ralph`, daily-brief generators)
- `scripts/` — one-off setup helpers (worktree fixers)

### Worktrees (core repo)

Agent config and MCP live in the **main repo**; worktrees symlink to it. New worktrees get this automatically from `wt()`.

1. **Merge MCP from all worktrees into main** (in case any worktree had its own `.mcp.json`):
   ```bash
   cd ~/Projects/core && "$DOTFILES"/scripts/merge-mcp-into-main.sh
   ```
2. **Fix existing worktrees** (symlink `.claude`, `.cursor`, `.mcp.json` to main):
   ```bash
   cd ~/Projects/core && "$DOTFILES"/scripts/fix-worktrees-agent-config.sh
   ```

## Archive

Legacy configs in `archive/` (Linux, old terminals, Cursor/VS Code).

## Setup

Ask an AI agent to follow [SETUP.md](SETUP.md).
