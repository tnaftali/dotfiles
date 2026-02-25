#!/bin/bash
# Setup script - creates symlinks from home directory to dotfiles

set -eu

DOTFILES="$HOME/dotfiles"

# Helper function to create symlinks with idempotency checks
create_symlink() {
  local source="$1"
  local target="$2"

  if [ -L "$target" ]; then
    local current_target
    current_target=$(readlink "$target")
    if [ "$current_target" != "$source" ]; then
      echo "  Warning: $target already exists but points to $current_target (expected $source)"
    fi
  fi
  ln -sf "$source" "$target"
}

echo "Setting up dotfiles from $DOTFILES..."

# Shell & editor configs
echo "Setting up shell and editor configs..."
create_symlink "$DOTFILES/.zshrc" ~/.zshrc
create_symlink "$DOTFILES/.tmux.conf" ~/.tmux.conf
create_symlink "$DOTFILES/.gitconfig" ~/.gitconfig
create_symlink "$DOTFILES/.aerospace.toml" ~/.aerospace.toml
mkdir -p ~/.config/nvim
create_symlink "$DOTFILES/init.vim" ~/.config/nvim/init.vim
mkdir -p ~/.config/ghostty
create_symlink "$DOTFILES/ghostty.config" ~/.config/ghostty/config

# Claude Code
echo "Setting up Claude Code..."
mkdir -p ~/.claude
create_symlink "$DOTFILES/.agents/agents" ~/.claude/agents
create_symlink "$DOTFILES/.agents/commands" ~/.claude/commands
create_symlink "$DOTFILES/.claude/settings.json" ~/.claude/settings.json
create_symlink "$DOTFILES/.claude/CLAUDE.md" ~/.claude/CLAUDE.md

# OpenCode
echo "Setting up OpenCode..."
mkdir -p ~/.config/opencode
create_symlink "$DOTFILES/.agents/agents" ~/.config/opencode/agents

echo "Done!"
