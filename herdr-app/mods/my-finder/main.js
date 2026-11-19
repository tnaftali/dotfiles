// Fuzzy finder for spaces, like a command palette. Type to filter, Up/Down (or Ctrl-N/P, Ctrl-J/K) to move, Enter to jump, Esc to close.
// Opened by my-spaces ("find": the search button and Ctrl-F).
import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { run, props, closeOverlay, theme, spaces, shared } from "herdr";

const SHOWN = 9;

// Subsequence match of `q` in `s`: -1 when it does not match, else a score (higher is better).
// Runs of letters and letters at the start of a word score more.
function fuzzy(q, s) {
  let score = 0, at = -1, run = 0;
  for (const c of q) {
    const i = s.indexOf(c, at + 1);
    if (i < 0) return -1;
    run = i === at + 1 ? run + 1 : 0;
    score += 1 + run * 3 + (i === 0 || /[\s\-_/.]/.test(s[i - 1]) ? 6 : 0) - Math.min(i - at - 1, 5) * 0.2;
    at = i;
  }
  return score - s.length * 0.01;
}

const tail = (p) => (p ?? "").replace(/\/+$/, "").split("/").pop();

export default class Finder extends View {
  init(_props, cx) {
    this.text = "";
    this.sel = 0;
    this.input = InputState.new({ value: "", placeholder: "Jump to a space" });
    this.input.on("change", (_e, cx) => { this.text = this.input.value(); this.sel = 0; cx.notify(); });
    this.input.on("submit", () => this.go());
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
    cx.bind_keys([
      { keystroke: "up", action: "finder.up", context: "Finder" },
      { keystroke: "down", action: "finder.down", context: "Finder" },
      { keystroke: "ctrl-p", action: "finder.up", context: "Finder" },
      { keystroke: "ctrl-n", action: "finder.down", context: "Finder" },
      { keystroke: "ctrl-k", action: "finder.up", context: "Finder" },
      { keystroke: "ctrl-j", action: "finder.down", context: "Finder" },
    ]);
  }

  // Most recent first, as the sidebar sorts: a space that works now, then by when its agent last worked (my-spaces keeps
  // "space.seen", saved every 30 s at most). Hidden spaces come last.
  recency(s) {
    if ((shared("space.hidden") ?? []).includes(s.id)) return -1;
    return s.status === "working" ? Infinity : shared("space.seen")?.[s.id] ?? 0;
  }

  // Every query word must match; the order is the best score, else most recent first.
  matches() {
    const words = this.text.toLowerCase().split(/\s+/).filter(Boolean);
    const rows = spaces().map((s, i) => {
      const hay = [s.name, tail(s.folder), s.branch ?? "", s.machine ?? "", ...(s.tabs ?? []).map((t) => t.name ?? "")].join(" ").toLowerCase();
      const scores = words.map((w) => fuzzy(w, hay));
      return { s, i, score: scores.some((x) => x < 0) ? -1 : scores.reduce((a, b) => a + b, 0) };
    }).filter((r) => r.score >= 0);
    return rows.sort((a, b) => (words.length && b.score - a.score) || this.recency(b.s) - this.recency(a.s) || a.i - b.i).slice(0, SHOWN).map((r) => r.s);
  }

  move(by, cx) {
    const n = this.matches().length;
    if (n) this.sel = (this.sel + by + n) % n;
    cx.notify();
  }

  go(id) {
    const to = id ?? this.matches()[this.sel]?.id;
    if (!to) return;
    closeOverlay(props().overlay);
    run(`my-spaces.pick:${to}`);
  }

  key(e, cx) {
    if (e.key === "escape") { closeOverlay(props().overlay); cx.stop_propagation(); }
  }

  render() {
    const t = theme();
    const rows = this.matches();
    const sel = Math.min(this.sel, Math.max(rows.length - 1, 0));
    const tone = { blocked: t.blocked, working: t.working, done: t.done, idle: t.idle };
    return v_flex().id("finder").track_focus(this.handle).key_context("Finder")
      .on_action("finder.up", (_e, cx) => this.move(-1, cx))
      .on_action("finder.down", (_e, cx) => this.move(1, cx))
      .on_key_down((e, cx) => this.key(e, cx))
      .w_full().min_h(0).p(10).bg(t.popover).text_color(t.foreground)
      .child(Input.new(this.input).h(38).px(12).rounded(13).border_1().border_color(t.accent).bg(t.background).text_size(14).text_color(t.foreground))
      .child(v_flex().pt(8).gap(2).children(rows.map((s, i) => h_flex().id(`f-${s.id}`).h(40).px(12).gap(10).items_center().rounded(10).cursor_pointer()
        .when(i === sel, (el) => el.bg(t.selected))
        .hover((h) => h.bg(t.hover))
        .on_click(() => this.go(s.id))
        .child(div().size(8).flex_none().rounded(4).bg(tone[s.status] ?? t.border))
        .child(div().flex_none().text_size(13.5).font_medium().child(s.name))
        .child(div().flex_1().min_w(0).truncate().text_size(11.5).text_color(t.dim).child([tail(s.folder) !== s.name ? tail(s.folder) : "", s.branch, s.machine].filter(Boolean).join(" · ")))
        .when(Boolean(s.status), (el) => el.child(div().flex_none().text_size(11).text_color(tone[s.status] ?? t.dim).child(s.status)))
        .when(s.active, (el) => el.child(div().flex_none().text_size(11).text_color(t.dim).child("open"))))))
      .when(!rows.length, (el) => el.child(div().p(16).text_size(12.5).text_color(t.dim).child("No space matches")));
  }
}
