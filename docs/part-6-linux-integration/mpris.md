---
title: "MPRIS"
description: "Media player control via the MPRIS D-Bus interface"
---

# MPRIS

## The Problem

A desktop shell should display now-playing info, album art, and playback controls (play/pause/next/prev) for any MPRIS-compatible media player. Polling `playerctl` every second is wasteful and introduces visible lag between the player state and the UI.

## The Naive Approach

Running `playerctl -a metadata --format '{{title}}|{{artist}}|{{status}}'` in a Timer. This forks a process every tick, produces raw strings that need splitting, and misses transient states (like track change mid-poll).

<MentalModel>

MPRIS (Media Player Remote Interfacing Specification) defines a D-Bus interface at `org.mpris.MediaPlayer2.*`. Each player exposes properties like `Metadata`, `PlaybackStatus`, and methods like `Play`, `Pause`. D-Bus `PropertiesChanged` signals push updates instantly — no polling needed.

</MentalModel>

## The Idea

Use Quickshell's `Mpris` service to bind to the active player. Show the album art (extracted as a `QPixmap` from the `Metadata` blob), track title/artist, and a play/pause button. List all available players and let the user pick one.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services.Mpris

Column {
  spacing: 6

  Mpris {
    id: mpris
  }

  property var player: mpris.players.length > 0 ? mpris.players[0] : null

  onPlayerChanged: {
    if (player) {
      // Bind to the first available player
    }
  }

  Row {
    visible: root.player != null
    spacing: 8

    Image {
      id: albumArt
      source: root.player?.albumArt ?? ""
      width: 48; height: 48
      fillMode: Image.PreserveAspectFit
    }

    Column {
      Label { text: root.player?.title ?? "No Track"; font.weight: Font.Bold }
      Label { text: root.player?.artist ?? "Unknown"; color: "#aaa" }
    }

    Row {
      spacing: 4
      IconButton { icon: "media-skip-backward"; onClicked: root.player?.previous() }
      IconButton {
        icon: root.player?.status === MprisPlayer.Playing ? "media-pause" : "media-play"
        onClicked: root.player?.playPause()
      }
      IconButton { icon: "media-skip-forward"; onClicked: root.player?.next() }
    }
  }
}
```

<BuildIt>

`Mpris.players` is a model of `MprisPlayer` objects. Each has `title`, `artist`, `album`, `albumArt`, `status`, `position`, and methods `play`, `pause`, `playPause`, `next`, `previous`. Properties update automatically when the player sends a D-Bus signal.

</BuildIt>

## Let's Improve It

Add a player switcher. When multiple media apps are open (e.g., Spotify + Firefox), let the user choose which player controls the shell widget. Also display a seekable progress bar.

```qml
Slider {
  from: 0
  to: root.player?.length ?? 0
  value: root.player?.position ?? 0
  onMoved: root.player?.seek(position)
  enabled: root.player?.canSeek ?? false
}
```

<CommonMistake>

Accessing `player.title` or `player.artist` before a track is loaded. These are empty strings initially. Guard with `player?.title` or check `player.status !== MprisPlayer.Stopped`.

</CommonMistake>

## Under the Hood

Quickshell's Mpris service connects to the session D-Bus bus, watches for name owners matching `org.mpris.MediaPlayer2.*`, and inspects each player's `org.freedesktop.DBus.Properties` interface. It subscribes to `PropertiesChanged` on `org.mpris.MediaPlayer2.Player`. The `albumArt` URL is fetched via QML's `Image` element, which handles caching.

## Exercises

**Beginner:** Show the current track title scrolling (marquee) when it overflows the panel.

**Intermediate:** Build a media player popup that shows the full playlist by iterating `CanGoNext`/`CanGoPrevious` and track list.

**Advanced:** Implement a now-playing integration with a notification: capture `track` change events and fire a custom notification with art and controls.

<Recap :points="['MPRIS gives your shell reactive access to media players via D-Bus', 'Quickshell Mpris service surfaces players, metadata, and transport', 'Bind title, artist, album, and playback status to QML widgets']" next-chapter="/part-6-linux-integration/upower-and-power-profiles" />

<!--
Sources verified for this chapter:
- https://specifications.freedesktop.org/mpris-spec/latest/ — MPRIS specification
- https://quickshell.org/docs/v0.3.0/types/Mpris/Mpris/ — Quickshell Mpris type
- https://dbus.freedesktop.org/doc/dbus-tutorial.html — D-Bus tutorial
-->
