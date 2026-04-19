# Global AI Agent Guidelines

- Never commit or push unless explicitly asked — leave files unstaged for review, don't run git add or git commit
- When using Bash, prefer user-installed CLI tools over defaults. Before falling back to basic commands, check if a better tool is available (e.g. `which fd`, `which rg`). Use what's installed.
- Be concise. No preamble, no summaries, no restating what I said.
- I'm a senior engineer. Skip basic explanations unless I ask for them.

## Implementation Plans

When creating implementation plans (any method — command, skill, or freeform), always include:

- **Checkbox syntax** (`- [ ]`) for every task/step — these track progress
- **This header** at the top of the plan, after the title:

```
## Execution

Work through tasks in order. For each unchecked `- [ ]` task:
1. Implement the changes described
2. Run tests to verify
3. Commit (if tests pass)
4. Check the box `- [x]` in this file

When all tasks are checked, run: `touch .ralph-done`
```

This format works both interactively and with the ralph loop (`ralph plan.md`).
