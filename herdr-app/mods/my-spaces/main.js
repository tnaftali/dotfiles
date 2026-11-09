// Workspace spaces: stable colored avatars, worktrees under their checkout,
// grouped by machine when more than one is known. After a space's name, the repo
// its first terminal is in now, its branch, ahead/behind. Agent state shows as a dot on the right, detail in the agents list. Click to
// switch, right-click for its menu. Sorted by when each agent last worked: Active (the last hour), Idle (1 to 3 hours), Inactive; Hidden is kept by hand.

import { View, div, svg, image } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { nextCommand, notify, readTextFile, writeTextFile, appHome, spaces, machines, panes, run, openOverlay, exec, hc, theme, shared, setShared, watchFolder, window, layout, focused, terminals, agents } from "herdr";

// Where a space is now: its first terminal's live folder, else where it was made.
// `ps`: panes(), read once by the caller (each read copies every pane).
function place(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}
const findNode = (node, id) => node?.id === id ? node : (node?.children ?? []).map((c) => findNode(c, id)).find(Boolean) ?? null;
// jq: the text the agent wrote since your last prompt. Its ASCII bar "[████░░] 4/8 ·" is how far it is.
const SINCE_PROMPT = '. as $a | ([range(0; length)] | map(select($a[.].type=="user" and (($a[.].message.content|type)=="string" or ([$a[.].message.content[]?|.type]|index("tool_result")|not)))) | last // -1) as $u | [$a[($u+1):][] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text] | join("\\n")';
const RANK = { blocked: 4, done: 3, working: 2, idle: 1 };
const HOUR = 3600000;
const where = (s, ps) => JSON.stringify([s.machine ?? null, place(s, ps)]);
const base = (path) => path.replace(/\/+$/, "").split("/").pop();
// Changes made outside Herdr (an editor's save, a commit in another app): looked
// for this often, in repos the list shows, while the window is in front.
const FALLBACK = 60000;
// The family for the list of spaces (installed in ~/.local/share/fonts/serif):
// "Source Serif 4", "Literata", "Newsreader", "Lora", "IBM Plex Serif", "Fraunces".
// null: the UI font.
const FONT = null;
// A pull request changes rarely: asked again after this long (gh is a network call).
const PR_TTL = 120000;

// What a stored color name looks like on an avatar (the same in every mod
// that draws space avatars): one strong color per hue, light and dark alike.
// Catppuccin Macchiato: teal, peach, blue, mauve, green, pink. The keys are what group.colors stores.
const MARK = { ansi6: "#8bd5ca", ansi3: "#f5a97f", ansi4: "#8aadf4", ansi5: "#c6a0f6", ansi2: "#a6da95", ansi1: "#f5bde6" };
// The laptop icon of another computer takes one of these (Catppuccin Macchiato). my-icons has the same list.
const LAPTOP = { blue: "#8aadf4", peach: "#f5a97f", green: "#a6da95", mauve: "#c6a0f6", teal: "#8bd5ca", pink: "#f5bde6", yellow: "#eed49f", red: "#ed8796", sky: "#91d7e3", lavender: "#b7bdf8", flamingo: "#f0c6c6", maroon: "#ee99a0", sapphire: "#7dc4e4" };

// A space speaks up only when something in it needs you.
export function glyph(status) {
  return status === "blocked" || status === "done" ? "●" : "·";
}

export function tone(t, status) {
  return t[status] ?? t.unknown;
}

export default class Spaces extends View {
  init(_props, cx) {
    this.git = {}; // where() -> { name, branch, ahead, behind, repo, linked }, null: not a repo
    this.checked = {}; // where() -> when it was last looked at
    this.unsure = new Set(); // where()s git couldn't answer for (a machine away)
    this.prs = {}; // repo|branch -> { at, v: {state, draft} | null }
    this.pending = new Set(); // where()s to look at next
    this.busy = {}; // pane -> an agent working or a program in front of its shell
    this.ready = {}; // machine -> its layout was readable at the last look
    this.at = {}; // space -> its where() at the last look
    this.watching = new Set(); // local repos' git folders
    // Spaces made while this runs wait (at most a moment) for their git, so a
    // worktree appears under its repo instead of jumping there.
    this.shown = new Set(spaces().map((s) => s.id));
    this.born = {};
    this.tip = null; // { row, text }: the status icon under the pointer
    this.prog = {}; // terminal address -> how far its agent says it is, 0 to 1
    this.machines = [];
    this.folded = new Set(JSON.parse(localStorage.getItem("machines.folded") ?? "[]"));
    this.visible = []; // space ids in the order drawn. Spaces in a folded section are not drawn, so not here.
    this.refreshMachines(cx);
    // Commands from the CLI, the prompts and the menu (the name carries the data):
    //   rename-ask:<space>       the prompt for a space's name (it takes Shift+Insert, so an emoji can be pasted); rename:<space>=<name> sets it
    //   hide:<space>, unhide:<space>   a hidden space is only in the Hidden section; it comes back when its agent starts working
    //   unread:<space>, read:<space>   show a space as done again (while its agent is idle) until it is opened
    //   grid                     the shown area becomes a grid of every Active and Idle space whose computer is connected (again: back)
    //   zoom                     ctrl-s z: the focused cell fills the grid, or Herdr's pane.zoom outside it
    //   sidebar                  narrow or widen the left sidebar
    //   mcolor-ask:<machine>     ask for the color of another computer's laptop icon; mcolor:<machine>|<name> sets it
    //   zoom:<space>             the same for that space's cell (its header button)
    //   go:<left|right|up|down>  ctrl-s h/j/k/l: the next cell in grid mode, Herdr's pane.go outside it
    //   gridmove:<from>|<to>     reorder the grid
    //   next, prev, select:<n>   go by what the sidebar shows, in the order it shows it
    cx.spawn(async (cx) => {
      for (;;) {
        const c = await nextCommand();
        let m;
        if ((m = /^rename-ask:(.+)$/s.exec(c))) {
          const cur = spaces().find((w) => w.id === m[1])?.name ?? "";
          openOverlay({ mod: "my-prompt", kind: "dialog", width: 340, height: 190, props: { title: "Rename", label: "Space name", value: cur, cmd: `my-spaces.rename:${m[1]}=` } });
        } else if ((m = /^rename:([^=]+)=(.*)$/s.exec(c))) {
          if (m[2]) run("space.rename", { id: m[1], name: m[2] });
        } else if ((m = /^(hide|unhide):(.+)$/s.exec(c))) {
          const rest = (shared("space.hidden") ?? []).filter((id) => id !== m[2]);
          setShared("space.hidden", m[1] === "hide" ? [...rest, m[2]] : rest);
        } else if (c === "sidebar") {
          this.sidebar();
        } else if ((m = /^mcolor-ask:(.+)$/s.exec(c))) {
          openOverlay({ mod: "my-icons", kind: "dialog", width: 340, height: 190, props: { machine: m[1] } });
        } else if ((m = /^mcolor:([^|]+)\|(.*)$/s.exec(c))) {
          const colors = { ...(shared("machine.colors") ?? {}) };
          if (m[2]) colors[m[1]] = m[2]; else delete colors[m[1]];
          setShared("machine.colors", colors);
        } else if (c === "grid") {
          this.toggleGrid(cx);
        } else if (c === "zoom" || (m = /^zoom:(.+)$/s.exec(c))) {
          this.zoom(cx, m?.[1]);
        } else if ((m = /^go:(left|right|up|down)$/.exec(c))) {
          this.go(m[1], cx);
        } else if ((m = /^gridmove:(.+)\|(.+)$/s.exec(c))) {
          this.gridMove(m[1], m[2], cx);
        } else if (c === "next" || c === "prev" || (m = /^select:(\d+)$/.exec(c))) {
          const ids = this.visible, at = ids.indexOf(spaces().find((w) => w.active)?.id);
          const to = m ? ids[Number(m[1]) - 1] : c === "next" ? ids[(at + 1) % ids.length] : ids[(at < 0 ? 0 : at - 1 + ids.length) % ids.length];
          if (to) this.pick(to);
        } else if ((m = /^(unread|read):(.+)$/s.exec(c))) {
          const un = { ...(shared("space.unread") ?? {}) };
          // Marked while open: it counts once the person leaves it.
          if (m[1] === "unread") un[m[2]] = spaces().find((w) => w.id === m[2])?.active ? "pending" : "on";
          else delete un[m[2]];
          setShared("space.unread", un);
        } else if ((m = /^panel:(files|changes|prs)$/.exec(c))) {
          const body = findNode(layout(), "panel-body"), panel = findNode(layout(), "panel");
          if (panel && !panel.hidden && body?.active === m[1]) run("layout.hide", { id: "panel" });
          else { run("layout.select", { stack: "panel-body", child: m[1] }); run("layout.show", { id: "panel" }); }
        } else if (c === "nvim") {
          // A press opens one nvim pane in this tab, the next closes it: no stacked splits.
          const f = focused();
          const open = terminals().filter(t => t.state === "live" && t.argv?.at(-1)?.endsWith("exec nvim")).map(t => t.address);
          const pane = panes().find(p => p.tab === f?.tab && open.includes(p.terminal));
          if (pane) run("pane.close", { pane: pane.pane });
          // The pane is split after the program starts: nvim must start once its final size is set.
          else run("terminal.open", { argv: ["sh", "-c", "sleep 0.5; exec nvim"], folder: f?.cwd ?? undefined, place: "right" });
        } else if (c === "lazygit" || c === "revdiff") {
          this.toggleFloat(cx, c);
        }
        cx.notify();
      }
    });
    cx.timer.every(15000, cx => this.refreshMachines(cx));
    // `git status` walks the whole tree, on another machine a process there:
    // only when its answer could have changed (see `due`).
    cx.timer.every(250, (cx) => { this.checkNew(cx); this.gridWatch(cx); this.track(cx); });
  }

  // Grid mode: the shown tab's area (the layout's `main`) becomes live terminals, one per Active or Idle space
  // and whose computer is connected (an agent's terminal if the shown tab has one). The layout tree is edited in place
  // by layout.set, so the original text is kept in shared("grid.saved") and put back on exit, or on the next start if
  // Herdr quit in grid mode. shortcut: one terminal per space, cells share the area equally.
  gridFile() { return `${appHome()}/layouts/${shared("layout") ?? "main"}.json`; }

  // The cells in order: the dragged order (shared "grid.order"), then the rest as the spaces are.
  gridCells() {
    const saved = shared("grid.order") ?? [];
    const up = new Set(machines().filter((m) => m.layout === "ready").map((m) => m.name));
    const live = spaces().filter((w) => ["active", "idle"].includes(this.tier(w)) && (w.machine === null || up.has(w.machine)));
    const order = [...saved.map((id) => live.find((w) => w.id === id)).filter(Boolean), ...live.filter((w) => !saved.includes(w.id))];
    return order.map((w) => {
      const tab = w.tabs.find((x) => x.active) ?? w.tabs[0];
      const all = panes().filter((x) => x.tab === tab?.id && x.terminal);
      // An idle shell with no agent is not worth a cell; keep one only when nothing else is left.
      const idle = new Set(terminals().filter((t) => t.program?.shell).map((t) => t.address));
      const ps = all.filter((x) => x.status || !idle.has(x.terminal));
      const shown = ps.length ? ps : all.slice(0, 1);
      const pane = shown.find((x) => x.status) ?? shown[0];
      return pane && { id: w.id, terminal: pane.terminal, terminals: shown.map((x) => x.terminal) };
    }).filter(Boolean);
  }

  // Puts the grid (or, zoomed, one cell) in place of `main` in the saved layout text.
  gridDraw(cx, focus = focused()?.terminal) {
    let cells = this.gridCells();
    this.gridSig = cells.map((c) => `${c.id}:${c.terminals.join("+")}`).join();
    const zoom = shared("grid.zoom");
    if (zoom && cells.some((c) => c.id === zoom)) cells = cells.filter((c) => c.id === zoom);
    else setShared("grid.zoom", null);
    if (!cells.length) return;
    // Columns side by side, each stacking its cells: a cell's height changes only its own column. Reading order
    // stays left to right, top to bottom. shortcut: a width is shared by the cells of a column, a tiling cannot do both.
    const cols = Math.ceil(Math.sqrt(cells.length));
    // Sizes the user dragged, kept per space by my-grid (shared "grid.sizes") and used as weights again, on every redraw and toggle.
    // shortcut: a cell weighs its terminal's height plus its header and border (28px), a column weighs its first cell's width.
    const sz = shared("grid.sizes") ?? {};
    const cell = (c, n, h = sz[c.id]?.h) => ({ id: `grid-c${n}`, type: "column", border: { width: 1, color: "border" }, radius: 12, resizable: false, ...(h && { size: { weight: h + 28 } }), children: [
      { type: "block", size: { px: 26 }, content: { mod: "my-grid", props: { space: c.id, terminals: c.terminals } } },
      // Not resizable: a divider next to the 1px probe would let it be dragged into a blank strip. shortcut: the panes of a cell split evenly; a nested row for them goes past Herdr's 16 levels.
      { id: `grid-b${n}`, type: "row", gap: 4, resizable: false, children: [
        ...c.terminals.map((t) => ({ type: "block", content: { terminal: t } })),
        { type: "block", size: { px: 1 }, content: { mod: "my-grid", props: { probe: c.id } } } ] } ] });
    const columns = Array.from({ length: cols }, (_, j) => {
      const mine = cells.filter((_, i) => i % cols === j);
      // A cell with no stored height (new here) weighs as much as the average of the others in its column; with none it would be squeezed to nothing.
      const known = mine.map((c) => sz[c.id]?.h).filter(Boolean);
      const avg = known.length ? known.reduce((a, b) => a + b, 0) / known.length : undefined;
      return { id: `grid-col${j}`, type: "column", gap: 8, ...(sz[mine[0]?.id]?.w && { size: { weight: sz[mine[0].id].w } }), children: mine.map((c) => cell(c, cells.indexOf(c), sz[c.id]?.h ?? avg)) };
    });
    // The columns go in `main`'s place, beside its siblings when the parent is a row: Herdr refuses layouts nested deeper than 16.
    const swap = (n) => (n.children ? { ...n, children: n.children.flatMap((c) => (c.id === "main" ? (n.type === "row" ? columns : [{ id: "main", type: "row", gap: 8, children: columns }]) : [swap(c)])) } : n);
    run("layout.set", { layout: swap(JSON.parse(shared("grid.saved"))) });
    // The drawn terminal blocks are new: give the keyboard back to the cell that had it.
    if (cx && cells.some((c) => c.terminals.includes(focus))) cx.timer.after(400, () => run("pane.focus", { terminal: focus }));
    return cells;
  }

  toggleGrid(cx) {
    const file = this.gridFile(), saved = shared("grid.saved");
    if (saved) {
      setShared("grid.saved", null);
      setShared("grid.zoom", null);
      run("layout.set", { layout: JSON.parse(saved) });
      // layout.set re-formats the file: write the original text back, so the dotfiles repo stays clean.
      cx.timer.after(1000, (cx) => cx.spawn(async () => { const now = await readTextFile(file); if (now !== saved) await writeTextFile(file, saved, now).catch(() => {}); }));
      return;
    }
    cx.spawn(async () => {
      const text = await readTextFile(file);
      if (!text) return notify({ title: "Grid did not open", body: `Cannot read ${file}.`, level: "warning" });
      if (!findNode(JSON.parse(text), "main")) return notify({ title: "Grid did not open", body: "The layout has no `main` block.", level: "warning" });
      if (!this.gridCells().length) return notify({ title: "Nothing to show", body: "Every space is inactive, hidden or offline.", level: "info" });
      setShared("grid.saved", text);
      setShared("grid.layout", shared("layout") ?? "main");
      setShared("grid.zoom", null);
      try { this.gridDraw(cx); } catch (e) { setShared("grid.saved", null); notify({ title: "Grid did not open", body: String(e?.message ?? e), level: "warning" }); }
    });
  }

  // ctrl-s z: in grid mode the focused cell fills the area, again: back to the grid. Elsewhere the pane zoom of Herdr.
  zoom(cx, id) {
    if (!shared("grid.saved")) return run("pane.zoom");
    const cells = this.gridCells(), t = focused()?.terminal, zid = shared("grid.zoom");
    const cell = id ? cells.find((c) => c.id === id) : cells.find((c) => c.terminals.includes(t));
    if (zid) setShared("grid.zoom", null);
    else if (cell) setShared("grid.zoom", cell.id);
    else return;
    // Zoomed or not, the keyboard stays in the cell that was zoomed.
    const to = cell ?? cells.find((c) => c.id === zid);
    this.gridDraw(cx, to?.terminals.includes(t) ? t : to?.terminal ?? t);
  }

  // ctrl-s h/j/k/l: the cell next to the focused one. Columns are `i % cols`; across columns the nearest by vertical middle wins.
  go(dir, cx) {
    if (!shared("grid.saved")) return run("pane.go", { direction: dir });
    const cells = this.gridCells(), t = focused()?.terminal, i = cells.findIndex((c) => c.terminals.includes(t));
    if (shared("grid.zoom") || !cells.length) return;
    if (i < 0) return run("pane.focus", { terminal: cells[0].terminal });
    // A cell with several panes: left and right go through them first.
    if (dir === "left" || dir === "right") {
      const next = cells[i].terminals[cells[i].terminals.indexOf(t) + (dir === "right" ? 1 : -1)];
      if (next) return run("pane.focus", { terminal: next });
    }
    const cols = Math.ceil(Math.sqrt(cells.length)), sz = shared("grid.sizes") ?? {};
    const mid = (j) => {
      const cs = cells.filter((_, k) => k % cols === j), known = cs.every((c) => sz[c.id]?.h), h = (c) => (known ? sz[c.id].h + 28 : 1);
      const total = cs.reduce((n, c) => n + h(c), 0);
      let y = 0;
      return cs.map((c) => { y += h(c); return { c, y: (y - h(c) / 2) / total }; });
    };
    const j = i % cols, col = mid(j), me = col.find((x) => x.c === cells[i]);
    const to = dir === "up" || dir === "down"
      ? col[col.indexOf(me) + (dir === "down" ? 1 : -1)]?.c
      : mid(j + (dir === "right" ? 1 : -1)).sort((a, b) => Math.abs(a.y - me.y) - Math.abs(b.y - me.y))[0]?.c;
    if (to) run("pane.focus", { terminal: to.terminal });
  }

  // Dragging a cell header onto another: the first takes the second's place.
  gridMove(from, to, cx) {
    const all = this.gridCells().map((c) => c.id), ids = all.filter((id) => id !== from);
    ids.splice(ids.indexOf(to) + (all.indexOf(from) < all.indexOf(to) ? 1 : 0), 0, from);
    setShared("grid.order", ids);
    this.gridDraw(cx);
  }

  // Floating tool in the focused folder (button in workspace-status). One per folder and tool:
  // a press opens it, the next press closes the overlay, and the tool keeps running.
  toggleFloat(cx, tool) {
    const f = focused(), cwd = f?.cwd;
    const warn = (body) => notify({ title: `${tool} did not open`, body, level: "warning" });
    if (!cwd) return warn("No folder in the focused pane.");
    if (f.space.includes("/")) return warn("The space is on another machine. This runs on this PC only.");
    const live = terminals().find(t => t.state === "live" && t.cwd === cwd && t.name?.startsWith(`${tool}-`));
    if (live && this.floatOpen === live.address) { this.floatOpen = null; run("overlay.close"); return; }
    if (live) { this.floatOpen = live.address; run("terminal.peek", { terminal: live.address }); return; }
    if (this.floatBusy) return;
    this.floatBusy = true;
    // revdiff prints its notes on quit: send them to the agent this was started from.
    const agent = terminals().find(t => t.address === f?.terminal && t.program?.agent && t.program.key !== "lazygit")?.address ?? "";
    const argv = tool === "revdiff"
      ? ["sh", "-c", 'F=$(mktemp); revdiff --untracked -o "$F"; [ -s "$F" ] && [ -n "$1" ] && hc send "$1" "Review notes from revdiff:\n$(cat "$F")"; rm -f "$F"', "revdiff", agent]
      : ["lazygit"];
    // Own task: `hc` is slow and nextCommand drops commands while its loop is busy.
    cx.spawn(async (cx) => {
      // Not a repo: both tools would offer to create one, or fail.
      const repo = await exec("git", ["rev-parse", "--is-inside-work-tree"], { cwd }).catch(() => null);
      if (repo?.code !== 0) { this.floatBusy = false; warn(`${cwd} is not a git repo.`); return; }
      const r = await hc(["run", "--bg", "--json", "--no-parent", "--outlive-parent", "--rm", "--name", `${tool}-${Date.now().toString(36)}`, ...(cwd ? ["--cwd", cwd] : []), ...argv]);
      this.floatBusy = false;
      if (r.code !== 0) { warn(r.stderr.trim().split("\n").at(-1) || `hc exit ${r.code}`); return; }
      const address = JSON.parse(r.stdout).address;
      this.floatOpen = address;
      // The window learns of a new terminal a moment later; peeking at once fails.
      cx.timer.after(600, () => run("terminal.peek", { terminal: address }));
    });
  }

  // claude.sessions: terminal address -> { id, cwd } of the Claude session running in it. The id is in
  // ~/.claude/sessions/<pid>.json, for the pid in front of that terminal's shell.
  trackClaude(cx) {
    if (this.tracking) return;
    const local = terminals().filter((t) => !t.address.includes("/"));
    const live = local.filter((t) => t.program?.key === "claude");
    this.tracking = true;
    cx.spawn(async () => {
      try {
        const found = {}, prog = {};
        if (live.length) {
          const script = 'F=$1; shift; for a in "$@"; do pid=$(hc get "$a" | jq -r .foreground.pid); f="$HOME/.claude/sessions/$pid.json"; [ -f "$f" ] || continue; id=$(jq -r .sessionId "$f"); t=$(printf "%s\\n" "$HOME"/.claude/projects/*/"$id".jsonl | head -1); p=""; [ -f "$t" ] && p=$(tail -n 300 "$t" | jq -Rc "fromjson?" | jq -rs "$F" | grep -oE "\\] [0-9]+/[0-9]+" | tail -1 | tr -d "] "); echo "$a $(jq -c --arg p "$p" "{id: .sessionId, cwd: .cwd, prog: \\$p}" "$f")"; done';
          const r = await exec("sh", ["-c", script, "sh", SINCE_PROMPT, ...live.map((t) => t.address)]);
          for (const line of r.stdout.split("\n")) {
            const m = line.match(/^(\S+) (\{.*\})$/);
            if (m) { const { prog: p, ...rec } = JSON.parse(m[2]); const [n, d] = p.split("/").map(Number); found[m[1]] = rec; if (d > 0) prog[m[1]] = Math.min(1, n / d); }
          }
        }
        const saved = shared("claude.sessions") ?? {};
        const next = { ...saved, ...found };
        // Only once the startup pass ran: before it, a shell with a saved session is what it must resume.
        if (this.resumed && local.length) {
          for (const addr of Object.keys(next)) {
            const t = local.find((x) => x.address === addr);
            if (!t || (!found[addr] && t.program?.key !== "claude")) delete next[addr];
          }
        }
        if (JSON.stringify(next) !== JSON.stringify(saved)) setShared("claude.sessions", next);
        if (JSON.stringify(prog) !== JSON.stringify(this.prog)) { this.prog = prog; cx.notify(); }
      } catch {}
      this.tracking = false;
    });
  }

  resumeClaude(cx) {
    const saved = shared("claude.sessions") ?? {};
    const local = terminals().filter((t) => !t.address.includes("/"));
    // No terminals listed yet: the window is not ready, so try again soon.
    if (!local.length) return void cx.timer.after(5000, (cx) => this.resumeClaude(cx));
    this.resumed = true;
    const q = (v) => `'${String(v).replace(/'/g, `'\\''`)}'`;
    for (const [addr, { id, cwd }] of Object.entries(saved)) {
      const t = local.find((x) => x.address === addr);
      if (!t || !t.program?.shell || t.state !== "live" || !/^[0-9a-f-]{36}$/.test(id)) continue;
      cx.spawn(async () => { try { await hc(["send", addr, `cd ${q(cwd)} && claude --resume ${id}`]); } catch {} });
    }
  }

  // Go to a space. In grid mode its cell takes the keyboard too, so typing goes into it.
  pick(id) {
    run("space.select", { id });
    const cell = shared("grid.saved") && this.gridCells().find((c) => c.id === id);
    if (cell) run("pane.focus", { terminal: cell.terminal });
  }

  // The section of a space, from when its agent last worked, not from where it was put. Hidden is the only manual one.
  // A space that waits for you (blocked, or done and unread) or works now is Active, however long ago it began.
  tier(w) {
    if ((shared("space.hidden") ?? []).includes(w.id)) return "hidden";
    if (["blocked", "done", "working"].includes(this.status(w))) return "active";
    const age = Date.now() - (this.seen?.[w.id] ?? 0);
    return age <= HOUR ? "active" : age <= 3 * HOUR ? "idle" : "inactive";
  }

  // Every tick: notes when each agent last worked (kept across restarts), brings back a hidden space whose agent starts
  // working (a message was sent; only opening it does not), and redraws when time moves a space to another section.
  track(cx) {
    const sp = spaces(), now = Date.now();
    this.seen ??= { ...(shared("space.seen") ?? {}) };
    if (!this.migrated && sp.length) {
      // The hand-made Inactive list became Hidden. Spaces that were not in it start Active.
      this.migrated = true;
      if (shared("space.hidden") == null) setShared("space.hidden", shared("space.minimized") ?? []);
      for (const w of sp) if (!(w.id in this.seen) && !(shared("space.hidden") ?? []).includes(w.id)) this.seen[w.id] = now;
      this.dirty = true;
    }
    // A new space starts Active: without a stamp its age would be "since 1970", so it would land in Inactive.
    const fresh = sp.filter((w) => !(w.id in this.seen) && !(shared("space.hidden") ?? []).includes(w.id));
    for (const w of fresh) this.seen[w.id] = now;
    if (fresh.length) this.dirty = true;
    const prev = this.prevState, cur = Object.fromEntries(sp.map((w) => [w.id, w.status]));
    this.prevState = cur;
    for (const w of sp) if (w.status === "working" || w.status === "blocked") { this.seen[w.id] = now; this.dirty = true; }
    // Saved when work stops, else at most every 30 s.
    const stopped = prev && sp.some((w) => prev[w.id] === "working" && w.status !== "working");
    if (this.dirty && (stopped || now - (this.savedAt ?? 0) > 30000)) { setShared("space.seen", this.seen); this.dirty = false; this.savedAt = now; }
    const hid = shared("space.hidden") ?? [], woke = prev ? hid.filter((id) => cur[id] === "working" && prev[id] && prev[id] !== "working") : [];
    if (woke.length) setShared("space.hidden", hid.filter((id) => !woke.includes(id)));
    const sig = sp.map((w) => this.tier(w)).join();
    if (sig !== this.tierSig) { this.tierSig = sig; cx.notify(); }
  }

  // The left sidebar: full width, or a narrow rail of icons (a header that stacks its buttons is taller).
  sidebar() {
    const node = findNode(layout(), "sidebar"), narrow = (node?.size?.px ?? Infinity) < 160;
    if (!narrow) setShared("sidebar.width", node?.size?.px);
    setShared("sidebar.collapsed", !narrow);
    run("layout.resize", { id: "sidebar", px: narrow ? (shared("sidebar.width") ?? 268) : window()?.platform === "macos" ? 76 : 44 });
    run("layout.resize", { id: "brand", px: narrow ? 46 : window()?.platform === "macos" ? 106 : 72 });
  }

  // Grid mode: a space that appears, goes, or changes section changes the cells, so draw them again.
  gridWatch(cx) {
    if (!shared("grid.saved") || (shared("grid.layout") ?? "main") !== (shared("layout") ?? "main")) return void (this.gridSig = undefined);
    const sig = this.gridCells().map((c) => `${c.id}:${c.terminals.join("+")}`).join();
    if (this.gridSig !== undefined && sig !== this.gridSig) { this.gridSig = sig; cx.timer.after(300, (cx) => this.gridDraw(cx)); }
  }

  checkNew(cx) {
    // Started here, not in init(): a hot reload keeps the instance and does not run init() again.
    if (!this.claudeStarted) {
      // After a reboot the core's terminals come back as plain shells: resume the Claude sessions that were in them.
      this.claudeStarted = true;
      // This mod started in grid mode (Herdr or the mod restarted): stay in it and draw the cells again with the live terminals.
      // Another layout is shown now: put the grid's layout file back.
      const saved = shared("grid.saved");
      if (saved) {
        if ((shared("grid.layout") ?? "main") === (shared("layout") ?? "main")) cx.timer.after(2000, (cx) => this.gridDraw(cx));
        else {
          setShared("grid.saved", null);
          const file = `${appHome()}/layouts/${shared("grid.layout")}.json`;
          cx.spawn(async () => { const now = await readTextFile(file).catch(() => null); if (now && now !== saved) await writeTextFile(file, saved, now).catch(() => {}); });
        }
      }
      // The right rail has Files and Changes: the tab bar's own buttons would repeat them.
      if (JSON.stringify(shared("workspace.panels")) !== "[]") setShared("workspace.panels", []);
      this.resumed = false;
      cx.timer.every(5000, (cx) => this.trackClaude(cx));
      cx.timer.after(10000, (cx) => this.resumeClaude(cx));
    }
    const now = Date.now();
    const sp = spaces();
    const act = sp.find((w) => w.active)?.id;
    if (act !== this.lastActive) {
      const un = { ...(shared("space.unread") ?? {}) };
      if (un[this.lastActive] === "pending") un[this.lastActive] = "on";
      delete un[act];
      setShared("space.unread", un);
      this.lastActive = act;
    }
    for (const s of sp) if (!this.shown.has(s.id)) this.born[s.id] ??= now;
    const due = this.due(now, sp, panes());
    if (due.size) this.refreshGit(due, cx);
    if (sp.some((s) => !this.shown.has(s.id))) cx.notify();
  }

  // Places whose git could have changed: new ones (a new space, a cd), where a
  // command or an agent's turn just ended (a checkout, a commit, edits), those on
  // a machine that is back, and repos in view whose fallback is due.
  due(now, sp, ps) {
    // Moved there: what it knew of that place may be old.
    const at = {};
    for (const s of sp) at[s.id] = where(s, ps);
    const keys = new Set(Object.values(at).filter((k) => JSON.parse(k)[1]));
    const due = new Set([...keys].filter((k) => !(k in this.git)));
    for (const [id, k] of Object.entries(at)) if (this.at[id] && this.at[id] !== k && keys.has(k)) due.add(k);
    this.at = at;
    const spaceOf = {};
    for (const s of sp) for (const t of s.tabs ?? []) spaceOf[t.id] = s;
    const busy = {};
    for (const p of ps) {
      if (!p.terminal || !spaceOf[p.tab]) continue;
      busy[p.pane] = p.status === "working" || !(p.program?.shell || p.program?.agent);
      if (this.busy[p.pane] && !busy[p.pane]) this.sameRepo(at[spaceOf[p.tab].id], keys).forEach((k) => due.add(k));
    }
    this.busy = busy;
    for (const m of machines()) {
      const ready = m.layout === "ready";
      if (ready && this.ready[m.name] === false) for (const k of keys) if (JSON.parse(k)[0] === m.name) due.add(k);
      this.ready[m.name] = ready;
    }
    if (window().active) {
      for (const k of keys) {
        const asks = this.git[k] || this.unsure.has(k);
        if (asks && !this.folded.has(JSON.parse(k)[0]) && now - (this.checked[k] ?? 0) > FALLBACK) due.add(k);
      }
    }
    return due;
  }

  // `key` and the other places in its repo (a commit there moves their ahead/behind).
  sameRepo(key, keys) {
    const repo = this.git[key]?.repo;
    return [key, ...(repo ? [...keys].filter((k) => this.git[k]?.repo === repo) : [])];
  }

  refreshMachines(cx) {
    cx.spawn(async cx => {
      try { const r = await hc(["machine", "ls", "--json"]); if (r.code === 0) this.machines = (JSON.parse(r.stdout).machines ?? []).filter((m) => !m.temporary); } catch {}
      cx.notify();
    });
  }

  // One look at a time, each place once however often it was asked for meanwhile.
  refreshGit(keys, cx) {
    for (const k of keys) this.pending.add(k);
    if (this.refreshing) return;
    this.refreshing = true;
    cx.spawn(async (cx) => {
      while (this.pending.size) {
        const keys = [...this.pending];
        this.pending.clear();
        for (const key of keys) await this.check(key, cx);
      }
      const used = new Set(Object.values(this.git).filter(Boolean).map((g) => JSON.parse(g.repo)).filter(([on]) => !on).map(([, repo]) => repo));
      for (const repo of this.watching) if (!used.has(repo)) this.watching.delete(repo);
      this.refreshing = false;
      cx.notify();
    });
  }

  // One place's git: branch, ahead/behind, its repo.
  async check(key, cx) {
    const [on, cwd] = JSON.parse(key);
    this.checked[key] = Date.now();
    this.unsure.delete(key);
    try {
      // No optional locks: a status that touched the index would wake the watch again.
      const r = await exec("git", ["--no-optional-locks", "status", "--porcelain=v2", "--branch"], { cwd, on });
      if (r.code !== 0) {
        // Only git's own "no" is remembered as no repo; anything else is asked again.
        if (!/not a git repository/i.test(r.stderr)) this.unsure.add(key);
        this.git[key] = null;
        return;
      }
      // The repo's own .git folder names it; a worktree's top differs from it.
      const top = await exec("git", ["rev-parse", "--show-toplevel"], { cwd, on });
      const common = await exec("git", ["rev-parse", "--path-format=absolute", "--git-common-dir"], { cwd, on });
      const repo = common.stdout.trim();
      const name = repo.endsWith("/.git") ? base(repo.slice(0, -5)) : base(repo).replace(/\.git$/, "");
      const info = { name, branch: null, ahead: 0, behind: 0, repo: JSON.stringify([on, repo]), linked: repo !== `${top.stdout.trim()}/.git` };
      info.dirty = 0;
      for (const line of r.stdout.split("\n")) {
        if (line && !line.startsWith("#")) info.dirty++;
        if (line.startsWith("# branch.head ")) info.branch = line.slice(14);
        else if (line.startsWith("# branch.ab ")) {
          const [a, b] = line.slice(12).split(" ");
          info.ahead = Math.abs(parseInt(a, 10)) || 0;
          info.behind = Math.abs(parseInt(b, 10)) || 0;
        }
      }
      this.git[key] = info;
      if (!on) this.watch(repo, cx);
      this.fetchPr(info, cwd, on, cx);
    } catch {
      // Couldn't ask (the machine is away): keep what it showed, look again later.
      this.git[key] ??= null;
      this.unsure.add(key);
    }
  }

  // The newest pull request from this branch (any state), cached. No gh, no login or no
  // remote: no icon.
  fetchPr(info, cwd, on, cx) {
    const b = info.branch;
    if (!b || b === "(detached)" || b === "main" || b === "master") return;
    const id = `${info.repo}|${b}`;
    if (Date.now() - (this.prs[id]?.at ?? 0) < PR_TTL) return;
    this.prs[id] = { at: Date.now(), v: this.prs[id]?.v ?? null };
    cx.spawn(async (cx) => {
      try {
        const r = await exec("gh", ["pr", "list", "--head", b, "--state", "all", "--limit", "1", "--json", "state,isDraft"], { cwd, on });
        const pr = r.code === 0 ? JSON.parse(r.stdout)[0] : null;
        this.prs[id].v = pr ? { state: pr.state, draft: pr.isDraft } : null;
      } catch {}
      cx.notify();
    });
  }

  // Icons for where the code stands: local changes, commits not pushed, the pull request.
  // Herdr's own tooltip never showed in this window: a small label inside the row instead.
  tipHover(h, cx, row, text) {
    if (h) this.tip = { row, text };
    else if (this.tip?.row === row && this.tip.text === text) this.tip = null;
    else return;
    cx.notify();
  }

  marks(g, t, id) {
    const out = [];
    const pr = this.prs[`${g.repo}|${g.branch}`]?.v;
    if (g.dirty > 0) out.push(["dirty", t.ansi3, `${g.dirty} uncommitted change${g.dirty > 1 ? "s" : ""}`]);
    else if (g.ahead > 0) out.push(["unpushed", t.ansi4, `${g.ahead} commit${g.ahead > 1 ? "s" : ""} not pushed`]);
    if (pr) {
      const k = pr.state === "MERGED" ? ["pr-merged", t.ansi5, "PR merged"]
        : pr.state === "CLOSED" ? ["pr-closed", t.ansi1, "PR closed"]
        : pr.draft ? ["pr-draft", t.dim, "PR draft"] : ["pr-open", t.ansi2, "PR open"];
      out.push(k);
    }
    return out.map(([i, c, tip]) => div().id(`mark-${id}-${i}`).flex_none().hover((x) => x.opacity(0.7)).on_hover((h, cx) => this.tipHover(h, cx, id, tip))
      .child(svg(`mods/my-spaces/icons/${i}.svg`).size(i === "dirty" ? 9 : 14).flex_none().text_color(c)));
  }

  watch(repo, cx) {
    if (this.watching.has(repo)) return;
    this.watching.add(repo);
    cx.spawn(async (cx) => {
      try {
        while (this.watching.has(repo)) {
          await watchFolder(repo);
          const mine = JSON.stringify([null, repo]);
          if (this.watching.has(repo)) this.refreshGit(Object.keys(this.git).filter((k) => this.git[k]?.repo === mine), cx);
        }
      } catch { this.watching.delete(repo); }
    });
  }

  menu(w) {
    // A popup is as tall as its items; height is only the most.
    openOverlay({ mod: "my-menu", kind: "popup", width: 200, height: 300, props: { tab: "space", target: { id: w.id } } });
  }

  // Spaces in Herdr's order; worktrees are not nested under their repo.
  ordered() {
    const sp = spaces(), ps = panes();
    const ready = (w) => this.shown.has(w.id) || where(w, ps) in this.git || Date.now() - (this.born[w.id] ??= Date.now()) > 1500;
    for (const w of sp) if (!this.shown.has(w.id) && ready(w)) this.shown.add(w.id);
    return sp.map((w, i) => ({ w, i, g: this.git[where(w, ps)] ?? null })).filter((r) => this.shown.has(r.w.id));
  }

  // The sections: Active, Idle, Inactive, Hidden. Newest first inside each; a space that works now comes before any
  // that worked before, and equal ones keep Herdr's order, so the list does not shuffle while two agents work.
  // A folded section still shows the open space.
  grouped(t, collapsed) {
    this.visible = [];
    this.open ??= { active: true, idle: true, inactive: false, hidden: false, ...JSON.parse(localStorage.getItem("sections.open") ?? "{}") };
    const rows = this.ordered();
    const loading = spaces().some((s) => !s.machine && !this.shown.has(s.id)) || machines().find((k) => k.name === null)?.layout === "loading";
    if (loading && !rows.length) return [div().id("machine-loading-local").h(28).flex_none().px(8).text_size(12).text_color(t.dim).child(collapsed ? "…" : "Loading…")];
    const key = (r) => (r.w.status === "working" ? Infinity : this.seen?.[r.w.id] ?? 0);
    const out = [];
    for (const [id, label, icon] of [["active", "Active", "sun"], ["idle", "Idle", "clock"], ["inactive", "Inactive", "moon"], ["hidden", "Hidden", "eye-off"]]) {
      const list = rows.filter((r) => this.tier(r.w) === id).sort((a, b) => key(b) - key(a) || a.i - b.i);
      if (!list.length) continue;
      const alert = list.find((r) => r.w.status === "blocked") ?? list.find((r) => this.status(r.w) === "done");
      const shown = this.open[id] ? list : list.filter((r) => r.w.active);
      out.push(this.sectionHead(id, label, icon, list.length, this.open[id], alert, t, collapsed, !out.length));
      for (const r of shown) { this.visible.push(r.w.id); out.push(collapsed ? this.compact(r, t) : this.row(r, t)); }
    }
    return out;
  }

  sectionHead(id, label, icon, n, open, alert, t, collapsed, first) {
    return h_flex().id(`section-${id}`).h(26).flex_none().px(collapsed ? 2 : 8).mt(first ? 2 : 8).gap(7).items_center().when(collapsed, (el) => el.justify_center()).rounded(10).text_size(12).text_color(t.dim)
      .cursor_pointer().hover((st) => st.bg(t.hover))
      .on_click((_e, cx) => {
        this.open[id] = !this.open[id];
        localStorage.setItem("sections.open", JSON.stringify(this.open));
        cx.notify();
      })
      .child(svg(`mods/my-spaces/icons/${icon}.svg`).size(13).flex_none())
      .when(!collapsed, (el) => el.child(div().flex_1().truncate().child(label))
        .when(!open && Boolean(alert), (e) => e.child(div().flex_none().text_color(tone(t, this.status(alert.w))).child("\u25cf")))
        .child(div().flex_none().text_size(11).child(String(n)))
        .child(svg(`mods/workspace-chrome/chevron-${open ? "down" : "right"}.svg`).size(11).flex_none()));
  }

  // A space's name. An emoji needs its own font, or it shows blank.
  title(name, t) {
    const parts = name.split(/(\p{Extended_Pictographic}(?:\uFE0F|\u200D\p{Extended_Pictographic})*)/u).filter(Boolean);
    return h_flex().flex_1().min_w(0).overflow_hidden().whitespace_nowrap().text_color(t.foreground)
      .children(parts.map((x) => (/^\p{Extended_Pictographic}/u.test(x) ? div().flex_none().font_family("Noto Color Emoji").child(x) : div().flex_none().child(x))));
  }

  // The laptop icon of another computer, in its color (shared "machine.colors"); without a choice, one picked from its name.
  laptop(m, t, size) {
    const names = Object.keys(LAPTOP), hue = (shared("machine.colors") ?? {})[m] ?? names[[...m].reduce((a, c) => (a * 31 + c.charCodeAt(0)) >>> 0, 7) % 7];
    return svg("mods/my-spaces/icons/laptop.svg").size(size).flex_none().text_color(LAPTOP[hue] ?? t.dim);
  }

  // After the name, always: "herdr \u00b7 spike \u21912 \u21931". Repo and branch show on
  // every space in a repo; a space outside git has no `g` and no tail.
  gitTail(g, tree, name, t, rid) {
    const where = [g.name, g.branch ?? "detached"].filter(Boolean).join(" \u00b7 ");
    return h_flex()
      .min_w(0)
      .gap(5)
      .justify_start()
      .items_center()
      .text_size(12.5)
      .text_color(t.dim)
      .when(Boolean(where), (el) => el.child(div().min_w(0).truncate().child(where)))
      .when(g.ahead > 0, (el) => el.child(div().id(`ahead-${name}`).flex_none().hover((x) => x.opacity(0.7)).on_hover((h, cx) => this.tipHover(h, cx, rid, `${g.ahead} commit${g.ahead > 1 ? "s" : ""} ahead of upstream`)).text_color(t.ansi2).child(`\u2191${g.ahead}`)))
      .when(g.behind > 0, (el) => el.child(div().id(`behind-${name}`).flex_none().hover((x) => x.opacity(0.7)).on_hover((h, cx) => this.tipHover(h, cx, rid, `${g.behind} commit${g.behind > 1 ? "s" : ""} behind upstream`)).text_color(t.ansi1).child(`\u2193${g.behind}`)));
  }

  // The Claude icon of a space's lead agent in a ring: yellow (working: filled as far as the agent says it is,
  // else turning), red (waiting for you), green (done), grey (idle). No agent: a faded icon with a z.
  // A space marked unread shows as done while its agent is idle, until the person opens it.
  // In grid mode the blue selection follows the focused cell, not the space Herdr calls active.
  act(w) {
    if (!shared("grid.saved")) return w.active;
    const c = this.gridCells().find((x) => x.terminals.includes(focused()?.terminal));
    return c ? c.id === w.id : w.active;
  }

  unread(id) { return shared("space.unread")?.[id] === "on"; }
  status(w) { return w.status === "idle" && this.unread(w.id) ? "done" : w.status; }

  agentIcon(a, t) {
    const ring = (color) => div().relative().size(36).flex_none().flex().items_center().justify_center().rounded(18).border(3).border_color(color);
    if (!a) return ring(t.raised).opacity(0.5).child(image("icons/claude.svg").w(20).h(20).flex_none())
      .child(div().absolute().right(-3).bottom(-5).text_size(10).font_bold().text_color(t.dim).child("z"));
    const p = a.program, st = a.status === "idle" && this.unread(a.space) ? "done" : a.status;
    const pic = p?.icon ? (p.tint ? svg(p.icon).size(20).flex_none().text_color(t.foreground) : image(p.icon).w(20).h(20).flex_none()) : div().size(10).rounded(5).bg(t.dim);
    const color = st === "blocked" ? t.blocked : st === "done" ? t.done ?? t.ansi2 : st === "working" ? t.raised : t.surface ?? t.raised;
    const f = this.prog[a.address];
    return ring(color).child(pic)
      .when(st === "working", (el) => el.child(svg("mods/workspace-chrome/spinner.svg").absolute().top(-3).left(-3).size(36).text_color(t.working).spin(900)))
      .when(st === "working" && f !== undefined, (el) => el.child(svg(`mods/my-spaces/icons/ring-${Math.round(f * 20) * 5}.svg`).absolute().top(-3).left(-3).size(36).text_color(t.working)));
  }

  row({ w, g }, t) {
    const on = this.act(w);
    const lead = agents().filter((a) => a.space === w.id && a.program?.key !== "lazygit")
      .sort((a, b) => (RANK[b.status] ?? 0) - (RANK[a.status] ?? 0) || b.seq - a.seq)[0];
    const tail = g ? this.gitTail(g, null, w.name, t, w.id) : null;
    return v_flex()
      .relative()
      .id(`space-${w.id}`)
      .px(8)
      .h(tail ? 54 : 42)
      .flex_none()
      .justify_center()
      .rounded(12)
      .when(on, (el) => el.bg(`${t.accent}1a`).border_1().border_color(t.accent))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      .on_mouse_up("middle", () => run("space.close", { id: w.id }))
      .on_mouse_up("left", (e, cx) => {
        if (e.click_count >= 2) run(`my-spaces.rename-ask:${w.id}`);
        else this.pick(w.id);
        cx.notify();
      })
      .on_mouse_down("right", () => this.menu(w))
      .when(this.tip?.row === w.id, (el) => el.child(div().absolute().right(6).bottom(3).px(6).py(1).rounded(8).bg(t.chrome).border_1().border_color(t.border).text_size(11).text_color(t.foreground).child(this.tip.text)))
      .child(
        h_flex()
          .gap(9)
          .items_center()
          .child(this.agentIcon(lead, t))
          .child(v_flex().flex_1().min_w(0).gap(1)
            .child(h_flex().min_w(0).gap(6).items_center()
              .child(this.title(w.name, t))
              .when(Boolean(w.machine), (el) => el.child(this.laptop(w.machine, t, 14)))
              .children(g ? this.marks(g, t, w.id) : [])
              .when(lead?.status === "blocked", (el) => el.child(div().flex_none().text_size(11).font_semibold().text_color(t.blocked).child("Needs you"))))
            .when(Boolean(tail), (el) => el.child(tail))),
      );
  }

  // Collapsed sidebar: the number of the space in a pill; a dot in its corner when an agent works or waits.
  compact({ w }, t) {
    const status = this.status(w), on = this.act(w);
    return h_flex().id(`space-${w.id}`).h(32).flex_none().items_center().justify_center().cursor_pointer()
      .on_click(() => this.pick(w.id))
      .child(div().relative().size(28).flex().items_center().justify_center().rounded(10).text_size(13)
        .text_color(on ? t.foreground : t.muted).bg(on ? t.raised : t.chrome).hover((s) => s.bg(on ? t.raised : t.hover))
        .child(String(this.visible.indexOf(w.id) + 1))
        .when(["blocked", "working", "done"].includes(status), (el) => el.child(div().absolute().top(4).right(4).size(6).rounded(3).bg(tone(t, status)))));
  }

  render() {
    const t = theme();
    // By the sidebar's width, not a flag: a restart or a layout reload resets the width and the flag would lie.
    const collapsed = (findNode(layout(), "sidebar")?.size?.px ?? Infinity) < 160;
    const palette = ["ansi6", "ansi3", "ansi4", "ansi5", "ansi2", "ansi1"];
    const sp = spaces();
    // The tab bar only shows with 2+ tabs; its Files/Changes buttons move to ctrl-s f / ctrl-s v.
    const bar = findNode(layout(), "tabs");
    const want = (sp.find(p => p.active)?.tabs ?? []).length > 1;
    if (bar && Boolean(bar.hidden) === want) run(want ? "layout.show" : "layout.hide", { id: "tabs" });
    const ids = new Set(sp.map(p => p.id));
    const kept = Object.fromEntries(Object.entries(shared("space.colors") ?? {}).filter(([id]) => ids.has(id)));
    let changed = Object.keys(kept).length !== Object.keys(shared("space.colors") ?? {}).length;
    for (const p of sp) {
      if (kept[p.id] || p.name === "~") continue;
      const uses = c => Object.values(kept).filter(v => v === c).length;
      kept[p.id] = palette.reduce((best, c) => uses(c) < uses(best) ? c : best);
      changed = true;
    }
    if (changed) setShared("space.colors", kept);
    return v_flex().size_full().min_h(0).bg(t.chrome).text_size(FONT ? 16 : 15).when(Boolean(FONT), (el) => el.font_family(FONT))
      .child(h_flex().h(collapsed ? 36 : 31).when(!collapsed, el => el.pl(16).pr(10)).items_center().justify_between().when(collapsed, el => el.justify_center()).text_size(11.5).text_color(t.dim)
        .when(!collapsed, el => el.child("Spaces"))
        .child(div().id("space-new").flex().items_center().justify_center().rounded(collapsed ? 10 : 8).text_size(22)
          .when(collapsed, el => el.size(28)).when(!collapsed, el => el.px(5))
          .hover(s => s.bg(t.hover).text_color(t.foreground)).on_click(() => run("space.new")).child("+")))
      .child(v_flex().flex_1().min_h(0).px(8).pb(14).overflow_y_scrollbar().mode("always")
        .children(this.grouped(t, collapsed)));
  }
}
