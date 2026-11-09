// Pick a color for a computer's laptop icon. Props: machine. A click sets it: my-spaces.mcolor:<machine>|<name> (empty name: the default).
import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, theme, shared } from "herdr";

// Catppuccin Macchiato. my-spaces has the same list.
const COLORS = { blue: "#8aadf4", peach: "#f5a97f", green: "#a6da95", mauve: "#c6a0f6", teal: "#8bd5ca", pink: "#f5bde6", yellow: "#eed49f", red: "#ed8796", sky: "#91d7e3", lavender: "#b7bdf8", flamingo: "#f0c6c6", maroon: "#ee99a0", sapphire: "#7dc4e4" };

export default class Icons extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
  }

  pick(name) {
    const p = props();
    closeOverlay(p.overlay);
    run(`my-spaces.mcolor:${p.machine}|${name}`);
  }

  render() {
    const t = theme();
    const p = props() ?? {};
    const now = (shared("machine.colors") ?? {})[p.machine];
    return v_flex().id("icons").track_focus(this.handle)
      .on_key_down((e, cx) => {
        if (e.key === "escape") { closeOverlay(p.overlay); cx.stop_propagation(); }
      })
      .w_full().min_h(0).p(18).gap(14).bg(t.popover).text_color(t.foreground)
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().child(p.machine ?? ""))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(h_flex().flex_wrap().gap(8)
        .children(Object.entries(COLORS).map(([name, hex]) => div().id(`mc-${name}`).size(30).rounded(15).bg(hex).border(2).border_color(now === name ? t.foreground : hex)
          .cursor_pointer().hover((s) => s.opacity(0.85)).on_click(() => this.pick(name)))))
      .child(h_flex().justify_end().child(div().id("mc-reset").h(30).px(12).rounded(11).flex().items_center().text_size(12.5)
        .border_1().border_color(t.input).bg(t.raised).cursor_pointer().hover((s) => s.opacity(0.88)).on_click(() => this.pick("")).child("Default color")));
  }
}
