# Dotfiles

Personal configuration files for macOS.

## Contents

- `.zshrc` - Zsh config
- `.tmux.conf` - Tmux config (Catppuccin theme, Ctrl+S prefix)
- `init.vim` - Neovim config
- `ghostty.config` - Ghostty terminal
- `.aerospace.toml` - AeroSpace window manager
- `.gitconfig` - Git settings
- `ide/` - Cursor/VS Code settings and keybindings

## AI Tools

Shared configs in `.agents/` with tool-specific symlinks:
- `.agents/` - Source of truth for agents, commands, hooks
- `.claude/` - Claude Code (symlinks to .agents/)
- `.opencode/` - OpenCode (symlinks to .agents/)
- `AGENTS.md`, `GEMINI.md` - Root symlinks for tool discovery

## Archive

Legacy configs in `archive/` (Linux, old terminals).

## Setup

Symlink files to their expected locations:
```
ln -sf ~/dotfiles/.zshrc ~/.zshrc
```
