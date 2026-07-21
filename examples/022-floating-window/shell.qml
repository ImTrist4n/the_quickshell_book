import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
  FloatingWindow {
    title: "Floating Window"
    width: 400
    height: 300
    color: "#1e1e2e"

    Text {
      anchors.centerIn: parent
      color: "#cdd6f4"
      text: "I float freely"
    }
  }
}
