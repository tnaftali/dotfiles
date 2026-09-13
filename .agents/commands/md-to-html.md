---
description: Convert a markdown artifact (plan, research, report) to a styled, shareable HTML sibling via pandoc. Mechanical — no invented visuals.
argument-hint: "<path-to-markdown> [output-path]"
---

# md-to-html

Convert a markdown artifact (plan, research doc, report) into a styled HTML sibling for easier reading and sharing. Mechanical conversion — does NOT invent diagrams, mockups, or interactivity. For rich visual output use `/html-artifact` instead.

## Usage

`/md-to-html <path-to-markdown-file> [output-path]`

If `output-path` omitted, writes `<input>.html` next to source.

## What it does

Runs pandoc with the shared template at `~/dotfiles/.agents/templates/html/pandoc-template.html`. Output is a single self-contained HTML file:

- Sticky sidebar TOC
- GFM tables, code highlighting (Prism via CDN)
- GFM task checkboxes `- [ ]` → interactive checkboxes with localStorage persistence
- Mermaid code blocks (```` ```mermaid ````) auto-rendered
- Dark/light theme follows OS
- Mobile responsive

## Steps

1. Resolve the input path (error if missing or not `.md`).
2. Compute output path: same dir, `.html` extension (or use arg 2).
3. Run:

```bash
pandoc "$INPUT" \
  --from gfm \
  --to html5 \
  --standalone \
  --toc \
  --toc-depth=3 \
  --template ~/dotfiles/.agents/templates/html/pandoc-template.html \
  --metadata title="$(basename "$INPUT" .md)" \
  -o "$OUTPUT"
```

4. Report output path. Do not delete the source `.md` — it stays the editable source of truth.

## Notes

- Pandoc must be on PATH (`brew install pandoc` if missing).
- Frontmatter in the markdown is honored (title, date).
- For multiple files: loop the command, don't ask Claude to re-author.
- This command is mechanical; if user wants diagrams/mockups/interactivity, redirect them to `/html-artifact`.
