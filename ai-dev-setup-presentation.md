# Local Development Setup with AI

## 1. Aerospace Window Manager

Tiling window manager for macOS (like i3 on Linux). Windows auto-tile to fill space, keyboard-driven navigation with HJKL, instant workspace switching. No more hunting for buried windows.

## 2. Ghostty Terminal

Modern GPU-accelerated terminal by Mitchell Hashimoto.

**AI-relevant config:**
- `keybind = shift+enter=text:\x1b\r` - newline without submitting (multi-line Claude input)
- `scrollback-limit = 100000000` - massive scrollback for long Claude outputs
- `copy-on-select = clipboard` - easy copying of Claude's output
- `desktop-notifications = true` - works with Claude's notification hooks
- Split panes with vim navigation (`ctrl+h/j/k/l`) - Claude in one pane, code in another

## 3. Claude Code

### Config Strategy

Dotfiles repo symlinked to `~/.claude/`:
```
~/.claude/settings.json  → dotfiles/.claude/settings.json
~/.claude/commands/      → dotfiles/.claude/commands/
~/.claude/hooks/         → dotfiles/.claude/hooks/
```

### Settings

- **Default model:** Opus
- **Pre-approved permissions:** git, gh, mix, npm, docker, psql, common CLI tools
- **Plugins:** code-review, code-simplifier

### No MCPs - CLI Tools Instead

Not using MCP servers. Claude uses CLI tools directly:
- `gh` for GitHub (PRs, issues, checks)
- `psql` for database queries
- `curl` for APIs

Simple, no extra infrastructure, same tools devs use manually.

### Hooks

| Hook | Trigger | Action |
|------|---------|--------|
| Stop | Task complete | Sound + macOS notification |
| Notification | Needs attention | Sound + macOS notification |
| PostToolUse | Edit/Write .ex files | Auto-run `mix format` |

### Status Line

```
~/Projects/core [opus-4.5] (main *) [42%]
```
Directory, model, git branch (with dirty indicator), context window usage.

### Global Commands (dotfiles)

| Command | Purpose |
|---------|---------|
| `/commit-push-pr` | Format → commit → push → create PR |
| `/format-run-tests-and-credo` | Format → test → credo |
| `/create-verify-unit-tests` | Review/add missing tests |
| `/cleanup-and-simplify` | Remove debug logs, dead code |

## 4. Project-Specific Config (Core)

### Commands

| Command | Purpose |
|---------|---------|
| `/research_codebase` | Parallel research agents → synthesized doc with file:line refs |
| `/create_implementation_plan` | Interactive planning with research → phased plan |
| `/implement_plan` | Execute plan phase-by-phase, verify with tests |
| `/create_pr_description` | Analyze diff → generate PR in team template |
| `/fix_credo_diff` | Fix Credo warnings only in branch diff |
| `/increase_test_coverage` | Analyze gaps → write tests to 80%+ |

### Custom Agents

Sub-agents spawned by commands for parallel work:

| Agent | Purpose |
|-------|---------|
| `codebase-locator` | Find WHERE code lives |
| `codebase-analyzer` | Analyze HOW code works |
| `codebase-pattern-finder` | Find similar implementations to model after |
| `thoughts-locator` | Find docs in thoughts/ directory |
| `thoughts-analyzer` | Extract insights from research docs |

Design principle: Agents document what exists, don't critique or suggest improvements.

## Demo Ideas

1. Hooks in action: start task → switch windows → hear notification
2. Auto-formatting: edit .ex file → `mix format` runs automatically
3. CLI tools: Claude using `gh` or `psql`
4. `/research_codebase` → parallel agents → synthesized output
5. Full cycle: `/create_implementation_plan` → `/implement_plan` → `/commit-push-pr`
