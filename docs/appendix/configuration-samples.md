---
title: "Configuration Samples"
description: "Complete, ready-to-use configuration examples for common setups"
---

# Configuration Samples

## Minimal Panel

A minimal panel with clock and system tray, suitable as a starting point:

```qml
// shell.qml
import Quickshell

ShellRoot {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; left: true; right: true }
      implicitHeight: 36

      Row {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        spacing: 8
        Text { anchors.verticalCenter: parent.verticalCenter; text: ""; color: "#cdd6f4"; font.pixelSize: 14 }
      }

      Item { width: 1; height: 1 }

      Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 12

        Text {
          id: clockDisplay
          anchors.verticalCenter: parent.verticalCenter
          text: SystemClock.timeString
          color: "#cdd6f4"; font.pixelSize: 13

          SystemClock { id: clock; precision: SystemClock.Minutes }
        }
      }
    }
  }
}
```

## Panel with All Widgets

A complete panel with workspace indicator, launcher button, system tray, and clock:

```qml
// shell.qml
import Quickshell

ShellRoot {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; left: true; right: true }
      implicitHeight: 36

      Row {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        spacing: 4
        Widgets.WorkspaceIndicator {}
        Widgets.LauncherButton {}
      }

      Row {
        anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
        spacing: 8
        Widgets.SystemTray {}
        Widgets.BatteryIcon {}
        Widgets.VolumeIcon {}
        Widgets.ClockWidget {}
      }
    }
  }
}
```

Requires `widgets/` directory with the individual widget files.

## Dark Theme (Catppuccin Mocha)

```qml
// config.qml (for Theme singleton)
pragma Singleton
import Quickshell

QtObject {
  readonly property color bg: "#1e1e2e"
  readonly property color bgAlt: "#181825"
  readonly property color fg: "#cdd6f4"
  readonly property color fgAlt: "#a6adc8"
  readonly property color accent: "#89b4fa"
  readonly property color surface: "#313244"
  readonly property color error: "#f38ba8"
  readonly property color warning: "#fab387"
  readonly property color success: "#a6e3a1"
}
```

## Light Theme (Catppuccin Latte)

```qml
// config.qml (for Theme singleton)
pragma Singleton
import Quickshell

QtObject {
  readonly property color bg: "#eff1f5"
  readonly property color bgAlt: "#e6e9ef"
  readonly property color fg: "#4c4f69"
  readonly property color fgAlt: "#5c5f77"
  readonly property color accent: "#1e66f5"
  readonly property color surface: "#ccd0da"
  readonly property color error: "#d20f39"
  readonly property color warning: "#fe640b"
  readonly property color success: "#40a02b"
}
```

## Popup-Mounted App Launcher

```qml
// AppLauncher.qml
PopupWindow {
  id: launcher
  width: 400; height: 500
  anchor.window: panel
  anchor.rect.x: parentWindow.width / 2 - width / 2
  anchor.rect.y: parentWindow.height
  visible: false

  property string searchText: ""
  property var apps: []

  Component.onCompleted: {
    Qt.process(["bash", "-c", "ls /usr/share/applications/*.desktop"])
      .onStdout.connect(function(data) {
        apps = data.trim().split("\n").map(function(path) {
          return path.split("/").pop().replace(".desktop", "")
        })
      })
  }

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 12 }; spacing: 8

      Rectangle {
        width: parent.width; height: 36; radius: 6; color: "#313244"
        TextInput {
          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          font.pixelSize: 14; color: "#cdd6f4"
          placeholderText: "Search applications..."
          onTextChanged: launcher.searchText = text
        }
      }

      ListView {
        width: parent.width; height: parent.height - 60
        model: apps.filter(function(a) {
          return a.toLowerCase().includes(launcher.searchText.toLowerCase())
        })
        spacing: 2; clip: true
        delegate: Rectangle {
          required property var modelData
          width: parent.width; height: 36; radius: 4; color: "#313244"

          Text {
            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
            text: modelData; color: "#cdd6f4"; font.pixelSize: 13
          }
          MouseArea {
            anchors.fill: parent
            onClicked: {
              Qt.execDetached({ command: modelData })
              launcher.visible = false
            }
          }
        }
      }
    }
  }
}
```

<Recap :points="['Start with the minimal panel template and add widgets incrementally', 'Use Theme singletons to switch between dark and light color schemes', 'App launchers read .desktop files and filter with a TextInput', 'Keep widget files in a widgets/ directory for clean organization']" next-chapter="/appendix/further-reading" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/introduction/ — Introduction guide
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/ — PanelWindow
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/ — PopupWindow
-->
