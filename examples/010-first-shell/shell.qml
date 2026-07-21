import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
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
      text: "My first shell"
    }
  }
}
