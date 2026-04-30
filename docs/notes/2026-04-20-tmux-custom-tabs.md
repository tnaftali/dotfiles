---
date: 2026-04-20T11:05:20+01:00
researcher: tobi
git_commit: ce7b007ddbcffc20e7cb7276e74064df581c69e8
branch: main
repository: dotfiles
topic: "Custom tmux tabs — how they work, adding attention indicator"
tags: [research, tmux, status-bar, sessions, windows]
status: complete
last_updated: 2026-04-20
last_updated_by: tobi
---

# Research: Custom tmux tabs

**Date**: 2026-04-20 11:05 +01:00
**Researcher**: tobi
**Git Commit**: ce7b007
**Branch**: main
**Repository**: dotfiles

## Research Question
How do my custom tmux "tabs" work, and where/how to add an attention indicator?

## Summary
Two tab-like UI elements in status bar, both hand-rolled via `status-left` / `window-status-*` format strings with Catppuccin-inspired pill styling:

1. **Session tabs** (left side) — rendered by `status-left` using `#{S:...}` iterator over all sessions. Active session = blue pill, inactive = grey. Click routed via `MouseDown1StatusLeft` hook → `click-session.sh` computes pill under cursor by measuring name length. `M-[` / `M-]` cycle via `cycle-session.sh`.
2. **Window tabs** (per-session) — rendered by `window-status-format` / `window-status-current-format`. Active = orange pill, inactive = grey. Standard tmux mechanism; no custom script.

Both use 3-segment pill format: `left-cap #[invert] name #[invert] right-cap` with same fg/bg swap trick to fake rounded edges.

For attention indicator: tmux already tracks two flags natively — `window_activity_flag` and `window_bell_flag` (windows), plus `session_alerts` (sessions, aggregated from windows). Hook into these inside the format strings with `#{?flag,on,off}` ternaries. No custom daemon needed.

## Detailed Findings

### Session tabs
- `~/dotfiles/.tmux.conf:70-71` — `status-left-length 300` then `status-left` uses `#{S:...}` which repeats inner template for each session.
- Template: `#{?session_attached, <active-pill>, <inactive-pill>}` with `#{session_name}` substituted.
- Active pill colors: fg `#89b4fa` (blue) cap, fg `#1e1e2e` text on bg `#89b4fa`.
- Inactive pill colors: fg `#45475a` cap, fg `#cdd6f4` text on bg `#45475a`.
- Pill structure: `cap_left` + ` ` + `name` + ` ` + `cap_right` + trailing ` ` separator.

### Session click routing
- `~/dotfiles/.tmux.conf:33` — `bind -n MouseDown1StatusLeft run-shell '~/dotfiles/tmux/click-session.sh #{mouse_x}'`
- `~/dotfiles/tmux/click-session.sh:1-13` — iterates sessions sorted by `session_id` numeric suffix, computes each pill's width as `len(name) + 5` (2 caps + 2 spaces + 1 trailing). First pill whose range contains `mouse_x` wins → `tmux switch-client -t "=$name"`.
- **Fragility**: hard-coded width math must match format string exactly. If you add an attention glyph, `len` calc needs updating.

### Session cycling
- `~/dotfiles/.tmux.conf:26-27` — `M-[` / `M-]` bound to `cycle-session.sh prev|next`.
- `~/dotfiles/tmux/cycle-session.sh:1-17` — same sort order as click script, modulo arithmetic on array index.

### Window tabs
- `~/dotfiles/.tmux.conf:77-78` — format strings for each window in current session.
- `window-status-format` = grey pill, `window-status-current-format` = orange pill. Uses `#W` (window name).
- No click / cycle scripts — tmux default window switching applies.

### Other status bar pieces
- `~/dotfiles/.tmux.conf:74` — right-side directory pill (orange, shows `#{b:pane_current_path}` basename).
- `~/dotfiles/.tmux.conf:51,58-62` — Catppuccin plugin loaded but mostly overridden. Post-plugin overrides at line 67+ set final look.

## Adding an attention indicator

### Available tmux flags
- `window_activity_flag` — set when window has activity and `monitor-activity on`.
- `window_bell_flag` — set on bell (`monitor-bell on`, default).
- `window_silence_flag` — set on silence timeout (`monitor-silence N`).
- `window_last_flag` — last-used window (not attention, just FYI).
- `session_alerts` — comma list like `1!,3~` aggregated per session. Non-empty string = attention somewhere.

Enable monitoring:
```
setw -g monitor-activity on
set -g visual-activity off   # don't print "Activity in window N" message
```

### Window tab indicator (easy)
Tweak `window-status-format` to include a dot when flag set:
```
set -g window-status-format "#[fg=#45475a,bg=default]#[fg=#cdd6f4,bg=#45475a] #W#{?window_activity_flag, ●,}#{?window_bell_flag, !,} #[fg=#45475a,bg=default]"
```
Current window format usually doesn't need indicator (you're looking at it) — tmux auto-clears the flag on select.

### Session tab indicator (harder, two catches)

**Catch 1**: inside `#{S:...}` the current session is `session_name`; check `#{session_alerts}` per iterated session. Format:
```
#{?session_alerts, ●,}
```

**Catch 2**: `click-session.sh` hard-codes `len = ${#session} + 5`. If you add a 2-char suffix (` ●`), update to `+ 7` *only when alert present*. Safer: add the indicator *outside* the clickable name, or bake a fixed-width slot (always 2 chars, space when no alert) so math stays constant:

```bash
# always reserve 2 chars for indicator
len=$(( ${#session} + 7 ))
```

And format:
```
#{?session_alerts, ●, }
```

Two trailing chars always, keeps click math deterministic.

### Color choice
Catppuccin palette already in use:
- Red `#f38ba8` — bell / urgent
- Yellow `#f9e2af` — activity
- Peach `#fab387` — already = active window
- Blue `#89b4fa` — already = active session

Suggest yellow dot for activity, red for bell:
```
#{?window_bell_flag,#[fg=#f38ba8] ●#[default],#{?window_activity_flag,#[fg=#f9e2af] ●#[default], }}
```

## Code References
- `~/dotfiles/.tmux.conf:70-71` — session tab `status-left`
- `~/dotfiles/.tmux.conf:77-78` — window tab formats
- `~/dotfiles/.tmux.conf:33` — click binding
- `~/dotfiles/.tmux.conf:26-27` — cycle bindings
- `~/dotfiles/tmux/click-session.sh:6` — pill-width math (`${#session} + 5`)
- `~/dotfiles/tmux/cycle-session.sh:4` — session sort order

## Architecture Insights
- Pill effect = 3 color segments swapping fg/bg. No Unicode rounded caps used currently — just space-padded solid blocks. Could add `` / `` Powerline caps if fonts support.
- Session ordering anchored on numeric `session_id` suffix (`$0`, `$1`, ...), stable across renames.
- Click math is the fragile link. Any format change touching session tab width requires `click-session.sh` update. Consider emitting actual pill widths from tmux via `#{E:...}` eval + wrapper, or switching to fixed-width names, to decouple.
- No existing attention/alert code — flags untouched, `monitor-activity` likely default-off. Enabling it is the first step.

## Open Questions
- Should inactive-but-attached windows on *other* sessions show indicator in session tab? (`session_alerts` covers this.)
- Want silence monitoring for long-running builds? Needs per-window `monitor-silence N`.
- Accept the extra click-math maintenance cost, or refactor to fixed-width pills first?
