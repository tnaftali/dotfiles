---
description: Fetch and analyze all PR comments for the current branch, listing each with owner, status, description, relevance, and direct link.
---

Analyze all comments on the pull request for the current branch. If no PR exists for this branch, tell me and stop.

## Steps

1. **Identify the PR** using `gh pr view --json number,url,title,headRefName` for the current branch.

2. **Fetch all comments** from two sources:
   - **Review thread comments** (inline code comments) via GraphQL — include `isResolved` status:
     ```
     gh api graphql -f query='
     {
       repository(owner: "{owner}", name: "{repo}") {
         pullRequest(number: NUMBER) {
           reviewThreads(first: 100) {
             nodes {
               isResolved
               comments(first: 10) {
                 nodes {
                   author { login }
                   body
                   url
                   createdAt
                 }
               }
             }
           }
         }
       }
     }'
     ```
   - **General comments** (not on code) via `gh api repos/{owner}/{repo}/issues/{number}/comments`

3. **For each comment**, determine:
   - **Owner**: The author login (include `[bot]` suffix for bot accounts)
   - **Status**:
     - For review thread comments: use `isResolved` (Resolved / Unresolved)
     - For general comments: infer from context — check if the topic was addressed in subsequent commits or replies. Mark as "Addressed", "Unaddressed", or "Informational" (for comments that don't require action)
   - **Description**: One-line summary of what the comment is saying
   - **Relevance & Correctness**: Brief assessment — is the suggestion valid? Is it relevant to the changes? Flag anything incorrect or outdated.
   - **Link**: Direct `html_url` to the comment

4. **Present as a markdown table**, grouped by status (unresolved/unaddressed first):

   | # | Owner | Status | Description | Relevance | Link |
   |---|-------|--------|-------------|-----------|------|

5. **Summary** at the end:
   - Total comments count
   - Unresolved/unaddressed count
   - Recommendations on which comments to prioritize
