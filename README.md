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
- `.agents/` - Source of truth (agents, commands, hooks)
- `.claude/` - Claude Code settings and hooks

Supported: Claude Code, OpenCode

## Archive

Legacy configs in `archive/` (Linux, old terminals, Cursor/VS Code).

## Setup

```bash
./setup.sh
```
