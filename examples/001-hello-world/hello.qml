import QtQuick
import QtQuick.Window

Window {
  width: 320
  height: 240
  title: "Hello World"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    Text {
      anchors.centerIn: parent
      text: "Hello, World!"
      color: "#cdd6f4"
      font.pixelSize: 24
    }
  }
}
