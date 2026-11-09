import { View, div, svg } from "gpui-kit";
import { h_flex } from "gpui-base";
import { props, spaces, terminals, focused, theme, run, shared, setShared } from "herdr";

// Header of a cell in grid mode (command `grid` of my-spaces): click goes to that space and leaves the grid.
const STATUS = (t) => ({ blocked: t.ansi1, working: t.ansi3, done: t.ansi2, idle: t.muted });

// Cell sizes in px, per space: the width from the header, the terminal's height from the 1px probe beside it. Not while zoomed.
function record(id, key, v) {
  if (shared("grid.zoom") || v < 40) return;
  const all = shared("grid.sizes") ?? {};
  if (Math.abs((all[id]?.[key] ?? 0) - v) < 2) return;
  setShared("grid.sizes", { ...all, [id]: { ...all[id], [key]: Math.round(v) } });
}

export default class Grid extends View {
  render() {
    const t = theme(), p = props() ?? {};
    if (p.probe) return div().size_full().on_size_change(({ height }) => record(p.probe, "h", height));
    // A space with several panes: the header splits into one segment per pane, over that pane (equal widths, like the panes below).
    const ts = p.terminals ?? [], multi = ts.length > 1;
    const row = h_flex().size_full().items_center().gap(multi ? 4 : 8).px(multi ? 0 : 10).bg(t.chrome).text_size(13).text_color(t.foreground);
    const w = spaces().find((s) => s.id === p.space);
    if (!w) return row;
    // Drag a header onto another to move the cell there (the drag is in shared state: each header is its own view).
    // While dragging: the grabbed header is filled, every other one is outlined and fills when the pointer is over it.
    const drag = shared("grid.drag"), zoomed = shared("grid.zoom") === w.id;
    return row.id(`grid-${w.id}`).cursor_grab().hover((s) => s.bg(t.hover))
      .on_size_change(({ width }) => record(w.id, "w", width))
      .when(drag === w.id, (el) => el.cursor_grabbing().bg(`${t.accent}55`).border_1().border_color(t.accent))
      .when(drag && drag !== w.id, (el) => el.cursor_grabbing().border_1().border_color(`${t.accent}88`).hover((s) => s.bg(`${t.accent}44`)))
      .on_mouse_down("left", (_e, cx) => { cx.stop_propagation(); setShared("grid.drag", w.id); })
      .on_mouse_up("left", () => {
        const from = shared("grid.drag");
        setShared("grid.drag", null);
        if (from && from !== w.id) run(`my-spaces.gridmove:${from}|${w.id}`);
      })
      .children(multi ? ts.map((a, k) => {
        const x = terminals().find((y) => y.address === a);
        return h_flex().flex_1().min_w(0).h_full().items_center().gap(7).px(10).rounded(6)
          .when(focused()?.terminal === a, (el) => el.bg(`${t.accent}22`))
          .child(div().size(8).flex_none().rounded(4).bg(STATUS(t)[x?.status] ?? t.muted))
          .child(div().flex_1().min_w(0).truncate().child(k === 0 ? w.name : (x?.name || x?.program?.key || "shell"))
            .when(k === 0 && w.active, (el) => el.text_color(t.accent)))
          .when(k === 0 && Boolean(w.branch), (el) => el.child(div().text_color(t.muted).truncate().child(w.branch)))
          .when(k === ts.length - 1, (el) => el.child(div().id(`grid-zoom-${w.id}`).size(20).flex_none().flex().items_center().justify_center().rounded(6).cursor_pointer()
        .text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(() => run(`my-spaces.zoom:${w.id}`))
        .child(svg(`mods/my-grid/icons/${zoomed ? "minimize" : "maximize"}.svg`).size(13))));
      }) : [
        div().size(8).flex_none().rounded(4).bg(STATUS(t)[w.status] ?? t.muted),
        div().flex_1().truncate().child(w.name).when(w.active, (el) => el.text_color(t.accent)),
        ...(w.branch ? [div().text_color(t.muted).truncate().child(w.branch)] : []),
        div().id(`grid-zoom-${w.id}`).size(20).flex_none().flex().items_center().justify_center().rounded(6).cursor_pointer()
        .text_color(t.muted).hover((s) => s.bg(t.hover).text_color(t.foreground))
        .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
        .on_click(() => run(`my-spaces.zoom:${w.id}`))
        .child(svg(`mods/my-grid/icons/${zoomed ? "minimize" : "maximize"}.svg`).size(13))])
  }
}
