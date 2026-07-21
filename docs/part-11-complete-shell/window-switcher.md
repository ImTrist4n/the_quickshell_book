---
title: "Window Switcher"
description: "Building an Alt+Tab-style window switcher with live previews"
---

<ChapterMeta reading-time="12 min" :difficulty="3" :prerequisites="['PopupWindow', 'ListView', 'Keyboard shortcuts']" you-will-build="A visual window switcher with thumbnail previews" />

## The Problem

Alt+Tab is the most-used shortcut in any desktop environment. A good window switcher shows all open windows with icons, titles, and live thumbnails. Users navigate with keyboard and select with Enter.

## The Naive Approach

List windows from `xdotool`:

```qml
Timer {
  interval: 500; running: true; repeat: true
  onTriggered: {
    var out = Qt.process(["xdotool", "search", "--onlyvisible", "--name", "."]).stdout
    // parse and display window list
  }
}
```

`xdotool` is X11-only and doesn't provide thumbnails. On Wayland, you need compositor-specific tools or the `wlr-foreign-toplevel-management` protocol.

<MentalModel>

Think of the window switcher like a Rolodex. Each card represents a window with its name, icon, and a photograph (thumbnail). You flip through cards with the keyboard and stop on the one you want. The Rolodex only appears when you need it — triggered by Alt+Tab.

</MentalModel>

## The Idea

Query open windows via compositor IPC, display them in a `PopupWindow` with keyboard navigation. Highlight the selected window. On enter, focus it.

## Let's Build It

```qml
// WindowService.qml
pragma Singleton
import Quickshell
import QtQml.Models

QtObject {
  id: ws

  property ListModel windows: ListModel {}

  function refresh() {
    Qt.process(["hyprctl", "clients", "-j"])
      .onStdout.connect(function(data) {
        try {
          var parsed = JSON.parse(data).filter(function(c) {
            return !c.hidden && c.mapped
          })
          windows.clear()
          parsed.forEach(function(w) {
            windows.append({
              address: w.address,
              title: w.title || "Untitled",
              klass: w.class,
              workspace: w.workspace.id,
              x: w.at[0], y: w.at[1],
              w: w.size[0], h: w.size[1]
            })
          })
        } catch (e) {}
      })
  }

  function focusWindow(address) {
    Qt.process(["hyprctl", "dispatch", "focuswindow", "address:" + address])
  }

  function closeWindow(address) {
    Qt.process(["hyprctl", "dispatch", "closewindow", "address:" + address])
  }
}
```

Window switcher popup:

```qml
// WindowSwitcher.qml
PopupWindow {
  id: root
  width: 500; height: 400
  visible: false

  property int selectedIndex: 0

  function open() {
    WindowService.refresh()
    selectedIndex = 0
    visible = true
    listView.forceActiveFocus()
  }

  Rectangle {
    anchors.fill: parent; radius: 10; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 12 }; spacing: 8

      Text {
        text: "Switch Window"
        font.pixelSize: 14; font.bold: true; color: "#cdd6f4"
      }

      ListView {
        id: listView
        width: parent.width; height: parent.height - 40
        model: WindowService.windows
        spacing: 4; clip: true

        delegate: Rectangle {
          required property var modelData
          required property int index

          width: parent.width; height: 52; radius: 6
          color: index === root.selectedIndex ? "#45475a" : "#313244"

          Row {
            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }; spacing: 12
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
              width: 40; height: 40; radius: 4; color: "#585b70"
              Text { text: modelData.klass.charAt(0).toUpperCase(); anchors.centerIn: parent; color: "white"; font.pixelSize: 18 }
            }

            Column { anchors.verticalCenter: parent.verticalCenter; spacing: 2
              Text { text: modelData.title; font.pixelSize: 13; color: "#cdd6f4"; elide: Text.ElideRight; width: 360 }
              Text { text: modelData.klass; font.pixelSize: 11; color: "#6c7086" }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              root.selectedIndex = index
              root.selectCurrent()
            }
          }
        }

        highlightMoveDuration: 100
        ScrollBar.vertical: ScrollBar { active: true }

        Keys.onPressed: function(event) {
          switch (event.key) {
            case Qt.Key_Tab:
            case Qt.Key_Down:
              selectedIndex = Math.min(selectedIndex + 1, WindowService.windows.count - 1)
              listView.currentIndex = selectedIndex
              break
            case Qt.Key_Up:
              selectedIndex = Math.max(selectedIndex - 1, 0)
              listView.currentIndex = selectedIndex
              break
            case Qt.Key_Return:
            case Qt.Key_Space:
              root.selectCurrent()
              break
            case Qt.Key_Escape:
              root.visible = false
              break
          }
        }
      }
    }
  }

  function selectCurrent() {
    var w = WindowService.windows.get(selectedIndex)
    if (w) {
      WindowService.focusWindow(w.address)
    }
    visible = false
  }
}
```

<BuildIt>

The window service fetches all open windows via `hyprctl clients -j`. The switcher popup renders them as a list with app icon (first letter of class), title, and app class. Arrow keys navigate, Enter selects, Escape dismisses. Alt+Tab cycles forward, Alt+Shift+Tab cycles backward.

</BuildIt>

## Let's Improve It

Add live window thumbnails via `hyprctl`:

```qml
Image {
  source: "file:///tmp/hypr/" + modelData.address + ".png"
  fillMode: Image.PreserveAspectFit
  asynchronous: true
}
```

(Requires enabling thumbnails in Hyprland config.)

<CommonMistake>

**Showing windows from other workspaces.** Some users want "all windows" in the switcher, others want "current workspace only". Make this configurable: `config.switcherScope: "all" | "current"`.

**Not updating the window list.** If a window opens or closes while the switcher is open, the list should update. Call `WindowService.refresh()` on a short timer while the popup is visible.

**Keyboard focus getting stuck.** Ensure the popup grabs keyboard focus when opened and releases it when closed. Missing this prevents Alt+Tab from working after the switcher is dismissed.

</CommonMistake>

## Under the Hood

The `wlr-foreign-toplevel-management` protocol (supported by Sway, Hyprland, River, etc.) provides a compositor-agnostic way to enumerate windows and receive open/close/state-change events. Using this protocol eliminates the need for compositor-specific commands like `hyprctl`. Quickshell may offer a wrapper for this protocol in future versions.

## Exercises

<ExerciseBlock :difficulty="1">
Add window search. When the switcher opens, the user can start typing and the list filters to windows whose title or class matches. Highlight the best match.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Support mouse selection — clicking a window item immediately focuses it and closes the switcher. Add a "Close" button (X icon) on hover that calls `closeWindow`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a "recently used ordering" (Alt+Tab MRU). Track window focus events in `WindowService` and sort the switcher list by last-focused time. The last-focused window should be pre-selected when the switcher opens.
</ExerciseBlock>

<Recap :points="['Use compositor IPC (hyprctl) or wlr-foreign-toplevel-management for window enumeration', 'Provide keyboard navigation: arrows, Enter, Escape', 'Support filtering by current workspace vs all workspaces', 'Update the window list while the switcher is open']" next-chapter="/part-11-complete-shell/session-management" />

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC
- https://wayland.app/protocols/wlr-foreign-toplevel-management-unstable-v1 — wlr-foreign-toplevel-management
- https://doc.qt.io/qt-6/qml-qtquick-controls-listview.html — ListView
-->
