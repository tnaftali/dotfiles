#!/bin/sh
# Hardlink the custom Herdr mods into the app folder.
# Not symlinks: Herdr (checked on 0.1.9) does not load svg files through a symlink.
# Run it again after a git pull or checkout, which can replace the files and break the links.
set -e
src=$(cd "$(dirname "$0")" && pwd)/mods
dst=${HERDR_APP_HOME:-$HOME/.config/herdr-app}/mods
cd "$src"
find . -type f | while read -r f; do
  mkdir -p "$dst/$(dirname "$f")"
  ln -f "$src/$f" "$dst/$f"
done
