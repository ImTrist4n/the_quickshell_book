---
title: "Dashboard"
description: "A dashboard view for the complete desktop shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'GridView']" you-will-build="A full-screen dashboard with system info, calendar, and quick actions" />

## The Problem

Users want a glanceable overview of everything — time, calendar, weather, system stats, recent notifications, and quick actions. Scattering these across separate popups is inefficient.

## The Naive Approach

Open multiple popups:

```qml
// User presses Super+I for system info
// User presses Super+N for notifications
// User presses Super+C for calendar
```

Three separate popups, three separate keybinds, three separate UI contexts.

<MentalModel>

Think of the dashboard as mission control. One big screen shows telemetry (CPU, RAM, disk), communications (notifications, calendar), and environment (weather, time). Everything the commander needs is visible at a glance.

</MentalModel>

## The Idea

Create a large `PopupWindow` that fills most of the screen. Divide it into panels: system stats, calendar, weather, recent notifications, and quick action buttons. Each panel is a separate QML component.

## Let's Build It

```qml
// Dashboard.qml
PopupWindow {
  id: dash
  width: Quickshell.screens[0].geometry.width * 0.7
  height: Quickshell.screens[0].geometry.height * 0.7
  visible: false
  x: (Quickshell.screens[0].geometry.width - width) / 2
  y: (Quickshell.screens[0].geometry.height - height) / 2

  Rectangle {
    anchors.fill: parent; radius: 12; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 24 }; spacing: 20

      // Header: Greeting + date
      Row {
        width: parent.width
        Text { text: "Good " + (new Date().getHours() < 12 ? "Morning" : new Date().getHours() < 18 ? "Afternoon" : "Evening"); font.pixelSize: 28; font.bold: true; color: "#cdd6f4" }
        Item { width: parent.width - 300; height: 1 }
        Text { text: new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat); font.pixelSize: 14; color: "#a6adc8"; anchors.verticalCenter: parent.verticalCenter }
      }

      // Two-column layout
      Row {
        width: parent.width; spacing: 20

        // Left column: System stats
        Column { spacing: 12; width: parent.width * 0.5

          // CPU
          DashboardPanel { title: "CPU"
            Row { spacing: 8
              Rectangle { width: 120; height: 8; radius: 4; color: "#313244"
                Rectangle { width: parent.width * (CpuService.usagePercent / 100); height: 8; radius: 4; color: "#89b4fa" }
              }
              Text { text: CpuService.usagePercent.toFixed(1) + "%"; color: "#cdd6f4"; font.pixelSize: 12 }
            }
          }

          // RAM
          DashboardPanel { title: "Memory"
            Row { spacing: 8
              Rectangle { width: 120; height: 8; radius: 4; color: "#313244"
                Rectangle { width: parent.width * (MemoryService.usedPercent / 100); height: 8; radius: 4; color: "#a6e3a1" }
              }
              Text { text: MemoryService.usedPercent.toFixed(1) + "%"; color: "#cdd6f4"; font.pixelSize: 12 }
            }
          }

          // Disk
          DashboardPanel { title: "Disk"
            Row { spacing: 8
              Rectangle { width: 120; height: 8; radius: 4; color: "#313244"
                Rectangle { width: parent.width * 0.6; height: 8; radius: 4; color: "#fab387" }
              }
              Text { text: "60%"; color: "#cdd6f4"; font.pixelSize: 12 }
            }
          }

          // Recent notifications
          DashboardPanel { title: "Recent Notifications"
            Text { text: "No new notifications"; color: "#6c7086"; font.pixelSize: 11 }
          }
        }

        // Right column: Calendar + Weather + Quick actions
        Column { spacing: 12; width: parent.width * 0.5

          // Calendar
          DashboardPanel { title: "Calendar"
            Rectangle { width: parent.width; height: 120; color: "#313244"; radius: 4
              Text { anchors.centerIn: parent; text: "📅 Calendar widget"; color: "#6c7086"; font.pixelSize: 12 }
            }
          }

          // Weather
          DashboardPanel { title: "Weather"
            Row { spacing: 8
              Text { text: "☀️"; font.pixelSize: 24 }
              Column { spacing: 2
                Text { text: "22°C"; font.pixelSize: 18; font.bold: true; color: "#cdd6f4" }
                Text { text: "Sunny | Humidity: 45%"; font.pixelSize: 11; color: "#a6adc8" }
              }
            }
          }

          // Quick actions
          DashboardPanel { title: "Quick Actions"
            Row { spacing: 8
              QuickActionButton { text: "Screenshot"; icon: "📷"; onClicked: Qt.process(["hyprctl", "dispatch", "screenshot"]) }
              QuickActionButton { text: "Bluetooth"; icon: "📶"; onClicked: BluetoothService.togglePower() }
              QuickActionButton { text: "Lock"; icon: "🔒"; onClicked: lockScreen.show() }
              QuickActionButton { text: "Sleep"; icon: "💤"; onClicked: Qt.process(["systemctl", "suspend"]) }
            }
          }
        }
      }
    }
  }
}
```

Helper components:

```qml
// DashboardPanel.qml
Column {
  property string title: ""
  spacing: 8
  Text { text: title; font.pixelSize: 13; font.bold: true; color: "#cdd6f4" }
  // Children here
}

// QuickActionButton.qml
Rectangle {
  property string text: ""
  property string icon: ""
  signal clicked()
  width: 70; height: 60; radius: 8; color: "#313244"
  Column {
    anchors.centerIn: parent; spacing: 4
    Text { text: icon; font.pixelSize: 20; anchors.horizontalCenter: parent.horizontalCenter }
    Text { text: text; color: "#cdd6f4"; font.pixelSize: 9; anchors.horizontalCenter: parent.horizontalCenter }
  }
  MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: parent.clicked() }
}
```

<BuildIt>

The dashboard fills 70% of the screen with a two-column layout. Left column shows system stats (CPU, RAM, Disk) and recent notifications. Right column shows calendar, weather, and quick action buttons.

</BuildIt>

## Let's Improve It

Add a search bar at the top that acts as an application launcher, and make panels collapsible:

```qml
Rectangle {
  width: parent.width; height: 36; radius: 6; color: "#313244"
  TextInput {
    anchors { fill: parent; margins: 12 }
    font.pixelSize: 14; color: "#cdd6f4"
    placeholderText: "Search apps, settings, or files..."
    onAccepted: { /* launch or search */ }
  }
}
```

<CommonMistake>

**Too much information.** A dashboard should show highlights, not every detail. CPU + RAM + Disk is sufficient for system stats. Adding GPU temp, fan speed, network throughput, and 20 other items creates noise.

**Not updating dynamically.** Dashboard panels should bind to service properties so they update automatically when data changes. Avoid one-shot timers that refresh everything — use reactive bindings.

**Overriding the entire screen.** A dashboard should feel like an overlay, not a separate desktop. Use partial screen coverage (70% width/height) with a semi-transparent background.

</CommonMistake>

## Under the Hood

The dashboard is a `PopupWindow` positioned at the center of the primary screen. Each panel is a separate QML component that imports the appropriate service. The dashboard doesn't poll anything — it reads from service singletons that manage their own update schedules.

## Exercises

<ExerciseBlock :difficulty="1">
Add per-panel refresh timers. The weather panel refreshes every 10 minutes, the CPU panel updates every second, the calendar panel updates once a day. Each panel manages its own update schedule independently.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a "widget picker" — users can add/remove/rearrange panels on the dashboard. Store the layout configuration in `settings.json`. Drag panel headers to reorder.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a full-screen dashboard mode. When activated (Super+D), the dashboard expands to cover the entire screen, and all other windows are minimized. This creates a "mission control" experience. Restoring de-minimizes the windows.
</ExerciseBlock>

<Recap :points="['Dashboard provides glanceable overview of system, calendar, and weather', 'Two-column layout with reactive panels reading from service singletons', 'Quick action buttons for common tasks', 'Partial screen overlay — 70% width/height centered']" next-chapter="/part-12-advanced/custom-modules" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/ — PopupWindow
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.screens
- https://doc.qt.io/qt-6/qml-qtquick-gridview.html — GridView
-->
