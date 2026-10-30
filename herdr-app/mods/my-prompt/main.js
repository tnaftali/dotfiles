// A text prompt. Enter saves, Esc cancels. Props: title, label, value, cmd: the mod command the text is appended to, and
// swatches: [[key, hex | null]] to pick one too (the command gets "|<key>" after the text), color: the key now.
import { View, div } from "gpui-kit";
import { v_flex, h_flex, InputState, Input } from "gpui-base";
import { run, props, closeOverlay, theme } from "herdr";

export default class Prompt extends View {
  init(_props, cx) {
    this.text = props()?.value ?? "";
    this.color = props()?.color ?? "";
    this.input = InputState.new({ value: this.text });
    // Input ranges use UTF-8 bytes, not JavaScript's UTF-16 length.
    if (this.text) this.input.set_selected_range({ start: 0, end: encodeURIComponent(this.text).replace(/%[0-9A-F]{2}/g, "_").length });
    this.input.on("change", (_e, cx) => { this.text = this.input.value(); cx.notify(); });
    this.input.on("submit", () => this.submit());
    this.inputFocused = true;
    this.input.on("focus", (_e, cx) => { this.inputFocused = true; cx.notify(); });
    this.input.on("blur", (_e, cx) => { this.inputFocused = false; cx.notify(); });
    this.input.focus();
    cx.timer.after(600, () => this.input.focus());
    this.handle = cx.focus_handle();
  }

  submit() {
    const p = props();
    closeOverlay(p.overlay);
    run(`${p.cmd}${this.text.trim().replace(/\|/g, "-")}${p.swatches ? `|${this.color}` : ""}`);
  }

  key(e, cx) {
    if (e.key === "escape") { closeOverlay(props().overlay); cx.stop_propagation(); }
  }

  render() {
    const t = theme();
    const p = props() ?? {};
    const label = (text) => div().pt(16).pb(7).text_size(11.5).text_color(t.dim).child(text);
    const button = (id, text, primary, action) => h_flex().id(id).h(32).px(14).items_center().rounded(8)
      .border_1().border_color(primary ? t.solid : t.input).bg(primary ? t.solid : t.raised)
      .text_color(primary ? t.solid_foreground : t.foreground).text_size(12.5).font_medium().cursor_pointer()
      .hover(s => s.opacity(0.88)).on_click(action).child(text);
    return v_flex().id("prompt").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx))
      .w_full().min_h(0).p(18).bg(t.popover).text_color(t.foreground)
      .child(h_flex().items_center().child(div().flex_1().text_size(15).font_semibold().child(p.title ?? ""))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .child(label(p.label ?? ""))
      .child(Input.new(this.input).h(36).px(10).rounded(9).border_1().border_color(this.inputFocused ? t.accent : t.input).bg(t.background).text_size(12.8).text_color(t.foreground))
      .when(Boolean(p.swatches), el => el.child(h_flex().pt(14).gap(9).items_center()
        .children((p.swatches ?? []).map(([key, hex]) => div().id(`sw-${key}`).size(24).rounded(12).flex_none().cursor_pointer()
          .flex().items_center().justify_center().text_size(12).text_color(t.dim)
          .bg(hex ?? t.raised).border_2().border_color(this.color === key ? t.foreground : "#00000000")
          .on_click((_e, cx) => { this.color = key; cx.notify(); }).child(hex ? "" : "\u2715")))))
      .when(Boolean(p.hint), el => el.child(div().pt(6).text_size(11.5).text_color(t.dim).child(p.hint)))
      .child(h_flex().pt(20).gap(8).justify_end()
        .child(button("pm-cancel", "Cancel", false, () => closeOverlay(p.overlay)))
        .child(button("pm-save", "Save", true, () => this.submit())));
  }
}
