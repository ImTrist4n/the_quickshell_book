---
title: "IPC Events"
description: "Reacting to Hyprland IPC events — workspace changes, window opens, monitor changes"
---

# IPC Events

<ChapterMeta title="IPC Events" icon="broadcast" />

## Problem

Beyond workspaces and active windows, your shell may need to react to arbitrary Hyprland events: window title changes, monitor hotplugs, window opens/closes, fullscreen state changes, or urgent hints. The `Hyprland` singleton covers common cases, but you may need raw event access for custom behavior.

## Naive Approach

Listen to everything with a generic `hyprctl` poll loop. Filter events by parsing `jq` output. Fragile, slow, and misses transient events that occur between polls.

## MentalModel

<MentalModel title="Event Bus">

Hyprland's IPC socket emits a continuous stream of event lines. Each line has the format `event>>payload`. Quickshell wraps this as a signal-based API. Think of it as an event bus — you subscribe to specific event names and get notified synchronously when they occur.

</MentalModel>

## Idea

Quickshell's `Hyprland` singleton provides a `socketEvent` signal that fires for every IPC event. Connect to it with a handler that filters by event name. The event name and payload are passed as strings.

## Build It

```qml
import Quickshell
import Quickshell.Hyprland

Item {
  Connections {
    target: Hyprland

    function onSocketEvent(event: string, payload: string) {
      switch (event) {
        case "openwindow":
          console.log(`Window opened: ${payload}`)
          break
        case "closewindow":
          console.log(`Window closed: ${payload}`)
          break
        case "windowtitle":
          console.log(`Title changed: ${payload}`)
          break
        case "fullscreen":
          console.log(`Fullscreen toggled: ${payload}`)
          break
        case "monitoradded":
          console.log(`Monitor plugged in: ${payload}`)
          break
        case "monitorremoved":
          console.log(`Monitor removed: ${payload}`)
          break
      }
    }
  }
}
```

## BuildIt Breakdown

`socketEvent` fires for every raw IPC line from Hyprland. The `event` parameter is the event type (e.g., `openwindow`). The `payload` is the rest of the line — typically comma-separated values like `windowAddress,workspaceId,windowClass,windowTitle`. This is a firehose; filter aggressively to avoid performance issues in hot paths like `windowtitle` which fires on every keystroke in a terminal.

## Improve It

Create typed wrapper signals. Build a `HyprlandEvent` QML singleton that parses payloads into structured objects. Use `Connections` with `enabled: false` and toggle it only when needed. Debounce high-frequency events with a Timer.

## CommonMistake

<CommonMistake>

Processing every event synchronously inside `onSocketEvent`. A rapid-fire event like `windowtitle` (fires per-keystroke) can block the UI thread. Offload heavy work to a `Timer` callback that batches events.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Hyprland's event socket is `.socket2.sock` — a UNIX socket that writes one line per event. Quickshell uses a `QSocketNotifier` to read from it asynchronously. When data is available, it reads all buffered lines and emits `socketEvent` for each one. This means multiple events may arrive in a single read cycle if they queued up. The notifier operates at the event loop level and does not block the UI thread during reads.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Log all `openwindow` events to see what payloads arrive.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Build a toast notification that shows when a window opens or closes.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Create a full event debugger panel that shows the last 50 IPC events with timestamps.

</ExerciseBlock>

## Recap

<Recap to="/part-7-hyprland/project-workspace-switcher">

We have all the IPC primitives. Now let's combine workspaces, active window, and events into a **complete workspace switcher** project.

</Recap>

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC documentation
- https://wiki.hyprland.org/Configuring/Workspace-rules/ — workspace management
-->
