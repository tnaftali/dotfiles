# Design: Analyze PR Comments v2

## Overview

Rewrite of `/analyze-pr-comments` command. Fetches all PR comments (human reviewers, automated review bots, general discussion), verifies each against the actual codebase, assigns a deterministic status, and produces a grouped actionable summary.

## Requirements

- Fetch comments from all sources: human review threads, bot reviews (arch-review, test-review, CodeRabbit), general PR comments
- For each comment: read referenced code, check git history, verify the claim
- Assign one of 7 deterministic statuses
- Output grouped by status, detailed for actionable items, brief for informational
- Write to file (`thoughts/shared/pr-comments-analysis.md`) and print to terminal
- Use parallel subagents for speed and context isolation

## Status Categories

| Status | Criteria | Action |
|--------|----------|--------|
| **Fix** | Claim is correct, code still has the issue | Describe what needs changing |
| **Already Fixed** | Valid claim but addressed in a later commit | None |
| **Incorrect** | Claim is factually wrong | Explain why with code evidence |
| **Reply** | No code change needed, commenter deserves a response | Draft suggested reply |
| **Out of Scope** | Valid but not related to this PR's changes | None |
| **Nitpick** | Stylistic/minor, no functional impact | None |
| **Informational** | FYI, bot summary header, status update | None |

## Architecture

### Parallel Subagent Model

Three agents, one per comment source, running concurrently:

| Agent | Source | API | Filter |
|-------|--------|-----|--------|
| **A: Human review threads** | Inline code comments + review bodies | GraphQL `reviewThreads` + `reviews` | `isResolved` status included |
| **B: Bot review comments** | Architecture review, test review, CodeRabbit | REST `issues/{number}/comments` | Filter by known bot authors (`github-actions[bot]`, `coderabbit[bot]`) or body markers (`arch-review-results`, `test-review-results`) |
| **C: General human comments** | Non-bot discussion comments | REST `issues/{number}/comments` | Exclude bot authors |

### Agent Input

Each agent receives:
- PR number and repo info
- Full branch diff (`git diff master...HEAD`)
- Its assigned comment source to fetch

### Agent Output

Each agent returns a structured list per comment:
- `comment_id`: unique identifier
- `author`: login (with `[bot]` suffix for bots)
- `source_type`: human-review / bot-arch / bot-test / bot-other / general
- `file_line`: `file:line` if applicable, null otherwise
- `comment_text`: full comment body
- `status`: one of the 7 statuses
- `reasoning`: one-line explanation of why this status was assigned
- `suggested_action`: what to change (Fix) or draft reply (Reply), null for others
- `link`: direct URL to the comment

### Status Assignment Decision Tree

```
1. Read comment text -> understand claim/request
2. If references specific code:
   a. Read the file at referenced line(s)
   b. Check git log -- was this addressed in a later commit?
   c. Evaluate: is the claim factually correct?
3. Assign status based on criteria table above
```

### Orchestration Flow

```
1. Main agent: identify PR (gh pr view --json number,url,title,headRefName)
2. Main agent: get branch diff (git diff master...HEAD)
3. Spawn 3 parallel subagents (A, B, C)
4. Each agent: fetch comments, verify against code, assign statuses
5. Main agent: merge results, deduplicate, sort into status groups
6. Main agent: write to thoughts/shared/pr-comments-analysis.md
7. Main agent: print full analysis to terminal
8. Main agent: ask "Want to start addressing Fix items?"
```

### Deduplication

Bot review comments sometimes appear as both a review thread and an issue comment (the `post-review-comment` action creates issue comments from review output). Deduplicate by matching on comment body similarity (first 100 chars).

### Edge Cases

- No PR for current branch: stop with message
- No comments found: "No comments found on PR #X"
- Agent finds 0 comments in its source: returns empty list, no error

## Output Format

Written to `thoughts/shared/pr-comments-analysis.md` and printed to terminal.

### Structure

```
# PR Comment Analysis -- PR #N: "Title"

**Branch**: feature/foo -> master
**Date**: YYYY-MM-DD
**Comments analyzed**: N (breakdown by source)

## Summary (table of status counts + action needed line)

## Fix (N) -- detailed: file, comment, reasoning, what to change
## Reply (N) -- detailed: file, comment, reasoning, suggested reply
## Already Fixed (N) -- medium detail
## Incorrect (N) -- medium detail with code evidence
## Out of Scope (N) -- brief
## Nitpick (N) -- brief one-liners
## Informational (N) -- brief one-liners
```

### Detail Levels

- **Fix and Reply**: full context (source, author, file:line, comment text, reasoning, action/reply)
- **Already Fixed and Incorrect**: reasoning + evidence (important for reviewer trust)
- **Out of Scope, Nitpick, Informational**: one-liner with link

Every item includes a direct link to the comment on GitHub.
