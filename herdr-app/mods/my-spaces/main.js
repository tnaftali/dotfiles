// Workspace spaces: stable colored avatars, worktrees under their checkout,
// grouped by machine when more than one is known. After a space's name, the repo
// its first terminal is in now, its branch, ahead/behind. Agent state shows as a dot on the right, detail in the agents list. Click to
// switch, right-click for its menu, drag to reorder.

import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { nextCommand, spaces, machines, panes, run, openOverlay, exec, hc, theme, shared, setShared, watchFolder, window, layout, focused, terminals } from "herdr";

// Where a space is now: its first terminal's live folder, else where it was made.
// `ps`: panes(), read once by the caller (each read copies every pane).
function place(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}
const findNode = (node, id) => node?.id === id ? node : (node?.children ?? []).map((c) => findNode(c, id)).find(Boolean) ?? null;
const rowHeight = ({ tree }, tail) => (tail ? 54 : tree ? 32 : 42);
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
    this.pressed = null;
    this.tip = null; // { row, text }: the status icon under the pointer
    this.over = null; // the row index, or "g:<name>" for a group header, under a drag
    this.dragGroup = null; // the group whose header is being dragged
    this.gd = null; // where that group would land: { name, block, after }
    this.machines = [];
    this.folded = new Set(JSON.parse(localStorage.getItem("machines.folded") ?? "[]"));
    this.groupFolded = new Set(JSON.parse(localStorage.getItem("groups.folded") ?? "[]"));
    this.refreshMachines(cx);
    // Commands from the CLI, the prompts and the menu (the name carries the data):
    //   group:<space>=<name>       the space's group; empty removes it
    //   group-ask:<space>          the prompt for that
    //   group-rename:<old>=<new>|<color>   a whole group's name and color; empty name ungroups it
    //   group-rename-ask:<old>     the prompt for that
    cx.spawn(async (cx) => {
      for (;;) {
        const c = await nextCommand();
        let m;
        if ((m = /^group:([^=]+)=(.*)$/s.exec(c))) {
          this.setGroup(m[1], m[2]);
        } else if ((m = /^group-ask:(.+)$/s.exec(c))) {
          const cur = (shared("space.groups") ?? {})[m[1]] ?? "";
          openOverlay({ mod: "my-prompt", kind: "dialog", width: 340, height: 190, props: { title: "Group", label: "Group name (empty removes)", value: cur, cmd: `my-spaces.group:${m[1]}=` } });
        } else if ((m = /^group-rename:([^=]*)=(.*)$/s.exec(c))) {
          const cut = m[2].lastIndexOf("|");
          const name = (cut < 0 ? m[2] : m[2].slice(0, cut)).replace(/=/g, "-");
          const color = cut < 0 ? "" : m[2].slice(cut + 1);
          const all = Object.fromEntries(Object.entries(shared("space.groups") ?? {}).flatMap(([id, g]) => (g !== m[1] ? [[id, g]] : name ? [[id, name]] : [])));
          setShared("space.groups", all);
          const colors = { ...(shared("group.colors") ?? {}) };
          delete colors[m[1]];
          if (name) colors[name] = color || colors[name] || "none";
          setShared("group.colors", colors);
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
        } else if ((m = /^group-rename-ask:(.+)$/s.exec(c))) {
          const sw = [["none", null], ...Object.entries(MARK)];
          openOverlay({ mod: "my-prompt", kind: "dialog", width: 340, height: 250, props: { title: "Group", label: "Group name (empty ungroups)", value: m[1], color: (shared("group.colors") ?? {})[m[1]] ?? "none", swatches: sw, cmd: `my-spaces.group-rename:${m[1]}=` } });
        }
        cx.notify();
      }
    });
    cx.timer.every(15000, cx => this.refreshMachines(cx));
    // `git status` walks the whole tree, on another machine a process there:
    // only when its answer could have changed (see `due`).
    cx.timer.every(250, (cx) => this.checkNew(cx));
  }

  // Floating tool in the focused folder (button in workspace-status). One per folder and tool:
  // a press opens it, the next press closes the overlay, and the tool keeps running.
  toggleFloat(cx, tool) {
    const f = focused(), cwd = f?.cwd;
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
      const repo = cwd ? await exec("git", ["rev-parse", "--is-inside-work-tree"], { cwd }).catch(() => null) : null;
      if (repo?.code !== 0) { this.floatBusy = false; return; }
      const r = await hc(["run", "--bg", "--json", "--no-parent", "--outlive-parent", "--rm", "--name", `${tool}-${Date.now().toString(36)}`, ...(cwd ? ["--cwd", cwd] : []), ...argv]);
      this.floatBusy = false;
      if (r.code !== 0) return;
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
        const found = {};
        if (live.length) {
          const script = 'for a in "$@"; do pid=$(hc get "$a" | jq -r .foreground.pid); f="$HOME/.claude/sessions/$pid.json"; [ -f "$f" ] && echo "$a $(jq -c "{id: .sessionId, cwd: .cwd}" "$f")"; done';
          const r = await exec("sh", ["-c", script, "sh", ...live.map((t) => t.address)]);
          for (const line of r.stdout.split("\n")) {
            const m = line.match(/^(\S+) (\{.*\})$/);
            if (m) found[m[1]] = JSON.parse(m[2]);
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

  checkNew(cx) {
    // Started here, not in init(): a hot reload keeps the instance and does not run init() again.
    if (!this.claudeStarted) {
      // After a reboot the core's terminals come back as plain shells: resume the Claude sessions that were in them.
      this.claudeStarted = true;
      // The right rail has Files and Changes: the tab bar's own buttons would repeat them.
      if (JSON.stringify(shared("workspace.panels")) !== "[]") setShared("workspace.panels", []);
      this.resumed = false;
      cx.timer.every(5000, (cx) => this.trackClaude(cx));
      cx.timer.after(10000, (cx) => this.resumeClaude(cx));
    }
    const now = Date.now();
    const sp = spaces();
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
    openOverlay({ mod: "my-menu", kind: "popup", width: 200, height: 260, props: { tab: "space", target: { id: w.id } } });
  }

  setGroup(id, name) {
    const all = { ...(shared("space.groups") ?? {}) };
    const n = (name ?? "").trim().replace(/=/g, "-");
    if (n) all[id] = n; else delete all[id];
    setShared("space.groups", all);
  }

  // Where the dragged group would land: next to the row, or the whole group, under the pointer.
  groupDrop() {
    const list = spaces(), groups = shared("space.groups") ?? {};
    const from = list.findIndex((w) => groups[w.id] === this.dragGroup);
    const name = typeof this.over === "string" ? this.over.slice(2) : list[this.over] ? groups[list[this.over].id] ?? null : undefined;
    if (from < 0 || name === undefined || name === this.dragGroup) return null;
    const block = name ? list.filter((w) => groups[w.id] === name) : [list[this.over]];
    return block.length ? { name, block, after: from < list.indexOf(block[0]) } : null;
  }

  // Drops the group: its spaces end up together, before or after what is under the pointer.
  moveGroup() {
    const gd = this.groupDrop();
    if (!gd) return;
    const groups = shared("space.groups") ?? {};
    const list = spaces().map((w) => w.id);
    const mine = list.filter((id) => groups[id] === this.dragGroup);
    const rest = list.filter((id) => !mine.includes(id));
    const edge = gd.block.map((w) => w.id)[gd.after ? gd.block.length - 1 : 0];
    const at = rest.indexOf(edge) + (gd.after ? 1 : 0);
    const next = [...rest.slice(0, at), ...mine, ...rest.slice(at)];
    const cur = [...list];
    next.forEach((id, k) => {
      if (cur[k] === id) return;
      run("space.move", { id, index: k + 1 });
      cur.splice(cur.indexOf(id), 1);
      cur.splice(k, 0, id);
    });
  }

  // A group sits where its first space is; its other spaces are drawn right under it.
  withGroups(rows, t, collapsed, draw) {
    const groups = shared("space.groups") ?? {};
    if (collapsed) return rows.map((r) => draw(r));
    const out = [], seen = new Set();
    for (const r of rows) {
      const g = groups[r.w.id];
      if (!g) { out.push(draw(r)); continue; }
      if (seen.has(g)) continue;
      seen.add(g);
      const members = rows.filter((m) => groups[m.w.id] === g);
      const folded = this.groupFolded.has(g);
      out.push(this.groupHead(g, members, folded, t));
      if (!folded) out.push(...members.map((m) => draw(m, true)));
    }
    return out;
  }

  // The group's color as a hex, null for none.
  groupColor(g) {
    return MARK[(shared("group.colors") ?? {})[g]] ?? null;
  }

  groupHead(g, members, folded, t) {
    const gc = this.groupColor(g);
    const first = members[0];
    const alert = members.find((m) => m.w.status === "blocked") ?? members.find((m) => m.w.status === "done");
    const target = this.pressed !== null && this.over === `g:${g}`;
    const gd = this.gd;
    const side = gd && gd.name === g ? (gd.after ? (folded ? "bottom" : null) : "top") : null;
    const bar = (el, s) => el.child(div().absolute().left(6).right(6).h(2).rounded(1).bg(t.accent).when(s === "top", (b) => b.top(-1)).when(s === "bottom", (b) => b.bottom(-1)));
    return h_flex().id(`group-${g}`).relative().h(26).flex_none().px(8).mt(4).gap(6).items_center().rounded(7).text_size(12).text_color(gc ?? t.dim)
      .when(Boolean(gc), (el) => el.bg(`${gc}1f`))
      .cursor_pointer().hover((s) => s.bg(gc ? `${gc}33` : t.hover))
      .when(target, (el) => el.bg(t.hover).border_1().border_color(t.accent))
      .when(this.dragGroup === g && this.gd !== null, (el) => el.opacity(0.4))
      .when(Boolean(side), (el) => bar(el, side))
      .on_hover((h, cx) => { if (h && (this.pressed !== null || this.dragGroup !== null) && this.over !== `g:${g}`) { this.over = `g:${g}`; cx.notify(); } })
      .on_mouse_down("left", () => { this.dragGroup = g; this.over = `g:${g}`; })
      .on_mouse_up("left", (_e, cx) => {
        const from = this.pressed, dragged = this.dragGroup;
        this.pressed = null;
        this.dragGroup = null;
        if (dragged !== null && dragged !== g) {
          this.dragGroup = dragged;
          this.over = `g:${g}`;
          this.moveGroup();
          this.dragGroup = null;
        } else if (from !== null) {
          // Dropped on the header: joins the group, at its top.
          const id = spaces()[from]?.id;
          if (id && id !== first.w.id) { this.setGroup(id, g); run("space.move", { id, index: first.i + 1 }); }
        } else {
          folded ? this.groupFolded.delete(g) : this.groupFolded.add(g);
          localStorage.setItem("groups.folded", JSON.stringify([...this.groupFolded]));
        }
        cx.notify();
      })
      .on_mouse_down("right", () => run(`my-spaces.group-rename-ask:${g}`))
      .child(svg(`mods/workspace-chrome/chevron-${folded ? "right" : "down"}.svg`).size(11).flex_none())
      .child(div().flex_1().min_w(0).truncate().child(g))
      .when(folded && Boolean(alert), (el) => el.child(div().flex_none().text_color(tone(t, alert.w.status)).child("\u25cf")))
      .child(div().flex_none().text_size(11).child(String(members.length)));
  }

  // Spaces in order; worktrees are not nested under their repo.
  ordered() {
    const sp = spaces(), ps = panes();
    const ready = (w) => this.shown.has(w.id) || where(w, ps) in this.git || Date.now() - (this.born[w.id] ??= Date.now()) > 1500;
    for (const w of sp) if (!this.shown.has(w.id) && ready(w)) this.shown.add(w.id);
    const list = sp.map((w, i) => ({ w, i, g: this.git[where(w, ps)] ?? null })).filter((r) => this.shown.has(r.w.id));
    const out = list.map((r) => ({ ...r, tree: null }));
    return out;
  }

  // The rows, under a header per machine once one isn't this computer.
  grouped(t, collapsed) {
    const rows = this.ordered();
    this.gd = this.dragGroup !== null ? this.groupDrop() : null;
    const draw = (r, indented) => (collapsed ? this.compact(r, t) : this.row(r, t, indented));
    const remote = [...new Set([...rows.map(r => r.w.machine).filter(Boolean), ...this.machines.map(m => m.name)])].sort();
    const loading = m => {
      const layout = machines().find(k => k.name === m)?.layout;
      return layout === "loading" || (!layout && this.machines.some(k => k.name === m && k.state === "connected"))
        || spaces().some(s => (s.machine ?? null) === m && !this.shown.has(s.id));
    };
    const loadingRow = m => div().id(`machine-loading-${m ?? "local"}`).h(28).flex_none().px(8).text_size(12).text_color(t.dim).child(collapsed ? "…" : "Loading…");
    if (!remote.length) return loading(null) && !rows.length ? [loadingRow(null)] : this.withGroups(rows, t, collapsed, draw);
    const machineNames = [null, ...remote];
    return machineNames.flatMap((m) => {
      const mine = rows.filter((r) => (r.w.machine ?? null) === m);
      const machine = this.machines.find(k => k.name === m);
      const connected = !m || machine?.state === "connected";
      const folded = this.folded.has(m);
      const head = h_flex().id(`machine-${m ?? "local"}`).h(26).flex_none().px(collapsed ? 2 : 8).gap(7).items_center().text_size(11).text_color(t.dim)
        .cursor_pointer().hover(s => s.bg(t.hover))
        .on_click((_e, cx) => {
          folded ? this.folded.delete(m) : this.folded.add(m);
          localStorage.setItem("machines.folded", JSON.stringify([...this.folded]));
          cx.notify();
        })
        .child(svg(`mods/workspace-chrome/${m ? "server" : "monitor"}.svg`).size(13).flex_none())
        .when(!collapsed, el => el.child(div().flex_1().truncate().child(m ?? "This computer"))
          .when(!connected, el => el.child(div().flex_none().child((machine?.state ?? "asleep").replace(/_/g, " "))))
          .when(connected, el => el.child(div().id(`machine-add-${m ?? "local"}`).flex_none().px(4).rounded(4).hover(s => s.bg(t.hover).text_color(t.foreground))
            .on_click((_e, cx) => { cx.stop_propagation(); run("space.new", m ? { machine: m } : {}); }).child("+")))
          .child(div().size(6).rounded(3).flex_none().bg(connected ? t.ansi2 : t.dim))
          .child(svg(`mods/workspace-chrome/chevron-${folded ? "right" : "down"}.svg`).size(11).flex_none()));
      const empty = h_flex().id(`machine-new-${m ?? "local"}`).h(28).flex_none().px(8).gap(7).items_center().rounded(7)
        .text_size(12).text_color(t.dim).hover(s => s.bg(t.hover).text_color(t.foreground))
        .on_click(() => run("space.new", m ? { machine: m } : {}))
        .child(svg("mods/workspace-chrome/plus.svg").size(12)).when(!collapsed, el => el.child("New space there"));
      return [head, ...(folded ? [] : mine.length ? this.withGroups(mine, t, collapsed, draw) : [loading(m) ? loadingRow(m) : empty])];
    });
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

  row({ w, i, g, tree }, t, indented) {
    const on = w.active;
    const tail = g ? this.gitTail(g, tree, w.name, t, w.id) : null;
    const dragging = this.pressed !== null && this.over !== this.pressed;
    const gname = (shared("space.groups") ?? {})[w.id];
    const gd = this.gd;
    const gc = indented && gname ? this.groupColor(gname) : null;
    // A dragged group lands next to this row, or after the group this row ends.
    const side = !gd ? null : !gname && gd.block[0].id === w.id ? (gd.after ? "bottom" : "top")
      : gname && gname === gd.name && gd.after && gd.block[gd.block.length - 1].id === w.id ? "bottom" : null;
    return v_flex()
      .relative()
      .id(`space-${w.id}`)
      .px(8)
      .h(rowHeight({ tree }, tail))
      .flex_none()
      .justify_center()
      .rounded(8)
      .when(Boolean(indented), (el) => el.ml(14))
      .when(on, (el) => el.bg(t.selected).border_1().border_color(t.accent))
      .when(!on && Boolean(gc), (el) => el.bg(`${gc}12`))
      .when(Boolean(gc), (el) => el.child(div().absolute().left(0).top(9).bottom(9).w(2).rounded(1).bg(`${gc}aa`)))
      .when(!on, (el) => el.hover((s) => s.bg(t.hover)))
      // While dragging: the row being moved fades, and a line shows where it will land.
      .when((dragging && this.pressed === i) || (gd !== null && gname === this.dragGroup), (el) => el.opacity(0.4))
      .when(Boolean(side), (el) => el.child(div().absolute().left(6).right(6).h(2).rounded(1).bg(t.accent).when(side === "top", (b) => b.top(-1)).when(side === "bottom", (b) => b.bottom(-1))))
      .when(dragging && this.over === i && this.pressed !== i, (el) => el.bg(t.hover).child(div().absolute().left(6).right(6).h(2).rounded(1).bg(t.accent).when(this.pressed < i, (b) => b.bottom(-1)).when(this.pressed > i, (b) => b.top(-1))))
      .on_hover((h, cx) => { if (h && (this.pressed !== null || this.dragGroup !== null) && this.over !== i) { this.over = i; cx.notify(); } })
      .on_mouse_down("left", () => {
        this.pressed = i;
        this.over = i;
      })
      .on_mouse_up("middle", () => run("space.close", { id: w.id }))
      .on_mouse_up("left", (e, cx) => {
        if (this.dragGroup !== null) {
          this.over = i;
          this.moveGroup();
          this.dragGroup = null;
          cx.notify();
          return;
        }
        const from = this.pressed;
        this.pressed = null;
        if (e.click_count >= 2) { run("space.rename", { id: w.id }); cx.notify(); return; }
        if (from !== null && from !== i) {
          // Dropped on a row: takes its place, and its group (none: leaves its own).
          const id = spaces()[from].id;
          this.setGroup(id, (shared("space.groups") ?? {})[w.id]);
          run("space.move", { id, index: i + 1 });
        }
        else run("space.select", { id: w.id });
        cx.notify();
      })
      .on_mouse_down("right", () => this.menu(w))
      .when(this.tip?.row === w.id, (el) => el.child(div().absolute().right(6).bottom(3).px(6).py(1).rounded(5).bg(t.chrome).border_1().border_color(t.border).text_size(11).text_color(t.foreground).child(this.tip.text)))
      .child(
        h_flex()
          .gap(9)
          .items_center()
          .when(Boolean(tree), el => el.pl(22).child(svg("mods/workspace-chrome/branch.svg").size(13).text_color(t.dim)))
          .child(v_flex().flex_1().min_w(0).gap(1)
            .child(h_flex().min_w(0).gap(6).items_center()
              .child(div().flex_1().min_w(0).truncate().text_color(t.foreground).child(w.name))
              .children(g ? this.marks(g, t, w.id) : [])
              .when(w.status === "working", el => el.child(div().id(`agent-${w.id}`).flex_none().hover((x) => x.opacity(0.7)).on_hover((h, cx) => this.tipHover(h, cx, w.id, "Agent working"))
                .child(svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900))))
              .when(w.status === "blocked" || w.status === "done", el => el.child(div().id(`agent-${w.id}`).size(8).flex_none().rounded(4).hover((x) => x.opacity(0.7)).bg(tone(t, w.status))
                .on_hover((h, cx) => this.tipHover(h, cx, w.id, w.status === "blocked" ? "Agent needs you" : "Agent done")))))
            .when(Boolean(tail), el => el.child(tail))),
      );
  }

  compact({ w, i }, t) {
    return h_flex()
      .id(`space-${w.id}`)
      .h(26)
      .flex_none()
      .justify_center()
      .gap(4)
      .when(w.active, (el) => el.bg(t.raised))
      .hover((s) => s.bg(t.hover))
      .on_click(() => run("space.select", { id: w.id }))
      .child(div().text_color(w.active ? t.foreground : t.muted).child(String(i + 1)))
      .child(div().text_color(tone(t, w.status)).child(glyph(w.status)));
  }

  render() {
    const t = theme();
    const collapsed = shared("sidebar.collapsed") === true;
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
    const groups = shared("space.groups") ?? {};
    const live = new Set(Object.values(groups)), gcol = shared("group.colors") ?? {};
    // Colors only for groups that exist; one that has none (made before colors) gets the least used.
    const kept2 = Object.fromEntries(Object.entries(gcol).filter(([g]) => live.has(g)));
    for (const g of live) {
      if (kept2[g]) continue;
      const keys = Object.keys(MARK), uses = (k) => Object.values(kept2).filter((v) => v === k).length;
      kept2[g] = keys.reduce((best, k) => (uses(k) < uses(best) ? k : best));
    }
    if (JSON.stringify(kept2) !== JSON.stringify(gcol)) setShared("group.colors", kept2);
    // Groups of spaces that are gone stay: pruning them here once wiped every group when spaces() was short at startup.
    return v_flex().size_full().min_h(0).bg(t.chrome).text_size(FONT ? 16 : 15).when(Boolean(FONT), (el) => el.font_family(FONT))
      .child(h_flex().h(31).pl(16).pr(10).items_center().justify_between().text_size(11.5).text_color(t.dim)
        .when(!collapsed, el => el.child("Spaces"))
        .child(div().id("space-new").px(5).text_size(22).rounded(5).hover(s => s.bg(t.hover).text_color(t.foreground)).on_click(() => run("space.new")).child("+")))
      .child(v_flex().flex_1().min_h(0).px(8).pb(14).overflow_y_scrollbar().mode("always")
        .on_mouse_up("left", (_e, cx) => { this.pressed = null; this.dragGroup = null; cx.notify(); })
        .children(this.grouped(t, collapsed)));
  }
}
