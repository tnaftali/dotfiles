#!/bin/bash
# Setup script - creates symlinks from home directory to dotfiles

set -eu

DOTFILES="$HOME/dotfiles"

# Helper function to create symlinks with idempotency checks.
# IMPORTANT: `ln -sf src target` follows existing symlinks-to-dirs and creates
# inside them, producing bogus `target/basename(src)` links. We avoid that by
# explicitly removing existing symlinks first.
create_symlink() {
  local source="$1"
  local target="$2"

  # Strip trailing slash so basename comparisons work
  source="${source%/}"

  if [ -L "$target" ]; then
    local current_target
    current_target=$(readlink "$target")
    if [ "$current_target" = "$source" ]; then
      return 0  # already correct
    fi
    rm "$target"
  elif [ -e "$target" ]; then
    echo "  Warning: $target exists as a regular file/dir; refusing to replace"
    return 0
  fi
  ln -s "$source" "$target"
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
create_symlink "$DOTFILES/.claude/settings.local.json" ~/.claude/settings.local.json
create_symlink "$DOTFILES/.claude/CLAUDE.md" ~/.claude/CLAUDE.md
create_symlink "$DOTFILES/.claude/RTK.md" ~/.claude/RTK.md
# Skills (each gets its own symlink; ~/.claude/skills/ also holds plugin entries)
mkdir -p ~/.claude/skills
for d in "$DOTFILES/.agents/skills/"*/; do
  [ -d "$d" ] || continue
  create_symlink "$d" ~/.claude/skills/"$(basename "$d")"
done

# Cursor (global fallback when not in a project)
# NOTE: Cursor pre-creates ~/.cursor as a state dir, so we cannot symlink the
# whole dir — we symlink individual entries inside it.
echo "Setting up Cursor..."
mkdir -p ~/.cursor
# Remove bogus ~/.cursor/.cursor link from earlier setup.sh runs
[ -L ~/.cursor/.cursor ] && rm ~/.cursor/.cursor
for entry in agents commands hooks rules; do
  create_symlink "$DOTFILES/.cursor/$entry" ~/.cursor/"$entry"
done
mkdir -p ~/.cursor/skills
for d in "$DOTFILES/.agents/skills/"*/; do
  [ -d "$d" ] || continue
  create_symlink "$d" ~/.cursor/skills/"$(basename "$d")"
done

# OpenCode
echo "Setting up OpenCode..."
mkdir -p ~/.config/opencode
create_symlink "$DOTFILES/.agents/agents" ~/.config/opencode/agents

echo "Done!"
