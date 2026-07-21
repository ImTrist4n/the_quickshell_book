---
title: "Bluetooth Manager"
description: "Adding Bluetooth device management to your shell panel"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'ListView']" you-will-build="A Bluetooth manager popup to scan, pair, and connect devices" />

## The Problem

Users frequently connect Bluetooth headphones, keyboards, and mice. Opening system settings to toggle Bluetooth or pair a device is cumbersome. A shell-integrated Bluetooth manager provides instant access.

## The Naive Approach

Use `bluetoothctl` commands:

```qml
function pairDevice(mac) {
  Qt.process(["bluetoothctl", "pair", mac])
}

Timer {
  interval: 2000; running: true; repeat: true
  onTriggered: {
    var result = Qt.process(["bluetoothctl", "devices"])
    // parse output
  }
}
```

`bluetoothctl` is interactive by design — it's meant for human use. Parsing its output is fragile across BlueZ versions.

<MentalModel>

Think of Bluetooth management like a radio. The power button turns the radio on/off. The scan button finds stations (devices). The dial selects a station to connect to. A good Bluetooth manager combines all these controls in one place.

</MentalModel>

## The Idea

Use BlueZ's D-Bus API (`org.bluez`) directly. BlueZ exposes adapters, devices, and connections as D-Bus objects with properties that change via signals — no polling needed.

## Let's Build It

```qml
// BluetoothService.qml
pragma Singleton
import Quickshell

QtObject {
  id: bt

  property bool available: false
  property bool powered: false
  property var devices: []
  property bool scanning: false

  function togglePower() {
    powered = !powered
    Qt.process(["bluetoothctl", powered ? "power on" : "power off"])
  }

  function startScan() {
    if (scanning) return
    scanning = true
    Qt.process(["bluetoothctl", "scan", "on"])
    Timer { interval: 10000; running: true; repeat: false
      onTriggered: {
        Qt.process(["bluetoothctl", "scan", "off"])
        bt.scanning = false
      }
    }
  }

  function pairDevice(mac) {
    Qt.process(["bluetoothctl", "pair", mac])
  }

  function connectDevice(mac) {
    Qt.process(["bluetoothctl", "connect", mac])
  }

  function disconnectDevice(mac) {
    Qt.process(["bluetoothctl", "disconnect", mac])
  }

  function removeDevice(mac) {
    Qt.process(["bluetoothctl", "remove", mac])
  }

  function refresh() {
    Qt.process(["bluetoothctl", "show", "--json"])
      .onStdout.connect(function(data) {
        try {
          var info = JSON.parse(data)
          powered = info.powered
          available = true
        } catch (e) { available = false }
      })
    Qt.process(["bluetoothctl", "devices", "--json"])
      .onStdout.connect(function(data) {
        try { devices = JSON.parse(data) } catch (e) {}
      })
  }

  Timer {
    interval: 5000; running: true; repeat: true
    onTriggered: bt.refresh()
  }
}
```

Bluetooth popup:

```qml
// BluetoothControl.qml
PopupWindow {
  id: root
  width: 320; height: 400
  anchor.window: panel

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 12 }; spacing: 8

      Row {
        width: parent.width; spacing: 8
        Text { text: "Bluetooth"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4"; anchors.verticalCenter: parent.verticalCenter }

        Rectangle { width: 8; height: 8; radius: 4; color: BluetoothService.powered ? "#a6e3a1" : "#f38ba8"; anchors.verticalCenter: parent.verticalCenter }

        Item { width: parent.width - 200; height: 1 }

        Button { text: BluetoothService.powered ? "Turn Off" : "Turn On"; onClicked: BluetoothService.togglePower(); height: 28; radius: 4; color: "#313244" }
        Button { text: "Scan"; onClicked: BluetoothService.startScan(); enabled: BluetoothService.powered; height: 28; radius: 4; color: "#313244" }
      }

      Text { text: BluetoothService.scanning ? "Scanning..." : ""; color: "#a6adc8"; font.pixelSize: 11 }

      ListView {
        width: parent.width; height: parent.height - 60
        model: BluetoothService.devices
        spacing: 4; clip: true

        delegate: Rectangle {
          required property var modelData
          width: parent.width; height: 48; radius: 6; color: "#313244"

          Row {
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }; spacing: 8; anchors.verticalCenter: parent.verticalCenter
            Text { text: "🎧"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
            Column { spacing: 2; anchors.verticalCenter: parent.verticalCenter
              Text { text: modelData.name || "Unknown"; font.pixelSize: 13; color: "#cdd6f4" }
              Text { text: modelData.connected ? "Connected" : modelData.paired ? "Paired" : "Available"; font.pixelSize: 11; color: modelData.connected ? "#a6e3a1" : "#6c7086" }
            }
            Item { width: parent.width - 200; height: 1 }
            Button { text: modelData.connected ? "Disconnect" : "Connect"; onClicked: modelData.connected ? BluetoothService.disconnectDevice(modelData.address) : BluetoothService.connectDevice(modelData.address); height: 24; radius: 4; color: "#45475a"; anchors.verticalCenter: parent.verticalCenter }
          }
        }

        ScrollBar.vertical: ScrollBar { active: true }
      }
    }
  }
}
```

<BuildIt>

The Bluetooth service wraps `bluetoothctl` commands and parses JSON output for structured device data. The popup shows power state, a scan button, and a list of devices with connect/disconnect actions. Each device shows name, status (Connected/Paired/Available), and an action button.

</BuildIt>

## Let's Improve It

Use BlueZ D-Bus directly for event-driven updates:

```qml
function connectDbus() {
  Qt.dbusCall("org.bluez", "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects")
    .onReply.connect(function(objects) {
      // Parse objects for adapters and devices
    })
}
```

D-Bus signals from BlueZ (`InterfacesAdded`, `InterfacesRemoved`, `PropertiesChanged`) provide real-time updates without polling.

<CommonMistake>

**Scanning forever.** Leaving Bluetooth scanning on drains battery and clutters the device list. Always set a scan timeout (10-15 seconds) and automatically turn scanning off.

**Not handling authentication.** Some devices require PIN or confirmation during pairing. Detect authentication requests via D-Bus and show a pairing dialog in your shell.

**Assuming device names are unique.** Multiple devices can have the same name (e.g., "WH-1000XM4"). Always use the MAC address for identifying and controlling devices.

</CommonMistake>

## Under the Hood

BlueZ exposes Bluetooth adapters and devices on D-Bus at `org.bluez`. Adapters are at `/org/bluez/hci0`, devices at `/org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX`. Each object implements interfaces like `org.bluez.Device1` (with properties `Name`, `Address`, `Connected`, `Paired`, etc.) and `org.bluez.Adapter1` (with `Powered`, `Discovering`, etc.).

## Exercises

<ExerciseBlock :difficulty="1">
Switch from `bluetoothctl` to direct D-Bus communication. Use `Qt.dbusCall()` to read device properties and call methods like `Connect`, `Disconnect`, and `StartDiscovery`. Remove the polling timer.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a battery level indicator for connected devices that support the Battery Service. Read `org.bluez.Battery1.Percentage` from the device object.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a quick-connect panel in the bar. Show the 3 most recently connected devices as small icons. Click to connect. Show a Bluetooth icon in the tray that changes color based on connection status.
</ExerciseBlock>

<Recap :points="['Manage Bluetooth via bluetoothctl with JSON output or directly via BlueZ D-Bus', 'Always time-box scanning to 10-15 seconds to save battery', 'Show device status (Connected/Paired/Available) clearly', 'Use MAC addresses, not names, for reliable device identification']" next-chapter="/part-11-complete-shell/power-profiles" />

<!--
Sources verified for this chapter:
- https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc/device-api.txt — BlueZ D-Bus API
- https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc/adapter-api.txt — Adapter API
- https://www.bluez.org/ — BlueZ project
- https://doc.qt.io/qt-6/qml-qtquick-controls-button.html — Button QML type
-->
