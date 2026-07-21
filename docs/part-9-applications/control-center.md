---
title: "Control Center"
description: "A control center with toggles for Wi-Fi, Bluetooth, Dark Mode, and quick settings"
---

# Control Center

<ChapterMeta title="Control Center" icon="toggles" />

## Problem

Users need quick access to system toggles — Wi-Fi, Bluetooth, Dark Mode, volume, brightness — without diving into settings. A control center provides one-press access.

## Naive Approach

Scatter toggles across the panel. No grouping. Inconsistent styling. No feedback on state.

## MentalModel

<MentalModel title="Toggle Grid">

A control center is a grid of toggle cards. Each card has an icon, a label, and a state. Tapping toggles the state. Cards can be single-state (Wi-Fi on/off) or multi-state (brightness slider).

</MentalModel>

## Idea

Build a `PopupWindow` containing a grid of `ToggleCard` components. Each card binds to a system service. Use `Network`, `Bluetooth`, and custom state properties for appearance.

## Build It

```qml
// ToggleCard.qml
import QtQuick

Rectangle {
  property string label: ""
  property string icon: ""
  property bool toggled: false
  property bool enabled: true

  signal clicked()

  width: 100
  height: 90
  radius: 12
  color: toggled ? "#5294e2" : "#2a2a3e"
  opacity: enabled ? 1.0 : 0.4

  Behavior on color { ColorAnimation { duration: 150 } }

  Column {
    anchors.centerIn: parent
    spacing: 6
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: parent.icon
      font.pixelSize: 24
    }
    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: parent.label
      font.pixelSize: 11
      color: "#ffffff"
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: parent.clicked()
  }
}
```

```qml
// ControlCenter.qml
import QtQuick
import Quickshell
import Quickshell.Services
import "."

PopupWindow {
  width: 340
  height: 400

  property bool wifiEnabled: false
  property bool bluetoothEnabled: false
  property bool darkMode: true

  Grid {
    anchors.fill: parent
    padding: 12
    columns: 3
    spacing: 8

    ToggleCard {
      label: "Wi-Fi"
      icon: "\uF1EB"
      toggled: wifiEnabled

      onClicked: {
        wifiEnabled = !wifiEnabled
        Process.exec("nmcli", ["radio", "wifi", wifiEnabled ? "on" : "off"])
      }
    }

    ToggleCard {
      label: "Bluetooth"
      icon: "\uF294"
      toggled: bluetoothEnabled

      onClicked: {
        bluetoothEnabled = !bluetoothEnabled
        Process.exec("bluetoothctl", ["power", bluetoothEnabled ? "on" : "off"])
      }
    }

    ToggleCard {
      label: "Dark Mode"
      icon: "\uF185"
      toggled: darkMode

      onClicked: {
        darkMode = !darkMode
        ThemeManager.currentTheme = darkMode ? "catppuccin-mocha" : "catppuccin-latte"
      }
    }
  }
}
```

## BuildIt Breakdown

`ToggleCard` is a reusable component. It changes color based on `toggled` state. The control center instantiates three cards, each managing its own state and dispatching shell commands on toggle. `nmcli` controls Wi-Fi, `bluetoothctl` controls Bluetooth, and `ThemeManager` switches dark mode.

## Improve It

Add a volume slider. Add a brightness slider. Show current values. Add a "Now Playing" section from MPRIS. Make cards draggable to reorder. Persist toggle states to a config file.

## CommonMistake

<CommonMistake>

Toggling state optimistically (changing the UI before the command succeeds). If `nmcli` fails (no Wi-Fi adapter), the UI shows Wi-Fi on but it is actually off. Wait for confirmation or use service signals.

</CommonMistake>

## Under the Hood

<UnderTheHood>

`nmcli` communicates with NetworkManager over D-Bus. `bluetoothctl` talks to BlueZ. Both are synchronous CLI tools that exit with code 0 on success. For a production control center, use Quickshell's `Network` and `Bluetooth` services instead of shell commands — they provide reactive properties and signals for real-time state tracking.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Add a volume slider to the control center using the `Volume` widget.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Build a power profile toggle (Performance / Balanced / Power Saver) using `powerprofilesctl`.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Create a fully reactive control center using Quickshell's `Network`, `Bluetooth`, and `Battery` services instead of shell commands.

</ExerciseBlock>

## Recap

<Recap to="/part-9-applications/network-menu">

Quick toggles give users instant control. Next: diving deeper into **network management**.

</Recap>

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/introduction/ — PanelWindow, PopupWindow documentation
- https://quickshell.org/docs/v0.3.0/ — Quickshell API documentation
-->
