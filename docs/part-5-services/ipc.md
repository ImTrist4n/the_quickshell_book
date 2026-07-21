---
title: "IPC"
description: "Inter-process communication between Quickshell and other applications"
---

# IPC

## The Problem

Your shell needs to talk to other programs: tell Hyprland to switch workspaces, ask MPRIS for the currently playing song, or send a notification to the notification daemon. These are all forms of inter-process communication (IPC), and they require a transport mechanism — Unix sockets, D-Bus, or FIFOs.

## The Naive Approach

Spawning a shell command for every IPC call:

```qml
Process {
  command: ["hyprctl", "dispatch", "workspace", "5"]
  // Works, but spawns a binary for every action
}
```

This works but is slow (process spawn overhead ~1-5ms) and wasteful. A single keypress might trigger multiple IPC calls.

<MentalModel>

IPC is like passing notes in class. Direct process spawning is standing up, walking across the room, and handing the note personally. A socket is a string tied between two desks — you tug it and the note slides over instantly. D-Bus is a school-wide messenger service: you write the recipient's name and the message, and the messenger delivers it.

</MentalModel>

## The Idea

Quickshell provides `Socket` for raw Unix sockets and `DBus` for D-Bus communication. These give you persistent, low-latency connections to other processes without spawning new processes for each message.

## Let's Build It

<BuildIt>

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property int activeWorkspace: 0

  Row {
    spacing: 8
    Repeater {
      model: 5
      Rectangle {
        width: 12; height: 12; radius: 6
        color: index + 1 === root.activeWorkspace ? "#7aa2f7" : "#3b4261"
        MouseArea {
          anchors.fill: parent
          onClicked: switchWorkspace(index + 1)
        }
      }
    }
  }

  function switchWorkspace(num) {
    var msg = '["dispatch", "workspace", "' + num + '"]\n'
    hyprSocket.send(msg)
  }

  Socket {
    id: hyprSocket
    type: SocketType.Unix
    path: hyprctl.socketPath // Provided by Quickshell Hyprland integration
    onMessage: (msg) => {
      var data = JSON.parse(msg)
      if (data.type === "workspace") {
        root.activeWorkspace = data.data.id
      }
    }
  }
}
```

</BuildIt>

## Let's Improve It

For D-Bus-based IPC (MPRIS, NetworkManager, UPower), Quickshell provides the `DBus` type:

```qml
import Quickshell
import QtQuick

Item {
  property string currentSong: ""

  DBus {
    id: mprisBus
    bus: DBusBus.Session
    address: "org.mpris.MediaPlayer2.playerctld"
    path: "/org/mpris/MediaPlayer2"
    interface: "org.freedesktop.DBus.Properties"

    function updateMetadata() {
      call("Get", "org.mpris.MediaPlayer2.Player", "Metadata", (result) => {
        var metadata = result.value
        var artist = metadata["xesam:artist"]?.toString() ?? "Unknown"
        var title = metadata["xesam:title"]?.toString() ?? "Unknown"
        currentSong = artist + " - " + title
      })
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    onTriggered: mprisBus.updateMetadata()
  }

  Text {
    text: currentSong || "No music playing"
    color: "#c0caf5"
    font.pixelSize: 13
    elide: Text.ElideRight
  }
}
```

<CommonMistake>

**Not handling socket disconnections.** A Unix socket can close if the server restarts. Listen for the `disconnected` signal and implement reconnection logic: set a `Timer` to reconnect every second.

**Blocking the UI with synchronous D-Bus calls.** Always use the asynchronous `call()` method of `DBus`. Synchronous calls freeze the UI until a response arrives, which may take hundreds of milliseconds over a slow bus.

**Sending malformed IPC messages.** Socket-based IPC (like Hyprland) expects exact message formats. A missing newline or extra whitespace can cause the server to ignore the message. Verify the protocol specification before sending.

</CommonMistake>

## Under the Hood

`Socket` wraps a POSIX socket file descriptor. On Linux, it uses `AF_UNIX` for local sockets. When you call `send()`, Quickshell writes to the socket in a non-blocking fashion. Incoming data is buffered until a newline (or configured delimiter) is received, then emitted as `onMessage`.

`DBus` wraps libdbus-1 and handles message marshalling, introspection, and signal subscriptions. Method calls are serialized to the D-Bus wire format, sent over the Unix domain socket at `/run/dbus/system_bus_socket` or `$XDG_RUNTIME_DIR/bus`.

<UnderTheHood>

For high-frequency IPC (e.g., compositor events), prefer `Socket` over D-Bus. Unix sockets have lower overhead per message. D-Bus adds marshalling overhead and a message broker process, making it unsuitable for sub-millisecond round trips.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Write a Hyprland workspace switcher widget using `Socket`. Connect to Hyprland's IPC socket, subscribe to workspace events, and display active workspace indicators.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Use `DBus` to connect to UPower over the system bus. Read the battery percentage from `org.freedesktop.UPower.Device` and display it in a panel.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a two-way IPC bridge: spawn a Python script that communicates with Quickshell via a Unix socket, sending structured commands back and forth.
</ExerciseBlock>

<Recap :points="['Socket provides Unix domain socket communication', 'DBus enables D-Bus method calls and signal subscriptions', 'Use persistent connections instead of spawning processes per call', 'Handle disconnections with reconnect logic', 'Prefer Socket over D-Bus for low-latency or high-frequency IPC']" next-chapter="/part-5-services/timers-revisited" />

<!-- Sources verified -->
