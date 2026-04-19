---
description: Analyze all PR comments with code verification and deterministic status assignment
---

Comprehensive analysis of all comments on the pull request for the current branch.
Fetches human reviews, automated bot reviews, and general discussion.
Verifies each comment against the actual codebase and assigns a deterministic status.

## Setup

1. **Identify the PR** using `gh pr view --json number,url,title,headRefName,baseRefName` for the current branch. If no PR exists, say so and stop.

2. **Get repo info**: `gh repo view --json owner,name`

3. **Get the branch diff** for context:
   ```bash
   git diff master...HEAD --name-only
   ```

## Analysis

Spawn 3 parallel subagents. Each agent receives the PR number, repo owner/name, and the list of changed files.

### Agent A: Human Review Threads

Fetch all review thread comments (inline code comments and review bodies) via GraphQL:

```graphql
{
  repository(owner: "{owner}", name: "{repo}") {
    pullRequest(number: NUMBER) {
      reviews(first: 100) {
        nodes {
          author { login }
          body
          url
          state
          createdAt
        }
      }
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 50) {
            nodes {
              author { login }
              body
              url
              path
              line
              createdAt
            }
          }
        }
      }
    }
  }
}
```

For each comment:
1. Read the comment text — understand what it claims or requests
2. If it references a specific file/line: read the file at that location using the Read tool
3. Check `git log --oneline master...HEAD -- <file>` to see if a later commit addressed it
4. Assign a status (see Status Categories below)
5. For **Fix**: describe what needs changing. For **Reply**: draft a suggested reply.

Exclude bot authors (`github-actions[bot]`, `coderabbit[bot]`, etc.) — Agent B handles those.

Return findings as a structured list.

### Agent B: Bot Review Comments

Fetch issue comments and filter to bot authors:

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

Filter to comments where:
- Author login ends in `[bot]`, OR
- Body contains markers: `arch-review-results`, `test-review-results`, `<!-- coderabbit -->`, or similar

Bot review comments are often long structured reviews with multiple findings. Parse each individual finding within the comment as a separate item — do not treat the entire bot comment as one item.

For each finding:
1. Read the referenced file/line if specified
2. Verify the claim against current code
3. Assign a status
4. For **Fix**: describe what needs changing

Return findings as a structured list.

### Agent C: General Human Comments

Fetch issue comments and exclude bots:

```bash
gh api repos/{owner}/{repo}/issues/{number}/comments --paginate
```

Filter to comments where author login does NOT end in `[bot]`.

For each comment:
1. Understand the intent — is it a question, suggestion, discussion, or FYI?
2. If it references code: read the file to verify
3. Assign a status
4. For **Reply**: draft a suggested reply

Return findings as a structured list.

## Status Categories

Each comment gets exactly one status:

| Status | Criteria | Action |
|--------|----------|--------|
| **Fix** | Claim is correct, code still has the issue | Describe what needs changing |
| **Already Fixed** | Valid claim but addressed in a later commit on the branch | None |
| **Incorrect** | Claim is factually wrong — explain why with code evidence | None |
| **Reply** | No code change needed, commenter deserves a response | Draft suggested reply |
| **Out of Scope** | Valid observation but not related to this PR's changes | None |
| **Nitpick** | Stylistic/minor, no functional impact | None |
| **Informational** | FYI, bot summary header, status update — no action needed | None |

Every status assignment must include a one-line **reasoning** field.

## Deduplication

Bot review comments sometimes appear as both a review thread and an issue comment (the `post-review-comment` action). Before merging, deduplicate by matching on first 100 characters of comment body.

## Output

After all agents complete, merge results and present grouped by status.

### 1. Write to file

Write the full analysis to `thoughts/shared/pr-comments-analysis.md`:

```markdown
# PR Comment Analysis — PR #N: "Title"

**Branch**: {head} → {base}
**Date**: {today}
**Comments analyzed**: N (X human review, Y bot review, Z general)

## Summary

| Status | Count |
|--------|-------|
| Fix | N |
| Already Fixed | N |
| Incorrect | N |
| Reply | N |
| Out of Scope | N |
| Nitpick | N |
| Informational | N |

**Action needed**: N fixes, N replies

---

## Fix (N)

### 1. {short description}
**Source**: {author} | [link]({url})
**File**: `{path}:{line}`
**Comment**: {comment text, abbreviated if long}
**Reasoning**: {why this is a valid fix}
**What to change**: {specific description of the needed change}

---

## Reply (N)

### 1. {short description}
**Source**: {author} | [link]({url})
**File**: `{path}:{line}` (if applicable)
**Comment**: {comment text}
**Reasoning**: {why a reply is needed}
**Suggested reply**: {drafted reply text}

---

## Already Fixed (N)

- **{short description}** — {author} | {reasoning} | [link]({url})

## Incorrect (N)

- **{short description}** — {author} | {reasoning with code evidence} | [link]({url})

## Out of Scope (N)

- **{short description}** — {author} | [link]({url})

## Nitpick (N)

- {short description} — {author} | [link]({url})

## Informational (N)

- {short description} — [link]({url})
```

### 2. Print to terminal

Print the same content to terminal output.

### 3. Prompt for action

After presenting the analysis, ask:

> "Want to start addressing the Fix items?"

ultrathink throughout. Be thorough — read every referenced file, verify every claim.