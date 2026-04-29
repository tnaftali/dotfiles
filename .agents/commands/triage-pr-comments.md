---
description: Interactively triage PR comment analysis; build ralph plan of fixes and post replies
---

Interactive triage of the analysis produced by `/analyze-pr-comments`.

Walks the **Fix** and **Reply** sections one item at a time. User decides per item:
- `y` accept
- `n` skip
- `e` edit the suggested text in `$EDITOR` (default `nvim`)
- `s` save progress and quit (resumable)

Fix items → appended as self-contained tasks to `thoughts/shared/pr-fixes-plan.md`.
Reply items → posted to GitHub immediately via `gh`.

Other statuses (Already Fixed / Incorrect / Out of Scope / Nitpick / Informational) are summarised once at the end. No prompts for them.

## Inputs

- **Required**: `thoughts/shared/pr-comments-analysis.md` (produced by `/analyze-pr-comments`). If missing, print an error telling the user to run `/analyze-pr-comments` first and stop.
- **Optional**: `thoughts/shared/pr-triage-state.json`. If present, resume from the stored index.

## Outputs

- `thoughts/shared/pr-fixes-plan.md` — created on first accepted Fix, appended to thereafter.
- `thoughts/shared/pr-triage-state.json` — written on `s`, deleted when triage completes cleanly.
- Posted PR comments via `gh` for accepted Replies.

## Startup

1. Check `thoughts/shared/pr-comments-analysis.md` exists. If not:
   > "No analysis file found. Run `/analyze-pr-comments` first."
   Stop.

2. Parse the analysis file. Extract from the `## Fix (N)` and `## Reply (N)` sections the ordered list of items. For each item capture:
   - `index` (1-based within its section)
   - `short_description` (the `### N. {desc}` heading)
   - `source_author`, `source_url`
   - `file_path`, `line` (if present)
   - `comment_text`
   - `reasoning`
   - **Fix only**: `what_to_change`
   - **Reply only**: `suggested_reply`

3. Read the PR context once:
   ```bash
   gh pr view --json number,url,title,headRefName,baseRefName
   gh repo view --json owner,name
   ```
   Retain `pr_number`, `pr_title`, `head_ref`, `base_ref`, `owner`, `repo` for plan header and reply posting.

4. If `thoughts/shared/pr-triage-state.json` exists:
   - Compare `analysis_mtime` stored in state vs current file mtime.
   - If equal: resume from `next_index.fix` and `next_index.reply`. Print: `Resuming triage from Fix #{i} / Reply #{j}.`
   - If different: print warning, ask:
     > "Analysis file has changed since last triage. [c]ontinue with stored indices, [r]estart from beginning, or [q]uit?"
     Act on response. On restart, delete the state file.

5. If no state, start fresh: `next_index.fix = 1`, `next_index.reply = 1`.

## Fix Loop

For each Fix item starting at `next_index.fix`:

1. Print the prompt block exactly as:

   ```
   [{i}/{total_fix}] Fix: {short_description}
     File: {file_path}:{line}
     Source: @{source_author} | {source_url}
     Comment: "{comment_text}"
     What to change: {what_to_change}

   [y] add to plan  [n] skip  [e] edit what-to-change  [s] save & quit  >
   ```

2. Read a single line of input.

3. Dispatch:

   | Input | Action |
   |---|---|
   | `y` | Call **Append Fix Task** (see below) with the current `what_to_change`. Increment `next_index.fix`. |
   | `n` | Increment `next_index.fix`. Do nothing else. |
   | `e` | Call **Edit-in-Editor** with the current `what_to_change` as initial buffer. On save, replace `what_to_change` with the edited text, then act as `y`. On empty-after-edit, act as `n`. |
   | `s` | Call **Save State**. Exit with message: `Saved. Resume by running /triage-pr-comments again.` |
   | anything else | Print `Unrecognised input. Use y/n/e/s.` and re-prompt the same item. |

4. When `next_index.fix > total_fix`, move to the Reply loop.

## Reply Loop

For each Reply item starting at `next_index.reply`:

1. Print the prompt block:

   ```
   [{j}/{total_reply}] Reply to @{source_author}{file_line_suffix}
     Comment: "{comment_text}"
     Suggested reply: {suggested_reply}

   [y] post reply  [n] skip  [e] edit reply  [s] save & quit  >
   ```

   where `{file_line_suffix}` is ` on {file_path}:{line}` if the item has a file/line, else empty.

2. Read input.

3. Dispatch:

   | Input | Action |
   |---|---|
   | `y` | Call **Post Reply** with the current `suggested_reply`. Increment `next_index.reply`. |
   | `n` | Increment `next_index.reply`. |
   | `e` | Call **Edit-in-Editor** with `suggested_reply`. On save, replace and act as `y`. On empty, act as `n`. |
   | `s` | Call **Save State**. Exit. |
   | anything else | Re-prompt same item. |

4. When `next_index.reply > total_reply`, proceed to **Summary**.

### Post Reply

- If the Reply item has both `file_path` and `line` AND the source URL looks like a review thread comment (contains `/pull/N#discussion_r`):
  - Use the **gh-pr-review-threads** skill to map the `discussion_r(\d+)` comment id → thread id, then post a thread reply via `addPullRequestReviewThreadReply`. Do NOT use `gh pr comment` (top-level only) or REST `pulls/{n}/comments` for thread context.
- Otherwise post as a general PR comment:
  ```bash
  gh pr comment {pr_number} --body "{reply_text}"
  ```
- For accepted items the user wants resolved after replying: use the **gh-pr-review-threads** skill's `resolveReviewThread` mutation.
- If `gh` exits non-zero: print the error, do **not** increment the index, return to the prompt for the same item so the user can retry, edit, or skip.

## Helpers

### Edit-in-Editor

1. Write the current text to a temp file: `$(mktemp -t triage).md`.
2. Run `${EDITOR:-nvim} <tempfile>` via Bash (foreground; user interacts directly).
3. Read the file back. Trim trailing whitespace. If file is empty or contains only whitespace, treat as empty.
4. Delete the temp file.
5. Return the edited text.

### Save State

Write `thoughts/shared/pr-triage-state.json`:

```json
{
  "analysis_path": "thoughts/shared/pr-comments-analysis.md",
  "analysis_mtime": "<ISO-8601 mtime of analysis file>",
  "pr_number": <int>,
  "next_index": { "fix": <int>, "reply": <int> },
  "plan_path": "thoughts/shared/pr-fixes-plan.md"
}
```

### Append Fix Task

On the first accepted Fix, if `thoughts/shared/pr-fixes-plan.md` does not yet exist, create it with the header block described in the next section.

Append to the `## Tasks` section:

```markdown

- [ ] **Fix {N}**: {short_description} <!-- attempts: 0 -->
  - **File**: `{file_path}:{line}`
  - **Source**: @{source_author} — {source_url}
  - **Original comment**: "{comment_text}"
  - **What to change**: {what_to_change}
  - **Tests to run**: {tests_hint}
```

where:
- `{N}` is one greater than the highest existing `**Fix N**:` number in the plan (starts at 1).
- `{tests_hint}` is inferred from the file path:
  - If path starts with `apps/`: `./bin/test {closest_test_file_path_or_parent_test_dir}`. If we cannot infer a test file, write `./bin/test {app_name}` where `{app_name}` is the segment after `apps/`.
  - Otherwise: `./bin/test` (run full suite).
  The engineer can refine this; the hint only needs to be a starting point.

## Plan Header (written once on first accepted Fix)

Write this to `thoughts/shared/pr-fixes-plan.md`:

````markdown
# PR #{pr_number} Fixes — "{pr_title}"

**Branch**: {head_ref} → {base_ref}
**Source**: thoughts/shared/pr-comments-analysis.md
**Generated**: {today YYYY-MM-DD}

## Execution

Work through tasks in order. For each unchecked `- [ ]` task:

1. Dispatch a `general-purpose` subagent via the Agent tool. Prompt it with the **full task block verbatim** followed by:
   > "Make the change described. Run the listed tests. Report back: tests pass/fail, files changed, and a 1-line commit message suffix. Do NOT commit."
2. If the subagent reports tests passed:
   - `git add <files reported>`
   - `git commit -m "fix(pr-{pr_number}): <subagent-provided suffix>"`
   - Edit this plan file: change `- [ ]` to `- [x]` for that task.
3. If tests failed:
   - Increment the `<!-- attempts: N -->` counter on the task line.
   - If the new count is `>= 2`: change `- [ ]` to `- [x] ⚠️ MANUAL REVIEW NEEDED`, and append a sub-bullet under the task: `- **Failure note**: <1-line subagent summary>`. Do not commit.
   - Otherwise leave the task unchecked so the next ralph tick retries.
4. When no `- [ ]` tasks remain (all either checked or flagged), run `/review-branch`. It applies the project architecture + test review guidelines, fixes any violations it finds (committing each fix), re-runs tests, and creates `.ralph-done` itself when the branch is clean. Do NOT create `.ralph-done` yourself.

**Context discipline**: the main session should only read this plan file and the subagent's summary. The subagent carries the cost of reading the codebase.

---

## Tasks
````

## Summary (end of triage)

After both loops finish (or on `s` before finishing, but only for the part that ran):

1. Delete `thoughts/shared/pr-triage-state.json` if both loops completed. Keep it if user saved.

2. **Review and correct the plan** (only if `count_added > 0`):
   1. Run `/review-plan thoughts/shared/pr-fixes-plan.md`.
   2. Read the findings. For each reported issue, edit `thoughts/shared/pr-fixes-plan.md` in place:
      - **Bugs / correctness issues** → rewrite the affected task's `What to change` (and `Tests to run` if needed) so the proposed change is correct.
      - **Inconsistencies** → reconcile by rewriting the tasks involved.
      - **Architecture / test guideline violations** → rewrite the task to comply. If compliance requires additional work, append sub-bullets under the task or add a new task.
      - **Simplification opportunities** → rewrite the task to use the simpler approach.
      - **Missing pieces** (e.g. missing test coverage) → append sub-bullets or add a new task.
   3. If any edits were applied, re-run `/review-plan`. Repeat until the report shows no actionable findings (only "Things That Look Good" remain, or the plan review returns empty on bugs/inconsistencies/violations/simplifications).
   4. Cap the loop at 3 review iterations. If issues persist after 3, print the remaining findings and instruct the user to review manually before running ralph.

3. Print a summary:
   ```
   Triage complete.
     Fixes added to plan: {count_added}
     Fixes skipped: {count_skipped}
     Replies posted: {count_posted}
     Replies skipped: {count_skipped_reply}

   Plan review iterations: {N}    (omit if count_added == 0)

   Other categories (no action taken):
     Already Fixed: {n}
     Incorrect: {n}
     Out of Scope: {n}
     Nitpick: {n}
     Informational: {n}

   Next: `ralph thoughts/shared/pr-fixes-plan.md`
   ```

4. If `count_added == 0`, omit the `Next:` line and the plan-review section; print `No fixes queued; nothing to run.` instead.
