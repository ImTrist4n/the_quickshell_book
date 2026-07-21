---
title: "Scratchpads"
description: "Implementing scratchpad/toggle windows in Hyprland from Quickshell"
---

# Scratchpads

<ChapterMeta title="Scratchpads" icon="window-maximize" />

## Problem

A scratchpad is a window that toggles visibility on a keybind — like a terminal you summon and dismiss. Hyprland has `hyprctl dispatch togglefloating` and `hyprctl dispatch movetoworkspace special`, but coordinating them from QML requires tracking window state.

## Naive Approach

Run `hyprctl dispatch exec kitty --class scratchpad` each time, spawning a new terminal. This litters your workspace with duplicate windows. The alternative — hardcoding `hyprctl dispatch togglespecialworkspace` — only works if you remember to send the window to the special workspace first.

## MentalModel

<MentalModel title="Toggle as State Machine">

A scratchpad has two states: visible and hidden. When hidden, the window lives on the special workspace (scratchpad space). When visible, it is moved to the current workspace. Toggling switches between these states. Your QML code tracks whether the window has been created at all and whether it is currently shown.

</MentalModel>

## Idea

Use `Hyprland.dispatch()` to send the window to the special workspace on first launch, then toggle `togglespecialworkspace` to show/hide it. Track launch state in a `property bool scratchpadCreated` to avoid spawning duplicates.

## Build It

```qml
import Quickshell
import Quickshell.Hyprland

Item {
  property bool scratchpadCreated: false
  property bool scratchpadVisible: false

  function toggleScratchpad() {
    if (!scratchpadCreated) {
      Hyprland.dispatch("exec", "kitty --class scratch-terminal")
      scratchpadCreated = true
      // Wait for window to appear, then move to special
      intervalTimer.start()
    } else {
      Hyprland.dispatch("togglespecialworkspace", "scratchpad")
      scratchpadVisible = !scratchpadVisible
    }
  }

  Timer {
    id: intervalTimer
    interval: 500
    repeat: false
    onTriggered: {
      Hyprland.dispatch("movetoworkspace", "special:scratchpad")
      scratchpadVisible = true
    }
  }

  Shortcut {
    sequence: "Ctrl+grave"
    onActivated: toggleScratchpad()
  }
}
```

## BuildIt Breakdown

The first invocation spawns a terminal with a specific class. A Timer waits for the window to map, then moves it to the `special:scratchpad` workspace. Subsequent calls toggle `special:scratchpad` — Hyprland moves it to the current workspace when shown and returns it to special when hidden. The `scratchpadVisible` flag lets UI elements react to the scratchpad state.

## Improve It

Use `Hyprland.activeWindow` to detect when the scratchpad is focused and auto-hide it on focus loss. Support multiple named scratchpads with different classes. Animate opacity on toggle using `Behavior on opacity`.

## CommonMistake

<CommonMistake>

Calling `togglespecialworkspace` before the window exists. Hyprland's special workspace must have at least one window for the toggle to work. Always ensure the window is created and moved to special before the first toggle.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Scratchpads exploit Hyprland's special workspace — a hidden workspace that is not shown in the regular workspace list. `togglespecialworkspace` moves the active special workspace window to the current workspace and focuses it. Calling it again moves it back. The `special` workspace type is a Hyprland-specific feature not available in all wlroots-based compositors.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Build a single-toggle scratchpad terminal bound to `Super+grave`.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Add a visual indicator showing whether the scratchpad is currently visible.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Build a multi-scratchpad system with a dropdown list to choose which application to toggle.

</ExerciseBlock>

## Recap

<Recap to="/part-7-hyprland/ipc-events">

Scratchpads use dispatch commands for window control. Next, we go deeper with **IPC events** — reacting to every Hyprland signal in real time.

</Recap>

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC documentation
- https://wiki.hyprland.org/Configuring/Workspace-rules/ — workspace management
-->
