// Now playing: the cover, the title and the artist of what a media player (MPRIS) plays, with previous, play/pause and next.
import { View, div, image, svg } from "gpui-kit";
import { h_flex, v_flex } from "gpui-base";
import { theme, exec, layout, run, shared, setShared } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
}

const PAD = 14, TEXT = 46, CTRL = 34, MINI = 44; // side padding; title + artist rows; button row; small cover
const small = () => shared("player.small") === true;
const side = () => Math.max(0, (find(layout(), "sidebar")?.size?.px ?? 268) - 2 * PAD);

// Per player: "<bus name> <status> <json>". The cover is copied into the app folder: image() reads files.
const READ = `for p in $(busctl --user list --no-legend | grep -o 'org.mpris.MediaPlayer2\\.[^ ]*'); do
  o="$p /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player"
  s=$(busctl --user get-property $o PlaybackStatus --json=short | jq -r .data)
  m=$(busctl --user get-property $o Metadata --json=short | jq -c '.data | {t: .["xesam:title"].data, a: ((.["xesam:artist"].data // []) | join(", ")), art: .["mpris:artUrl"].data}')
  echo "$p $s $m"
done`;
const COVER = `import sys, os, hashlib, urllib.request
url = sys.argv[1]; d = os.path.expanduser("~/.config/herdr-app/cache"); os.makedirs(d, exist_ok=True)
f = "art-" + hashlib.sha1(url.encode()).hexdigest()[:12] + ".jpg"
if not os.path.exists(os.path.join(d, f)): urllib.request.urlretrieve(url, os.path.join(d, f))
print("cache/" + f)`;

export default class Player extends View {
  init(_props, cx) {
    this.now = null; // { player, status, t, a, art }
    this.covers = {}; // art url -> path
    this.read(cx);
    cx.timer.every(1000, (cx) => this.read(cx));
  }

  // The block is as tall as the cover (square) plus the text; 0 when the sidebar is collapsed.
  fit() {
    const w = find(layout(), "sidebar")?.size?.px ?? 268, px = w < 160 ? 0 : small() ? MINI + 2 * PAD : side() + 2 * PAD + 10 + TEXT + 10 + CTRL;
    if (px !== this.px) { this.px = px; run("layout.resize", { id: "player", px }); }
  }

  read(cx) {
    this.fit();
    if (this.busy) return;
    this.busy = true;
    cx.spawn(async () => {
      try {
        const rows = (await exec("sh", ["-c", READ])).stdout.split("\n")
          .map((l) => l.match(/^(\S+) (\S+) (\{.*\})$/)).filter(Boolean)
          .map((m) => ({ player: m[1], status: m[2], ...JSON.parse(m[3]) })).filter((r) => r.t);
        const now = rows.find((r) => r.status === "Playing") ?? rows.find((r) => r.status === "Paused") ?? null;
        if (now?.art && !(now.art in this.covers)) {
          this.covers[now.art] = null;
          try { this.covers[now.art] = (await exec("python3", ["-c", COVER, now.art])).stdout.trim() || null; } catch {}
        }
        if (now) now.cover = this.covers[now.art] ?? null;
        if (JSON.stringify(now) !== JSON.stringify(this.now)) { this.now = now; cx.notify(); }
      } catch {}
      this.busy = false;
    });
  }

  render() {
    const t = theme(), n = this.now, w = side(), mini = small();
    const toggle = () => { setShared("player.small", !mini); this.fit(); };
    // A button calls the MPRIS method on the active player; it does nothing when no player is active.
    const btn = (icon, method, size, bg) => div().id(`player-${icon}`).size(size).flex_none().rounded(size / 2).flex().items_center().justify_center()
      .when(bg, (el) => el.bg(bg)).when(Boolean(n), (el) => el.cursor_pointer().on_click(() => exec("busctl", ["--user", "call", n.player, "/org/mpris/MediaPlayer2", "org.mpris.MediaPlayer2.Player", method])))
      .child(svg(`mods/my-player/icons/${icon}.svg`).size(size * 0.55).text_color(n ? t.foreground : t.dim));
    if (!w || w + 2 * PAD < 160) return div();
    const size = mini ? MINI : w;
    const chevron = (bg) => div().id("player-toggle").size(24).flex_none().rounded(12).flex().items_center().justify_center().cursor_pointer().when(bg, (el) => el.bg(bg)).on_click(toggle)
      .child(svg(`mods/my-player/icons/${mini ? "up" : "down"}.svg`).size(14).text_color(t.foreground));
    const art = div().w(size).h(size).flex_none().rounded(mini ? 12 : 16).overflow_hidden().bg(t.raised).flex().items_center().justify_center().text_color(t.dim).text_size(size / 3)
      .when(n?.cover, (el) => el.child(image(n.cover).w(size).h(size))).when(!n?.cover, (el) => el.child("\u266a"));
    const title = (sz, sub) => v_flex().gap(2).min_w(0).opacity(n?.status === "Paused" ? 0.6 : 1)
      .child(div().truncate().text_size(sz).font_semibold().text_color(n ? t.foreground : t.dim).child(n?.t ?? "Nothing playing"))
      .child(div().truncate().text_size(sub).text_color(t.dim).child(n?.a ?? ""));
    const play = (sz) => btn(n?.status === "Playing" ? "pause" : "play", "PlayPause", sz, t.raised);
    if (mini) return h_flex().id("player").size_full().p(PAD).gap(10).items_center().border_t(1).border_color(t.border)
      .child(art).child(div().flex_1().min_w(0).child(title(13, 11.5))).child(play(30)).child(chevron(null));
    return v_flex().id("player").size_full().p(PAD).gap(10).border_t(1).border_color(t.border)
      .child(div().relative().w(w).h(w).flex_none().child(art).child(div().absolute().top(8).right(8).child(chevron(`${t.chrome}cc`))))
      .child(title(15, 12.5))
      .child(h_flex().h(CTRL).gap(22).items_center().justify_center()
        .child(btn("prev", "Previous", 22, null))
        .child(play(34))
        .child(btn("next", "Next", 22, null)));
  }
}
