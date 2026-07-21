import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 300
  title: "Components"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    Column {
      anchors.centerIn: parent
      spacing: 16

      StyledButton {
        text: "Primary"
        onClicked: print("Primary clicked")
      }

      StyledButton {
        text: "Secondary"
        color: "#a6e3a1"
        border.color: "#94d492"
        onClicked: print("Secondary clicked")
      }

      StyledButton {
        text: "Danger"
        color: "#f38ba8"
        border.color: "#d97a8e"
        onClicked: print("Danger clicked")
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Reusable components save code"
        color: "#a6adc8"
        font.pixelSize: 13
        topPadding: 8
      }
    }
  }
}
