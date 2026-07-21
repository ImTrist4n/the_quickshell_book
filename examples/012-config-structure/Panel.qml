import Quickshell.Window
import QtQuick

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

    Text { color: Theme.accent; text: " Launcher" }
    Text { color: Theme.fgColor; text: " Terminal" }
    Item { width: 1; height: 1 }
    Text { color: Theme.fgColor; text: " 12:00" }
  }
}
