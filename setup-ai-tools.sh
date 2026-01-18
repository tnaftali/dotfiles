#!/bin/bash
# Setup script for AI tools - creates symlinks from home directory to dotfiles

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

echo "Setting up AI tools from $DOTFILES..."

# Claude Code
echo "Setting up Claude Code..."
mkdir -p ~/.claude
create_symlink "$DOTFILES/.agents/agents" ~/.claude/agents
create_symlink "$DOTFILES/.agents/commands" ~/.claude/commands
create_symlink "$DOTFILES/.claude/settings.json" ~/.claude/settings.json

# OpenCode
echo "Setting up OpenCode..."
mkdir -p ~/.config/opencode
create_symlink "$DOTFILES/.agents/agents" ~/.config/opencode/agents

# Gemini CLI
echo "Setting up Gemini CLI..."
mkdir -p ~/.gemini
create_symlink "$DOTFILES/.agents/AGENTS.md" ~/.gemini/GEMINI.md

# Cursor (VS Code fork) - app settings
echo "Setting up Cursor app settings..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    CURSOR_DIR="$HOME/Library/Application Support/Cursor/User"
else
    CURSOR_DIR="$HOME/.config/Cursor/User"
fi
mkdir -p "$CURSOR_DIR"
create_symlink "$DOTFILES/ide/settings.json" "$CURSOR_DIR/settings.json"
create_symlink "$DOTFILES/ide/keybindings.json" "$CURSOR_DIR/keybindings.json"

# Google Antigravity - global skills
echo "Setting up Google Antigravity..."
mkdir -p ~/.gemini/antigravity
create_symlink "$DOTFILES/.agents/skills" ~/.gemini/antigravity/skills

echo "Done! AI tools configured."
