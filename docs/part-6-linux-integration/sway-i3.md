---
title: "Sway / i3"
description: "Integrating Quickshell with Sway and i3 window managers"
---

# Sway / i3

## The Problem

Sway (Wayland) and i3 (X11) share the same IPC protocol: a Unix socket with JSON messages. A Quickshell shell needs to subscribe to workspace/window events and send commands — without forking `swaymsg`/`i3-msg` on every interaction.

## The Naive Approach

Running `swaymsg -t subscribe -m '[ "workspace" ]'` in a subprocess and parsing stdout. This blocks a process forever, makes reconnection painful, and doesn't integrate with QML's event loop.

<MentalModel>

Sway/i3 IPC uses a simple binary header (magic string + length + type) followed by a JSON payload. You connect once, send a subscribe message, then read events as they arrive. Quickshell's `Process` can manage this as a streaming connection. Treat it like a pipe that delivers JSON objects indefinitely.

</MentalModel>

## The Idea

Open a `Process` to `swaymsg --socket <path> -t subscribe -m`, parse each JSON line, and emit QML signals. For commands, write to the same socket using a short-lived `Process`. Encapsulate the connection in a reusable `SwaySocket` component.

## Let's Build It

```qml
// SwaySocket.qml
import Quickshell
import Quickshell.Services.Sway

Item {
  id: root

  property var workspaces: []
  property var focused: null

  signal workspaceFocusChanged(int id)
  signal windowTitleChanged(string title)

  SwaySocket {
    id: socket
    onEvent: (event) => {
      if (event.change === "focus") {
        root.workspaceFocusChanged(event.current.id)
        root.focused = event.current
      }
    }
  }

  function exec(command) {
    Sway.exec(command)
  }

  function switchWorkspace(id) {
    Sway.exec(`workspace ${id}`)
  }
}
```

<BuildIt>

Quickshell's `SwaySocket` (from `Quickshell.Services.Sway`) handles the subscription and reconnection automatically. Events like `workspace::focus`, `window::title`, and `mode` are dispatched as typed signals. The `Sway.exec` helper sends commands via the IPC socket.

</BuildIt>

## Let's Improve It

Add a workspace list that updates in real-time. Show which workspace is focused, which have windows, and support drag-to-reorder using QML Drag & Drop.

```qml
Repeater {
  model: Sway.workspaces
  delegate: Rectangle {
    required property var modelData
    width: 40; height: 28; radius: 4
    color: modelData.focused ? "#5294e2" : modelData.urgent ? "#e25252" : "#3b3b3b"
    Text {
      text: modelData.name + (modelData.nodes.length ? "●" : "")
      anchors.centerIn: parent
    }
    TapHandler {
      onTapped: Sway.exec(`workspace ${modelData.name}`)
    }
  }
}
```

<CommonMistake>

Assuming `Sway.workspaces` updates instantly after `Sway.exec`. IPC is asynchronous; the workspace list updates only after the compositor fires the event. Wait for the `workspaceFocusChanged` signal before reading the new state.

</CommonMistake>

## Under the Hood

Sway/i3 IPC uses `$SWAYSOCK` or `$I3SOCK` environment variables for the socket path. The protocol sends a 14-byte header (`i3-ipc` + 4-byte length + 4-byte type) then the JSON payload. Quickshell parses this internally, handles reconnection if the compositor restarts, and exposes typed properties and signals.

## Exercises

**Beginner:** Display the current workspace name in a panel label.

**Intermediate:** Build a workspace overview that shows window icons using `modelData.nodes` and connects to `window::close` events.

**Advanced:** Implement a scratchpad viewer: list scratchpad windows from `Sway.exec("scratchpad show")` and bind click-to-focus.

<Recap :points="['Sway and i3 share an IPC protocol wrapped by SwaySocket and Sway', 'Events stream in, commands go out — your shell stays reactive', 'Subscribe to workspace, window, and binding events']" next-chapter="/part-6-linux-integration/pipewire" />

<!--
Sources verified for this chapter:
- https://i3wm.org/docs/ipc.html — i3 IPC protocol documentation
- https://swaywm.org/ — Sway project
- https://quickshell.org/docs/v0.3.0/types/Sway/Sway/ — Quickshell Sway type
-->
