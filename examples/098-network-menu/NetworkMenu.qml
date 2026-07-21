import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  width: 380
  height: 480
  backgroundColor: "#1e1e2e"
  color: "#1e1e2e"

  ListModel {
    id: networkModel

    ListElement { ssid: "Home Network"; strength: 85; secured: true; connected: true }
    ListElement { ssid: "Neighbor WiFi"; strength: 60; secured: true; connected: false }
    ListElement { ssid: "Coffee Shop"; strength: 40; secured: false; connected: false }
    ListElement { ssid: "Office 5G"; strength: 95; secured: true; connected: false }
    ListElement { ssid: "IoT Hub"; strength: 20; secured: true; connected: false }
    ListElement { ssid: "Public Hotspot"; strength: 55; secured: false; connected: false }
    ListElement { ssid: "Library WiFi"; strength: 70; secured: true; connected: false }
    ListElement { ssid: "Guest Network"; strength: 30; secured: true; connected: false }
  }

  Timer {
    id: refreshTimer
    interval: 5000
    repeat: true
    running: true
    onTriggered: {
      for (let i = 0; i < networkModel.count; i++) {
        let delta = Math.floor(Math.random() * 11) - 5;
        let newStr = Math.max(10, Math.min(100, networkModel.get(i).strength + delta));
        networkModel.setProperty(i, "strength", newStr);
      }
      networkModel.sort(function(a, b) {
        if (a.connected) return -1;
        if (b.connected) return 1;
        return b.strength - a.strength;
      });
    }
  }

  function connectToNetwork(ssid) {
    for (let i = 0; i < networkModel.count; i++)
      networkModel.setProperty(i, "connected", false);
    for (let i = 0; i < networkModel.count; i++) {
      if (networkModel.get(i).ssid === ssid) {
        networkModel.setProperty(i, "connected", true);
        break;
      }
    }
    Process.exec("bash", ["-c", `nmcli device wifi connect "${ssid}"`]);
  }

  function strengthBars(strength) {
    let bars = "";
    if (strength >= 80) bars = "▂▄▆█";
    else if (strength >= 60) bars = "▂▄▆";
    else if (strength >= 40) bars = "▂▄";
    else if (strength >= 20) bars = "▂";
    else bars = " ";
    return bars;
  }

  function strengthColor(strength) {
    if (strength >= 80) return "#a6e3a1";
    if (strength >= 60) return "#f9e2af";
    if (strength >= 40) return "#fab387";
    return "#f38ba8";
  }

  Shortcut {
    sequence: "Escape"
    onActivated: root.visible = false
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    RowLayout {
      Layout.fillWidth: true

      Text {
        text: "Wi-Fi Networks"
        font.pixelSize: 16
        font.bold: true
        color: "#cdd6f4"
        Layout.fillWidth: true
      }

      Text {
        text: "⟳"
        font.pixelSize: 14
        color: "#585b70"

        MouseArea {
          anchors.fill: parent
          onClicked: refreshTimer.onTriggered()
        }
      }
    }

    Rectangle {
      Layout.fillWidth: true
      height: 1
      color: "#313244"
    }

    ListView {
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: networkModel
      spacing: 4

      delegate: Rectangle {
        width: parent.width
        height: 52
        radius: 8
        color: model.connected ? "#313244" : mouse.containsMouse ? "#313244" : "transparent"
        border.color: model.connected ? "#a6e3a1" : "transparent"
        border.width: model.connected ? 1 : 0

        RowLayout {
          anchors.fill: parent
          anchors.margins: 12
          spacing: 10

          ColumnLayout {
            spacing: 2

            Text {
              text: model.ssid
              font.pixelSize: 13
              font.bold: model.connected
              color: "#cdd6f4"
            }

            RowLayout {
              spacing: 4

              Text {
                text: root.strengthBars(model.strength)
                font.pixelSize: 12
                color: root.strengthColor(model.strength)
              }

              Text {
                text: model.secured ? "" : ""
                font.pixelSize: 10
                color: model.secured ? "#f9e2af" : "#a6e3a1"
              }
            }
          }

          Item { Layout.fillWidth: true }

          Text {
            text: model.connected ? "Connected" : ""
            font.pixelSize: 11
            color: "#a6e3a1"
          }

          Text {
            text: model.strength + "%"
            font.pixelSize: 11
            color: "#585b70"
          }
        }

        property alias mouse: mouseArea

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            if (!model.connected)
              root.connectToNetwork(model.ssid);
          }
        }
      }
    }

    Text {
      text: "Refreshing every 5s"
      font.pixelSize: 10
      color: "#585b70"
      Layout.alignment: Qt.AlignHCenter
    }
  }
}
