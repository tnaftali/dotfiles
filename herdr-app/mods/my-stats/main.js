// CPU, RAM and GPU load under the logo: a label, a percent, and a bar of ten cells for each.
import { View, div } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, exec, layout } from "herdr";

const find = (node, id) => node?.id === id ? node : (node?.children ?? []).map((c) => find(c, id)).find(Boolean) ?? null;
// One read: the cpu line, memory lines, and the GPU's load (nothing without nvidia-smi).
const READ = "head -1 /proc/stat; grep -E '^(MemTotal|MemAvailable):' /proc/meminfo; nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1";

export default class Stats extends View {
  init(_props, cx) {
    this.v = { CPU: null, RAM: null, GPU: null };
    this.prev = null;
    this.read(cx);
    cx.timer.every(2000, (cx) => this.read(cx));
  }

  read(cx) {
    // Hidden in the layout ("hidden": true on the stats block): no polling. Remove that flag to show it again.
    if (this.busy || find(layout(), "stats")?.hidden) return;
    this.busy = true;
    cx.spawn(async () => {
      try {
        const [cpu, ...rest] = (await exec("sh", ["-c", READ])).stdout.trim().split("\n");
        const n = cpu.trim().split(/\s+/).slice(1).map(Number);
        const idle = n[3] + (n[4] || 0), total = n.reduce((a, b) => a + b, 0);
        const mem = Object.fromEntries(rest.filter((l) => l.includes(":")).map((l) => { const [k, v] = l.split(/:\s+/); return [k, parseInt(v)]; }));
        const gpu = rest.find((l) => /^\d+$/.test(l.trim()));
        const dt = this.prev ? total - this.prev.total : 0;
        const v = {
          CPU: dt > 0 ? Math.round(100 * (1 - (idle - this.prev.idle) / dt)) : this.v.CPU,
          RAM: mem.MemTotal ? Math.round(100 * (1 - mem.MemAvailable / mem.MemTotal)) : null,
          GPU: gpu === undefined ? null : Number(gpu),
        };
        this.prev = { idle, total };
        if (JSON.stringify(v) !== JSON.stringify(this.v)) { this.v = v; cx.notify(); }
      } catch {}
      this.busy = false;
    });
  }

  render() {
    const t = theme();
    const color = { CPU: t.ansi4, RAM: t.ansi5, GPU: t.ansi2 };
    return h_flex().size_full().px(16).gap(12).items_center().text_size(10.5)
      .children(Object.entries(this.v).filter(([k, p]) => p !== null || k !== "GPU").map(([k, p]) => {
        const on = Math.round((p ?? 0) / 10);
        return v_flex().flex_1().min_w(0).gap(4)
          .child(h_flex().justify_between().text_color(t.dim).child(k).child(div().text_color(t.foreground).child(p === null ? "–" : `${p}%`)))
          .child(h_flex().gap(2).children(Array.from({ length: 10 }, (_, i) =>
            div().flex_1().h(4).rounded(1).bg(i < on ? (p >= 90 ? t.blocked : color[k]) : t.raised)))
          );
      }));
  }
}
