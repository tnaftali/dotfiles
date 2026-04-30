# tmux session-tab attention indicator for Claude Code

**Date:** 2026-04-20
**Status:** Design approved, pending implementation
**Repository:** `~/dotfiles` (+ `~/.claude/settings.json`)

## Goal

Surface Claude Code state on tmux session pills so multi-session workflows don't miss attention events. Two tiers: task complete vs needs input.

## User context

- Uses multiple tmux sessions, typically one Claude pane per session.
- Current Claude notifications (`afplay` + macOS toast) are easy to miss when cross-session.
- Session tabs already custom-rendered in `status-left` (see `~/dotfiles/.tmux.conf:70-71`).

## Design

### Signaling

Claude Code hooks set a tmux user-option on the current session:

```bash
[ -n "$TMUX" ] && sess=$(tmux display -p '#{session_name}') \
  && tmux set -t "$sess" @claude_state needs_input
```

- `Stop` hook sets `@claude_state done`
- `Notification` hook (matcher `permission_prompt|idle_prompt|elicitation_dialog`) sets `@claude_state needs_input`
- Both appended to existing `afplay`/`osascript` commands; guarded by `[ -n "$TMUX" ]` so non-tmux runs unaffected.

### Rendering

`status-left` session template (in `.tmux.conf`) gets a fixed 2-char indicator slot inside both active and inactive pill branches. Slot renders:

- `needs_input` → red dot `#f38ba8` + space
- `done` → green dot `#a6e3a1` + space
- unset → two spaces

Fixed width keeps click-routing math deterministic.

```
#{?#{==:#{@claude_state},needs_input},#[fg=#f38ba8]●#[default] ,#{?#{==:#{@claude_state},done},#[fg=#a6e3a1]●#[default] ,  }}
```

Placed between name and right cap in the pill.

### Clearing

```
set-hook -g client-session-changed 'run-shell "tmux set -u -t \"#{hook_session_name}\" @claude_state"'
```

Fires when user focuses a session; unsets the option. If Claude is still waiting, the next `idle_prompt` event re-sets `needs_input`.

### Click-math update

`~/dotfiles/tmux/click-session.sh:6`: bump pill-width constant from `+ 5` to `+ 7` to account for the 2-char indicator slot.

## Files touched

| File | Change |
|------|--------|
| `~/.claude/settings.json` | Append `tmux set` to Stop + Notification hook commands |
| `~/dotfiles/.tmux.conf` | Update `status-left` template; add `set-hook client-session-changed` |
| `~/dotfiles/tmux/click-session.sh` | Change `len` formula to `${#session} + 7` |

## Colors (Catppuccin Mocha)

- needs_input → `#f38ba8` (red)
- done → `#a6e3a1` (green)

Active-session background blue `#89b4fa` and inactive grey `#45475a` unchanged. Dot on either background: red and green both readable on both bg colors — verified mentally against palette contrast.

## Non-goals

- No window-tab indicator (user works session-level).
- No integration with native `monitor-activity` / `bell` / `silence`.
- No per-pane state tracking.
- No persistence across tmux server restart (user-options vanish; Claude will re-fire).

## Edge cases

- **Non-tmux Claude run:** `[ -n "$TMUX" ]` guard skips. No-op.
- **Stop fires after needs_input:** state becomes `done` (green), masking unresolved prompt. Rare; user will see on focus, and next `idle_prompt` re-escalates.
- **Session renamed mid-work:** `@claude_state` is set against name at hook-fire time; rename doesn't carry it. Accept.
- **Concurrent Claude instances in one session:** last hook wins. Acceptable for session-level signal.

## Verification plan

1. Reload tmux config, confirm sessions render with 2-char padding (spaces) — no layout shift, clicks still hit correct session.
2. Manually run `tmux set -t <current> @claude_state needs_input` → red dot appears.
3. Switch away and back via `M-[` / click → dot clears.
4. Trigger real Claude Stop event → green dot on correct session.
5. Trigger a permission prompt → red dot on correct session.
6. Click a non-current session's pill with indicator active → switches correctly (width math works with dot present).

## Out-of-scope follow-ups

- Window-level indicator if multi-pane-per-session usage grows.
- Different glyph (e.g. `⏺` vs `●`) if dot clashes with other status bar elements.
- Optional sound suppression when tmux indicator already lights up.
