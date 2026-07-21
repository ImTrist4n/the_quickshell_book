import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 480
  title: "Models & Delegates"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    ListView {
      anchors.fill: parent
      anchors.margins: 20
      spacing: 8
      clip: true

      model: ListModel {
        ListElement { name: "Firefox"; color: "#e06c75" }
        ListElement { name: "Kitty"; color: "#98c379" }
        ListElement { name: "Neovim"; color: "#61afef" }
        ListElement { name: "tmux"; color: "#c678dd" }
        ListElement { name: "Git"; color: "#d19a66" }
        ListElement { name: "Fish"; color: "#56b6c2" }
      }

      delegate: Rectangle {
        width: parent.width
        height: 48
        color: "#313244"
        radius: 8

        Rectangle {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter
          anchors.leftMargin: 12
          width: 10
          height: 10
          radius: 5
          color: model.color
        }

        Text {
          anchors.left: parent.left
          anchors.leftMargin: 36
          anchors.verticalCenter: parent.verticalCenter
          text: model.name
          color: "#cdd6f4"
          font.pixelSize: 16
        }

        Text {
          anchors.right: parent.right
          anchors.rightMargin: 12
          anchors.verticalCenter: parent.verticalCenter
          text: "Item " + (index + 1)
          color: "#585b70"
          font.pixelSize: 13
        }
      }
    }
  }
}
