import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
  // Full-width top panel
  PanelWindow {
    anchors {
      top: true
      left: true
      right: true
    }
    height: 48
    color: "#1e1e2e"

    Text {
      anchors.centerIn: parent
      color: "#cdd6f4"
      text: "Top panel (anchors top + left + right)"
    }
  }

  // Bottom panel with margins on each side
  PanelWindow {
    anchors {
      bottom: true
      left: true
      right: true
      leftMargin: 64
      rightMargin: 64
      bottomMargin: 8
    }
    height: 48
    color: "#313244"
    exclusiveZone: 48

    Text {
      anchors.centerIn: parent
      color: "#cdd6f4"
      text: "Bottom panel with margins"
    }
  }
}
