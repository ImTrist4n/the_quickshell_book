import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  width: 360
  height: 300
  backgroundColor: "#1e1e2e"
  color: "#1e1e2e"

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 20
    spacing: 16

    Text {
      text: "Control Center"
      font.pixelSize: 16
      font.bold: true
      color: "#cdd6f4"
      Layout.alignment: Qt.AlignHCenter
    }

    GridLayout {
      columns: 2
      columnSpacing: 16
      rowSpacing: 16
      Layout.alignment: Qt.AlignHCenter

      ToggleCard {
        icon: ""
        label: "Wi-Fi"
        property var process: null

        onToggledChanged: {
          if (toggled)
            Process.exec("bash", ["-c", "nmcli radio wifi on"]);
          else
            Process.exec("bash", ["-c", "nmcli radio wifi off"]);
        }
      }

      ToggleCard {
        icon: ""
        label: "Bluetooth"
        toggled: false

        onToggledChanged: {
          if (toggled)
            Process.exec("bash", ["-c", "bluetoothctl power on"]);
          else
            Process.exec("bash", ["-c", "bluetoothctl power off"]);
        }
      }

      ToggleCard {
        icon: ""
        label: "Dark Mode"
        toggled: true

        onToggledChanged: {
          Process.exec("bash", ["-c", `gsettings set org.gnome.desktop.interface color-scheme '${toggled ? "prefer-dark" : "prefer-light"}'`]);
        }
      }

      ToggleCard {
        icon: ""
        label: "DND"
        toggled: false

        onToggledChanged: {
          Process.exec("bash", ["-c", `dunstctl set ${toggled ? "true" : "false"}`]);
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
    onActivated: root.visible = false
  }
}
