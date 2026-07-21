---
title: "Media Player"
description: "Building a media playback control widget with MPRIS integration"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'IPC']" you-will-build="A media player popup that controls playback and shows now-playing info" />

## The Problem

Users play music and video throughout their workday. Without a media widget, they must alt-tab to their media app to pause, skip, or see what's playing. A shell-integrated media player solves this.

## The Naive Approach

Spawn `playerctl` commands for every media action:

```qml
function playPause() {
  Qt.process(["playerctl", "play-pause"])
}
function nextTrack() {
  Qt.process(["playerctl", "next"])
}
```

This works but each command spawns a subprocess (50-100ms latency). There's no reactive way to know when the track changes or playback state toggles.

<MentalModel>

Think of MPRIS as a universal remote protocol. Any media player that speaks MPRIS (Spotify, VLC, Firefox, mpv) exposes play/pause/next/prev controls and track metadata. Your shell is a universal remote that can control any of them.

</MentalModel>

## The Idea

MPRIS (Media Player Remote Interfacing Specification) is a D-Bus interface that media players implement. Quickshell provides `MprisService` from `Quickshell.Services` that connects to all running MPRIS players and exposes their state.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services
import QtQml.Models

PopupWindow {
  id: root
  width: 350
  height: 160
  visible: false

  property var player: MprisService.players.length > 0
    ? MprisService.players[0] : null

  // Reactive bindings to current player
  property string trackTitle: player ? player.title : "No media playing"
  property string trackArtist: player ? player.artist : ""
  property string artUrl: player ? player.artUrl : ""
  property bool isPlaying: player ? player.isPlaying : false
  property double position: player ? player.position : 0
  property double length: player ? player.length : 0

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 8

    Column {
      anchors.fill: parent; anchors.margins: 16; spacing: 8

      // Album art + track info
      Row {
        spacing: 12
        Rectangle {
          width: 64; height: 64; radius: 6; color: "#313244"
          Image { source: artUrl; anchors.fill: parent; radius: 6; fillMode: Image.PreserveAspectCrop }
          Text { text: "♪"; anchors.centerIn: parent; color: "#6c7086"; font.pixelSize: 24; visible: artUrl === "" }
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter; spacing: 4
          Text { text: trackTitle; font.pixelSize: 15; font.bold: true; color: "#cdd6f4"; elide: Text.ElideRight; width: 220 }
          Text { text: trackArtist; font.pixelSize: 12; color: "#a6adc8"; elide: Text.ElideRight; width: 220 }
        }
      }

      // Progress bar
      Rectangle {
        width: parent.width; height: 4; radius: 2; color: "#313244"
        Rectangle {
          width: parent.width * (length > 0 ? position / length : 0); height: 4; radius: 2; color: "#89b4fa"
        }
      }

      // Controls
      Row {
        spacing: 16; anchors.horizontalCenter: parent.horizontalCenter
        Text { text: "⏮"; color: "#cdd6f4"; font.pixelSize: 20; MouseArea { anchors.fill: parent; onClicked: player?.previous() } }
        Text { text: isPlaying ? "⏸" : "▶"; color: "#89b4fa"; font.pixelSize: 24; MouseArea { anchors.fill: parent; onClicked: player?.playPause() } }
        Text { text: "⏭"; color: "#cdd6f4"; font.pixelSize: 20; MouseArea { anchors.fill: parent; onClicked: player?.next() } }

        Item { width: 20; height: 1 }

        Text { text: "⏹"; color: "#f38ba8"; font.pixelSize: 18; MouseArea { anchors.fill: parent; onClicked: player?.stop() } }
      }
    }
  }
}
```

<BuildIt>

`MprisService.players` returns a list of all active MPRIS players. Each player has `title`, `artist`, `album`, `artUrl`, `isPlaying`, `position`, `length`, and methods `playPause()`, `next()`, `previous()`, `stop()`. Bind to these properties reactively — when the track changes, your UI updates automatically.

</BuildIt>

## Let's Improve It

Add track list and player selection. Some users have multiple media apps open:

```qml
Row {
  spacing: 6
  Repeater {
    model: MprisService.players
    delegate: Rectangle {
      required property var modelData
      width: 80; height: 24; radius: 4
      color: modelData === player ? "#89b4fa" : "#45475a"
      Text {
        text: modelData.identity || "Player"
        anchors.centerIn: parent
        color: "white"; font.pixelSize: 11
      }
      MouseArea {
        anchors.fill: parent
        onClicked: root.player = modelData
      }
    }
  }
}
```

<CommonMistake>

**Assuming a player is always available.** MPRIS players come and go. When no player is active, show a "No media playing" state. When the current player exits, fall back to another player or show the idle state.

**Not handling position updates.** `position` updates every ~200ms during playback. If you bind a progress bar to `position`, it animates smoothly. But if you're polling `position` with a Timer, you're wasting cycles on paint events.

**Forgetting that artUrl might be a file:// path or data URL.** Some players send local file paths (`file:///tmp/album-art.jpg`), others send HTTP URLs. Handle both, and provide a fallback icon when the image fails to load.

</CommonMistake>

## Under the Hood

MPRIS is specified at `specifications.freedesktop.org/mpris-spec/latest/`. The D-Bus interface `org.mpris.MediaPlayer2` provides root properties, and `org.mpris.MediaPlayer2.Player` provides playback controls. Quickshell's `MprisService` connects to all players on the session bus, listens to `PropertiesChanged` signals, and exposes a unified model to QML.

The `position` property is mapped from the D-Bus `Position` property (microseconds via `org.freedesktop.DBus.Properties.Get`). Quickshell converts it to seconds and updates it at ~5Hz during active playback.

## Exercises

<ExerciseBlock :difficulty="1">
Add a volume slider (0-100) that controls the media player's volume via `player.volume`. Display volume percentage next to the slider.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a "Now Playing" panel widget that shows the current track title scrolling (marquee) when it's too long to fit. Use `Text` with `elide` and a `Timer` to animate text position.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a full queue view. Subscribe to the player's `TrackList` property via D-Bus (requires extra D-Bus calls beyond what MprisService exposes). Display a `ListView` of upcoming tracks and allow reordering.
</ExerciseBlock>

<Recap :points="['MprisService exposes all MPRIS-compatible media players as a reactive model', 'Bind to player.title, artist, isPlaying, position for live updates', 'Provide a fallback UI when no player is active', 'Position updates at ~5Hz for smooth progress bar animation']" next-chapter="/part-9-applications/emoji-picker" />

<!--
Sources verified for this chapter:
- https://www.freedesktop.org/wiki/Specifications/mpris-spec/ — MPRIS specification
- https://quickshell.org/docs/v0.3.0/services/mpris/ — MprisService documentation
- https://doc.qt.io/qt-6/qml-qtquick-image.html — Image type
-->
