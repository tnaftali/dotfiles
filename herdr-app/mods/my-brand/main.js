import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, run, window, shared, layout } from "herdr";
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

export default class Brand extends View {
  button(id, label, action, on = false) {
    const t = theme();
    return div().id(id).size(26).flex_none().flex().items_center().justify_center().rounded(9).text_color(t.muted).hover(s => s.bg(t.hover).text_color(t.foreground))
      .when(on, el => el.bg(`${t.accent}33`).text_color(t.accent))
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation()).on_click(action).child(label);
  }
  render() {
    const t = theme();
    const collapsed = narrow();
    // The header is taller when its buttons stack; set it again after a restart or layout reload.
    const want = !collapsed ? 46 : window()?.platform === "macos" ? 106 : 72;
    if (find(layout(), "brand")?.size?.px !== want) run("layout.resize", { id: "brand", px: want });
    // The colors of the dock icon (icon-dark.svg): a dark tile with a lavender ram.
    const ram = v_flex().flex_none().p(6).rounded(10).bg("#1b1b27").children(RAM.map((row) => h_flex().children([...row].map((c) => div().size(PX).flex_none().when(c === "X", (el) => el.bg("#c1caf5"))))));
    const grid = this.button("grid-toggle", svg("mods/my-brand/icons/grid.svg").size(15), () => run("my-spaces.grid"), Boolean(shared("grid.saved")));
    const toggle = this.button("sidebar-toggle", svg("mods/workspace-chrome/sidebar.svg").size(15), () => run("my-spaces.sidebar"));
    // Collapsed: the buttons stack, centered, as in the right rail; on macOS below the window buttons.
    if (collapsed) {
      return v_flex().size_full().bg(t.chrome).items_center().gap(4).pt(window()?.platform === "macos" ? 40 : 10).child(toggle).child(grid);
    }
    return h_flex().size_full().bg(t.chrome).pl(14).pr(10).gap(4).items_center().text_size(13.5)
      .when(window()?.platform === "macos", el => el.pl(76))
      .child(h_flex().flex_1().gap(8).items_center().child(ram))
      .child(grid)
      .child(toggle);
  }
}
