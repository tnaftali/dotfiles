#!/bin/bash
mouse_x=$1
pos=0
tmux list-sessions -F '#{session_id}:#{session_name}' | sort -t'$' -k2 -n | cut -d: -f2 | while read -r session; do
  # Each pill: left_cap(1) + space(1) + name(N) + space(1) + indicator(2) + right_cap(1) + space(1) = N+7
  len=$(( ${#session} + 7 ))
  if [ "$mouse_x" -ge "$pos" ] && [ "$mouse_x" -lt "$(( pos + len ))" ]; then
    tmux switch-client -t "=$session"
    break
  fi
  pos=$(( pos + len ))
done
