---
title: "Hyprland"
description: "Integrating Quickshell with the Hyprland compositor"
---

# Hyprland

## The Problem

Hyprland is a dynamic tiling Wayland compositor with its own IPC and socket-based protocol. A shell built on Quickshell needs to react to workspace changes, active window updates, monitor events, and send commands (move windows, switch workspaces, toggle floating). Without direct integration, the shell is blind to compositor state.

## The Naive Approach

Polling `hyprctl` every 100ms in a Timer. This works but burns CPU, introduces latency, and desyncs between polls. You also risk race conditions when multiple shell components query state simultaneously.

<MentalModel>

Hyprland exposes two mechanisms: a socket for JSON-based events (`$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock`) and `hyprctl` for commands/queries. Quickshell's `Process` type can read the socket as a stream. Think of it as a push-based event bus: Hyprland fires events, your shell reacts.

</MentalModel>

## The Idea

Connect to the Hyprland event socket using a QML `Process` that reads lines forever. Parse each JSON line, dispatch to the relevant QML signal, and let the UI update reactively. Use `hyprctl` wrapped in `Process` calls for sending commands. No polling.

## Let's Build It

```qml
// HyprlandSocket.qml
import Quickshell
import Quickshell.Services.Hyprland

Item {
  id: root

  property var workspaces: []
  property var activeWindow: null
  property var monitors: []

  signal workspaceChanged(int id)
  signal activeWindowChanged(string title, string cls)
  signal monitorAdded(string name)

  HyprlandSocket {
    id: socket
    onEvent: (eventType, data) => {
      switch (eventType) {
        case "workspace":
          root.workspaces = Hyprland.workspaces
          root.workspaceChanged(data.id)
          break
        case "activewindow":
          root.activeWindow = data
          root.activeWindowChanged(data.title, data.windowClass)
          break
        case "monitoradded":
          root.monitorAdded(data.name)
          break
      }
    }
  }

  function switchWorkspace(id) {
    Hyprland.dispatch("workspace", id)
  }

  function moveWindowToWorkspace(id) {
    Hyprland.dispatch("movetoworkspace", id)
  }
}
```

<BuildIt>

The `HyprlandSocket` component from `Quickshell.Services.Hyprland` wraps the event socket. Every event fires the `onEvent` callback with a parsed `eventType` and `data`. You never need raw socket parsing. The `Hyprland` singleton also exposes helper methods like `dispatch` for sending commands.

</BuildIt>

## Let's Improve It

Add a `HyprlandWorkspaceBar` component that renders workspace buttons using the `workspaces` property. Highlight the active workspace. Handle clicks to switch. Also track `monitors` to show per-monitor workspaces.

```qml
Row {
  spacing: 4
  Repeater {
    model: Hyprland.workspaces
    delegate: Rectangle {
      width: 32; height: 32
      radius: 6
      color: modelData.active ? "#5294e2" : "#3b3b3b"
      Text { text: modelData.id; anchors.centerIn: parent }
      TapHandler { onTapped: Hyprland.dispatch("workspace", modelData.id) }
    }
  }
}
```

<CommonMistake>

Polling `Hyprland.workspaces` repeatedly instead of listening to the `workspace` event. The event socket is the source of truth; the property is a snapshot. If you poll, you miss events or read stale data. Always use signals.

</CommonMistake>

## Under the Hood

Quickshell's `Hyprland` service opens the Unix socket at `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock`. It reads newline-delimited JSON, parses each line, and emits typed signals. The `dispatch` function writes IPC commands to `.socket.sock`. Both use `Process` internally but you never touch it directly.

## Exercises

**Beginner:** Display the active window title in a panel label.

**Intermediate:** Build a workspace grid that shows per-monitor workspaces with window thumbnails (use `Hyprland.clients`).

**Advanced:** Implement a scratchpad system — toggle a hidden workspace with `Hyprland.dispatch("togglespecialworkspace", "scratch")` and animate its windows.

<Recap :points="['Hyprland event socket pushes state changes without polling', 'HyprlandSocket and Hyprland singleton abstract Hyprland IPC', 'Subscribe to workspace, window, and monitor events']" next-chapter="/part-6-linux-integration/sway-i3" />

<!--
Sources verified for this chapter:
- https://wiki.hyprland.org/IPC/ — Hyprland IPC documentation
- https://wiki.hyprland.org/Configuring/Environment-variables/ — Hyprland environment variables
- https://quickshell.org/docs/v0.3.0/types/Hyprland/HyprlandSocket/ — Quickshell HyprlandSocket type
-->
