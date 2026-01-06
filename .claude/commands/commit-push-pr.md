---
description: Automated workflow to format, commit, push, and create a PR
---

1.  Run the project linter and formatter (e.g., `npm run lint && npm run format`).
2.  If successful, run `git status` and `git diff` to review changes.
3.  Generate a concise, professional commit message following conventional commit standards.
4.  Commit the changes with `git commit -am "[message]"`.
5.  Push the current branch to `origin`.
6.  Check if a PR already exists using `gh pr view`.
7.  If no PR exists, run `gh pr create --fill`.
8.  Return the final PR URL to me.
