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

# Agent config (hooks, shared agents) — used by Claude and others
echo "Setting up agent config..."
create_symlink "$DOTFILES/.agents" ~/.agents

# Claude Code
echo "Setting up Claude Code..."
mkdir -p ~/.claude/agents
# Symlink individual agent files (directory has other files from plugins)
for f in "$DOTFILES/.agents/agents/"*.md; do
  create_symlink "$f" ~/.claude/agents/"$(basename "$f")"
done
create_symlink "$DOTFILES/.agents/commands" ~/.claude/commands
create_symlink "$DOTFILES/.claude/settings.json" ~/.claude/settings.json
create_symlink "$DOTFILES/.claude/CLAUDE.md" ~/.claude/CLAUDE.md

# Cursor (global fallback when not in a project)
echo "Setting up Cursor..."
create_symlink "$DOTFILES/.cursor" ~/.cursor

# OpenCode
echo "Setting up OpenCode..."
mkdir -p ~/.config/opencode
create_symlink "$DOTFILES/.agents/agents" ~/.config/opencode/agents

echo "Done!"
