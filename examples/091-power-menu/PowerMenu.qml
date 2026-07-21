import Quickshell
import Quickshell.Window
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  width: 400
  height: 280
  backgroundColor: "#1e1e2e"
  color: "#1e1e2e"

  property string shutdownIcon: "⏻"

  property real shutdownHoldProgress: 0
  property bool shutdownConfirming: false

  function execute(command) {
    Process.exec("bash", ["-c", command]);
    root.visible = false;
  }

  function startShutdownTimer() {
    if (root.shutdownConfirming) return;
    root.shutdownConfirming = true;
    root.shutdownHoldProgress = 0;
    shutdownTimer.start();
  }

  function cancelShutdown() {
    root.shutdownConfirming = false;
    root.shutdownHoldProgress = 0;
    shutdownTimer.stop();
  }

  Timer {
    id: shutdownTimer
    interval: 50
    repeat: true
    onTriggered: {
      root.shutdownHoldProgress += 0.025;
      if (root.shutdownHoldProgress >= 1) {
        root.shutdownHoldProgress = 0;
        root.shutdownConfirming = false;
        shutdownTimer.stop();
        root.execute("systemctl poweroff");
      }
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 12

    Text {
      text: "Power Menu"
      font.pixelSize: 18
      font.bold: true
      color: "#cdd6f4"
      Layout.alignment: Qt.AlignHCenter
    }

    GridLayout {
      columns: 3
      columnSpacing: 10
      rowSpacing: 10
      Layout.fillWidth: true
      Layout.alignment: Qt.AlignHCenter

      Repeater {
        model: ListModel {
          ListElement { label: "Lock"; icon: ""; cmd: "loginctl lock-session" }
          ListElement { label: "Log Out"; icon: ""; cmd: "loginctl terminate-user $USER" }
          ListElement { label: "Sleep"; icon: ""; cmd: "systemctl suspend" }
          ListElement { label: "Restart"; icon: ""; cmd: "systemctl reboot" }
          ListElement { label: "Shutdown"; icon: "⏻"; cmd: "systemctl poweroff" }
        }

        delegate: Rectangle {
          width: 100
          height: 80
          radius: 10
          color: {
            if (label === "Shutdown" && root.shutdownConfirming)
              return Qt.rgba(1, 0, 0, root.shutdownHoldProgress);
            return "#313244";
          }
          border.color: {
            if (label === "Shutdown" && root.shutdownConfirming)
              return "#f38ba8";
            return "transparent";
          }
          border.width: root.shutdownConfirming && label === "Shutdown" ? 2 : 0

          ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Text {
              text: icon
              font.pixelSize: 22
              color: "#89b4fa"
              Layout.alignment: Qt.AlignHCenter
            }

            Text {
              text: label
              font.pixelSize: 11
              color: "#cdd6f4"
              Layout.alignment: Qt.AlignHCenter
            }

            Rectangle {
              Layout.fillWidth: true
              height: 3
              radius: 2
              color: "#585b70"
              visible: label === "Shutdown" && root.shutdownConfirming

              Rectangle {
                width: parent.width * root.shutdownHoldProgress
                height: parent.height
                radius: 2
                color: "#f38ba8"
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              if (label === "Shutdown")
                root.startShutdownTimer();
              else
                root.execute(cmd);
            }
          }
        }
      }
    }

    Item { Layout.fillHeight: true }

    Text {
      text: "Esc to close"
      font.pixelSize: 11
      color: "#585b70"
      Layout.alignment: Qt.AlignHCenter
    }
  }

  Shortcut {
    sequence: "Escape"
    onActivated: {
      root.cancelShutdown();
      root.visible = false;
    }
  }
}
