---
title: "Workspaces"
description: "Tracking and managing Hyprland workspaces from Quickshell"
---

# Workspaces

<ChapterMeta title="Workspaces" icon="desktop" />

## Problem

Hyprland organizes windows into virtual workspaces. Your shell needs to know which workspaces exist, which is active, and what windows they contain. Without this, you cannot build a workspace switcher, show workspace indicators, or implement scratchpad behavior.

## Naive Approach

Poll `hyprctl workspaces` every second with a Timer. This works but wastes CPU, introduces latency, and misses rapid changes. The output is plain text you must parse every cycle.

## MentalModel

<MentalModel title="Workspace as a Collection">

A workspace is a numbered container mapped to a virtual desktop. Hyprland maintains a list of these containers internally. The `Hyprland` singleton in Quickshell mirrors this list as a reactive model. When a workspace is created, destroyed, or focused, Hyprland emits an event and the model updates automatically.

Think of it like a `ListView` model — it has `count`, individual items, and notifies listeners on change.

</MentalModel>

## Idea

Quickshell's `Hyprland` singleton provides `workspaces` — a model of `HyprlandWorkspace` objects. Each object exposes `id`, `name`, `monitor`, `windows`, `isActive`, and more. You bind directly to these properties without polling.

## Build It

```qml
import Quickshell
import Quickshell.Hyprland

Column {
  Repeater {
    model: Hyprland.workspaces

    delegate: Rectangle {
      width: 40
      height: 40
      color: modelData.isActive ? "#5294e2" : "#333333"

      Text {
        anchors.centerIn: parent
        text: modelData.id
        color: "#ffffff"
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("workspace", modelData.id)
      }
    }
  }
}
```

## BuildIt Breakdown

`Hyprland.workspaces` is a live model — when a workspace is added or removed, the `Repeater` updates automatically. `modelData` gives each delegate its corresponding `HyprlandWorkspace`. The `isActive` property determines the active workspace. `Hyprland.dispatch()` sends a Hyprland socket command — same as `hyprctl dispatch workspace 5`.

## Improve It

Filter out empty workspaces by binding `visible: modelData.windows > 0`. Sort workspaces using a `SortProxyModel`. Add window count badges. Animate the active indicator with a `NumberAnimation` on `color`.

## CommonMistake

<CommonMistake>

Assuming `workspaces` returns a flat list you can index by ID. Workspace IDs may be non-contiguous (you can skip from workspace 1 to 5). Always treat the model as an ordered list, not an array with ID-based indices.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Hyprland exposes a UNIX socket at `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock`. The `Hyprland` singleton opens this socket and listens for `workspace` events using a `QSocketNotifier`. When an event arrives, it issues `hyprctl workspaces -j` once and updates the model. This is far more efficient than periodic polling because the OS wakes your process only when data changes.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Create a vertical workspace bar that highlights the active workspace and switches on click.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Add a window counter badge to each workspace indicator. Show the count of windows per workspace.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Build a workspace preview — on hover, show miniature window thumbnails for each workspace using `hyprctl clients -j` parsed into a custom model.

</ExerciseBlock>

## Recap

<Recap to="/part-7-hyprland/active-window-and-monitor">

Workspaces are the first layer of Hyprland integration. Next, we track the **active window and monitor** — the second piece of the workspace-awareness puzzle.

</Recap>

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC documentation
- https://wiki.hyprland.org/Configuring/Workspace-rules/ — workspace management
-->
