---
title: "Network"
description: "Displaying network status, SSID, and signal strength"
---

## The Problem

A network widget must show Wi-Fi SSID, signal strength, connection state, and maybe IP address. Wired Ethernet should also be detected. The state changes frequently — you connect to a new network, drop signal, or plug in an Ethernet cable.

## The Naive Approach

Run `iwconfig` or `nmcli` in a polling `Timer`. These tools have inconsistent output formats and spawning processes every few seconds is wasteful. Worse, polling misses transient states (connecting, authenticating, DHCP timeout).

```qml
Timer {
  interval: 5000
  onTriggered: {
    // "nmcli -t -f active,ssid,signal dev wifi" or "iwconfig wlan0"
    // Parse messy output
  }
}
```

<MentalModel>

Think of network status like a phone's cellular indicator. You don't check your data plan every second — the phone tells you when you connect, disconnect, or switch towers. Similarly, your widget should react to events, not poll for changes.

</MentalModel>

## The Idea

Quickshell provides `NetworkManager` integration via the `NetworkManager` singleton. It exposes active connections, device status, signal strength, and SSID through reactive properties. No polling, no shell commands.

## Let's Build It

A network widget with Wi-Fi SSID and signal strength:

<BuildIt>

```qml
import Quickshell
import Quickshell.Services.NetworkManager

Row {
  spacing: 6

  property var primaryDevice: {
    for (var i = 0; i < NetworkManager.devices.length; i++) {
      var dev = NetworkManager.devices[i]
      if (dev.activeConnection) return dev
    }
    return null
  }

  property var connection: primaryDevice ? primaryDevice.activeConnection : null
  property string ssid: connection ? connection.id : ""
  property int signalStrength: primaryDevice && primaryDevice.type === "wifi"
    ? primaryDevice.wirelessStrength : -1
  property bool connected: connection !== null

  Text {
    text: {
      if (!connected) return ""
      if (primaryDevice && primaryDevice.type === "ethernet") return ""
      if (signalStrength >= 80) return ""
      if (signalStrength >= 50) return ""
      if (signalStrength >= 25) return ""
      return ""
    }
    font.pixelSize: 14
    color: connected ? "#a6e3a1" : "#585b70"
  }

  Text {
    text: ssid
    font.pixelSize: 12
    color: "#cdd6f4"
    visible: ssid !== ""
  }

  Text {
    text: signalStrength >= 0 ? signalStrength + "%" : ""
    font.pixelSize: 10
    color: "#585b70"
    visible: primaryDevice && primaryDevice.type === "wifi"
  }
}
```

</BuildIt>

## Let's Improve It

Show download/upload speed and IP address:

```qml
Row {
  spacing: 8

  property var prevRx: 0
  property var prevTx: 0
  property real speedRx: 0
  property real speedTx: 0

  function updateSpeed() {
    var data = readFile("/sys/class/net/" + iface + "/statistics/rx_bytes")
    var rx = parseInt(data.trim())
    data = readFile("/sys/class/net/" + iface + "/statistics/tx_bytes")
    var tx = parseInt(data.trim())
    speedRx = (rx - prevRx) / 1024 / 2 // KB/s over 2s window
    speedTx = (tx - prevTx) / 1024 / 2
    prevRx = rx
    prevTx = tx
  }

  Text {
    text: " " + speedTx.toFixed(1) + "K"
    font.pixelSize: 10
    color: "#585b70"
  }
  Text {
    text: " " + speedRx.toFixed(1) + "K"
    font.pixelSize: 10
    color: "#585b70"
  }
}
```

<CommonMistake>

**Assuming Wi-Fi is the only interface.** Desktops use Ethernet. Laptops may have both. Check `device.type === "wifi"` vs `"ethernet"`. Handle the case where no connection is active.

**Polling signal strength.** `NetworkManager` properties are reactive. Just bind to `primaryDevice.wirelessStrength` — the UI updates when the kernel reports a signal change to NetworkManager.

**Exposing raw IP addresses.** If you show your local IP in the panel, consider privacy implications for screenshots or streaming. Make it opt-in.

</CommonMistake>

## Under the Hood

`NetworkManager` is a Quickshell module wrapping the `org.freedesktop.NetworkManager` D-Bus interface. It subscribes to `StateChanged`, `DeviceAdded`, `DeviceRemoved`, and `PropertiesChanged` signals. The `wirelessStrength` property updates when NetworkManager receives a scan update from `wpa_supplicant` (typically every 5-15 seconds).

<UnderTheHood>

Network speed is computed by reading `/sys/class/net/&lt;iface&gt;/statistics/rx_bytes` and `tx_bytes`. These are kernel counters incremented by the NIC driver on every packet. By taking deltas over a 2-second window, you get a smoothed throughput rate. The filesystem path must match the active interface name.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Add a connection type icon that distinguishes Wi-Fi (waves icon), Ethernet (plug icon), and no connection (disconnected icon). Change color based on connectivity state.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a network list popup: when clicking the widget, show available Wi-Fi networks with SSID and signal strength bars. Indicate which one is currently connected.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a data usage tracker per session. Sum rx/tx bytes since the widget loaded and display total transferred in MB/GB. Persist the counter across shell restarts using a JSON file.
</ExerciseBlock>

<Recap :points="['NetworkManager singleton provides reactive network state', 'Device type (wifi vs ethernet) determines the icon', 'Signal strength is reactive — no polling needed', 'Network speed comes from sysfs byte counters', 'Always handle the disconnected state gracefully']" next-chapter="/part-4-widgets/volume" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

