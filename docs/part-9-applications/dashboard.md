---
title: "Dashboard"
description: "Building a comprehensive system dashboard with performance monitoring"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['CPU widget', 'RAM widget', 'Disk widget', 'Network widget']" you-will-build="A full-screen dashboard showing system performance, weather, and calendar" />

## The Problem

Users often want a glanceable overview of their system — CPU load, memory usage, disk space, network activity, weather, and upcoming events. Opening multiple widgets or terminals to check these individually is inefficient.

## The Naive Approach

Place every widget inline in a panel:

```qml
Row {
  CpuWidget {}
  RamWidget {}
  DiskWidget {}
  NetworkWidget {}
}
```

This works but the panel becomes overcrowded. Users can't see detailed information like per-core CPU usage or process lists without clicking through to separate windows.

<MentalModel>

Think of a dashboard as the instrument cluster in a car. It consolidates all critical information into one organized view: speed (CPU), fuel (RAM), odometer (disk), navigation (network), and climate (weather). Each gauge is specialized but shares the same display space.

</MentalModel>

## The Idea

A dashboard is a large popup or fullscreen window containing multiple data panels. Each panel is a self-contained component that can be developed independently. The dashboard exposes configuration options for which panels to show and their arrangement.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services
import QtQml.Models

PopupWindow {
  id: root
  width: 800
  height: 600
  visible: false

  property var cpuData: []
  property var memoryData: {}
  property var diskData: []

  // Update timer
  Timer {
    interval: 2000
    running: root.visible
    repeat: true
    onTriggered: refreshData()
  }

  function refreshData() {
    // In production, fetch from system services
    cpuData = [45, 62, 30, 78, 55, 41, 82, 33] // per-core percentages
    memoryData = { used: 8.2, total: 16, percent: 51 }
    diskData = [
      { mount: "/", used: 120, total: 500, percent: 24 },
      { mount: "/home", used: 340, total: 1000, percent: 34 }
    ]
  }

  Rectangle {
    anchors.fill: parent; color: "#1e1e2e"; radius: 8

    Grid {
      anchors.fill: parent; anchors.margins: 16
      columns: 2; spacing: 12

      // CPU Panel
      Rectangle {
        width: 370; height: 160; radius: 8; color: "#181825"
        Column {
          anchors { fill: parent; margins: 12 }; spacing: 8
          Text { text: "CPU"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }

          Row {
            spacing: 4
            Repeater {
              model: root.cpuData
              delegate: Rectangle {
                required property var modelData
                width: 40; height: 80; radius: 3; color: "#313244"
                Rectangle {
                  anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
                  width: 36; height: parent.height * modelData / 100; radius: 2
                  color: modelData > 80 ? "#f38ba8" : modelData > 50 ? "#fab387" : "#a6e3a1"
                }
                Text {
                  anchors { bottom: parent.top; horizontalCenter: parent.horizontalCenter; bottomMargin: 4 }
                  text: modelData + "%"; color: "#6c7086"; font.pixelSize: 9
                }
              }
            }
          }
        }
      }

      // Memory Panel
      Rectangle {
        width: 370; height: 160; radius: 8; color: "#181825"
        Column {
          anchors { fill: parent; margins: 12 }; spacing: 8
          Text { text: "Memory"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }
          Text { text: memoryData.used + " / " + memoryData.total + " GB"; font.pixelSize: 24; font.bold: true; color: "#89b4fa" }
          Rectangle { width: parent.width; height: 8; radius: 4; color: "#313244"
            Rectangle { width: parent.width * memoryData.percent / 100; height: 8; radius: 4; color: "#89b4fa" }
          }
        }
      }

      // Disk Panel
      Rectangle {
        width: 370; height: 160; radius: 8; color: "#181825"
        Column {
          anchors { fill: parent; margins: 12 }; spacing: 8
          Text { text: "Storage"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }
          Repeater {
            model: root.diskData
            delegate: Rectangle {
              required property var modelData
              width: parent.width; height: 40; color: "transparent"
              Text { text: modelData.mount + ": " + modelData.used + "/" + modelData.total + " GB"; font.pixelSize: 12; color: "#a6adc8" }
              Rectangle { y: 20; width: parent.width; height: 6; radius: 3; color: "#313244"
                Rectangle { width: parent.width * modelData.percent / 100; height: 6; radius: 3; color: "#a6e3a1" }
              }
            }
          }
        }
      }

      // Process List
      Rectangle {
        width: 370; height: 160; radius: 8; color: "#181825"
        Column {
          anchors { fill: parent; margins: 12 }; spacing: 4
          Text { text: "Top Processes"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }
          // Populated via Qt.process(["ps", "aux", "--sort=-%cpu"])
        }
      }
    }
  }
}
```

<BuildIt>

The dashboard uses a `Grid` layout to arrange monitoring panels. Each panel is a self-contained component that can be pulled out and reused. A `Timer` refreshes data every 2 seconds while visible.

</BuildIt>

## Let's Improve It

Add configuration options and panel rearrangement:

```qml
property var enabledPanels: ["cpu", "memory", "disk", "network", "weather", "calendar"]

// Filter panels based on config
Repeater {
  model: enabledPanels
  delegate: Loader {
    source: panelName + "-panel.qml"
    visible: modelData in enabledPanels
  }
}
```

<CommonMistake>

**Updating too frequently.** Refreshing CPU/memory/disk every 100ms wastes CPU showing the CPU usage. 1-2 second intervals are sufficient for monitoring. Use longer intervals (30-60s) for weather and disk space, which change slowly.

**Blocking the UI thread during data collection.** If your dashboard collects data by spawning shell commands (`ps aux`, `df -h`), the synchronous wait blocks the UI. Use `Qt.process()` with async callbacks and show loading indicators.

**Not handling removable drives.** Disk monitoring breaks if a USB drive is unplugged. Always handle null or undefined disk entries gracefully — show "No data" instead of a crash.

</CommonMistake>

## Under the Hood

A dashboard is a composition pattern: it aggregates data from multiple independent sources (CPU via `/proc/stat`, memory via `/proc/meminfo`, disk via `statfs()`, network via `/proc/net/dev`) and presents them in a unified view. Each data source is best accessed through the most efficient mechanism: D-Bus for systemd services, procfs for kernel stats, and Quickshell services for shell-level information.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "Process Killer" to the process list. Each row shows PID, name, and CPU%. Add a "Kill" button that sends SIGTERM (or SIGKILL for stubborn processes).
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a weather panel. Fetch weather data from `wttr.in` or OpenWeatherMap. Cache the response and refresh every 30 minutes. Show temperature, conditions, and 5-day forecast.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a dashboard plugin system. Allow users to write their own panels as separate QML files dropped into `~/.config/quickshell/dashboard/panels/`. Load them dynamically with `Loader` and register them in a configuration menu.
</ExerciseBlock>

<Recap :points="['Dashboard aggregates system metrics into a unified glanceable view', 'Use Timer with appropriate intervals (1-2s for CPU/memory, 30-60s for weather)', 'Each panel is an independent component that can be developed separately', 'Avoid blocking the UI thread during data collection']" next-chapter="/part-9-applications/notification-center" />

<!--
Sources verified for this chapter:
- https://man7.org/linux/man-pages/man5/proc.5.html — procfs documentation
- https://www.freedesktop.org/wiki/Software/systemd/ — systemd D-Bus API
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/ — PopupWindow type
-->
