---
description: Analyze disk storage, identify cleanup opportunities, and write a machine-readable report for /disk-triage.
---

Perform a comprehensive disk storage analysis on this macOS system. **Read only — never delete anything.** Deletion is `/disk-triage`'s job.

## 1. Overall disk status

`df -h /System/Volumes/Data` for total / used / available.

## 2. Scan these locations

Run scans in parallel batches. For each, report the total and the top entries.

**macOS user data**
- `~/Library/Caches` (top 10)
- `~/Library/Application Support` (top 10)
- `~/Library/Containers` (top 10)
- `~/Library/Group Containers` (top 10)
- `~/Library/Developer` (Xcode, simulators, DerivedData)
- `~/Library/Logs`
- `~/Downloads` — flag files >100 MB
- `~/.Trash` — itemize, this is usually the single biggest win

**MCP server leftovers** — these are never garbage-collected and grow without bound. Every MCP server launched via `npx`/`uvx`/`bunx` pins a version into a content-hashed dir and keeps every prior version forever.
- `~/.npm/_npx` — per-hash breakdown; identify each by its `node_modules` top entries and dir mtime
- `~/.cache/uv/archive-v0` — uvx-unpacked Python servers. **Mark this `review`, never `safe`**: any `uvx`-launched MCP server holds `~/.cache/uv/.lock` for the whole session, so `uv cache clean`/`prune` always times out from inside Claude. Set `owner_tool` to `null` and say in the `reason` that it must be cleaned after quitting Claude Code. Check `pgrep -fl uvx` to name the holder.
- `~/.bun/install`
- Per-server caches under `~/Library/Caches` (e.g. `codehealth-mcp` ships a ~215 MB native binary *per version*) — list versions, keep newest only
- `~/Library/Caches/claude-cli-nodejs` — MCP stderr logs, one dir per project *and per worktree*; dead worktrees leave theirs behind
- Cross-reference against configured servers: `jq -r '.mcpServers | keys[]' ~/.claude.json`. Far more cached packages than configured servers = stale.

**Dev tools**
- `~/.npm` (`_cacache` separately), `~/.yarn`, `~/.cargo`, `~/.rustup`, `~/.asdf`, `~/.bun`, `~/.deno`, `~/.docker`, `~/.claude`, `~/.cache`, `~/.local`
- `$(brew --cache)` and `/opt/homebrew`

**Projects**
- `~/Projects` total, and any sibling `*-worktrees` dirs — worktrees each carry a full `_build`/`.elixir_ls`, so N worktrees = N× the artifacts
- Build artifacts: `node_modules`, `_build`, `deps`, `.elixir_ls`, `target`, `.next`, `dist`
- `.git` dir sizes (candidates for `git gc`)
- Stale worktree registrations: compare `git worktree list | wc -l` against dirs that actually exist on disk

**Known non-issues — check, but expect ~0:** iOS backups (`~/Library/Application Support/MobileSync`), Time Machine local snapshots (`tmutil listlocalsnapshots /`), `~/Library/Mail`, `~/Library/Messages`, `~/Library/Mobile Documents`. `/private/var/vm/sleepimage` is ~2 GB and regenerates — never suggest deleting it.

### Measurement gotcha

`du` on a parent and the sum of `du` on its children **will disagree** — TCC-protected subdirectories silently contribute nothing to per-child calls. Observed: `~/Library/Caches` 22 G parent vs ~5 G children; `~/Library/Group Containers` 6.6 G vs ~1 G.

**Always treat the parent total as authoritative** and explicitly flag the unexplained remainder rather than presenting the children sum as complete.

## 3. Categorize

- **Safe to clean** — caches, logs, package-manager stores, superseded versions, build artifacts that regenerate
- **Review first** — large personal files, `.Trash` (irreversible), app profile data, active-project artifacts, `.git`
- **Keep** — app data, system files, active toolchains

## 4. Output

**a) Markdown tables** to the user: largest opportunities, suggested cleanup commands (do **not** run them), total potential savings.

**b) A report file** at `~/.claude/disk-reports/YYYY-MM-DD-HHMM.json` (create the dir if needed) — this is what `/disk-triage` consumes:

```json
{
  "scanned_at": "2026-08-07T14:32:00Z",
  "disk": { "total_bytes": 0, "used_bytes": 0, "free_bytes": 0 },
  "findings": [
    {
      "path": "/Users/tobi/.cache/uv",
      "bytes": 11811160064,
      "human": "11G",
      "category": "mcp-leftovers",
      "verdict": "safe",
      "reason": "uvx-unpacked Python MCP servers; 7 servers configured",
      "owner_tool": "uv cache clean"
    }
  ],
  "notes": ["Group Containers: 6.6G parent vs 1.0G children — TCC-protected subdirs"]
}
```

Field rules:
- `verdict` — `safe` | `review` | `keep`. Only `safe` and `review` findings are actionable; include `keep` for completeness.
- `category` — groups the triage prompts. Use: `trash`, `mcp-leftovers`, `browser`, `package-manager-cache`, `build-artifacts`, `app-data`, `downloads`, `git`, `system`.
- `owner_tool` — the tool's own GC command when one exists (`npm cache clean --force`, `uv cache clean`, `brew cleanup`, `bun pm cache rm`, `git worktree prune`, `git gc`), else `null` meaning `rm -rf` is the only option.
- Anything with no safe deletion path belongs in `keep` with `owner_tool: null` — don't invent a command.

Finish by telling the user the report path and that `/disk-triage` will act on it.
