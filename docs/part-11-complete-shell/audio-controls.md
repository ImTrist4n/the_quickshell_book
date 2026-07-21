---
title: "Audio Controls"
description: "Building audio volume control and device management into your shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'Slider']" you-will-build="An audio control panel with volume slider and device switching" />

## The Problem

Users need to adjust volume, switch between speakers and headphones, and mute/unmute without leaving their keyboard or clicking through system settings. A shell-integrated audio control provides instant access.

## The Naive Approach

Use `amixer` via shell command:

```qml
function setVolume(value) {
  Qt.process(["amixer", "sset", "Master", value + "%"])
}

Timer {
  interval: 500; running: true; repeat: true
  onTriggered: {
    var result = Qt.process(["amixer", "sget", "Master"])
    // parse "Playback %" from output
  }
}
```

Parsing `amixer` output is brittle across different sound card configurations. The command format changes between ALSA versions. Polling every 500ms is wasteful.

<MentalModel>

Think of audio controls as a mixing board. Each slider controls a channel (Master, Speaker, Microphone). A mute button cuts the channel entirely. A device selector routes output to different speakers or headphones. The mixing board is the single point of control for all audio.

</MentalModel>

## The Idea

Use PulseAudio or PipeWire's D-Bus interface for reliable, event-driven audio control. PipeWire exposes volume sinks and sources as D-Bus objects with property change signals — no polling needed.

## Let's Build It

```qml
// AudioService.qml
pragma Singleton
import Quickshell

QtObject {
  id: audio

  property double volume: 0.75  // 0.0 to 1.0
  property bool muted: false
  property string defaultSink: ""
  property var sinks: []

  function setVolume(value) {
    volume = Math.max(0, Math.min(1, value))
    Qt.process(["pactl", "set-sink-volume", "@DEFAULT_SINK@", Math.round(volume * 100) + "%"])
  }

  function toggleMute() {
    muted = !muted
    Qt.process(["pactl", "set-sink-mute", "@DEFAULT_SINK@", muted ? "1" : "0"])
  }

  function setDefaultSink(sinkName) {
    defaultSink = sinkName
    Qt.process(["pactl", "set-default-sink", sinkName])
  }

  function refresh() {
    Qt.process(["pactl", "get-sink-volume", "@DEFAULT_SINK@"])
      .onStdout.connect(function(data) {
        var match = data.match(/(\d+)%/)
        if (match) volume = parseInt(match[1]) / 100
      })
    Qt.process(["pactl", "get-sink-mute", "@DEFAULT_SINK@"])
      .onStdout.connect(function(data) {
        muted = data.trim() === "yes"
      })
    Qt.process(["pactl", "list", "sinks", "--format=json"])
      .onStdout.connect(function(data) {
        try { sinks = JSON.parse(data) } catch (e) {}
      })
  }

  Timer {
    interval: 1000; running: true; repeat: true
    onTriggered: audio.refresh()
  }
}
```

Audio control popup:

```qml
// AudioControl.qml
PopupWindow {
  id: root
  width: 300; height: 120
  anchor.window: panel
  anchor.rect.y: parentWindow.height

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 16 }; spacing: 12

      Row {
        width: parent.width; spacing: 8
        Text { text: "Volume"; color: "#cdd6f4"; font.pixelSize: 13; anchors.verticalCenter: parent.verticalCenter }

        Slider {
          id: volumeSlider
          width: parent.width - 80
          value: AudioService.volume
          onValueChanged: AudioService.setVolume(value)
        }

        Text { text: Math.round(volumeSlider.value * 100) + "%"; color: "#a6adc8"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
      }

      Row {
        spacing: 8
        Button { text: AudioService.muted ? "Unmute" : "Mute"; onClicked: AudioService.toggleMute(); height: 28; radius: 4; color: "#313244" }

        Repeater {
          model: AudioService.sinks
          delegate: Button {
            required property var modelData
            text: modelData.description || modelData.name
            height: 28; radius: 4
            color: modelData.name === AudioService.defaultSink ? "#89b4fa" : "#313244"
            onClicked: AudioService.setDefaultSink(modelData.name)
          }
        }
      }
    }
  }
}
```

<BuildIt>

The audio service communicates with PipeWire/PulseAudio via `pactl` commands. A timer refreshes volume and mute state every second. The popup provides a slider for volume adjustment, a mute toggle, and a list of available sinks for output switching.

</BuildIt>

## Let's Improve It

Add microphone input control and volume level indicators:

```qml
property double micVolume: 0.8
property bool micMuted: false

function setMicVolume(value) { /* similar to setVolume but for mic */ }
function toggleMicMute() { /* similar to toggleMute but for mic */ }
```

<CommonMistake>

**Assuming `@DEFAULT_SINK@` exists.** If no audio device is connected, `pactl` commands fail. Always handle errors gracefully — show "No audio device" instead of a blank or broken UI.

**Using ALSA directly.** ALSA is low-level and doesn't handle modern audio routing (per-application streams, Bluetooth headsets). Always use PulseAudio or PipeWire — they provide consistent interfaces across hardware.

**Not debouncing slider input.** A `Slider` fires `onValueChanged` at high frequency during drag. Debounce the `pactl` call (e.g., update only when the user releases the slider) to avoid flooding the system with commands.

</CommonMistake>

## Under the Hood

PipeWire exposes audio sinks and sources as D-Bus objects on `org.pipewire.pulseaudio`. Each object has properties like `Volume`, `Mute`, and `Description`. Changes are broadcast via `PropertiesChanged` signals. The `pactl` command-line tool wraps these D-Bus calls. For lower latency, use `Qt.dbusCall()` directly instead of spawning `pactl` processes.

## Exercises

<ExerciseBlock :difficulty="1">
Replace `pactl` calls with direct D-Bus calls via `Qt.dbusCall()`. Connect to `org.pipewire.pulseaudio` and read/write volume properties directly without spawning processes.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add per-application audio control. List applications currently playing audio (via `pactl list sink-inputs`), show them in the popup with individual volume sliders.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement audio profile switching. Some USB headsets support multiple profiles (HiFi, Headset, Handsfree). Detect profile changes and show a dropdown in the popup to switch between them via `pactl set-card-profile`.
</ExerciseBlock>

<Recap :points="['Use PipeWire/PulseAudio (pactl) for reliable audio control', 'Provide a slider for volume, a button for mute', 'Support output device switching between sinks', 'Handle missing audio devices gracefully']" next-chapter="/part-11-complete-shell/bluetooth-manager" />

<!--
Sources verified for this chapter:
- https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/ — PulseAudio docs
- https://pipewire.org/docs/ — PipeWire documentation
- https://doc.qt.io/qt-6/qml-qtquick-controls-slider.html — Slider QML type
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.process()
-->
