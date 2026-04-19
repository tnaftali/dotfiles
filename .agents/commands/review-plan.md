---
description: Review implementation plan for bugs, inconsistencies, and simplification opportunities
argument-hint: "[path-to-plan]"
---

Review the implementation plan at `$ARGUMENTS` (default: `thoughts/shared/plan.md`) with fresh eyes.

## Goal

Find obvious bugs, inconsistencies, or things that could be done in a simpler/more robust manner. If project review guidelines exist, validate the plan against them before code is written.

## Steps

1. **Read the full plan** using the Read tool. Understand the overall architecture and goals before diving in.

2. **Detect project review guidelines** — check if these files exist in the current project:
   - `.agents/prompts/architecture-review.md`
   - `.agents/prompts/test-review.md`

   If found, read them. These define the architectural rules and test standards that CI will enforce. The plan should not propose anything that would violate them.

3. **Identify investigation areas** — break the plan into independent areas that can be reviewed in parallel. Think about:
   - Does each step actually achieve what it claims?
   - Are there implicit assumptions or missing error cases?
   - Are there simpler alternatives to proposed approaches?
   - Do the pieces fit together consistently (naming, data flow, dependencies)?
   - Are there race conditions, ordering issues, or edge cases?
   - **If review guidelines were found:** Does the plan violate any architectural rules? Does the testing approach meet the test quality standards? Would CI reject this?

4. **Spawn parallel subagents** to investigate the actual codebase for each area. Each agent should:
   - Read the relevant existing code
   - Compare what exists vs what the plan proposes
   - Flag mismatches, unnecessary complexity, or missing pieces
   - If review guidelines exist, check proposed changes against those rules
   - Be specific: file paths, line numbers, concrete alternatives

5. **Synthesize findings** after all agents complete. Present as:

   ### Bugs / Correctness Issues
   - [issue]: [why it's wrong] → [fix]

   ### Inconsistencies
   - [contradiction]: [where it conflicts]

   ### Architecture/Test Guideline Violations
   *(only if review guidelines were detected)*
   - [rule violated]: [what the plan proposes] → [what it should do instead]

   ### Simplification Opportunities
   - [current approach]: [simpler alternative] → [why it's better]

   ### Things That Look Good
   - [brief acknowledgment of solid decisions]

ultrathink throughout. Be direct — flag real problems, skip nitpicks.