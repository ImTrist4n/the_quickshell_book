---
title: "Multi-Monitor"
description: "Handling multiple monitors with per-screen shell instances"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PanelWindow', 'Variants with model']" you-will-learn="How to create shell UI that adapts to multiple monitors" />

## The Problem

Most desktop setups have multiple monitors. Your shell must appear on every screen, adapt to different resolutions, and handle screens being added or removed without crashing.

## The Naive Approach

Hardcode one panel:

```qml
PanelWindow {
  anchors { top: true; left: true; right: true }
  height: 36
}
```

This creates one panel on one screen. Users with multiple monitors see a panel on only one display. They have no clock, no system tray, no widgets on their secondary monitors.

<MentalModel>

Think of multi-monitor support like a TV broadcast. Each TV (monitor) receives the same channel (shell instance). But each TV might be a different model (different resolution, orientation). Your shell should broadcast a signal that each TV can tune in and display correctly.

</MentalModel>

## The Idea

Use `Variants` with `Quickshell.screens` as the model. Quickshell creates one instance of your window per connected screen. Each instance receives the screen's properties (resolution, scale, name) so it can adapt.

## Let's Build It

```qml
// shell.qml
import Quickshell

ShellRoot {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 36

      Row {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter }
        spacing: 8
        Text { text: screen.name; color: "#6c7086"; font.pixelSize: 11 }
        // Workspace indicators, app launcher
      }

      Item { width: 1; height: 1 }

      Row {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        spacing: 8
        ClockWidget {}
        SystemTray {}
        BatteryWidget {}
      }
    }
  }
}
```

<BuildIt>

`Variants` with `Quickshell.screens` creates one `PanelWindow` per connected screen. The `screen` property links each window to its display. When a monitor is plugged in, Quickshell creates a new instance. When unplugged, it destroys the instance.

</BuildIt>

## Per-Screen Configuration

Different monitors may need different widgets or layouts:

```qml
PanelWindow {
  property bool isPrimary: screen === Quickshell.screens[0]

  Row {
    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
    spacing: 8

    // Only show workspace indicator on primary monitor
    Loader {
      active: isPrimary
      source: "WorkspaceIndicator.qml"
    }
  }

  Row {
    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
    spacing: 8

    ClockWidget {}
    SystemTray {}

    // Only show battery on primary (or on laptop screen)
    Loader {
      active: isPrimary || screen.name.includes("eDP")
      source: "BatteryWidget.qml"
    }
  }
}
```

## Handling Different Resolutions

Use proportional sizing and anchors instead of fixed pixel values:

```qml
PanelWindow {
  implicitHeight: Math.round(screen.geometry.height * 0.02)  // 2% of screen height

  Row {
    spacing: screen.geometry.width * 0.005  // 0.5% of screen width
  }
}
```

## Popup Positioning

Popups need to appear on the correct screen:

```qml
PopupWindow {
  anchor.window: panelWindowOnCurrentScreen

  // The popup will automatically appear on the same screen as its anchor
}
```

## Hot-Plug Handling

When a monitor is connected or disconnected, Quickshell automatically updates `Quickshell.screens`. The `Variants` model adds or removes window instances. Components that read screen dimensions via bindings re-evaluate automatically.

## Common Mistakes

**Assuming a single screen.** Never use `screen: Quickshell.screens[0]` unless you explicitly mean "show on primary only." Always iterate with `Variants { model: Quickshell.screens }`.

**Fixed pixel widths.** `width: 1920` breaks on a 1366x768 laptop screen. Use proportional values, anchors, or `implicitWidth`.

**Ignoring scale factor.** A 4K monitor at 200% scale reports `screen.geometry.width` as the logical (scaled) width, not the physical pixel width. QML rendering handles the scaling — trust the logical values.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "primary-only" mode in your config. When enabled, the panel with system tray and battery appears only on the primary monitor. Secondary monitors get a minimal panel with just clock and workspaces.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement dynamic popup positioning — when a popup opens on a secondary monitor, ensure it doesn't overflow off-screen. Use `screen.availableGeometry` to calculate safe bounds.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a monitor configuration popup. Show all connected monitors with their names, resolutions, and current layout. Allow dragging to rearrange monitor positions (stored via `wlr-randr` or `kscreen`).
</ExerciseBlock>

<Recap :points="['Use Variants { model: Quickshell.screens } for per-screen instances', 'Distinguish primary vs secondary monitors for conditional widget visibility', 'Use proportional values and anchors instead of fixed pixel sizes', 'Quickshell handles hot-plug addition/removal automatically']" next-chapter="/part-11-complete-shell/workspace-indicator" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Variants — Variants type
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.screens property
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/ — PanelWindow
-->
