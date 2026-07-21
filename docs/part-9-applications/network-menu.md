---
title: "Network Menu"
description: "Building a Wi-Fi and network status menu for your shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'Processes & Shell Commands']" you-will-build="A network menu popup showing Wi-Fi networks and connection status" />

## The Problem

Users need to connect to Wi-Fi networks, see their signal strength, and troubleshoot connectivity issues. Without a network menu, they must open a settings app or use `nmcli` in a terminal.

## The Naive Approach

Parse `iwconfig` or `nmcli` output with a Timer and display the results:

```qml
Timer {
  interval: 5000
  running: true
  repeat: true
  onTriggered: {
    Qt.process("nmcli -t -f SSID,SIGNAL dev wifi list")
  }
}
```

This works but polls every 5 seconds, adds subprocess overhead, and parsing CLI output is brittle.

<MentalModel>

Think of NetworkManager as a switchboard operator. Your shell doesn't need to manage connections directly — it just asks the operator "what's available?" and "what's connected?" The operator handles all the complex stuff (DHCP, WPA, DNS).

</MentalModel>

## The Idea

Quickshell doesn't have a built-in network service, but you can build a clean network menu using `nmcli` with efficient process management, `PopupWindow` for the dropdown, and reactive state tracking.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services

PopupWindow {
  id: root
  width: 320
  height: 400
  visible: false

  property string status: ""
  property string ssid: ""
  property int signalStrength: 0

  // Poll periodically
  Timer {
    interval: 10000
    running: root.visible
    repeat: true
    onTriggered: refresh()
  }

  function refresh() {
    Qt.process(["nmcli", "-t", "-f", "TYPE,STATE,DEVICE", "general", "status"])
  }

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 8

    Column {
      anchors.fill: parent; anchors.margins: 12; spacing: 8

      Text { text: "Network"; font.pixelSize: 16; font.bold: true; color: "#cdd6f4" }

      Rectangle {
        width: parent.width; height: 48; radius: 6; color: "#313244"
        Text { text: "Connected: " + root.ssid; anchors.centerIn: parent; color: "#a6adc8"; font.pixelSize: 13 }
      }

      Text { text: "Available Networks"; font.pixelSize: 13; font.bold: true; color: "#6c7086" }

      ListView {
        width: parent.width
        height: 250
        model: ListModel { id: networkModel }
        delegate: Rectangle {
          required property string ssid
          required property int signal
          width: parent.width; height: 40; radius: 4; color: "#313244"
          Text { text: ssid; anchors.centerIn: parent; color: "#cdd6f4"; font.pixelSize: 13 }
          MouseArea { anchors.fill: parent; onClicked: Qt.process(["nmcli", "dev", "wifi", "connect", ssid]) }
        }
      }
    }
  }
}
```

<BuildIt>

This implementation uses `nmcli` for network management. The `Timer` refreshes every 10 seconds while the popup is visible. `Qt.process()` spawns the CLI tool asynchronously.

For a more polished approach, parse `nmcli` output into a structured model.

</BuildIt>

## Let's Improve It

Add signal strength bars, connection status icons, and a disconnect button:

```qml
delegate: Rectangle {
  required property string ssid
  required property int signal
  required property bool connected

  width: parent.width; height: 44; radius: 6
  color: connected ? "#313244" : "#1e1e2e"

  Row {
    anchors.fill: parent; anchors.margins: 10; spacing: 8
    anchors.verticalCenter: parent.verticalCenter

    // Signal bars
    Row {
      spacing: 2
      anchors.verticalCenter: parent.verticalCenter
      Repeater {
        model: 4
        Rectangle {
          property int barIndex: index
          width: 4; height: 6 + index * 5
          radius: 1; color: signal > index * 25 ? "#a6e3a1" : "#45475a"
        }
      }
    }

    Text { text: ssid; color: "#cdd6f4"; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }
    Item { width: 1; height: 1 }
    Text { text: connected ? "✓" : ""; color: "#a6e3a1"; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }

    MouseArea {
      anchors.fill: parent
      onClicked: Qt.process(["nmcli", "dev", "wifi", "connect", ssid])
    }
  }
}
```

<CommonMistake>

**Polling too frequently.** Network scanning is expensive (Wi-Fi scans take 2-5 seconds). Polling every second is wasteful and drains battery. Every 10-30 seconds is sufficient for most shells.

**Parsing nmcli output in QML.** `nmcli` output formatting changes between versions. Use `nmcli -t -f FIELD1,FIELD2` with tab separators for stable parsing. Test your parsing against multiple nmcli versions.

**Forgetting offline state.** If no interface is available, show a clear "No Wi-Fi adapter" or "Airplane Mode" state. An empty list with no explanation confuses users.

</CommonMistake>

## Under the Hood

NetworkManager is a D-Bus service (`org.freedesktop.NetworkManager`). For production shells, consider using D-Bus directly via `QDBusInterface` instead of spawning `nmcli`. D-Bus gives you signal-based updates (instant notification when a connection drops) without polling. The tradeoff is more complex QML code.

## Exercises

<ExerciseBlock :difficulty="1">
Add an airplane mode toggle. When enabled, disable Wi-Fi and hide the network list. Toggle with `nmcli radio wifi off`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Display connection type icons: "🔒" for secure Wi-Fi, "🌐" for ethernet, "📱" for hotspot. Parse the connection type from `nmcli` output.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a full network manager with D-Bus. Use `QDBusInterface` to connect to NetworkManager's `PropertiesChanged` signal. Display real-time signal strength, IP address, and data usage.
</ExerciseBlock>

<Recap :points="['Network menus use nmcli or D-Bus to query NetworkManager', 'Poll every 10-30 seconds — scanning is expensive', 'Use -t flag for stable nmcli output parsing', 'Show clear offline/error states for empty lists']" next-chapter="/part-10-architecture/folder-structure" />

<!--
Sources verified for this chapter:
- https://networkmanager.dev/docs/api/latest/ — NetworkManager D-Bus API
- https://developer-old.gnome.org/NetworkManager/stable/ — NetworkManager reference
- https://wiki.archlinux.org/title/NetworkManager — NetworkManager usage guide
-->
