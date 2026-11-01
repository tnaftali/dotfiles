// Pull requests of the spaces: for each space, the pull request of the branch its first
// terminal is on (else of a branch named like the space), with its state, checks and review. Lives in the right panel, next to
// Files and Changes. Click a card to open the pull request in the browser.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, panes, exec, theme } from "herdr";

// A pull request changes rarely: asked again after this long (gh is a network call).
const TTL = 180000;
const FIELDS = "number,title,state,isDraft,url,reviewDecision,statusCheckRollup,headRefName";

// Where a space is now: its first terminal's live folder, else where it was made (as in my-spaces).
function place(s, ps) {
  const tabs = new Set((s.tabs ?? []).map((c) => c.id));
  return ps.find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder;
}

// All the checks in one word: the worst one wins. No checks: null.
export function checks(list) {
  if (!list?.length) return null;
  if (list.some((c) => /FAILURE|ERROR|TIMED_OUT|CANCELLED|ACTION_REQUIRED/.test(c.conclusion || c.state || ""))) return "fail";
  if (list.some((c) => (c.status && c.status !== "COMPLETED") || /PENDING|EXPECTED/.test(c.state ?? ""))) return "pending";
  return "pass";
}

export default class Prs extends View {
  init(_props, cx) {
    this.prs = {}; // [machine, folder, space name] -> { at, v: the pull request | null }
    // Wake up now and then; render asks again for what is stale. A hidden panel does not render, so it does not ask.
    cx.spawn(async (cx) => { for (;;) { await cx.sleep(TTL); cx.notify(); } });
  }

  fetch(key, cx) {
    const [on, cwd, name] = JSON.parse(key);
    this.prs[key] = { at: Date.now(), v: this.prs[key]?.v };
    if (!cwd) return;
    cx.spawn(async (cx) => {
      try {
        // No pull request for the branch (or no gh, login or remote): gh exits nonzero.
        // Then a branch named like the space: its terminals can sit on master while the PR's branch is not checked out.
        let r = await exec("gh", ["pr", "view", "--json", FIELDS], { cwd, on });
        if (r.code !== 0) r = await exec("gh", ["pr", "view", name, "--json", FIELDS], { cwd, on });
        this.prs[key].v = r.code === 0 ? JSON.parse(r.stdout) : null;
      } catch {}
      this.prs[key].done = true;
      cx.notify();
    });
  }

  render(cx) {
    const t = theme(), now = Date.now(), ps = panes();
    const rows = spaces().map((s) => ({ s, key: JSON.stringify([s.machine ?? null, place(s, ps), s.name]) }));
    for (const { key } of rows) if (now - (this.prs[key]?.at ?? 0) > TTL) this.fetch(key, cx);
    const found = rows.filter((r) => this.prs[r.key]?.v);
    const waiting = rows.some((r) => !this.prs[r.key]?.done);
    const STATE = { OPEN: ["Open", t.ansi2], DRAFT: ["Draft", t.dim], MERGED: ["Merged", t.ansi5], CLOSED: ["Closed", t.ansi1] };
    const CHECK = { pass: ["✓ checks", t.ansi2], fail: ["✕ checks", t.ansi1], pending: ["● checks", t.ansi3] };
    const REVIEW = { APPROVED: ["✓ approved", t.ansi2], CHANGES_REQUESTED: ["! changes", t.ansi1], REVIEW_REQUIRED: ["○ review", t.muted] };
    const label = ([text, color]) => div().flex_none().text_color(color).child(text);

    const card = ({ s, key }) => {
      const pr = this.prs[key].v;
      const [state, color] = STATE[pr.isDraft && pr.state === "OPEN" ? "DRAFT" : pr.state] ?? [pr.state, t.muted];
      const c = checks(pr.statusCheckRollup), review = REVIEW[pr.reviewDecision];
      return v_flex().id(`pr-${s.id}`).flex_none().p(10).gap(5).rounded(12).border_1().border_color(t.border).bg(t.surface).cursor_pointer()
        .hover((st) => st.bg(t.hover)).on_click((_e, cx) => cx.open_url(pr.url))
        .child(h_flex().gap(6).items_center().text_size(11).text_color(t.dim)
          .child(div().flex_1().min_w(0).truncate().child(s.name))
          .child(div().flex_none().px(5).py(1).rounded(6).border_1().border_color(color).text_color(color).child(state)))
        .child(h_flex().gap(6).min_w(0).child(div().flex_none().text_color(t.dim).child(`#${pr.number}`)).child(div().flex_1().min_w(0).truncate().child(pr.title)))
        .child(h_flex().gap(10).items_center().text_size(11)
          .when(Boolean(c), (el) => el.child(label(CHECK[c])))
          .when(Boolean(review), (el) => el.child(label(review)))
          .child(div().flex_1().min_w(0).text_color(t.dim).truncate().child(pr.headRefName)));
    };

    const refresh = div().id("prs-refresh").px(6).py(2).rounded(8).cursor_pointer().text_color(t.muted).hover((st) => st.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => { for (const k in this.prs) this.prs[k].at = 0; cx.notify(); }).child("↻");
    return v_flex().id("prs").size_full().min_h(0).rounded(14).overflow_hidden().bg(t.background).border_1().border_color(t.border).text_color(t.foreground).text_size(13)
      .child(h_flex().h(42).flex_none().px(14).gap(8).items_center().border_b(1).border_color(t.border)
        .child(div().font_semibold().child("Pull requests"))
        .child(div().px(5).py(1).rounded(6).border_1().border_color(t.border).text_size(10).text_color(t.muted).child(`${found.length}`))
        .child(div().flex_1()).child(refresh))
      .child(v_flex().id("prs-list").flex_1().min_h(0).overflow_y_scrollbar().p(8).gap(8).children(found.map(card))
        .when(!found.length, (el) => el.child(div().p(6).text_color(t.dim).child(waiting ? "Looking for pull requests…" : "No space has a pull request"))));
  }
}
