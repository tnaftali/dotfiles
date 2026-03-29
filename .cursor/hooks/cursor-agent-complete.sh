#!/usr/bin/env bash
# Play "task complete" sound + macOS notification (same as Claude Code Stop hook).
# Run when the Cursor agent finishes a task. Use CURSOR_PROJECT_DIR or PWD for title.

set -euo pipefail
PROJECT_NAME="${CURSOR_PROJECT_DIR:-$PWD}"
PROJECT_NAME="${PROJECT_NAME##*/}"
afplay /System/Library/Sounds/Glass.aiff
osascript -e "display notification \"Task Complete\" with title \"Cursor Agent (${PROJECT_NAME})\""
