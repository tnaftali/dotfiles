# Global AI Agent Guidelines

- Never commit or push unless explicitly asked — leave files unstaged for review, don't run git add or git commit
- When using Bash, prefer user-installed CLI tools over defaults. Before falling back to basic commands, check if a better tool is available (e.g. `which fd`, `which rg`). Use what's installed.
- Be concise. No preamble, no summaries, no restating what I said.
- I'm a senior engineer. Skip basic explanations unless I ask for them.

## Writing Style

Every reply, every session. Use ASD-STE100 (Simplified Technical English) and Zinsser's four principles:

- **Simplicity** — one idea per sentence, plain words over jargon.
- **Brevity** — shortest version that keeps the evidence; cut warm-ups, hedges, restated context.
- **Clarity** — no ambiguity about what's wrong, why it matters, what to change; concrete `file:line` over abstraction.
- **Humanity** — one engineer to another; direct, natural, never bureaucratic or robotic.

**Sign-off on text for others.** Any reply, comment or message I draft for Tobi to send, or post on Tobi's behalf (Basecamp, Slack, GitHub, email), ends with this line:
`✻ text drafted by Claude, verified by Tobi`

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
- A **favicon** (see "All Documents")
- **This execution block** at the top, after the title:

```html
<h2>Execution</h2>
<p>Work each task in order. For each unchecked task:</p>
<ol>
  <li>Implement</li>
  <li>Run tests</li>
  <li>Commit only if tests pass <em>and</em> I asked for commits. Otherwise leave changes unstaged.</li>
  <li>Mark done — add <code>checked</code> to its checkbox</li>
</ol>
<p>All checked → run <code>touch .ralph-done</code></p>
```

## Explanations & Reports

Any explanation, comparison, walkthrough, or report longer than ~3 paragraphs
goes in a **local `.html` file on disk** — same as implementation plans. Richer
format aids understanding — the whole point of the output.

- **Local files, never published Claude Artifacts.** Write with the `Write`
  tool to a `.html` file in the project (or a path I give), then open it with
  `open <file>`. Do not use the `Artifact` tool / claude.ai publishing unless I
  explicitly ask.
- **Where files go.** Inside a repo or project folder: that folder. Anywhere
  else (e.g. working from `~`): `~/Documents/claude/`. Never loose in `~`.
  Applies to plans, reports, research, and explanations.
- **Lead with a diagram** when structure, flow, or architecture is involved —
  inline SVG, or mermaid via a `mermaid` CDN `<script>` in the file so it renders
  in the browser. The terminal does not render diagrams, so they belong in the
  `.html`, never in chat.
- Same skimmable style as plans: bottom line first, tables and short fragments
  over prose, `<code>` for paths/commands, fold detail in `<details>`.
- Use `dataviz` for chart design, `artifact-diagramming` for diagram mechanics —
  for the content, not as a reason to publish.
- Interactive controls export their state: add a "Copy as prompt" button so I
  can feed it back to you.
- Never overwrite an existing file silently — ask, or version the filename.
- Short Q&A, a single fact, or an action confirmation stays in the terminal —
  do not over-produce. Caveman still governs the chat around the file.

## All Documents

These apply to every document I ask for — plans, reports, explanations, research, any HTML:

- **Favicon.** Every `.html` file has one: an inline emoji SVG data URI, emoji picked to fit the topic (e.g. 🛒 for a groceries app):
  `<link rel="icon" href="data:image/svg+xml,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><text y='.9em' font-size='90'>🛒</text></svg>">`
- **Writing Style.** Document prose follows the same rules as chat: ASD-STE100 and Zinsser's four principles.
- **Fact Verification.** Check every factual claim in the document against a real source from this session. Mark each unverifiable claim `[UNVERIFIED]` in the document. End the document with one `Verified: N/N claims checked against <sources>` line.
- **Progress Bars.** Building a document in several steps → show the progress bar in chat, as for any multi-step work.

## Document Theme — Catppuccin Macchiato, Sans Titles

Every document I build — implementation plans, reports, explanations, any HTML
output — uses the **Catppuccin Macchiato** palette. Dark theme. Apply it unasked.

Define these as CSS variables and build everything off them:

```css
:root {
  --base: #24273a; --mantle: #1e2030; --crust: #181926;
  --surface0: #363a4f; --surface1: #494d64; --surface2: #5b6078;
  --overlay0: #6e738d; --overlay1: #8087a2; --overlay2: #939ab7;
  --text: #cad3f5; --subtext1: #b8c0e0; --subtext0: #a5adcb;
  --rosewater: #f4dbd6; --flamingo: #f0c6c6; --pink: #f5bde6; --mauve: #c6a0f6;
  --red: #ed8796; --maroon: #ee99a0; --peach: #f5a97f; --yellow: #eed49f;
  --green: #a6da95; --teal: #8bd5ca; --sky: #91d7e3; --sapphire: #7dc4e4;
  --blue: #8aadf4; --lavender: #b7bdf8;
  --sans: system-ui, -apple-system, "Segoe UI", sans-serif;
  --title: "Inter", system-ui, -apple-system, "Segoe UI", sans-serif;
  --mono: ui-monospace, "JetBrains Mono", monospace;
}
```

Role mapping:
- Page background `--base`; nested panels/cards `--mantle`; deepest wells `--crust`.
- Body text `--text`; muted/secondary `--subtext0`; borders/dividers `--surface0`/`--surface1`.
- Accent/links/headings `--blue` or `--mauve`; code `--green`.
- Status: done `--green`, todo `--overlay1`, risk/warn `--yellow`/`--peach`, error `--red`, dependency `--sky`.
- No serif fonts anywhere. Body uses `--sans`. Titles (`h1`–`h3`) use `--title` (Inter): `h1` 26px `--blue` weight 700, `h2` 18px `--mauve` weight 600, `h3` 14px `--subtext1` weight 600.
- Load Inter with this tag in `<head>`; offline, `--title` falls back to the system font:
  `<link href="https://fonts.googleapis.com/css2?family=Inter:wght@500;600;700&display=swap" rel="stylesheet">`
- Lead with a row of stat tiles for the headline numbers (label 12px uppercase `--subtext0`, value 28px weight 650, tabular-nums). The deciding number (price, cost, total) goes first and biggest.
- Reference look: `~/Documents/claude/pc-electricity-cost.html` (tiles, cards, quiet tables, pill badges).

## Alternate Theme — Claude Cream (opt-in)

Use only when I ask for "cream" / "Claude Cream" / a light warm look. Macchiato stays the default.

Minimal, warm, light by default, with a dark toggle. Copy the `:root` block, the dark block and the component styles from the reference page: `~/dotfiles/.claude/themes/claude-cream.html`.

```css
:root {
  --bg: #e6e0d2; --panel: #ede8dc; --well: #ddd6c6;
  --border: #d4ccba; --border-strong: #bfb6a2;
  --text: #2b2925; --muted: #57534b; --faint: #625d54;
  --accent: #a34c31; --accent-soft: #e8d5c8;
  --green: #4f6d43; --amber: #8a6223; --red: #9c3d33; --blue: #415e80;
  --sans: system-ui, -apple-system, "Segoe UI", sans-serif;
  --title: "Domine", Georgia, serif;
  --mono: ui-monospace, "JetBrains Mono", monospace;
}
:root[data-theme="dark"] {
  --bg: #262624; --panel: #2f2f2c; --well: #1f1e1d;
  --border: #3a3936; --border-strong: #4a4945;
  --text: #f5f4ed; --muted: #b7b5a9; --faint: #9a988e;
  --accent: #d97757; --accent-soft: #3d2c25;
  --green: #9bb98a; --amber: #d4a85a; --red: #e08a7d; --blue: #8eaacb;
}
```

Rules:
- Ink on cream. Headings use `--text`, not color.
- Titles (`h1`–`h3`) and stat-tile values use `--title` (Domine, a serif): `h1` 30px 700, `h2` 19px 600, `h3` 14px 600 `--muted`, letter-spacing -0.005em. Body stays system sans. Serif for titles only.
- Load it in `<head>`; offline, `--title` falls back to the system font: `<link href="https://fonts.googleapis.com/css2?family=Domine:wght@500;600;700&display=swap" rel="stylesheet">`
- Accent `--accent` (clay) in three places only: links, the lead stat tile, the bottom-line callout border.
- Cards `--panel` + 1px `--border`, 12px radius. Code on `--well`.
- Status pills are outlined, not filled: done `--green`, todo `--faint`, risk `--amber`, error `--red`, dependency `--blue`.
- Same structure as Macchiato: stat tiles first, bottom-line callout, quiet tables, `<details>` folds.
- Visual cues, used sparingly so pages scan fast and are not a wall of text. Copy the CSS from the reference page:
  - numbered `h2` (`.num`) when order matters
  - callouts (`.callout note|warn|err|ok`) instead of paragraphs for notes, risks, blockers, decisions
  - owner `.chip`s
  - task rows: group rows (`tr.group`), a status-coloured left edge (`tr.s-todo|warn|dep|err`), and ticked rows fade
  - a progress `.meter` tile for checklists
  - `ol.steps` for ordered steps
  - pills carry an icon (✓ ○ ! ✕ ↗)
  - `<details>` with a rotating ▸
- Persist the dark toggle in `localStorage` (try/catch), as the reference page does.

@devlog.md
@RTK.md
