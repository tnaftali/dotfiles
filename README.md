# Dotfiles

Personal config files for macOS development.

## Contents

- `.zshrc` - Zsh config
- `.tmux.conf` - Tmux config
- `.gitconfig` - Git settings (delta, lfs)
- `.aerospace.toml` - AeroSpace window manager
- `init.vim` - Neovim config
- `ghostty.config` - Ghostty terminal

## AI Tools

Shared configs in `.agents/` with tool-specific symlinks:
- `~/.agents` → `.agents/` (agents, commands, hooks — e.g. format-elixir)
- `~/.claude/` — Claude Code (setup.sh symlinks agents, commands, settings, CLAUDE.md)
- `~/.cursor` → `.cursor/` — global Cursor config when a project has no own `.cursor`

Supported: Claude Code, OpenCode, Cursor

### Worktrees (core repo)

Agent config and MCP live in the **main repo**; worktrees symlink to it. New worktrees get this automatically from `wt()`.

1. **Merge MCP from all worktrees into main** (in case any worktree had its own `.mcp.json`):
   ```bash
   cd ~/Projects/core && ~/dotfiles/scripts/merge-mcp-into-main.sh
   ```
2. **Fix existing worktrees** (symlink `.claude`, `.cursor`, `.mcp.json` to main):
   ```bash
   cd ~/Projects/core && ~/dotfiles/scripts/fix-worktrees-agent-config.sh
   ```

## Archive

Legacy configs in `archive/` (Linux, old terminals, Cursor/VS Code).

## Setup

```bash
./setup.sh
```
