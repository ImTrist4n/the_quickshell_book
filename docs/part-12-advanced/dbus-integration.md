---
title: "D-Bus Integration"
description: "Connecting your shell to the Linux desktop's inter-process communication bus"
---

<ChapterMeta reading-time="16 min" :difficulty="3" :prerequisites="['Custom services', 'Qt.process']" you-will-learn="How to use D-Bus for system and session communication" />

## The Problem

The Linux desktop communicates via D-Bus — a message bus system for inter-process communication. Applications expose services, methods, and properties over D-Bus. Your shell can listen for system events (screen lock, power changes), control applications (media players, network manager), and provide its own services.

## The Naive Approach

Shell out to D-Bus command-line tools:

```qml
function getBatteryPercentage() {
  var result = Qt.process(["dbus-send", "--system",
    "--dest=org.freedesktop.UPower",
    "/org/freedesktop/UPower/devices/battery_BAT0",
    "org.freedesktop.DBus.Properties.Get",
    "string:org.freedesktop.UPower.Device",
    "string:Percentage"]).stdout
  // parse dbus-send output
}
```

Parsing `dbus-send` text output is unreliable and slow. Every call spawns a new process.

<MentalModel>

Think of D-Bus like the telephone system. Each application has a phone number (bus name: `org.mpris.MediaPlayer2.firefox`). Each feature has a department (object path: `/org/mpris/MediaPlayer2`). You call with a method ("What's the current track?") and get a response. You can also subscribe to announcements (signals: "Track changed!").

</MentalModel>

## The Idea

Quickshell provides `Qt.dbusCall()` for direct D-Bus communication without spawning processes. Use it to read properties, call methods, and subscribe to signals.

## Let's Build It

```qml
// MprisService.qml — read currently playing track info
pragma Singleton
import Quickshell

QtObject {
  id: mpris

  readonly property string playerName: findActivePlayer()
  property string title: "No track"
  property string artist: ""
  property string album: ""
  property string artUrl: ""
  property bool playing: false
  property double position: 0
  property double length: 0

  function findActivePlayer() {
    var result = Qt.dbusCall(
      "org.freedesktop.DBus",
      "/org/freedesktop/DBus",
      "org.freedesktop.DBus",
      "ListNames"
    )
    if (!result) return ""
    var names = result.filter(function(n) {
      return n.startsWith("org.mpris.MediaPlayer2.")
    })
    return names.length > 0 ? names[0] : ""
  }

  function updateMetadata() {
    if (!playerName) return

    var metadata = Qt.dbusCall(
      playerName,
      "/org/mpris/MediaPlayer2",
      "org.freedesktop.DBus.Properties",
      "Get",
      "org.mpris.MediaPlayer2.Player",
      "Metadata"
    )
    if (metadata) {
      title = metadata["xesam:title"] || "Unknown"
      artist = metadata["xesam:artist"] ? metadata["xesam:artist"].join(", ") : ""
      album = metadata["xesam:album"] || ""
      artUrl = metadata["mpris:artUrl"] || ""
    }

    var playback = Qt.dbusCall(
      playerName,
      "/org/mpris/MediaPlayer2",
      "org.freedesktop.DBus.Properties",
      "Get",
      "org.mpris.MediaPlayer2.Player",
      "PlaybackStatus"
    )
    playing = playback === "Playing"
  }

  function playPause() {
    Qt.dbusCall(playerName, "/org/mpris/MediaPlayer2",
      "org.mpris.MediaPlayer2.Player", "PlayPause")
  }

  function next() {
    Qt.dbusCall(playerName, "/org/mpris/MediaPlayer2",
      "org.mpris.MediaPlayer2.Player", "Next")
  }

  function previous() {
    Qt.dbusCall(playerName, "/org/mpris/MediaPlayer2",
      "org.mpris.MediaPlayer2.Player", "Previous")
  }

  Timer {
    interval: 2000; running: true; repeat: true
    onTriggered: mpris.updateMetadata()
  }
}
```

<BuildIt>

The MPRIS service connects to media players via D-Bus. It reads metadata (title, artist, album, art URL), playback status, and provides control methods (play/pause, next, previous). This is the same interface that playerctl uses — but without spawning a subprocess.

</BuildIt>

## Listening for Signals

Subscribe to D-Bus signals for real-time updates:

```qml
// In your shell initialization
Qt.dbusConnect("org.freedesktop.UPower",
  "/org/freedesktop/UPower/devices/battery_BAT0",
  "org.freedesktop.DBus.Properties",
  "PropertiesChanged")

// Handle the signal in a component
Connections {
  target: Qt.dbusSignal("PropertiesChanged")
  function onBatterySignal(interface, changed, invalidated) {
    if (changed.Percentage) {
      batteryLevel = changed.Percentage.value
    }
  }
}
```

## Exposing Your Own D-Bus Service

Register your shell as a D-Bus service to allow other applications to interact with it:

```qml
Qt.dbusRegisterService("org.quickshell.UserShell")
Qt.dbusRegisterObject("/org/quickshell/UserShell", {
  "VolumeUp": function() { AudioService.setVolume(AudioService.volume + 0.1) },
  "VolumeDown": function() { AudioService.setVolume(AudioService.volume - 0.1) },
  "ToggleMute": function() { AudioService.toggleMute() }
})
```

Now external applications can call `org.quickshell.UserShell.VolumeUp()` to control your shell's volume.

## Common D-Bus Services

| Bus | Service | Object | Interface | Use |
|---|---|---|---|---|
| Session | `org.mpris.MediaPlayer2.*` | `/org/mpris/MediaPlayer2` | `org.mpris.MediaPlayer2.Player` | Media playback |
| System | `org.freedesktop.UPower` | `/org/freedesktop/UPower` | `org.freedesktop.UPower` | Battery and power |
| System | `org.freedesktop.NetworkManager` | `/org/freedesktop/NetworkManager` | `org.freedesktop.NetworkManager` | Network state |
| Session | `org.freedesktop.Notifications` | `/org/freedesktop/Notifications` | `org.freedesktop.Notifications` | Notifications |
| Session | `org.freedesktop.ScreenSaver` | `/org/freedesktop/ScreenSaver` | `org.freedesktop.ScreenSaver` | Inhibit sleep |
| System | `org.freedesktop.login1` | `/org/freedesktop/login1` | `org.freedesktop.login1.Manager` | Session management |

<CommonMistake>

**Not checking bus type.** Session bus vs system bus — connecting to the wrong one fails silently. Media players use the session bus; hardware (UPower, NetworkManager) uses the system bus. Specify the correct type in `Qt.dbusCall()`.

**Blocking on D-Bus calls.** D-Bus method calls can block if the target application is unresponsive. Use async variants when available, or set a timeout.

**Property cache staleness.** D-Bus properties can change at any time. Either subscribe to `PropertiesChanged` signals or poll at a reasonable interval. Don't cache properties indefinitely.

</CommonMistake>

## Under the Hood

D-Bus operates on a binary protocol over Unix sockets. The session bus runs per-user (`/run/user/$UID/bus`), and the system bus runs system-wide (`/run/dbus/system_bus_socket`). Messages are typed (primitive types, structs, arrays, variants, object paths, signatures). Quickshell's `Qt.dbusCall()` handles serialization/deserialization transparently.

## Exercises

<ExerciseBlock :difficulty="1">
Subscribe to NetworkManager's `StateChanged` signal to detect when the network connects/disconnects. Update a `connected` property in your `NetworkService` singleton reactively.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Expose a custom D-Bus interface for your shell's brightness control. Register methods `SetBrightness(value)` and `GetBrightness()`. Test with `dbus-send --session --dest=org.quickshell.UserShell ...`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a D-Bus "monitor" popup that shows live D-Bus traffic. Filter by bus type, service name, or interface. Display method calls, signals, and property changes in a scrolling list.
</ExerciseBlock>

<Recap :points="['Use Qt.dbusCall() for direct D-Bus communication without subprocess overhead', 'Subscribe to PropertiesChanged signals for real-time updates', 'Register your shell as a D-Bus service for external control', 'Match bus type (session vs system) correctly for each service']" next-chapter="/part-12-advanced/qml-extensions" />

<!--
Sources verified for this chapter:
- https://www.freedesktop.org/wiki/Software/dbus/ — D-Bus documentation
- https://specifications.freedesktop.org/mpris-spec/latest/ — MPRIS specification
- https://quickshell.org/docs/v0.3.0/guide/qml-language — QML Language
- https://doc.qt.io/qt-6/qtdbus-index.html — Qt D-Bus module
-->
