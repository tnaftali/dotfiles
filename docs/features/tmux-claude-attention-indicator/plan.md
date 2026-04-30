# tmux Claude Attention Indicator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show Claude Code state (task-done / needs-input) as coloured dot on tmux session pills.

**Architecture:** Claude Stop + Notification hooks write a per-session tmux user-option `@claude_state`. The `status-left` format renders a fixed-width 2-char indicator slot based on that option. tmux `client-session-changed` hook clears the option on focus. Session-pill click-math constant bumps `+5 → +7` to keep routing aligned.

**Tech Stack:** tmux 3.x, bash, macOS Claude Code hooks.

---

## Execution

Work through tasks in order. For each unchecked `- [ ]` task:
1. Implement the changes described
2. Run tests to verify
3. Commit (if tests pass)
4. Check the box `- [x]` in this file

When all tasks are checked, run: `touch .ralph-done`

---

## File Structure

| File | Responsibility |
|------|----------------|
| `~/dotfiles/.tmux.conf` | Session-pill format template + `client-session-changed` clear hook |
| `~/dotfiles/tmux/click-session.sh` | Pill-width math for click-to-switch |
| `~/.claude/settings.json` | Claude Stop + Notification hooks emit tmux-set commands |

No new files. Three existing files edited.

---

### Task 1: Bump click-session.sh width constant

Add the 2-char indicator slot to the width math before changing the format — keeps click routing correct while the format still renders 2 literal spaces (no visual change yet).

**Files:**
- Modify: `~/dotfiles/tmux/click-session.sh:6`

- [ ] **Step 1: Update format template first so widths match**

Edit `~/dotfiles/.tmux.conf:71` — insert a 2-char blank slot (`  `) into both branches of the `#{?session_attached,...}` template, between `#{session_name}` and the closing cap. Result preserves colors; adds 2 spaces per pill.

Replace the line with:
```
set -g status-left '#{S:#{?session_attached,#[fg=#89b4fa]#[bg=default]#[fg=#1e1e2e]#[bg=#89b4fa] #{session_name}   #[fg=#89b4fa]#[bg=default] ,#[fg=#45475a]#[bg=default]#[fg=#cdd6f4]#[bg=#45475a] #{session_name}   #[fg=#45475a]#[bg=default] }}'
```

(Note: the single space after `#{session_name}` becomes 3 spaces = original 1 + 2-char slot.)

- [ ] **Step 2: Update click-session.sh**

Edit `~/dotfiles/tmux/click-session.sh` — change line 6 from:
```bash
  len=$(( ${#session} + 5 ))
```
to:
```bash
  len=$(( ${#session} + 7 ))
```

- [ ] **Step 3: Reload tmux and verify pills still clickable**

Run:
```bash
tmux source-file ~/.tmux.conf
```

Expected: status bar renders; each session pill slightly wider (2 extra spaces). Click each session pill in turn; verify it switches to that session. Use `M-[` / `M-]` to confirm cycle still works.

- [ ] **Step 4: Commit**

```bash
cd ~/dotfiles
git add .tmux.conf tmux/click-session.sh
git commit -m "tmux: reserve 2-char slot in session pills for indicator"
```

---

### Task 2: Render coloured indicator from @claude_state

Replace the 2-char blank slot with a conditional format reading `#{@claude_state}`. Still no Claude integration; manual `tmux set` commands exercise it.

**Files:**
- Modify: `~/dotfiles/.tmux.conf:71`

- [ ] **Step 1: Replace the blank slot with conditional format**

Edit `~/dotfiles/.tmux.conf:71`. Replace the line with:
```
set -g status-left '#{S:#{?session_attached,#[fg=#89b4fa]#[bg=default]#[fg=#1e1e2e]#[bg=#89b4fa] #{session_name} #{?#{==:#{@claude_state},needs_input},#[fg=#f38ba8]●#[fg=#1e1e2e] ,#{?#{==:#{@claude_state},done},#[fg=#a6e3a1]●#[fg=#1e1e2e] ,  }}#[fg=#89b4fa]#[bg=default] ,#[fg=#45475a]#[bg=default]#[fg=#cdd6f4]#[bg=#45475a] #{session_name} #{?#{==:#{@claude_state},needs_input},#[fg=#f38ba8]●#[fg=#cdd6f4] ,#{?#{==:#{@claude_state},done},#[fg=#a6e3a1]●#[fg=#cdd6f4] ,  }}#[fg=#45475a]#[bg=default] }}'
```

Notes:
- Active branch: fg switches back to `#1e1e2e` after the dot so trailing space keeps original text colour.
- Inactive branch: fg switches back to `#cdd6f4`.
- Every branch emits exactly 2 visible characters (dot+space or two spaces) → click math unchanged.

- [ ] **Step 2: Reload and verify baseline (no state set = two spaces)**

```bash
tmux source-file ~/.tmux.conf
tmux show-options -sv @claude_state 2>/dev/null || echo "unset (expected)"
```

Expected: status bar unchanged visually (still blank slot).

- [ ] **Step 3: Set needs_input on current session, verify red dot**

```bash
sess=$(tmux display -p '#{session_name}')
tmux set -t "$sess" @claude_state needs_input
```

Expected: red `●` appears in current session's pill.

- [ ] **Step 4: Set done, verify green dot**

```bash
tmux set -t "$sess" @claude_state done
```

Expected: dot turns green.

- [ ] **Step 5: Unset, verify blank**

```bash
tmux set -u -t "$sess" @claude_state
```

Expected: dot disappears, blank slot back.

- [ ] **Step 6: Click pills with indicator present, verify switching still works**

Set `@claude_state needs_input` on a non-current session:
```bash
tmux list-sessions -F '#{session_name}' | grep -v "^$sess$" | head -1 | \
  xargs -I{} tmux set -t {} @claude_state needs_input
```

Click each pill. Verify correct session activates even with dot visible on some.

- [ ] **Step 7: Commit**

```bash
cd ~/dotfiles
git add .tmux.conf
git commit -m "tmux: render @claude_state as coloured dot on session pill"
```

---

### Task 3: Clear @claude_state on session focus

**Files:**
- Modify: `~/dotfiles/.tmux.conf` (append near other `set-hook`/options section; place after the status-right line)

- [ ] **Step 1: Add client-session-changed hook**

Append to `~/dotfiles/.tmux.conf` (after line 78, before the final blank line):

```
# Clear Claude attention indicator when session is focused
set-hook -g client-session-changed 'run-shell "tmux set -u -t \"#{hook_session_name}\" @claude_state 2>/dev/null || true"'
```

- [ ] **Step 2: Reload**

```bash
tmux source-file ~/.tmux.conf
```

- [ ] **Step 3: Verify clear-on-focus**

```bash
other=$(tmux list-sessions -F '#{session_name}' | grep -v "^$(tmux display -p '#{session_name}')$" | head -1)
tmux set -t "$other" @claude_state needs_input
```

Red dot should appear on `$other`'s pill.

Switch to it:
```bash
tmux switch-client -t "=$other"
```

Expected: dot disappears. Confirm by:
```bash
tmux show-options -t "$other" -v @claude_state 2>/dev/null; echo "exit=$?"
```
Expected: empty output, `exit=1` (option unset).

- [ ] **Step 4: Commit**

```bash
cd ~/dotfiles
git add .tmux.conf
git commit -m "tmux: clear @claude_state on session focus"
```

---

### Task 4: Wire Claude Stop hook → @claude_state done

**Files:**
- Modify: `~/.claude/settings.json` (Stop hook command)

- [ ] **Step 1: Back up settings.json**

```bash
cp ~/.claude/settings.json ~/.claude/settings.json.bak
```

- [ ] **Step 2: Update Stop hook command**

Current command (one line):
```
bash -c 'afplay /System/Library/Sounds/Glass.aiff && osascript -e "display notification \"Task Complete\" with title \"Claude Code (${CLAUDE_PROJECT_DIR##*/})\""'
```

Replace with (still one line — settings.json is JSON, use `\"` escaping):
```
bash -c 'afplay /System/Library/Sounds/Glass.aiff && osascript -e "display notification \"Task Complete\" with title \"Claude Code (${CLAUDE_PROJECT_DIR##*/})\""; [ -n "$TMUX" ] && sess=$(tmux display -p "#{session_name}") && tmux set -t "$sess" @claude_state done'
```

Use your editor of choice; confirm JSON still valid:
```bash
python3 -m json.tool < ~/.claude/settings.json > /dev/null && echo OK
```
Expected: `OK`.

- [ ] **Step 3: Manually simulate the hook command**

From inside a tmux pane:
```bash
bash -c '[ -n "$TMUX" ] && sess=$(tmux display -p "#{session_name}") && tmux set -t "$sess" @claude_state done'
```

Expected: green dot on current session pill.

- [ ] **Step 4: Verify clears on focus change**

Switch to another session and back:
```bash
tmux switch-client -n    # next session
tmux switch-client -p    # back
```

Expected: dot gone after focus returned (client-session-changed hook fired on switch away).

- [ ] **Step 5: Commit (settings.json lives in ~/.claude, separate repo if any)**

If `~/.claude` is git-tracked:
```bash
cd ~/.claude && git add settings.json && git commit -m "claude: signal tmux @claude_state=done on Stop hook"
```
Otherwise leave as working change.

---

### Task 5: Wire Claude Notification hook → @claude_state needs_input

**Files:**
- Modify: `~/.claude/settings.json` (Notification hook command, matcher `permission_prompt|idle_prompt|elicitation_dialog`)

- [ ] **Step 1: Update Notification hook command**

Current:
```
bash -c 'env > /tmp/claude-hook-env.txt && afplay /System/Library/Sounds/Hero.aiff && osascript -e "display notification \"Needs attention\" with title \"Claude Code (${PWD##*/})\""'
```

Replace with:
```
bash -c 'env > /tmp/claude-hook-env.txt && afplay /System/Library/Sounds/Hero.aiff && osascript -e "display notification \"Needs attention\" with title \"Claude Code (${PWD##*/})\""; [ -n "$TMUX" ] && sess=$(tmux display -p "#{session_name}") && tmux set -t "$sess" @claude_state needs_input'
```

Validate JSON:
```bash
python3 -m json.tool < ~/.claude/settings.json > /dev/null && echo OK
```

- [ ] **Step 2: Simulate**

```bash
bash -c '[ -n "$TMUX" ] && sess=$(tmux display -p "#{session_name}") && tmux set -t "$sess" @claude_state needs_input'
```

Expected: red dot on current session pill.

- [ ] **Step 3: End-to-end verify with a real Claude run**

In another tmux session, start `claude` in a project dir. Issue a command that triggers a permission prompt (e.g. a file write in a non-permissive dir). Observe the originating session's pill turn red in the status bar of *this* session too (since `status-left` shows all sessions).

Switch to that session → dot clears.

Trigger a task completion (end of Claude reply with no further action) → dot turns green.

- [ ] **Step 4: Commit**

If `~/.claude` git-tracked:
```bash
cd ~/.claude && git add settings.json && git commit -m "claude: signal tmux @claude_state=needs_input on Notification hook"
```

---

### Task 6: Cleanup + documentation

- [ ] **Step 1: Remove backup**

```bash
rm ~/.claude/settings.json.bak
```

- [ ] **Step 2: Update dotfiles README if tmux section exists**

Check for a README in `~/dotfiles/tmux/` or main `~/dotfiles/README.md`. If one exists and documents tmux bindings, add a line under a new "Claude Code integration" subsection:

> Session pills display a red dot when Claude needs input, green when a task completes. Dot clears on session focus. Powered by `@claude_state` user-option set from Claude Code Stop/Notification hooks.

If no README section exists, skip this step.

- [ ] **Step 3: Final verification run**

Run all of:
```bash
tmux kill-server    # optional clean restart; only if comfortable
# or:
tmux source-file ~/.tmux.conf
```

Start two sessions. Start `claude` in one. Trigger a prompt. Switch sessions. Confirm behaviour end-to-end.

- [ ] **Step 4: Final commit (if any pending)**

```bash
cd ~/dotfiles && git status
```

Commit any remaining tracked changes with an appropriate message. Leave untracked files alone.

---

## Verification checklist (end-to-end)

- [ ] Session pills render with 2-char-wider width; no visual regression otherwise.
- [ ] Clicks on every session pill switch correctly (including pills with an active indicator).
- [ ] `M-[` and `M-]` still cycle sessions.
- [ ] Manual `tmux set @claude_state needs_input` shows red dot.
- [ ] Manual `tmux set @claude_state done` shows green dot.
- [ ] Focusing a session clears its indicator.
- [ ] Real Claude Stop event → green dot on that session.
- [ ] Real Claude permission prompt → red dot on that session.
- [ ] Non-tmux Claude run (outside `$TMUX`) does not error.
