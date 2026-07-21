import QtQuick
import QtQuick.Window

Window {
  width: 480
  height: 360
  title: "QML Properties"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    Rectangle {
      id: box
      x: 40
      y: 40
      width: 120
      height: 120
      color: "#89b4fa"
      radius: 8
    }

    Text {
      id: label
      x: 180
      y: 45
      text: "x: " + box.x
      color: "#cdd6f4"
      font.pixelSize: 16
    }

    Text {
      x: 180
      y: 75
      text: "y: " + box.y
      color: "#cdd6f4"
      font.pixelSize: 16
    }

    Text {
      x: 180
      y: 105
      text: "width: " + box.width
      color: "#a6e3a1"
      font.pixelSize: 16
    }

    Text {
      x: 180
      y: 135
      text: "height: " + box.height
      color: "#a6e3a1"
      font.pixelSize: 16
    }

    Text {
      x: 180
      y: 165
      text: "color: " + box.color
      color: "#f38ba8"
      font.pixelSize: 16
    }

    Rectangle {
      x: 40
      y: 200
      width: 400
      height: 2
      color: "#585b70"
    }

    Text {
      x: 40
      y: 220
      text: "Properties use bindings — expressions that auto-update."
      color: "#a6adc8"
      font.pixelSize: 14
    }
  }
}
