#!/usr/bin/env bash
# Gather MCP config from main + all worktrees (real .mcp.json only), merge into main's .mcp.json.
# Run from the main repo. Then run fix-worktrees-agent-config.sh so worktrees symlink to main.
#   cd ~/Projects/core && ~/dotfiles/scripts/merge-mcp-into-main.sh

set -euo pipefail

main_repo="${1:-$(pwd)}"
if [[ ! -d "$main_repo/.git" ]]; then
  echo "Usage: run from main repo, or: $0 /path/to/main/repo"
  exit 1
fi

main_root=$(git -C "$main_repo" worktree list --porcelain | awk '/^worktree /{print $2; exit}')
if [[ -z "$main_root" || ! -d "$main_root" ]]; then
  echo "Could not determine main worktree root."
  exit 1
fi

main_mcp="$main_root/.mcp.json"
merged=$(mktemp)
trap 'rm -f "$merged"' EXIT

echo '{"mcpServers":{}}' > "$merged"

# Merge main + every worktree's .mcp.json (real files only) into one config
collect() {
  local path="$1"
  local mcp="$path/.mcp.json"
  if [[ -f "$mcp" && ! -L "$mcp" ]] && jq -e '.mcpServers | keys | length > 0' "$mcp" >/dev/null 2>&1; then
    merged_prev=$(cat "$merged")
    jq -s '.[0].mcpServers * .[1].mcpServers | { mcpServers: . }' <(echo "$merged_prev") "$mcp" > "$merged"
  fi
}
collect "$main_root"
while IFS= read -r wt_path; do
  [[ -z "$wt_path" ]] && continue
  [[ "$wt_path" == "$main_root" ]] && continue
  [[ ! -d "$wt_path" ]] && continue
  collect "$wt_path"
done < <(git -C "$main_root" worktree list --porcelain | awk '/^worktree /{print $2}')

# Write back to main (only if main is the repo we're merging into)
if [[ -f "$merged" ]]; then
  jq . "$merged" > "$main_mcp"
  echo "Merged MCP config written to $main_mcp"
  cat "$main_mcp"
fi
