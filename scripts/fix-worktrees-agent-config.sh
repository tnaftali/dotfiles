#!/usr/bin/env bash
# Fix existing worktrees: point .claude, .cursor, .mcp.json at the main repo
# so they share one config (and MCP). Run from the main repo, e.g.:
#   cd ~/Projects/core && ~/dotfiles/scripts/fix-worktrees-agent-config.sh

set -euo pipefail

main_repo="${1:-$(pwd)}"
if [[ ! -d "$main_repo/.git" ]]; then
  echo "Usage: run from main repo, or: $0 /path/to/main/repo"
  echo "Example: cd ~/Projects/core && $0"
  exit 1
fi

# Resolve main repo (first worktree is usually the main repo)
main_root=$(git -C "$main_repo" worktree list --porcelain | awk '/^worktree /{print $2; exit}')
if [[ -z "$main_root" || ! -d "$main_root" ]]; then
  echo "Could not determine main worktree root."
  exit 1
fi

echo "Main repo: $main_root"
echo ""

while IFS= read -r wt_path; do
  [[ -z "$wt_path" ]] && continue
  [[ "$wt_path" == "$main_root" ]] && continue
  [[ ! -d "$wt_path" ]] && continue

  echo "Worktree: $wt_path"
  cd "$wt_path" || continue

  if [[ -d ".claude" && ! -L ".claude" ]]; then
    rm -rf .claude
    ln -sf "$main_root/.claude" .claude
    echo "  .claude -> symlinked to main"
  elif [[ -L ".claude" ]]; then
    echo "  .claude already symlinked"
  fi

  if [[ -d ".cursor" && ! -L ".cursor" ]]; then
    rm -rf .cursor
    ln -sf "$main_root/.cursor" .cursor
    echo "  .cursor -> symlinked to main"
  elif [[ -L ".cursor" ]]; then
    echo "  .cursor already symlinked"
  fi

  if [[ -f "$main_root/.mcp.json" ]]; then
    if [[ -f ".mcp.json" && ! -L ".mcp.json" ]]; then
      rm -f .mcp.json
    fi
    ln -sf "$main_root/.mcp.json" .mcp.json
    echo "  .mcp.json -> symlinked to main"
  fi

  echo ""
done < <(git -C "$main_root" worktree list --porcelain | awk '/^worktree /{print $2}')

echo "Done."
