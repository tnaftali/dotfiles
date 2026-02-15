#!/bin/bash
direction=$1
current=$(tmux display-message -p '#{session_name}')
sessions=($(tmux list-sessions -F '#{session_name}'))
count=${#sessions[@]}

for i in "${!sessions[@]}"; do
  if [ "${sessions[$i]}" = "$current" ]; then
    if [ "$direction" = "next" ]; then
      idx=$(( (i + 1) % count ))
    else
      idx=$(( (i - 1 + count) % count ))
    fi
    tmux switch-client -t "=${sessions[$idx]}"
    break
  fi
done
