# Dotfiles Project Instructions

Personal configuration files for macOS development environment.

## Structure

- **Shell**: `.zshrc` - Zsh configuration
- **Editor**: `init.vim` - Neovim config, `ide/` - Cursor/VS Code settings
- **Terminal**: `ghostty.config` - Ghostty terminal emulator
- **Window Management**: `.aerospace.toml` - AeroSpace tiling WM
- **Multiplexer**: `.tmux.conf` - Tmux with Catppuccin theme
- **Git**: `.gitconfig` - Git settings and aliases
- **AI Tools**: `.agents/` - Shared agents/commands for AI coding assistants

## Conventions

- Keep configs minimal and well-commented
- Use symlinks from home directory to this repo
- Archive unused configs in `archive/` rather than deleting
- Test changes before committing

## AI Agent Guidelines

When making changes to this repo:
1. Preserve existing functionality unless explicitly asked to change it
2. Follow the existing style and formatting of each config file
3. Keep README.md under 50 lines
4. Commit messages should be concise and descriptive
