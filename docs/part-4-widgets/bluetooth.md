---
title: "Bluetooth"
description: "Bluetooth status and device management in your shell"
---

## The Problem

Bluetooth is increasingly important for wireless keyboards, mice, headphones, and game controllers. A Bluetooth widget should show adapter status, paired devices, current connections, and allow toggling Bluetooth on/off.

## The Naive Approach

Use `bluetoothctl` commands spawned from QML. `echo -e "power on\n" | bluetoothctl` is fragile, slow, and parsing the interactive output is painful. State changes (device connects/disconnects) require constant polling.

```qml
Timer {
  interval: 3000
  onTriggered: {
    // exec("bluetoothctl", ["show"]) and parse the output
    // Check for "Powered: yes" / "Powered: no"
  }
}
```

<MentalModel>

Bluetooth is like a radio walkie-talkie. You can turn the radio on and off (adapter power), see which channels are in use (connected devices), and pair with new devices (handshake). The radio doesn't change state unless someone flips the switch — so you should listen for events, not keep checking.

</MentalModel>

## The Idea

Quickshell provides `BlueZ` integration that wraps the BlueZ D-Bus API. It exposes adapter power state, discovered devices, connected devices, and pairing status through reactive properties. Changes are event-driven via D-Bus signals.

## Let's Build It

A Bluetooth indicator with connection count:

<BuildIt>

```qml
import Quickshell
import Quickshell.Services.BlueZ

Row {
  spacing: 6

  property var adapter: BlueZ.adapters[0]
  property bool powered: adapter ? adapter.powered : false
  property var connectedDevices: {
    var list = []
    for (var i = 0; i < BlueZ.devices.length; i++) {
      if (BlueZ.devices[i].connected) list.push(BlueZ.devices[i])
    }
    return list
  }

  Text {
    text: powered ? "" : ""
    font.pixelSize: 14
    color: powered ? "#89dceb" : "#585b70"
    MouseArea {
      anchors.fill: parent
      onClicked: {
        if (adapter) adapter.powered = !adapter.powered
      }
    }
  }

  Text {
    text: connectedDevices.length > 0 ? connectedDevices.length + "" : ""
    font.pixelSize: 10
    color: "#a6adc8"
    visible: connectedDevices.length > 0
  }
}
```

</BuildIt>

## Let's Improve It

Show connected device names and battery levels (for supported devices):

```qml
Column {
  spacing: 4

  // Header: toggle + count
  Row {
    spacing: 6
    Text {
      text: powered ? "" : ""
      font.pixelSize: 14
      color: powered ? "#89dceb" : "#585b70"
      MouseArea {
        anchors.fill: parent
        onClicked: if (adapter) adapter.powered = !adapter.powered
      }
    }
    Text {
      text: "Bluetooth"
      font.pixelSize: 12
      color: "#cdd6f4"
    }
    Text {
      text: connectedDevices.length + " connected"
      font.pixelSize: 10
      color: "#585b70"
    }
  }

  // Connected devices
  Repeater {
    model: connectedDevices

    Row {
      spacing: 6
      Text {
        text: modelData.name || "Unknown"
        font.pixelSize: 11
        color: "#a6adc8"
      }
      Text {
        text: modelData.batteryLevel >= 0 ? modelData.batteryLevel + "%" : ""
        font.pixelSize: 10
        color: "#585b70"
      }
    }
  }
}
```

<CommonMistake>

**Assuming the adapter is always present.** Some systems disable Bluetooth in BIOS or have no hardware. Check `BlueZ.adapters.length > 0` before accessing `adapter.powered`.

**Not handling pairing flow.** The widget can show paired devices, but actual pairing (discovery + passkey confirmation) is complex. Use `bluetoothctl` or a system dialog for pairing, and only display state in the widget.

**Updating `connectedDevices` in a loop.** The binding expression iterates all devices every time any device property changes. This is fine for &lt;20 devices. For large lists, cache the result and update only on `deviceAdded`/`deviceRemoved`/`connected` change signals.

</CommonMistake>

## Under the Hood

BlueZ is the Linux Bluetooth stack. Quickshell's `BlueZ` module communicates with BlueZ via D-Bus at `org.bluez`. The adapter object maps to `/org/bluez/hci0`, devices to `/org/bluez/hci0/dev_XX_XX_XX_XX_XX_XX`. Property changes (Powered, Connected, BatteryPercentage) come through `PropertiesChanged` signals.

<UnderTheHood>

Each connected device holds a D-Bus proxy object. The `batteryLevel` property is read from the `org.bluez.Battery1` interface if the device exposes it (most modern headphones and earbuds do). Not all devices report battery — `batteryLevel` returns -1 in that case.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Add a battery indicator next to each connected Bluetooth device if the device reports battery level. Show a warning icon when battery is below 20%.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a device list popup that shows all paired devices (connected or not), with a connect/disconnect button for each. Use `modelData.connect()` and `modelData.disconnect()` methods.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement Bluetooth audio device switching. When a Bluetooth headset connects, automatically switch the PipeWire default sink to it. When it disconnects, revert to the internal speaker.
</ExerciseBlock>

<Recap :points="['BlueZ provides reactive adapter and device state via D-Bus', 'Click the icon to toggle Bluetooth power', 'Connected device list is reactive — no polling needed', 'Battery level is available for supported devices', 'Always check adapter availability before accessing properties']" next-chapter="/part-4-widgets/brightness" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

