// Kanban board of the spaces: drag a space's card to the column of its state of work.
// Drop on a card to put it before that card, on a column's empty part to put it last.
// Click a card to switch to its space. The board is the "board" block of the layout,
// hidden by default: the rail's Board button or layout.toggle:board shows it.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { spaces, theme, run, shared, setShared } from "herdr";

// shortcut: fixed columns, edit here to rename or add one. Spaces not on the board yet go to the first.
const COLUMNS = [
  { id: "todo", name: "To do", color: "dim" },
  { id: "doing", name: "In progress", color: "ansi4" },
  { id: "hold", name: "On hold", color: "ansi1" },
  { id: "review", name: "In review", color: "ansi3" },
  { id: "done", name: "Done", color: "ansi2" },
];

// Each column's space ids in order, from shared("board"): closed spaces dropped, new ones last in the first column.
export function columns(saved, ids) {
  const live = new Set(ids), seen = new Set();
  const out = Object.fromEntries(COLUMNS.map((c) => [c.id, (saved?.[c.id] ?? []).filter((id) => live.has(id) && !seen.has(id) && seen.add(id))]));
  out[COLUMNS[0].id].push(...ids.filter((id) => !seen.has(id)));
  return out;
}

// Move a space to a column, before another space or last.
export function move(lists, id, col, before) {
  const out = Object.fromEntries(Object.entries(lists).map(([k, v]) => [k, v.filter((x) => x !== id)]));
  const i = before ? out[col].indexOf(before) : -1;
  out[col].splice(i < 0 ? out[col].length : i, 0, id);
  return out;
}

export default class Board extends View {
  init() {
    this.pressed = null; // the space being dragged
    this.over = null; // where it would land: { col, before } (before: a space id or null for last)
  }

  render() {
    const t = theme();
    const all = spaces(), byId = Object.fromEntries(all.map((s) => [s.id, s]));
    const lists = columns(shared("board"), all.map((s) => s.id));
    const dragging = this.pressed !== null && this.over?.before !== this.pressed;
    const land = (cx, col, before) => {
      if (this.pressed === null || (this.over?.col === col && this.over?.before === before)) return;
      this.over = { col, before };
      cx.notify();
    };

    const card = (s, col) => v_flex().id(`board-${s.id}`).relative().flex_none().px(10).py(8).gap(3).rounded(12).cursor_pointer()
      .bg(s.active ? t.selected : t.surface).border_1().border_color(t.border).hover((st) => st.bg(t.hover))
      .when(dragging && this.pressed === s.id, (el) => el.opacity(0.4))
      .when(dragging && this.over?.before === s.id, (el) => el.child(div().absolute().left(4).right(4).top(-6).h(2).rounded(1).bg(t.accent)))
      .on_mouse_down("left", () => { this.pressed = s.id; this.over = { col, before: s.id }; })
      .on_hover((h, cx) => {
        if (h) land(cx, col, s.id);
        else if (this.pressed !== null && this.over?.before === s.id) land(cx, col, lists[col][lists[col].indexOf(s.id) + 1] ?? null);
      })
      .child(h_flex().gap(6).items_center().min_w(0)
        .child(div().size(7).flex_none().rounded(4).bg(t[s.status] ?? t.dim))
        .child(div().flex_1().min_w(0).truncate().text_size(12.5).child(s.name)))
      .when(Boolean(s.branch), (el) => el.child(div().pl(13).text_size(11).text_color(t.dim).truncate().child(s.branch)));

    const column = (c) => v_flex().id(`board-col-${c.id}`).flex_1().min_w(0).h_full().p(6).gap(6).rounded(12)
      .bg(dragging && this.over?.col === c.id && this.over.before === null ? t.hover : t.chrome)
      .on_hover((h, cx) => { if (h && this.over?.col !== c.id) land(cx, c.id, null); })
      .child(h_flex().h(24).flex_none().px(4).gap(6).items_center().text_size(11.5)
        .child(div().size(8).rounded(4).bg(t[c.color])).child(div().font_semibold().child(c.name))
        .child(div().text_color(t.dim).child(`${lists[c.id].length}`)))
      .child(v_flex().id(`board-list-${c.id}`).flex_1().min_h(0).gap(6).overflow_y_scrollbar()
        .children(lists[c.id].map((id) => card(byId[id], c.id))));

    return h_flex().id("board").size_full().p(8).gap(8).bg(t.background).border_b(1).border_color(t.border).text_color(t.foreground)
      .on_mouse_up("left", (_e, cx) => {
        const p = this.pressed, o = this.over;
        this.pressed = this.over = null;
        if (p !== null && o) {
          if (o.before === p) run("space.select", { id: p }); // let go where it was pressed: a click
          else setShared("board", move(lists, p, o.col, o.before));
        }
        cx.notify();
      })
      .children(COLUMNS.map(column));
  }
}
