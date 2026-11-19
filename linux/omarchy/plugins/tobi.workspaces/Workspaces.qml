import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  // Quickshell's Hyprland model goes stale (a closed workspace stays, the focused one lags), so ask Hyprland itself:
  // on its workspace/window events, and every 3 s as a net.
  property int focusedId: -1
  property var usedIds: []

  function resync() {
    if (!query.running) query.running = true
  }

  Process {
    id: query
    command: ["sh", "-c", "hyprctl activeworkspace -j | jq -r .id; hyprctl workspaces -j | jq -r '[.[]|select(.windows>0)|.id]|join(\" \")'"]
    stdout: StdioCollector {
      onStreamFinished: {
        var lines = text.split("\n")
        root.focusedId = parseInt(lines[0])
        root.usedIds = (lines[1] || "").split(" ").filter(function(x) { return x !== "" }).map(Number)
      }
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (/workspace|focusedmon|movewindow|openwindow|closewindow/.test(event.name)) Qt.callLater(root.resync)
    }
  }

  Timer {
    interval: 3000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.resync()
  }

  function workspaceIds() {
    var ids = []
    // Only workspaces with windows, plus the focused one.
    var all = root.usedIds.concat([root.focusedId])
    for (var i = 0; i < all.length; i++) {
      if (all[i] > 0 && all[i] <= 10 && ids.indexOf(all[i]) === -1) ids.push(all[i])
    }
    ids.sort(function(left, right) { return left - right })
    return ids
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        required property int modelData

        readonly property bool occupied: root.usedIds.indexOf(modelData) !== -1
        readonly property bool focused: root.focusedId === modelData

        bar: root.bar
        text: modelData === 10 ? "0" : String(modelData)
        foreground: focused ? Color.accent : (root.bar ? root.bar.barForeground : Color.foreground)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
