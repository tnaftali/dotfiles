# Dotfiles

Personal config files for development.

## Contents

- `.zshrc` - zsh config
- `.tmux.conf` - tmux config
- `init.vim` - neovim config
- `ghostty.config` - Ghostty terminal
- `.aerospace.toml` - AeroSpace window manager
- `.gitconfig` - Git settings
- `ide/` - Cursor/VS Code settings and keybindings

## AI Tools

Shared configs in `.agents/` with tool-specific symlinks:
- `.agents/` - Source of truth (agents, commands, hooks)
- `.claude/`, `.opencode/`, `.agent/` - Tool-specific symlinks
- `.cursorrules`, `AGENTS.md`, `GEMINI.md` - Root symlinks

Supported: Claude Code, OpenCode, Gemini CLI, Cursor, Google Antigravity

## Archive

Legacy configs in `archive/` (Linux, old terminals).

## Setup

```bash
# Symlink shell/editor configs
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# Setup all AI tools
./setup-ai-tools.sh
```
