import QtQuick
import QtQuick.Window

Window {
  width: 480
  height: 360
  title: "QML Objects"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    Rectangle {
      x: 40
      y: 40
      width: 120
      height: 80
      color: "#89b4fa"
      radius: 8
    }

    Rectangle {
      x: 180
      y: 40
      width: 120
      height: 80
      color: "#a6e3a1"
      radius: 8
    }

    Rectangle {
      x: 320
      y: 40
      width: 120
      height: 80
      color: "#f38ba8"
      radius: 8
    }

    Text {
      x: 40
      y: 150
      text: "Text object"
      color: "#cdd6f4"
      font.pixelSize: 18
    }

    Rectangle {
      x: 40
      y: 200
      width: 200
      height: 2
      color: "#fab387"
    }

    Text {
      x: 40
      y: 220
      text: "Every visual item is a QML object."
      color: "#a6adc8"
      font.pixelSize: 14
    }
  }
}
