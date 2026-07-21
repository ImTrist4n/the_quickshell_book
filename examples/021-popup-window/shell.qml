import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
  PanelWindow {
    id: panel
    anchors {
      top: true
      left: true
      right: true
    }
    height: 48
    color: "#1e1e2e"

    Rectangle {
      id: button
      anchors.centerIn: parent
      width: 120
      height: 32
      radius: 6
      color: "#313244"

      Text {
        anchors.centerIn: parent
        color: "#cdd6f4"
        text: "Click for popup"
      }

      MouseArea {
        anchors.fill: parent
        onClicked: popup.visible = !popup.visible
      }
    }

    PopupWindow {
      id: popup
      width: 200
      height: 150
      color: "#1e1e2e"
      visible: false

      property var anchor: Qt.point(
        panel.x + button.x + button.width / 2 - width / 2,
        panel.y + panel.height
      )

      Column {
        anchors {
          top: parent.top
          topMargin: 8
          horizontalCenter: parent.horizontalCenter
        }
        spacing: 8

        Text { color: "#cdd6f4"; text: "Item 1" }
        Text { color: "#cdd6f4"; text: "Item 2" }
        Text { color: "#cdd6f4"; text: "Item 3" }
      }
    }
  }
}
