---
description: Iterative architecture and test quality review for the current branch
---

Iterative architecture and test quality review loop for the current branch. Applies the project's architecture and test review guidelines, fixes issues, and verifies with tests.

## Setup

1. **Detect review guidelines** — check if these files exist and read them if found:
   - `.agents/prompts/architecture-review.md` — architecture rules
   - `.agents/prompts/test-review.md` — test quality rules

   If neither exists, stop and tell the user: "No review guidelines found at `.agents/prompts/`. This command requires project-specific review prompts."

2. **Get the branch diff**: `git diff master...HEAD --name-only` and `git diff master...HEAD` to understand all changes on the branch.

3. **Read all changed files** completely — both production and test files.

## Loop

Run this loop until no actionable issues remain:

### Phase 1: Architecture Review

1. **Apply architecture rules** from `.agents/prompts/architecture-review.md` against every changed file. Use parallel subagents to review independent areas.
2. **Triage findings**:
   - **Violations introduced by this branch** (must fix)
   - **Pre-existing issues in modified files** (note but don't fix unless trivial)
3. **Fix each violation**, one at a time.
4. **Run relevant tests** to verify fixes. Use `./bin/test <test_file>` with appropriate tags (e.g., `--include ai_eval`, `--include tracing`) since some tests are excluded by default.
5. **Re-review each fix** to ensure it doesn't introduce new issues.

### Phase 2: Test Quality Review

6. **Apply test review rules** from `.agents/prompts/test-review.md` against the branch diff. Use parallel subagents.
7. **Triage findings** — only fix issues relevant to branch changes.
8. **Fix each issue** and run corresponding tests.

### Phase 3: Full Verification

9. **Run all affected test directories** with appropriate include tags:
   ```bash
   ./bin/test <all_affected_dirs> --include ai_eval --include tracing --exclude uses_llm
   ```
10. **Verify clean diff**: `git diff` should show only intentional changes.

### Phase 4: Recurse

11. If any fixes were made, go back to Phase 1 and re-review the entire branch including fixes.
12. If no issues found in both reviews, the loop is complete. Create `.ralph-done` to signal completion if running inside a ralph loop.

## Key Reminders

- **Only flag issues in changed/new code**, not pre-existing patterns.
- **Check test tags**: Many test files use `@moduletag :skip` or `@moduletag :ai_eval` — adjust run commands accordingly.
- **Test commands**: Always use `./bin/test`, never `mix test`.
- **Be pragmatic**: Don't fix things outside the branch's scope.
- **Architecture rules reference**: AuditInfo rules only apply to workers calling `PlatformOperationsContext`, `Core.Clients`, or creating ApplicationEvents — not all Context calls.
- **Pipeline tests**: Pipeline eval tests (`@moduletag :skip, :ai_eval`) are intentionally skipped in normal test runs. `IO.puts` in them is by design.

ultrathink throughout.