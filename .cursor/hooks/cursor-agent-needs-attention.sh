#!/usr/bin/env bash
# Play "needs attention" sound + macOS notification (same as Claude Code Notification hook).
# Run when the Cursor agent needs user input. Use CURSOR_PROJECT_DIR or PWD for title.

set -euo pipefail
PROJECT_NAME="${CURSOR_PROJECT_DIR:-$PWD}"
PROJECT_NAME="${PROJECT_NAME##*/}"
afplay /System/Library/Sounds/Hero.aiff
osascript -e "display notification \"Needs attention\" with title \"Cursor Agent (${PROJECT_NAME})\""
