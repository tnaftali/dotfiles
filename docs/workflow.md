# AI Coding Workflow — Plan/Loop Pattern

## Core Idea

Long tasks are split into a **checkboxed plan file**, then executed by a shell loop that re-invokes Claude until every box is checked. Each iteration is one atomic unit of work — code, tests, commit, check the box, exit.

## Components

### 1. Global instructions (`~/.claude/CLAUDE.md`)

Every implementation plan must use checkbox syntax and include this execution header:

```markdown
## Execution

Work through tasks in order. For each unchecked `- [ ]` task:
1. Implement the changes described
2. Run tests to verify
3. Commit (if tests pass)
4. Check the box `- [x]` in this file

When all tasks are checked, run: `touch .ralph-done`
```

This turns any plan into something both a human-driven session and a loop can execute identically.

### 2. `ralph` — loop runner (`~/bin/ralph`)

```bash
ralph plan.md              # run until .ralph-done appears
ralph plan.md 10           # cap at 10 iterations
```

Behavior:
- Runs `claude --print --verbose --output-format stream-json < plan.md` in a loop
- Streams tool calls + text live via `jq`
- Exits when the agent creates `.ralph-done`, hits max iterations, or Ctrl-C
- Exports `RALPH_LOOP=1` and `RALPH_ITERATION=N` so agents can detect loop mode
- 3 s pause between iterations

Named after Ralph Wiggum — dumb, persistent, eventually gets there.

### 3. Slash commands (`~/.agents/commands/`, symlinked into `.claude/` and `.cursor/`)

Cross-tool via a single `.agents/` directory:

| Command | Purpose |
|---|---|
| `/create-implementation-plan` | Interactive plan builder — researches codebase, asks questions, writes checkboxed plan |
| `/implement-plan <path>` | Walks an existing plan, updating checkboxes |
| `/research-codebase` | Parallel codebase + thoughts research |
| `/review-plan` | Red-team a plan for bugs/inconsistencies before execution |
| `/review-branch` | Architecture/test review of current branch |
| `/commit-push-pr` | Format → test → commit → push → PR |
| `/format-run-tests-and-credo` | Elixir-specific QA |
| `/analyze-pr-comments`, `/triage-pr-comments` | PR feedback workflow |
| `/daily_brief` | Morning brief (calendar, notifications, priorities) |
| `/cleanup-and-simplify` | Refactor pass on diff |

### 4. Plan-maker agents (in `.agents/skills/` and `.agents/agents/`)

- `codebase-locator`, `codebase-analyzer`, `codebase-pattern-finder`
- `thoughts-locator`, `thoughts-analyzer`

Invoked by `/create-implementation-plan` to parallelize research before drafting.

## The Typical Flow

```bash
# 1. plan
claude /create-implementation-plan "ticket description or file"
# → produces plan.md with checkboxes + execution header

# 2. (optional) sanity check the plan
claude /review-plan plan.md

# 3. loop until done
ralph plan.md

# 4. ship
claude /commit-push-pr
```

For smaller tasks skip the loop and run the plan interactively — same file works both ways.

## Dotfiles Layout

```
~/dotfiles/
  bin/ralph                    # loop runner
  .agents/                     # shared across Claude/Cursor/OpenCode
    commands/                  # slash commands
    skills/                    # skill definitions
    agents/                    # subagent prompts
    hooks/                     # format/validate hooks
  .claude/
    CLAUDE.md                  # global rules (checkbox mandate)
    settings.json              # model, hooks, permissions
    commands → ../.agents/commands   # symlinks
    agents   → ../.agents/agents
  .cursor/                     # same symlink pattern
```

One source of truth, every AI tool sees the same commands.

## Why This Works

- **Checkboxes = resumable state.** Crash mid-iteration? Next run picks up at the first unchecked box.
- **One commit per task.** Clean history, easy rollback, loop can't accumulate mess.
- **`.ralph-done` sentinel.** Explicit completion signal — no timeouts or heuristics.
- **Same plan, two runtimes.** Interactive and loop share the execution header, so you can hand off either direction.
