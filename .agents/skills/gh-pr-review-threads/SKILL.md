---
name: gh-pr-review-threads
description: |
  Resolve, unresolve, list, and reply to PR review threads on GitHub via `gh api graphql`.
  REST (`gh pr comment`, `gh api .../pulls/{n}/comments`) CANNOT resolve threads — only
  the GraphQL `resolveReviewThread` mutation can. Use whenever a task involves marking
  review comments as resolved/unresolved or replying within a specific review thread.
triggers:
  - resolve review thread
  - resolve pr comment
  - resolve github comment
  - mark thread resolved
  - unresolve review thread
  - reply to review thread
  - list unresolved threads
  - gh graphql review
---

# GitHub PR Review Threads via `gh`

REST cannot resolve review threads. Use GraphQL.

## Common trap

`reviewThread.id` ≠ comment id. Mutations need the **thread node ID** (starts with `PRRT_` or `RT_`), not the comment id (`PRRC_…`) and not the numeric `databaseId`.

A review-comment URL like `…/pull/123#discussion_r456789` gives you the comment, not the thread. Resolve the thread the comment belongs to.

## List unresolved threads on a PR

```bash
gh api graphql -F owner="$OWNER" -F repo="$REPO" -F number="$PR" -f query='
query($owner:String!,$repo:String!,$number:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$number){
      reviewThreads(first:100){
        nodes{
          id
          isResolved
          isOutdated
          path
          line
          comments(first:1){nodes{author{login} body url databaseId}}
        }
      }
    }
  }
}'
```

Filter `isResolved=false` client-side with `jq`.

## Map a comment URL/id → thread ID

`#discussion_rN` in the URL is the comment `databaseId`. Walk threads, match comment, return thread `id`:

```bash
gh api graphql -F owner=... -F repo=... -F number=... -f query='
query($owner:String!,$repo:String!,$number:Int!){
  repository(owner:$owner,name:$repo){
    pullRequest(number:$number){
      reviewThreads(first:100){
        nodes{ id comments(first:50){ nodes{ databaseId } } }
      }
    }
  }
}' | jq -r --argjson cid 456789 '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.comments.nodes[].databaseId == $cid) | .id'
```

## Resolve a thread

```bash
gh api graphql -f threadId="$THREAD_ID" -f query='
mutation($threadId:ID!){
  resolveReviewThread(input:{threadId:$threadId}){
    thread{ id isResolved }
  }
}'
```

## Unresolve a thread

```bash
gh api graphql -f threadId="$THREAD_ID" -f query='
mutation($threadId:ID!){
  unresolveReviewThread(input:{threadId:$threadId}){
    thread{ id isResolved }
  }
}'
```

## Reply inside a thread (not a new top-level comment)

Need the **first comment's node id** in the thread (the `pullRequestReviewThread` mutation needs `inReplyTo` of a comment id, but the simpler path is `addPullRequestReviewThreadReply`):

```bash
gh api graphql -F threadId="$THREAD_ID" -F body="$BODY" -f query='
mutation($threadId:ID!,$body:String!){
  addPullRequestReviewThreadReply(input:{
    pullRequestReviewThreadId:$threadId, body:$body
  }){ comment{ id url } }
}'
```

`gh pr comment` posts a top-level PR comment — wrong tool for thread replies.

## Bulk resolve (e.g. all by author, all outdated)

```bash
gh api graphql -F owner=... -F repo=... -F number=... -f query='...listQuery...' \
  | jq -r '.data.repository.pullRequest.reviewThreads.nodes[]
           | select(.isResolved==false and .isOutdated==true) | .id' \
  | while read -r tid; do
      gh api graphql -f threadId="$tid" -f query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id}}}'
    done
```

## Auth / scopes

`gh auth status` must show `repo` scope. Org PRs may need SSO authorization (`gh auth refresh -h github.com -s repo`).

## Errors

- `Could not resolve to a node with the global id of '...'` → wrong id type (passed comment id or databaseId, not thread node id).
- `Resource not accessible by integration` → token lacks `repo` write or SSO not authorized.
- `Variable $threadId of type ID! was provided invalid value` → `-F` coerced it; use `-f threadId=...` to keep it a string.
