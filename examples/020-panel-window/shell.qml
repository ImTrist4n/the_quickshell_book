import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
  PanelWindow {
    anchors {
      bottom: true
      left: true
      right: true
    }
    height: 48
    color: "#1e1e2e"
    exclusiveZone: 48

    Text {
      anchors.centerIn: parent
      color: "#cdd6f4"
      text: "Bottom panel with exclusive zone"
    }
  }
}
