---
title: "Volume"
description: "A volume slider and indicator using PipeWire"
---

## The Problem

A volume widget must show the current audio level, allow changing it, and toggle mute. It should also show the active audio sink (speakers vs headphones). Unlike other widgets, volume needs two-way communication: read the current level and write a new one.

## The Naive Approach

Call `pamixer --get-volume` and `pamixer --get-mute` in a polling `Timer`. To set volume, call `pamixer --set-volume <n>`. This spawns subprocesses constantly — every slider drag would fork a process.

```qml
Timer {
  interval: 1000
  onTriggered: {
    // "pamixer --get-volume" then parse stdout
    // "pamixer --get-mute" for mute state
  }
}

// On slider change:
// exec("pamixer", ["--set-volume", sliderValue.toString()])
```

<MentalModel>

Volume control is like a stereo amplifier. The amplifier has a knob (input) and a display (output). A good volume widget connects both — the knob adjusts the amplifier, and the display shows the current level without lag.

</MentalModel>

## The Idea

Quickshell provides `PipeWire` integration via the `PulseAudio` or `PipeWire` singleton. It exposes sinks, sources, volume levels, and mute state as reactive properties. Setting volume is a direct property assignment — no shell commands.

## Let's Build It

A volume widget with mute toggle and slider:

<BuildIt>

```qml
import Quickshell
import Quickshell.Services.PipeWire

Row {
  spacing: 8

  property var sink: PipeWire.defaultSink
  property real volume: sink ? sink.volume : 0
  property bool muted: sink ? sink.muted : false

  Text {
    text: {
      if (muted) return "ﱝ"
      if (volume <= 0) return ""
      if (volume < 0.5) return ""
      return ""
    }
    font.pixelSize: 16
    color: muted ? "#585b70" : "#cdd6f4"
    MouseArea {
      anchors.fill: parent
      onClicked: if (sink) sink.muted = !sink.muted
    }
  }

  Rectangle {
    width: 80; height: 6
    radius: 3
    color: "#313244"
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
      width: parent.width * volume
      height: parent.height
      radius: 3
      color: "#89b4fa"
      Behavior on width { SmoothedAnimation { duration: 100 } }
    }

    MouseArea {
      anchors.fill: parent
      onPressed: mouse => setVolume(mouse.x / width)
      onPositionChanged: mouse => setVolume(mouse.x / width)
      function setVolume(fraction) {
        if (sink) sink.volume = Math.max(0, Math.min(1, fraction))
      }
    }
  }

  Text {
    text: Math.round(volume * 100) + "%"
    font.pixelSize: 12
    color: "#a6adc8"
  }
}
```

</BuildIt>

## Let's Improve It

Add per-app audio streams and a vertical slider variant:

```qml
Column {
  spacing: 4

  Repeater {
    model: PipeWire.sinks

    Row {
      spacing: 6
      Text {
        text: modelData.name || "Sink " + index
        font.pixelSize: 10
        color: "#585b70"
        width: 80
        elide: Text.ElideRight
      }
      Slider {
        from: 0; to: 1
        value: modelData.volume
        onMoved: modelData.volume = value
        width: 80
        height: 16
      }
    }
  }
}
```

<CommonMistake>

**Assuming a single sink.** PipeWire can have multiple sinks (HDMI audio, Bluetooth headphones, built-in speakers). Always use `PipeWire.defaultSink` or iterate `PipeWire.sinks`. Never hardcode sink IDs.

**Not clamping volume.** Volume values range from 0.0 to 1.0 (or sometimes higher for max amplification). Always clamp slider input with `Math.max(0, Math.min(1, fraction))` to avoid negative or overflow values.

**Ignoring `muted` state.** The volume slider should snap to zero position when muted but remember the previous level for unmuting. Store `preMuteVolume` when mute is activated and restore it on unmute.

</CommonMistake>

## Under the Hood

PipeWire's volume is a float from 0.0 to 1.0 (mapped to the underlying hardware's dB scale). When you set `sink.volume`, Quickshell calls the PipeWire API to update the channel volumes. The hardware responds immediately (milliseconds). The `muted` property maps to the `SUSPEND` flag on the PipeWire node.

<UnderTheHood>

The `SmoothedAnimation` on the bar width makes slider movements feel responsive even though we're clamping to 100ms animation. The mouse tracking in `positionChanged` fires at the mouse device's report rate (typically 125-1000Hz). Each move calls `sink.volume = fraction`, which hits PipeWire. For smooth dragging, PipeWriter handles up to hundreds of updates per second without glitching.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Add a mute button that toggles mute on click. When muted, show the muted icon in red. On unmute, restore the previous volume level.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Detect when headphones are plugged in (check active port name) and automatically switch the display icon from speaker to headphone icon.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a per-application volume mixer. List audio streams from `PipeWire.streams`, show each app's icon and volume slider. Allow muting individual applications.
</ExerciseBlock>

<Recap :points="['PipeWire singleton provides reactive volume and mute state', 'Click icon to toggle mute, drag bar to set volume', 'Clamp volume between 0.0 and 1.0', 'Handle multiple sinks via defaultSink or iteration', 'PreMuteVolume pattern preserves level across mute cycles']" next-chapter="/part-4-widgets/bluetooth" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

