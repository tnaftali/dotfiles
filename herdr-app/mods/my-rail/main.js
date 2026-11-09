import { View, div, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { theme, run, layout, shared, setShared } from "herdr";

const findNode = (node, id) => node?.id === id ? node : (node?.children ?? []).map((c) => findNode(c, id)).find(Boolean) ?? null;

// Right rail: launchers for the tools. Each sends a command to my-spaces, which owns the logic.
// Like the left sidebar it collapses to icons only; the toggle stays in view.
const WIDE = 64, NARROW = 44;
const TOOLS = [
  { id: "nvim", text: "Neovim", icon: "nvim", cmd: "my-spaces.nvim" },
  { id: "revdiff", text: "Review", icon: "review", cmd: "my-spaces.revdiff" },
  { id: "lazygit", text: "Lazygit", icon: "git", cmd: "my-spaces.lazygit" },
  { id: "files", text: "Files", icon: "folder-tree", cmd: "my-spaces.panel:files", panel: true },
  { id: "changes", text: "Changes", icon: "diff", cmd: "my-spaces.panel:changes", panel: true },
  { id: "prs", text: "PRs", icon: "pr", cmd: "my-spaces.panel:prs", panel: true },
];

export default class Rail extends View {
  constructor(...a) {
    super(...a);
    this.pressed = null; // the tool being dragged
    this.over = null; // the tool under the drag
  }

  // Saved order first; tools missing from it (new ones) go last.
  ordered() {
    const saved = shared("rail.order") ?? [];
    return [...saved.map((id) => TOOLS.find((b) => b.id === id)).filter(Boolean), ...TOOLS.filter((b) => !saved.includes(b.id))];
  }

  move(from, to) {
    const ids = this.ordered().map((b) => b.id);
    ids.splice(ids.indexOf(to), 0, ...ids.splice(ids.indexOf(from), 1));
    setShared("rail.order", ids);
  }

  render() {
    const t = theme();
    const collapsed = shared("rail.collapsed") !== false;
    // The layout file starts at the narrow width; a wide rail is set again after a restart.
    const want = collapsed ? NARROW : WIDE;
    if (findNode(layout(), "rail")?.size?.px !== want) run("layout.resize", { id: "rail", px: want });
    const panel = findNode(layout(), "panel"), body = findNode(layout(), "panel-body");
    const toggle = () => {
      setShared("rail.collapsed", !collapsed);
      run("layout.resize", { id: "rail", px: collapsed ? WIDE : NARROW });
    };
    const list = this.ordered();
    const dragging = this.pressed !== null && this.over !== this.pressed;
    const button = (b) => {
      const block = b.block && findNode(layout(), b.block);
      const on = block ? !block.hidden : b.panel && panel && !panel.hidden && body?.active === b.id;
      const i = list.indexOf(b), from = list.findIndex((x) => x.id === this.pressed);
      return v_flex().id(`rail-${b.id}`).relative().w(collapsed ? 28 : 52).when(collapsed, (el) => el.h(28).justify_center()).when(!collapsed, (el) => el.py(6)).gap(3).flex_none().items_center().rounded(collapsed ? 10 : 12).cursor_pointer()
        .bg(on ? t.raised : t.chrome).text_color(on ? t.foreground : t.muted).hover(s => s.bg(on ? t.raised : t.hover))
        .when(dragging && this.pressed === b.id, (el) => el.opacity(0.4))
        .when(dragging && this.over === b.id, (el) => el.bg(t.hover).child(div().absolute().left(4).right(4).h(2).rounded(1).bg(t.accent).when(from < i, (l) => l.bottom(-1)).when(from > i, (l) => l.top(-1))))
        .on_hover((h, cx) => { if (h && this.pressed !== null && this.over !== b.id) { this.over = b.id; cx.notify(); } })
        .on_mouse_down("left", () => { this.pressed = b.id; this.over = b.id; })
        .on_mouse_up("left", (_e, cx) => {
          const f = this.pressed;
          this.pressed = this.over = null;
          if (f !== null && f !== b.id) this.move(f, b.id);
          else run(b.cmd, b.args);
          cx.notify();
        })
        .child(svg(`mods/my-rail/${b.icon}.svg`).size(collapsed ? 16 : 20))
        .when(!collapsed, (el) => el.child(div().text_size(9.5).child(b.text)));
    };
    const toggleButton = div().id("rail-toggle").size(26).flex_none().flex().items_center().justify_center().rounded(9).text_color(t.muted)
      .hover(s => s.bg(t.hover).text_color(t.foreground)).on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_click(toggle)
      .child(svg("mods/my-rail/sidebar-right.svg").size(15));
    return v_flex().size_full().bg(t.chrome)
      .on_mouse_up("left", (_e, cx) => { this.pressed = this.over = null; cx.notify(); })
      .child(h_flex().h(collapsed ? 44 : 46).flex_none().items_start().justify_center().pt(10).child(toggleButton))
      .child(v_flex().items_center().gap(4).children(list.map(button)));
  }
}
