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
    height: Theme.panelHeight
    color: Theme.bgColor

    Row {
      anchors {
        left: parent.left
        leftMargin: 12
        verticalCenter: parent.verticalCenter
      }
      spacing: 16

      Text { color: Theme.accent; text: "Apps" }
      Text { color: Theme.fgColor; text: "Terminal" }
      Text { color: Theme.fgColor; text: "Settings" }
    }
  }
}
