import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, run, window, shared, setShared, layout } from "herdr";
import { svg } from "gpui-kit";

// Copy of workspace-chrome's header (the "brand" block) with Herdr's ram drawn in text instead of the logo image.
// Herdr's ram as a pixel grid, X = filled. Each cell is a square div, so no font gaps.
const RAM = [
  ".....XXXX...",
  "....X....X..",
  "..XXX.XX..X.",
  ".XXXX.X.X.X.",
  "XX.XXX.XX.XX",
  "XXXXXXXXXXXX",
  ".XXXXXXXXXXX",
  "..XXXXXXXXX.",
];
const PX = 3;

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar's rail goes by its width, not a flag: dragging its edge narrows it too.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

function toggleSidebar() {
  const width = find(layout(), "sidebar")?.size?.px;
  if (!narrow()) setShared("sidebar.width", width);
  setShared("sidebar.collapsed", !narrow());
  run("layout.resize", { id: "sidebar", px: narrow() ? (shared("sidebar.width") ?? 268) : window()?.platform === "macos" ? 76 : 44 });
}

export default class Brand extends View {
  button(id, label, action) {
    const t = theme();
    return div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(9).text_color(t.muted).hover(s => s.bg(t.hover).text_color(t.foreground))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_click(action).child(label);
  }
  render() {
    const t = theme();
    const collapsed = narrow();
    const ram = v_flex().flex_none().children(RAM.map((row) => h_flex().children([...row].map((c) => div().size(PX).flex_none().when(c === "X", (el) => el.bg(t.foreground))))));
    return h_flex().size_full().bg(t.chrome).pl(collapsed ? 6 : 14).pr(10).gap(4).items_center().text_size(13.5)
      .when(window()?.platform === "macos" && !collapsed, el => el.pl(76))
      .when(!collapsed, el => el.child(h_flex().flex_1().gap(8).items_center().child(ram)))
      .when(!(collapsed && window()?.platform === "macos"), el => el.child(this.button("sidebar-toggle", svg("mods/workspace-chrome/sidebar.svg").size(15), toggleSidebar)));
  }
}
