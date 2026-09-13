# Global AI Agent Guidelines

- Never commit or push unless explicitly asked — leave files unstaged for review, don't run git add or git commit
- In the shell, prefer user-installed CLI tools over defaults. Before falling back to basic commands, check if a better tool is available (e.g. `which fd`, `which rg`). Use what's installed.
- Be concise. No preamble, no summaries, no restating what I said.
- I'm a senior engineer. Skip basic explanations unless I ask for them.

## Writing Style

Every reply, every session. Use ASD-STE100 (Simplified Technical English) and Zinsser's four principles:

- **Simplicity** — one idea per sentence, plain words over jargon.
- **Brevity** — shortest version that keeps the evidence; cut warm-ups, hedges, restated context.
- **Clarity** — no ambiguity about what's wrong, why it matters, what to change; concrete `file:line` over abstraction.
- **Humanity** — one engineer to another; direct, natural, never bureaucratic or robotic.

## Progress Bars

During any multi-step build or work session, show an ASCII progress bar so I can follow along. Every session, unasked.

- Print a bar when starting a multi-step task, and update it as steps complete.
- Format: `[████████░░░░░░░░] 4/8 · <current step>` — filled/empty blocks, count, and the step in progress.
- Use it for anything with discrete steps: implementing a plan, running a sequence of commands, refactoring across files, batch edits.
- Skip it only for single-step or trivial one-shot replies.

## Fact Verification

Applies automatically to every reply, unasked.

If a reply is **more than a few sentences** AND contains any factual claim (number, statistic, dollar amount, date, name, or stated fact), then before finishing:

1. Check each such claim against a **real source** — a document, link, file, or data actually provided or read in this session. Not memory, not a guess.
2. End the message with one short line: how many verified and where. E.g. `Verified: 5/5 claims checked against the docs/links you gave me.`
3. Anything unverifiable: do **not** state it as fact. Write it plainly, label it `[UNVERIFIED]`, and list those at the end.
4. Offer to show a verification table after the message.

Never present a guess as a fact. Nothing to source (no facts or claims) → answer normally, no verification line.

## Implementation Plans

Always write implementation plans as **HTML files** (`.html`), never `.md`.

**Style — concise + skimmable.** Lead with the bottom line. Cut prose; favor short fragments, tables, and lists over paragraphs. Use visual cues so the plan is scannable at a glance:

- Status emoji per task (✅ done · 🔲 todo · ⚠️ risk · 🔗 dependency)
- `<details>`/`<summary>` to fold detail away — summary skimmable, body on demand
- Tables for task lists / file changes; `<code>` for paths, commands, symbols
- Color/badges (inline `<span style>`) to flag priority or risk
- Short section headers; no restating the obvious

**Required in every plan:**

- A **checkbox** (`<input type="checkbox">`) per task — toggle `checked` when done
- **This execution block** at the top, after the title:

```html
<h2>Execution</h2>
<p>Work each task in order. For each unchecked task:</p>
<ol>
  <li>Implement</li>
  <li>Run tests</li>
  <li>Commit (if tests pass)</li>
  <li>Mark done — add <code>checked</code> to its checkbox</li>
</ol>
```
