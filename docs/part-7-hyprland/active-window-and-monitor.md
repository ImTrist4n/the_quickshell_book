---
title: "Active Window & Monitor"
description: "Tracking the focused window and active monitor in Hyprland"
---

# Active Window & Monitor

<ChapterMeta title="Active Window & Monitor" icon="window" />

## Problem

Your shell needs to know which window is focused and which monitor is active. This powers features like showing the current app name in the top bar, applying per-monitor wallpaper, or routing keyboard shortcuts to the correct output.

## Naive Approach

Run `hyprctl activewindow` and `hyprctl monitors` on a timer. Parse the JSON output. This adds 10-50ms of latency per poll and wastes CPU when nothing changes.

## MentalModel

<MentalModel title="Focus as a Reactive Property">

Focus is a global property of the compositor. At any moment, exactly one window is active and one monitor is primary. Hyprland broadcasts focus changes via IPC events. Quickshell's `Hyprland` singleton exposes these as reactive QML properties — `activeWindow` and `activeMonitor` update automatically when focus shifts.

</MentalModel>

## Idea

Bind directly to `Hyprland.activeWindow` and `Hyprland.activeMonitor`. Each is a `HyprlandWindow` / `HyprlandMonitor` object with properties like `title`, `class`, `address`, `monitor.name`, `monitor.width`, etc.

## Build It

```qml
import Quickshell
import Quickshell.Hyprland

Row {
  spacing: 12

  Text {
    text: Hyprland.activeWindow?.class ?? "Desktop"
    color: "#ffffff"
    font.pixelSize: 14
  }

  Text {
    text: Hyprland.activeMonitor?.name ?? ""
    color: "#888888"
    font.pixelSize: 12
  }

  Text {
    text: Hyprland.activeWindow?.title ?? ""
    elide: Text.ElideRight
    width: 200
    color: "#aaaaaa"
    font.pixelSize: 12
  }
}
```

## BuildIt Breakdown

`Hyprland.activeWindow` is `null` when no window is focused (empty desktop). The `?.` optional chaining operator prevents crashes. `class` is the window class (e.g., `firefox`, `kitty`). `title` is the window title. `activeMonitor` gives the focused monitor object with `name`, `description`, `width`, `height`, `refreshRate`, and `scale`.

## Improve It

Add a window icon using `Hyprland.activeWindow?.icon`. Show per-monitor workspace lists. Display the focused monitor's workspace. Use `activeMonitor` to position popup windows on the correct screen.

## CommonMistake

<CommonMistake>

Binding to `Hyprland.activeWindow.title` directly may crash if `activeWindow` is null. Always use optional chaining (`?.`) or check for null before accessing sub-properties.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Hyprland sends `activewindow` and `focusedmon` events on `.socket2.sock`. Quickshell's `Hyprland` singleton parses the event payload (window address and class) and then fetches full details via `hyprctl activewindow -j` — but only when something changes, not on a timer. The monitor list is similarly cached and invalidated on `monitor` events.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Display the current active window class and title in a top bar label.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Show different background colors per monitor based on which one is active.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Build a per-monitor workspace indicator that highlights the workspace on the active monitor differently from inactive ones.

</ExerciseBlock>

## Recap

<Recap to="/part-7-hyprland/scratchpads">

We now know the active window and monitor. Next, let's handle **scratchpads** — toggling windows with IPC dispatches.

</Recap>

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC documentation
- https://wiki.hyprland.org/Configuring/Workspace-rules/ — workspace management
-->
