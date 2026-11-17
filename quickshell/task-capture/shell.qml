// Quick capture bar: a resident Quickshell daemon. ALT+N toggles it over IPC, so it is already running when the key is pressed
// (a freshly started window loses the first keystrokes). Enter posts the text to the Tasks capture URL, Esc closes.
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
  id: root
  property bool shown: false

  // Hyprland calls this straight into the running daemon: no `qs ipc` process to spawn first, so the bar maps (and takes focus) sooner.
  GlobalShortcut {
    appid: "task-capture"
    name: "toggle"
    onPressed: root.shown = !root.shown
  }

  IpcHandler {
    target: "capture"
    function toggle(): void { root.shown = !root.shown; }
  }

  Process {
    id: send
    property string text: ""
    command: ["bash", "-c", 'if curl -fsS --max-time 10 --data-raw "$1" "$(< "$HOME/.config/task-capture/url")" >/dev/null; then notify-send -t 1500 Captured "$1"; else notify-send -u critical "Capture failed" "$1"; printf %s "$1" | wl-copy; fi', "_", text]
  }

  PanelWindow {
    id: win
    // Always mapped: a fresh layer surface takes a few frames to appear and focus, and keys typed meanwhile are lost.
    // Hidden = transparent, click-through, no keyboard focus. Showing only flips those, so focus lands at once.
    visible: true
    mask: root.shown ? null : emptyMask
    color: "transparent"
    implicitWidth: 680
    implicitHeight: 64
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "task-capture"

    Region { id: emptyMask }
    Connections {
      target: root
      function onShownChanged() { if (root.shown) { input.text = ""; input.forceActiveFocus(); } }
    }

    Rectangle {
      anchors.fill: parent
      opacity: root.shown ? 1 : 0
      radius: 16
      color: "#2f2f2c"
      border.width: 1
      border.color: "#4a4945"

      TextInput {
        id: input
        anchors.fill: parent
        anchors.margins: 20
        verticalAlignment: TextInput.AlignVCenter
        color: "#f5f4ed"
        font.pixelSize: 20
        selectionColor: "#d97757"
        clip: true
        onAccepted: {
          const t = text.trim();
          root.shown = false;
          if (t) { send.text = t; send.running = true; }
        }
        Keys.onEscapePressed: root.shown = false
        Text {
          visible: !input.text
          anchors.verticalCenter: parent.verticalCenter
          text: "Capture a task or link…"
          color: "#9a988e"
          font: input.font
        }
      }
    }
  }
}
