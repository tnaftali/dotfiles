# Dotfiles

Personal configuration files for macOS.

## Contents

- `.zshrc` - Zsh config
- `.tmux.conf` - Tmux config (Catppuccin theme, Ctrl+S prefix)
- `init.vim` - Neovim config
- `ghostty.config` - Ghostty terminal
- `.aerospace.toml` - AeroSpace window manager
- `.gitconfig` - Git settings
- `settings.json` / `keybindings.json` - Cursor editor

## Claude Code

Custom agents and commands in `.claude/`:
- `agents/` - Codebase analysis tools
- `commands/` - Workflow automation (research, planning, testing)
- `hooks/` - Post-edit formatting

## Archive

Legacy configs in `archive/` (Linux, old terminals).

## Setup

Symlink files to their expected locations. Example:
```
ln -sf ~/dotfiles/.zshrc ~/.zshrc
```
