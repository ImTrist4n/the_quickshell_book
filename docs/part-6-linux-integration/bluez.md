---
title: "BlueZ"
description: "Bluetooth device management through BlueZ D-Bus API"
---

# BlueZ

## The Problem

A desktop shell needs to show Bluetooth adapter status, list paired (and nearby) devices, and allow connect/disconnect and pairing. BlueZ's D-Bus API is complex — adapters and devices are nested object paths under `/org/bluez/hci0`.

## The Naive Approach

Calling `bluetoothctl paired-devices` and parsing text output. This is slow, doesn't give real-time updates (device connects/disconnects), and can't initiate scanning reliably.

<MentalModel>

BlueZ uses a hierarchical D-Bus object tree: `/org/bluez/hci0` (adapter) → `/org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX` (device). Each device has properties: `Name`, `Connected`, `Paired`, `Trusted`, `RSSI`. The `org.freedesktop.DBus.ObjectManager` signals `InterfacesAdded`/`Removed` for new devices. Quickshell's `Bluez` service maps this to QML-friendly models.

</MentalModel>

## The Idea

Use Quickshell's `Bluez` service to bind to the adapter and device list. Show a list of paired devices with a connect/disconnect toggle. Provide a scan button that discovers new devices.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services.Bluez

Column {
  spacing: 8

  Bluez {
    id: bluez
  }

  Row {
    spacing: 8
    Text { text: bluez.adapter.powered ? "Bluetooth On" : "Bluetooth Off" }
    Switch {
      checked: bluez.adapter.powered
      onCheckedChanged: bluez.adapter.powered = checked
    }
  }

  Button {
    text: bluez.adapter.discovering ? "Scanning..." : "Scan"
    onClicked: {
      if (bluez.adapter.discovering) bluez.adapter.stopDiscovery()
      else bluez.adapter.startDiscovery()
    }
  }

  ListView {
    width: 300; height: 200
    model: bluez.devices
    delegate: Row {
      required property var modelData
      spacing: 6
      Icon { source: modelData.connected ? "bluetooth-active" : "bluetooth-disabled" }
      Text { text: modelData.name; width: 140; elide: Text.ElideRight }
      Text { text: modelData.connected ? "Connected" : "Disconnected"; color: modelData.connected ? "#4caf50" : "#aaa" }
      Button {
        text: modelData.connected ? "Disconnect" : "Connect"
        onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
      }
    }
  }
}
```

<BuildIt>

`Bluez.adapter` exposes `powered` (read/write), `discovering`, `name`, and `address`. `Bluez.devices` is a model of `BluezDevice` objects with `name`, `address`, `connected`, `paired`, `rssi`, and methods `connect()`, `disconnect()`, `pair()`.

</BuildIt>

## Let's Improve It

Add a pairing workflow: when a new device appears during scanning (not paired), show a "Pair" button. Handle the pairing agent — Quickshell's BlueZ service handles the agent internally, but you can customize prompts.

```qml
Button {
  text: "Pair"
  visible: !modelData.paired
  onClicked: modelData.pair()
}
```

<CommonMistake>

Calling `connect()` before `pair()` on a new device. Some devices require pairing first. Check `modelData.paired` and call `pair()` if false, then `connect()`. Also, scanning only finds discoverable devices — ensure the target is in pairing mode.

</CommonMistake>

## Under the Hood

Quickshell registers a D-Bus object at `/quickshell/agent` implementing `org.bluez.Agent1`. It handles PIN/passkey requests (auto-confirms for Simple Pairing). The `Bluez.devices` model updates as `InterfacesAdded`/`PropertiesChanged` signals arrive. `startDiscovery()` sets the adapter's `Discovering` property to `true` via D-Bus.

## Exercises

**Beginner:** Show the Bluetooth adapter status icon in a panel (on/off/connecting).

**Intermediate:** Build a Bluetooth popup that lists devices grouped by "Paired" and "Available", with signal strength indicator bars.

**Advanced:** Implement a bluetooth tray that shows battery level of connected devices (BlueZ exposes `BatteryPercentage` on some devices) and auto-reconnects on wake.

<Recap :points="['BlueZ Bluetooth is fully controllable through Quickshell Bluez service', 'Adapter power, device scanning, connect/disconnect, and pairing from QML', 'Bluez service exposes D-Bus properties as reactive QML bindings']" next-chapter="/part-6-linux-integration/notifications-daemon" />

<!--
Sources verified for this chapter:
- https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc/device-api.txt — BlueZ Device API
- https://git.kernel.org/pub/scm/bluetooth/bluez.git/tree/doc/adapter-api.txt — BlueZ Adapter API
- https://quickshell.org/docs/v0.3.0/types/BlueZ/Bluez/ — Quickshell Bluez type
- https://www.bluez.org/ — BlueZ project
-->
