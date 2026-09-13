---
description: Author a rich single-file HTML artifact (diagrams, mockups, interactive controls) from scratch or by enriching markdown. For visuals markdown can't convey.
argument-hint: "<topic> | --enrich <md> | --from <sources> <topic>"
---

# html-artifact

Author a rich, single-file HTML artifact from scratch (or by enriching an existing markdown source). Use when the content benefits from visual representation that markdown cannot convey: SVG diagrams, mockup grids, interactive controls, annotated diffs, side-by-side comparisons, kanban boards.

Contrast with `/md-to-html` (mechanical pandoc conversion — no invented visuals).

## Usage

- `/html-artifact <topic-or-description>` — author from scratch
- `/html-artifact --enrich <path-to-md>` — read markdown, generate richer HTML version alongside it
- `/html-artifact --from <source-files> <topic>` — pull context from listed files (code paths, ticket files, research docs) and synthesize

Default output path: `thoughts/shared/artifacts/{YYYY-MM-DD}-{slug}.html` (create dir if missing). For plans use `thoughts/shared/plans/{YYYY-MM-DD}-{slug}.html`. Ask user if ambiguous.

## When to pick which pattern

Decide based on the content. Multiple patterns can coexist in one file.

| Goal | Pattern | Tech |
|------|---------|------|
| Explain flow/architecture | SVG flowchart OR mermaid diagram | inline `<svg>` or ```` ```mermaid ```` |
| Compare design options | Mockup grid (3-6 panels side-by-side) | CSS grid + HTML mockups |
| Tune parameters | Sliders + live preview + copy-as-prompt | `<input type="range">` + JS |
| Reorder/prioritize items | Draggable kanban columns | HTML5 drag-and-drop |
| Annotate code or diff | Two-column: code on left, margin notes on right | CSS grid, color-coded severity |
| Walk through algorithm | Step-through with prev/next buttons | JS state machine |
| Show data shape | Tables + JSON viewer (collapsible `<details>`) | native HTML |
| Implementation plan | TOC sidebar + sections + task checkboxes + SVG data-flow | full template |

## Authoring guidelines

1. **Single self-contained file.** Inline CSS in `<style>`, inline JS in `<script>`. External resources only via CDN (Prism, mermaid). Must work opened directly from disk.
2. **Dark/light theme via `prefers-color-scheme`.** Define CSS vars.
3. **Sticky TOC sidebar** for any document over ~3 sections.
4. **Always include a "Copy as prompt" or "Copy as JSON" button** for interactive artifacts so the user can feed state back to Claude. Pattern:

   ```js
   document.getElementById('copy').onclick = async () => {
     const payload = /* serialize current state */;
     await navigator.clipboard.writeText(payload);
   };
   ```

5. **Mockups**: use real HTML/CSS, not screenshots. Wrap in a `.mockup` frame with browser-chrome or device-frame styling so they're visually distinct from real UI.
6. **SVG diagrams**: prefer hand-authored `<svg>` over mermaid when the diagram needs precise positioning, custom shapes, or annotations. Use mermaid when it's a standard flowchart/sequence/ER.
7. **Code snippets**: `<pre><code class="language-X">` so Prism highlights them. Annotate inline with a 2-column grid (code | notes) when explaining.
8. **Task lists**: `<ul class="task-list">` with `<input type="checkbox">` items, persisted to `localStorage` keyed on `location.pathname`. Compatible with the `/md-to-html` template's behavior.
9. **Mobile responsive**: collapse multi-column layouts under ~900px.
10. **No build step.** No npm, no bundler. Browser-native modules only.

## Base skeleton

Start from the shared template at `~/dotfiles/.agents/templates/html/pandoc-template.html` (copy its `<style>` + script block) and replace `$body$` with hand-authored content. Or use this minimal shell:

```html
<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{{TITLE}}</title>
<style>/* embed full theme — copy from pandoc-template.html */</style>
</head><body>
<div class="layout">
  <nav class="toc"><h2>Contents</h2><ul><!-- TOC links --></ul></nav>
  <main>
    <h1>{{TITLE}}</h1>
    <!-- sections here -->
  </main>
</div>
<script type="module">/* mermaid + checkbox persistence + custom interactivity */</script>
</body></html>
```

## Process

1. Determine intent: from-scratch, enrich, or synthesize-from-sources.
2. If `--enrich` or `--from`: read the input files first to gather concrete content.
3. Pick patterns from the table above based on the topic. Briefly tell the user which patterns you'll use before writing.
4. Author the HTML. Aim for a file that's readable cold by someone who hasn't been in the conversation.
5. Write the file. Report path. Suggest the user open it: `open <path>`.
6. Do NOT also generate a `.md` version unless asked. HTML is the artifact.

## Anti-patterns

- Don't ASCII-diagram inside `<pre>` when SVG/mermaid would work.
- Don't emit a giant wall of text — break with diagrams, mockups, collapsibles.
- Don't add interactive controls that don't export their state (dead-end UI).
- Don't depend on a local build pipeline.
- Don't overwrite an existing artifact silently — ask or version the filename.
