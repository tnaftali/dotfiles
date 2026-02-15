#!/bin/bash
mouse_x=$1
pos=0
tmux list-sessions -F '#{session_name}' | while read -r session; do
  # Each pill: left_cap(1) + space(1) + name(N) + space(1) + right_cap(1) + space(1) = N+5
  len=$(( ${#session} + 5 ))
  if [ "$mouse_x" -ge "$pos" ] && [ "$mouse_x" -lt "$(( pos + len ))" ]; then
    tmux switch-client -t "=$session"
    break
  fi
  pos=$(( pos + len ))
done
