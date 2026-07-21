---
title: "Top Bar"
description: "Building the top bar for a complete desktop shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PanelWindow', 'Row layout']" you-will-build="A feature-rich top bar with workspace indicator, clock, and system tray" />

## The Problem

The top bar is the centerpiece of every desktop shell. It shows workspaces, launcher, clock, system tray, and quick controls. Users interact with it constantly — it must be fast, reliable, and customizable.

## The Naive Approach

Put everything in one massive PanelWindow:

```qml
PanelWindow {
  anchors { top: true; left: true; right: true }
  height: 36
  // 200 lines of inline layout
}
```

This works for a personal config but isn't maintainable or reusable.

<MentalModel>

Think of the top bar as the dashboard of a car. The speedometer (clock), radio (system tray), navigation (workspace indicator), and climate control (quick toggles) are separate modules that share the same dashboard space. Each module is independently replaceable.

</MentalModel>

## The Idea

Build the top bar as a composition of independent widgets, each in its own file. The bar is just a `PanelWindow` with three sections (left, center, right) that import widget components.

## Let's Build It

```qml
// TopBar.qml
import Quickshell
import qs.widgets
import qs.bar

ShellRoot {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData
      anchors { top: true; left: true; right: true }
      implicitHeight: 36
      exclusionMode: ExclusionMode.Normal

      Row {
        anchors { fill: parent }
        spacing: 0

        // Left section: workspaces + launcher
        BarSection {
          width: parent.width * 0.3
          Row {
            spacing: 4
            WorkspaceIndicator {}
            LauncherButton {}
          }
        }

        // Center section: clock
        BarSection {
          width: parent.width * 0.4
          ClockWidget {}
        }

        // Right section: system tray + quick controls
        BarSection {
          width: parent.width * 0.3
          Row {
            layoutDirection: Qt.RightToLeft
            spacing: 4
            VolumePopupButton {}
            BatteryIcon {}
            SystemTray {}
          }
        }
      }
    }
  }
}
```

<BuildIt>

The top bar splits into three equal-width sections using a `Row`. Each section imports its widgets from separate files. The exclusion zone reserves space so maximized windows don't overlap.

</BuildIt>

## Let's Improve It

Add a slim mode for when the bar is in auto-hide state, and a hover-expand panel:

```qml
property bool expanded: true

SequentialAnimation {
  id: expandAnim
  NumberAnimation { target: root; property: "implicitHeight"; to: 36; duration: 150; easing.type: Easing.OutCubic }
}

SequentialAnimation {
  id: collapseAnim
  NumberAnimation { target: root; property: "implicitHeight"; to: 4; duration: 200; easing.type: Easing.InCubic }
}
```

<CommonMistake>

**Ignoring the exclusion zone.** Without `exclusionMode: ExclusionMode.Normal`, maximized windows render behind your bar, making the content inaccessible.

**Hardcoding colors.** The top bar should read from a `Theme` singleton, not use raw hex values. A user who changes the theme expects the bar to follow.

**No right-to-left support.** System tray icons and notifications should be right-aligned. Use `layoutDirection: Qt.RightToLeft` on the right section.

</CommonMistake>

## Under the Hood

The top bar is a `PanelWindow` at the `top` layer. Each section is a `BarSection` component that fills its portion of the width. The `exclusionZone` is set automatically based on `implicitHeight` and anchors. The compositor adjusts window positions to account for the reserved space.

## Exercises

<ExerciseBlock :difficulty="1">
Add a configuration option to show the top bar on all monitors vs only the primary monitor. Use `Variants` with a filtered screen model.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a "smart autohide" — the bar only hides when a window is maximized on the current workspace. When all windows are tiled/floating, the bar stays visible.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a modular top bar system where users can drag widgets between sections (left, center, right) via a settings popup. Persist the layout to `config.json`.
</ExerciseBlock>

<Recap :points="['Top bar is a PanelWindow with three Row sections: left, center, right', 'Each section is a reusable component that can be independently developed', 'Set exclusionMode to Normal for proper maximized window behavior', 'Use Theme singleton for colors, not raw hex values']" next-chapter="/part-11-complete-shell/keyboard-shortcuts" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/ — PanelWindow
- https://quickshell.org/docs/v0.3.0/guide/qml-language/ — QML Language
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Variants — Variants
-->
