---
title: "Project: Complete Workspace Switcher"
description: "Build a complete workspace switcher widget for Hyprland"
---

# Project: Complete Workspace Switcher

<ChapterMeta title="Project: Complete Workspace Switcher" icon="project" />

## Problem

Build a production-quality workspace switcher widget. It must show all workspaces, highlight the active one, display window icons, support click-to-switch, and integrate with multiple monitors. It should feel responsive and modern.

## Naive Approach

A simple `Repeater` with colored rectangles. No window previews. No per-monitor awareness. No animations. This barely qualifies as a switcher.

## MentalModel

<MentalModel title="Multi-Layer Visualization">

A workspace switcher visualizes three layers: workspaces (numbered containers), windows (icons inside each workspace), and focus (the active indicator). Each layer is a model driving a delegate. Composition of models creates the full picture.

</MentalModel>

## Idea

Combine `Hyprland.workspaces` with `Hyprland.clientList` (from the Hyprland singleton, a model of all windows). Group clients by workspace ID. Display workspaces as horizontal items, each containing its windows as small icons. Animate transitions.

## Build It

```qml
import Quickshell
import Quickshell.Hyprland

ListView {
  orientation: ListView.Horizontal
  model: Hyprland.workspaces
  spacing: 4

  delegate: Item {
    width: 60
    height: 40

    required property var modelData

    Rectangle {
      anchors.fill: parent
      radius: 6
      color: modelData.isActive ? "#5294e2" : "#2a2a2a"
      opacity: modelData.windows > 0 ? 1.0 : 0.5

      Behavior on color {
        ColorAnimation { duration: 150 }
      }

      Column {
        anchors.centerIn: parent
        spacing: 2

        Text {
          anchors.horizontalCenter: parent.horizontalCenter
          text: modelData.id
          color: "#ffffff"
          font.bold: true
        }

        Row {
          anchors.horizontalCenter: parent.horizontalCenter
          spacing: 2
          Repeater {
            model: windowIconsFor(modelData.id)
            delegate: Rectangle {
              width: 8
              height: 8
              radius: 2
              color: "#88ffffff"
            }
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: Hyprland.dispatch("workspace", modelData.id)
    }

    function windowIconsFor(workspaceId: int): var {
      var icons = []
      for (var i = 0; i < Hyprland.clientList.length; i++) {
        if (Hyprland.clientList.get(i).workspace.id === workspaceId) {
          icons.push(Hyprland.clientList.get(i))
        }
      }
      return icons
    }
  }
}
```

## BuildIt Breakdown

The `ListView` scrolls horizontally through workspaces. Each delegate shows the workspace number and dot indicators for windows. The `windowIconsFor` function filters `clientList` by workspace. Clicking dispatches `workspace` to switch. The `ColorAnimation` on `Behavior` gives smooth transitions when the active workspace changes.

## Improve It

Use `Hyprland.clientModel` (a proper QML model) instead of iterating `clientList`. Show actual window icons from `.desktop` files. Add drag-and-drop reordering. Show workspace names instead of numbers. Add a popup preview on hover showing client titles.

## CommonMistake

<CommonMistake>

Calling `Hyprland.clientList` in a tight loop inside a delegate. `clientList` is a JS array — accessing it repeatedly in a delegate property binding triggers re-evaluation on every change. Use a `QML model` or cache the result instead.

</CommonMistake>

## Under the Hood

<UnderTheHood>

`Hyprland.clientList` is rebuilt from scratch each time a window opens, closes, or moves. It is based on `hyprctl clients -j` output. For production shells, consider maintaining your own incremental model using `socketEvent` (`openwindow` / `closewindow`) to avoid full-list rebuilds.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Add the workspace switcher to your top bar with basic active highlighting.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Implement per-monitor workspace lists that only show workspaces on the current monitor.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Build a workspace overview (like GNOME Activities) that shows tiled window previews when you hover over a workspace indicator.

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/color-systems">

Part 7 complete. You now control workspaces, windows, monitors, events, and scratchpads in Hyprland. Next, we shift to **Part VIII — Design System**, starting with **color systems** that make your shell beautiful.

</Recap>

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC documentation
- https://wiki.hyprland.org/Configuring/Workspace-rules/ — workspace management
-->
