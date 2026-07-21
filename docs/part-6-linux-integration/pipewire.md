---
title: "PipeWire"
description: "Audio control through PipeWire — volume, devices, and streams"
---

# PipeWire

## The Problem

A desktop shell needs to display and control audio: master volume, mute toggling, active sink/source switching, and per-application stream management. PipeWire exposes this over the WirePlumb D-Bus API, but raw D-Bus calls are verbose and error-prone in QML.

## The Naive Approach

Launching `pactl` or `wpctl` in a subprocess every second and parsing stdout. This is slow, consumes CPU, and creates visible latency in volume sliders. It also fails when the audio server is busy.

<MentalModel>

PipeWire organizes audio into **nodes** (sinks, sources, streams). Each node has properties (volume, mute, name, description). WirePlumb exposes these as D-Bus objects on `org.pipewire`. Quickshell's `PipeWire` service mirrors this tree as reactive QML properties — changes propagate instantly via D-Bus signals.

</MentalModel>

## The Idea

Use Quickshell's `PipeWire` service to bind a volume slider directly to the default sink's volume property. Connect the `muted` property to a mute button icon. For advanced use, list all sinks and sources and let the user pick the default.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services.PipeWire

Column {
  spacing: 8

  PipeWireAudio {
    id: audio
  }

  // Volume slider
  Row {
    spacing: 8
    Icon { source: audio.defaultSink.muted ? "audio-volume-muted" : "audio-volume-high" }
    TapHandler { onTapped: audio.defaultSink.muted = !audio.defaultSink.muted }

    Slider {
      id: volSlider
      from: 0; to: 150
      value: audio.defaultSink.volume
      onMoved: audio.defaultSink.volume = value
    }
    Label { text: `${Math.round(audio.defaultSink.volume)}%` }
  }

  // Sink selector
  ComboBox {
    model: audio.sinks
    textRole: "description"
    valueRole: "name"
    onCurrentValueChanged: audio.defaultSink = audio.sinks.find(s => s.name === currentValue)
  }
}
```

<BuildIt>

`PipeWireAudio.defaultSink` returns a reactive `SinkInfo` object with `volume` (0-150%), `muted` (bool), `name`, and `description`. Setting `volume` or `muted` writes through to PipeWire immediately. The `audio.sinks` model updates as devices are plugged or removed.

</BuildIt>

## Let's Improve It

Add per-application stream control. Listen for new streams with `onStreamAdded` and display them in a list with individual volume sliders.

```qml
Repeater {
  model: audio.streams
  delegate: Row {
    required property var modelData
    spacing: 6
    Label { text: modelData.name; width: 120; elide: Text.ElideRight }
    Slider {
      from: 0; to: 150
      value: modelData.volume
      onMoved: modelData.volume = value
    }
  }
}
```

<CommonMistake>

Forgetting that PipeWire node IDs change on restart. Never store node IDs persistently. Always look up nodes by name or description from the current `audio.sinks` and `audio.streams` arrays.

</CommonMistake>

## Under the Hood

Quickshell's PipeWire service communicates over the WirePlumb D-Bus interface (`org.pipewire`). It monitors the `ObjectManager` for node additions/removals and connects to `PropertiesChanged` signals on each node. Volume changes are batched and dispatched on the QML thread, so your UI never stalls.

## Exercises

**Beginner:** Display the current volume percentage and mute state in a panel widget.

**Intermediate:** Build an OSD overlay that shows a volume bar for 2 seconds after the user scrolls on a panel area.

**Advanced:** Create a full audio mixer with sink profiles (analog/digital), per-stream routing, and a visual equalizer using `Canvas`.

<Recap :points="['PipeWire audio control is reactive through PipeWireAudio service', 'Bind volume and mute to QML controls via properties', 'Manage sinks/streams as reactive models']" next-chapter="/part-6-linux-integration/mpris" />

<!--
Sources verified for this chapter:
- https://pipewire.org/docs/ — PipeWire documentation
- https://docs.pipewire.org/page_dbus_api.html — PipeWire D-Bus API
- https://quickshell.org/docs/v0.3.0/types/PipeWire/PipeWireAudio/ — Quickshell PipeWireAudio type
- https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/ — PulseAudio compatibility docs
-->
