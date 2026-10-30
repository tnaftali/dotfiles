#!/bin/sh
# Give Herdr.app the dark ram icon (icon-dark.icns). macOS only.
# Finder-style custom icon: adds an Icon file to the bundle root; the signature still verifies.
# Run it again after a Herdr update, which replaces the app and its icon.
set -e
app=${1:-/Applications/Herdr.app}
icon=$(cd "$(dirname "$0")" && pwd)/icon-dark.icns
osascript -l JavaScript -e "ObjC.import('AppKit'); \$.NSWorkspace.sharedWorkspace.setIconForFileOptions(\$.NSImage.alloc.initWithContentsOfFile('$icon'), '$app', 0) || 'failed'"
