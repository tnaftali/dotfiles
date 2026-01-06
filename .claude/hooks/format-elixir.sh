#!/bin/bash
# Format Elixir files after Edit/Write operations
# Only runs if an Elixir file was modified

file_path=$(jq -r '.tool_input.file_path')

if [[ "$file_path" =~ \.exs?$ ]]; then
  cd "$CLAUDE_PROJECT_DIR" && mix format 2>/dev/null
fi

exit 0
