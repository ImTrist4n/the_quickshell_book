import QtQuick
import QtQuick.Window

Window {
  width: 480
  height: 360
  title: "Anchors"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    Rectangle {
      id: centerBox
      width: 160
      height: 100
      color: "#89b4fa"
      radius: 8
      anchors.centerIn: parent
    }

    Rectangle {
      width: 80
      height: 50
      color: "#a6e3a1"
      radius: 8
      anchors.left: centerBox.right
      anchors.leftMargin: 16
      anchors.verticalCenter: centerBox.verticalCenter
    }

    Rectangle {
      width: 80
      height: 50
      color: "#f38ba8"
      radius: 8
      anchors.right: centerBox.left
      anchors.rightMargin: 16
      anchors.verticalCenter: centerBox.verticalCenter
    }

    Rectangle {
      width: 80
      height: 50
      color: "#fab387"
      radius: 8
      anchors.top: centerBox.bottom
      anchors.topMargin: 16
      anchors.horizontalCenter: centerBox.horizontalCenter
    }

    Rectangle {
      width: 80
      height: 50
      color: "#cba6f7"
      radius: 8
      anchors.bottom: centerBox.top
      anchors.bottomMargin: 16
      anchors.horizontalCenter: centerBox.horizontalCenter
    }

    Text {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 16
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Items anchored relative to each other"
      color: "#a6adc8"
      font.pixelSize: 14
    }
  }
}
