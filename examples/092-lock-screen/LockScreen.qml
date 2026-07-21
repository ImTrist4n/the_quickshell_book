import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PanelWindow {
  id: root

  layer: "overlay"
  anchors.fill: true
  backgroundColor: "#1e1e2e"
  color: "#1e1e2e"

  property var currentTime: new Date()

  Timer {
    interval: 1000
    repeat: true
    running: true
    onTriggered: root.currentTime = new Date()
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 20

    Text {
      text: root.currentTime.toLocaleTimeString(Qt.locale(), "HH:mm:ss")
      font.pixelSize: 72
      font.weight: Font.Light
      color: "#cdd6f4"
      Layout.alignment: Qt.AlignHCenter
    }

    Text {
      text: root.currentTime.toLocaleDateString(Qt.locale(), "dddd, MMMM d, yyyy")
      font.pixelSize: 20
      color: "#a6adc8"
      Layout.alignment: Qt.AlignHCenter
    }

    Item { height: 20 }

    Rectangle {
      Layout.preferredWidth: 320
      Layout.preferredHeight: 44
      radius: 10
      color: "#313244"

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.margins: 12
        color: "#cdd6f4"
        font.pixelSize: 16
        echoMode: TextInput.Password
        passwordCharacter: "●"
        focus: true

        onAccepted: {
          Process.exec("bash", ["-c", `loginctl unlock-session $(loginctl list-sessions --no-legend | grep $USER | awk '{print $1}')`]);
        }
      }
    }

    Item { height: 20 }

    Rectangle {
      Layout.preferredWidth: 360
      Layout.preferredHeight: 80
      radius: 10
      color: "#181825"

      RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Rectangle {
          width: 56
          height: 56
          radius: 8
          color: "#45475a"

          Text {
            anchors.centerIn: parent
            text: "♫"
            font.pixelSize: 24
            color: "#585b70"
          }
        }

        ColumnLayout {
          spacing: 4

          Text {
            text: "No media playing"
            font.pixelSize: 14
            font.bold: true
            color: "#6c7086"
          }

          Text {
            text: "—"
            font.pixelSize: 12
            color: "#585b70"
          }
        }
      }
    }
  }

  Text {
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 40
    anchors.horizontalCenter: parent.horizontalCenter
    text: "Press Enter to unlock"
    font.pixelSize: 12
    color: "#585b70"
  }
}
