#!/bin/bash
# Elm validation hook (Claude Code / Cursor agent)
# Runs after Edit/Write operations to validate Elm files
# Warns on compilation errors but does not block (exit 0)

# Read JSON input from stdin (if any)
INPUT=$(cat 2>/dev/null || true)

# Extract file path from tool_input (Claude) or first arg (Cursor)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
if [[ -z "$FILE_PATH" && -n "$1" ]]; then
  FILE_PATH="$1"
fi

# Exit early if no file path
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Exit early if not an Elm file
if [[ ! "$FILE_PATH" =~ \.elm$ ]]; then
    exit 0
fi

# Project root: Claude, Cursor, or script location
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${CURSOR_PROJECT_DIR:-$(cd "$(dirname "$0")/../../.." && pwd)}}"
cd "$PROJECT_DIR"

# Run elm make to validate (capture both stdout and stderr)
if OUTPUT=$(elm make "$FILE_PATH" --output=/dev/null 2>&1); then
    # Compilation succeeded
    echo "Elm validation passed: $FILE_PATH"
else
    # Compilation failed - warn but don't block
    echo "WARNING: Elm compilation failed for $FILE_PATH"
    echo ""
    echo "$OUTPUT"
    echo ""
    echo "Please fix the compilation errors before proceeding."
fi

# Always exit 0 (warn only, don't block)
exit 0
