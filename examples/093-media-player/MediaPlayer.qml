import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PopupWindow {
  id: root

  width: 360
  height: 440
  backgroundColor: "#1e1e2e"
  color: "#1e1e2e"

  property string currentPlayer: "spotify"
  property bool isPlaying: false
  property real progress: 0.45
  property var players: ["spotify", "firefox", "vlc"]

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 16

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Text {
        text: "Now Playing"
        font.pixelSize: 16
        font.bold: true
        color: "#cdd6f4"
        Layout.fillWidth: true
      }

      ComboBox {
        model: root.players
        currentIndex: root.players.indexOf(root.currentPlayer)
        font.pixelSize: 12
        contentItem: Text {
          text: parent.currentText
          color: "#cdd6f4"
          font.pixelSize: 12
        }
        background: Rectangle {
          radius: 6
          color: "#313244"
        }
        indicator: Text {
          x: parent.width - width - 8
          y: parent.height / 2 - height / 2
          text: "▼"
          color: "#585b70"
          font.pixelSize: 8
        }
        onActivated: root.currentPlayer = root.players[index]
      }
    }

    Rectangle {
      Layout.preferredWidth: 200
      Layout.preferredHeight: 200
      Layout.alignment: Qt.AlignHCenter
      radius: 12
      color: "#313244"

      Text {
        anchors.centerIn: parent
        text: "♫"
        font.pixelSize: 64
        color: "#45475a"
      }
    }

    Text {
      text: "Bohemian Rhapsody"
      font.pixelSize: 16
      font.bold: true
      color: "#cdd6f4"
      Layout.alignment: Qt.AlignHCenter
      elide: Text.ElideRight
    }

    Text {
      text: "Queen"
      font.pixelSize: 14
      color: "#a6adc8"
      Layout.alignment: Qt.AlignHCenter
    }

    ColumnLayout {
      Layout.fillWidth: true
      spacing: 4

      Rectangle {
        Layout.fillWidth: true
        height: 6
        radius: 3
        color: "#313244"

        Rectangle {
          width: parent.width * root.progress
          height: parent.height
          radius: 3
          color: "#cba6f7"
        }
      }

      RowLayout {
        Layout.fillWidth: true

        Text {
          text: "1:23"
          font.pixelSize: 11
          color: "#585b70"
        }

        Item { Layout.fillWidth: true }

        Text {
          text: "3:04"
          font.pixelSize: 11
          color: "#585b70"
        }
      }
    }

    RowLayout {
      Layout.alignment: Qt.AlignHCenter
      spacing: 20

      Rectangle {
        width: 40; height: 40; radius: 20; color: "#313244"
        Text { anchors.centerIn: parent; text: "❮"; color: "#cdd6f4"; font.pixelSize: 16 }
        MouseArea { anchors.fill: parent; onClicked: {} }
      }

      Rectangle {
        width: 52; height: 52; radius: 26; color: "#cba6f7"
        Text {
          anchors.centerIn: parent
          text: root.isPlaying ? "⏸" : "▶"
          color: "#1e1e2e"
          font.pixelSize: 18
        }
        MouseArea { anchors.fill: parent; onClicked: root.isPlaying = !root.isPlaying }
      }

      Rectangle {
        width: 40; height: 40; radius: 20; color: "#313244"
        Text { anchors.centerIn: parent; text: "❯"; color: "#cdd6f4"; font.pixelSize: 16 }
        MouseArea { anchors.fill: parent; onClicked: {} }
      }
    }

    Text {
      text: root.isPlaying ? "Playing" : "Paused"
      font.pixelSize: 11
      color: "#585b70"
      Layout.alignment: Qt.AlignHCenter
    }
  }
}
