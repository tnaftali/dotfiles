#!/bin/sh
# Hardlink the custom Herdr mods into the app folder.
# Not symlinks: Herdr 0.1.8 does not load svg files behind a symlinked mod folder.
# Run it again after a git pull or checkout, which can replace the files and break the links.
set -e
src=$(cd "$(dirname "$0")" && pwd)/mods
dst=${HERDR_APP_HOME:-$HOME/.config/herdr-app}/mods
cd "$src"
find . -type f | while read -r f; do
  mkdir -p "$dst/$(dirname "$f")"
  ln -f "$src/$f" "$dst/$f"
done
