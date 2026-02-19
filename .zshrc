#═══════════════════════════════════════════════════════════════════════════════
# ZSH CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════════

# ── Oh My Zsh Setup ─────────────────────────────────────────────────────────────
export ZSH="/Users/tobi/.oh-my-zsh"

# ZSH_THEME="avit"
ZSH_THEME="agnoster-newline"

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
LANG="en_US.UTF-8"
DISABLE_AUTO_TITLE="true"
unset MAILCHECK

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  docker
  sudo
  history
  extract
  last-working-dir
  z
  asdf
)

source $ZSH/oh-my-zsh.sh

# ── Environment Variables ───────────────────────────────────────────────────────
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8
export EDITOR='nvim'
export ARCHFLAGS="-arch x86_64"
export SSH_KEY_PATH="~/.ssh/id_rsa"
export TERM="xterm-256color"

# Development Environment Variables
export MASTER_PASSWORD_REQUIRED="False"
export PGPASSWORD="postgres"
export ERL_AFLAGS="-kernel shell_history enabled -kernel shell_history_file_bytes 1024000"

# Node.js & NPM Configuration
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`
export DISABLE_OPENCOLLECTIVE=1
export ADBLOCK=1

# ── Aliases ─────────────────────────────────────────────────────────────────────
# Development Server Aliases
alias srcsrv="source .local.env && nvm use 20 && iex -S mix phx.server"
alias srctst="source .local.env && MIX_ENV=test bin/migrate && mix test --color; afplay /System/Library/Sounds/Ping.aiff"
alias srctstbf="source .local.env && MIX_ENV=test bin/migrate && mix test apps/betafolio/test --color; afplay /System/Library/Sounds/Ping.aiff"
alias srctstcr="source .local.env && MIX_ENV=test bin/migrate && mix test apps/core/test --color; afplay /System/Library/Sounds/Ping.aiff"

# Git Aliases
alias gas="git add . && git status"
alias gs="git status"
alias gc="git checkout $1"
alias gp="git pull origin $1"
alias gdiff="git diff --staged --color-words"

# Configuration Reload Aliases
alias srcz="source ~/dotfiles/.zshrc"
alias srct="tmux source-file ~/dotfiles/.tmux.conf"

# Utility Aliases
alias list="exa --long --header --git --icons --all"
alias lg="lazygit"
alias nv="nvim"
alias fm="frogmouth"
alias t="tmux a"

# ── Node Version Manager (NVM) Setup ────────────────────────────────────────────
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
source $(brew --prefix nvm)/nvm.sh

# export DEFAULT_USER=""

prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.) $USER"
  fi
}

# ── System Configuration ────────────────────────────────────────────────────────
defaults write -g NSWindowShouldDragOnGesture -bool true

# Aerospace Window Manager
# Move to the next/prev workspace on the current monitor silently
aerospace workspace next --wrap-around > /dev/null 2>&1
aerospace workspace prev --wrap-around > /dev/null 2>&1

# ── Additional PATH Configuration ───────────────────────────────────────────────
# # Add the .mix directory for the current GLOBAL asdf version to the PATH (for rebar/rebar3)
export PATH="${HOME}/.asdf/installs/elixir/`asdf current elixir | awk '{print $1}'`/.mix:${PATH}"

# ── System Greeting ─────────────────────────────────────────────────────────────
neofetch

# ── Custom Functions ────────────────────────────────────────────────────────────
# Worktrees function START
# Git worktree helper function: wt <feature-name>
wt() {
  emulate -L zsh             # localise options for zsh
  # Don't use set -e to avoid crashes on errors

  local project_dir
  project_dir=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "❌ Not inside a Git repository."
    return 1
  }

  local project_name feature_name worktree_parent worktree_path
  project_name="${project_dir:t}"
  feature_name="$1"

  if [[ -z "$feature_name" ]]; then
    echo "❌ Usage: wt <feature-name>"
    return 1
  fi

  worktree_parent="${project_dir:h}/${project_name}-worktrees"
  worktree_path="${worktree_parent}/${feature_name}"
  mkdir -p "$worktree_parent" || {
    echo "❌ Failed to create worktree parent directory."
    return 1
  }

  git -C "$project_dir" worktree add -b "$feature_name" "$worktree_path" || {
    echo "❌ Failed to create git worktree."
    return 1
  }

  if [[ -f "$project_dir/.env" ]]; then
    cp "$project_dir/.env" "$worktree_path/.env" && echo "📋 Copied .env into worktree."
  fi

  if [[ -f "$project_dir/.local.env" ]]; then
    cp "$project_dir/.local.env" "$worktree_path/.local.env" && echo "📋 Copied .local.env into worktree."
  fi

  local hidden_dirs=(.instrumental .agent_os .claude .cursor)
  for dir in $hidden_dirs; do
    if [[ -d "$project_dir/$dir" ]]; then
      cp -R "$project_dir/$dir" "$worktree_path/$dir" && echo "📂 Copied $dir into worktree."
    fi
  done

  cd "$worktree_path" || {
    echo "❌ Failed to change to worktree directory."
    return 1
  }

  # Use correct Node version for npm install
  if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Ensure nvm is properly loaded in this subshell
    export NVM_DIR="$HOME/.nvm"
    source "$NVM_DIR/nvm.sh" 2>/dev/null || true

    # Try to use node 20 (trying specific version first, then any 20.x)
    nvm use 20.19 &>/dev/null || nvm use 20 &>/dev/null || echo "⚠️  Could not switch to Node 20"
  fi

  # Temporarily disable engine-strict to avoid version mismatch errors
  local old_engine_strict
  old_engine_strict=$(npm config get engine-strict 2>/dev/null || echo "false")
  npm config set engine-strict false 2>/dev/null || true

  # Run npm install with error handling - use --force to bypass engine checks if needed
  echo "📦 Installing npm dependencies..."
  if ! npm install 2>&1; then
    echo "⚠️  npm install had issues, trying with --force..."
    if ! npm install --force 2>&1; then
      echo "⚠️  npm install failed, but continuing..."
    fi
  fi

  # Restore original engine-strict setting
  npm config set engine-strict "$old_engine_strict" 2>/dev/null || true

  # Run mix commands with error handling
  echo "🔧 Getting Elixir dependencies..."
  mix deps.get || {
    echo "⚠️  mix deps.get had issues, but continuing..."
  }

  echo "🔨 Compiling Elixir code..."
  mix compile || {
    echo "⚠️  mix compile had issues, but continuing..."
  }

  # if command -v cursor &>/dev/null; then
  #   # Launch cursor in background without blocking the shell
  #   (cursor "$worktree_path" &) 2>/dev/null
  # else
  #   echo "💡 Tip: Install Cursor or open manually in your editor."
  # fi

  echo "✅ Worktree '$feature_name' created at $worktree_path and checked out."
}

# Worktrees END

# 3. The Title Function: folder | command
_update_ghostty_title() {
  local folder="%1~"
  local cmd="${1:-zsh}"
  # Esc sequence to set title
  print -Pn "\e]0;${folder} | ${cmd}\a"
}

# 4. Define the hooks
_title_preexec() { _update_ghostty_title "${1%% *}" }
_title_precmd()  { _update_ghostty_title "zsh" }

# 5. Manual Title / Reset Function
title() {
  if [[ -z "$1" ]]; then
    add-zsh-hook preexec _title_preexec
    add-zsh-hook precmd _title_precmd
    _update_ghostty_title "zsh"
    echo "Default titles enabled."
  else
    add-zsh-hook -d preexec _title_preexec
    add-zsh-hook -d precmd _title_precmd
    print -Pn "\e]0;$1\a"
    echo "Manual title set to: $1"
  fi
}

# 6. Initialize hooks on startup
add-zsh-hook preexec _title_preexec
add-zsh-hook precmd _title_precmd

# ── PATH Configuration ──────────────────────────────────────────────────────────
export PATH="/opt/homebrew/bin:/opt/homebrew/opt/postgresql@16/bin:$PATH"

# Created by `pipx` on 2025-07-08 13:14:22
export PATH="$PATH:/Users/tobi/.local/bin"

# ── Shell History & Completion ──────────────────────────────────────────────────
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# opencode
export PATH=/Users/tobi/.opencode/bin:$PATH
