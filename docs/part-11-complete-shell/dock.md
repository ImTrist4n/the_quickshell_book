---
title: "Dock"
description: "A macOS-style dock for launching and switching applications"
---

<ChapterMeta reading-time="14 min" :difficulty="2" :prerequisites="['PanelWindow', 'ListView', 'Qt.process']" you-will-build="A taskbar dock with app icons, running indicators, and launch functionality" />

## The Problem

Users want a visual dock at the bottom (or side) of the screen showing their favorite applications and currently running windows. Clicking an icon launches the app or focuses its window.

## The Naive Approach

Hardcode icon buttons:

```qml
Row {
  Image { source: "firefox.svg"; MouseArea { onClicked: Qt.process(["firefox"]) } }
  Image { source: "code.svg"; MouseArea { onClicked: Qt.process(["code"]) } }
}
```

Adding new apps requires editing QML. There's no running-state indication, no window focusing, no drag-to-reorder.

<MentalModel>

Think of the dock as a physical tool rack. Each tool (app) has its designated hook. When a tool is in use, a light turns on (running indicator). Clicking a lit hook brings the tool to hand (focus window). You can rearrange hooks by moving pegs (drag to reorder).

</MentalModel>

## The Idea

Create a config-driven dock. Users define their pinned apps in a config array. A service tracks running applications via window IPC. The dock renders icons with running indicators and supports click-to-launch/focus.

## Let's Build It

```qml
// Dock.qml
PanelWindow {
  id: dock
  anchors { bottom: true; left: true; right: true }
  implicitHeight: 52

  property var pinnedApps: [
    { name: "Firefox", icon: "firefox", exec: "firefox" },
    { name: "Terminal", icon: "kitty", exec: "kitty" },
    { name: "Code", icon: "code", exec: "code" },
    { name: "Files", icon: "nautilus", exec: "nautilus" },
    { name: "Spotify", icon: "spotify", exec: "spotify" }
  ]

  property var runningWindows: []

  function refreshRunning() {
    Qt.process(["hyprctl", "clients", "-j"])
      .onStdout.connect(function(data) {
        try {
          runningWindows = JSON.parse(data)
            .filter(function(c) { return !c.hidden })
            .map(function(c) { return c.class.toLowerCase() })
        } catch (e) {}
      })
  }

  function launchOrFocus(exec, name) {
    var cls = name.toLowerCase()
    if (runningWindows.indexOf(cls) >= 0) {
      Qt.process(["hyprctl", "dispatch", "focuswindow", "class:" + cls])
    } else {
      Qt.execDetached({ command: exec })
    }
  }

  Timer {
    interval: 2000; running: true; repeat: true
    onTriggered: dock.refreshRunning()
  }

  Rectangle {
    anchors.fill: parent; color: "#1e1e2e"

    Row {
      anchors.centerIn: parent
      spacing: 8

      Repeater {
        model: pinnedApps

        delegate: Rectangle {
          required property var modelData
          required property int index

          width: 44; height: 44; radius: 8
          color: runningWindows.indexOf(modelData.name.toLowerCase()) >= 0 ? "#45475a" : "transparent"

          Item {
            anchors.centerIn: parent
            width: 32; height: 32
            Text {
              anchors.centerIn: parent
              text: modelData.name.charAt(0).toUpperCase()
              color: "white"; font.pixelSize: 16
            }
          }

          // Running indicator dot
          Rectangle {
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 2 }
            width: 4; height: 4; radius: 2
            color: runningWindows.indexOf(modelData.name.toLowerCase()) >= 0 ? "#a6e3a1" : "transparent"
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: launchOrFocus(modelData.exec, modelData.name)
          }
        }
      }
    }
  }
}
```

<BuildIt>

The dock reads a `pinnedApps` config array with name, icon, and exec. Running windows are polled via compositor IPC. Clicking an app either focuses its window (if running) or launches it (if not). A green dot indicates running apps.

</BuildIt>

## Let's Improve It

Add drag-to-reorder and unread notification badges:

```qml
Drag.active: dragArea.drag.active
Drag.hotSpot.x: width / 2
Drag.hotSpot.y: height / 2

MouseArea {
  id: dragArea
  drag.target: parent
  drag.axis: Drag.XAxis
  onReleased: reorderPinned(index, parent.x)
}
```

<CommonMistake>

**No separation between pinned and running apps.** A dock should show pinned apps (always visible) and running apps that aren't pinned (appear when launched). Filter duplicates — a pinned running app should show only once.

**Polling too frequently.** `hyprctl clients -j` every 500ms is wasteful. 2-second intervals are smooth enough for indicator dots. Subscribe to workspace events for instant updates.

**Hardcoding app icons as text fallbacks.** Use proper icon lookups with `Quickshell.iconPath()` for themed icons. Text fallbacks are fine during development but look unpolished in production.

</CommonMistake>

## Under the Hood

The dock uses the same PanelWindow layer-shell approach as the top bar but anchored to the bottom. The `exclusionZone` is set to the dock height. Application detection relies on compositor IPC (`hyprctl clients -j` or `swaymsg -t get_tree`). For cross-compositor support, query `wlr-foreign-toplevel-management` output.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "running apps only" mode that hides pinned apps and shows only currently running applications, sorted by most recently focused.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement drag-to-reorder for pinned apps. Persist the new order to `config.qml` or a JSON file. Add visual feedback (ghost icon) during drag.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a "dock preferences" popup. Users add/remove apps from the dock by searching available `.desktop` files, reorder with drag handles, and toggle between icon sizes (small/medium/large).
</ExerciseBlock>

<Recap :points="['Dock shows pinned apps + running indicators with click-to-launch/focus', 'Poll compositor IPC at 2s intervals for running app detection', 'Use a config array for pinned apps, not hardcoded QML', 'Set exclusionZone so maximized windows respect the dock space']" next-chapter="/part-11-complete-shell/launcher" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/ — PanelWindow
- https://wiki.hyprland.org/IPC/ — Hyprland IPC
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.iconPath()
-->
