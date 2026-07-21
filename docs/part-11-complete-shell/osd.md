---
title: "OSD"
description: "On-screen display for volume, brightness, and media feedback"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['PopupWindow', 'Timer']" you-will-build="A sleek OSD overlay for volume and brightness changes" />

## The Problem

When users adjust volume or brightness, they need visual feedback. An on-screen display (OSD) shows a progress bar or icon for 1-2 seconds and then fades away. Without an OSD, users overshoot or undershoot their desired level.

## The Naive Approach

Use `console.log()` for feedback:

```qml
function setVolume(v) { volume = v; console.log("Volume: " + v) }
```

No visual feedback means users can't tell the current level without looking at a widget.

<MentalModel>

Think of the OSD as a heads-up display in a fighter jet. Critical information (speed, altitude) briefly appears in your field of view, then disappears so it doesn't clutter the windshield. The OSD should be immediate, unobtrusive, and auto-dismissing.

</MentalModel>

## The Idea

Create a `PopupWindow` in the center of the screen that shows a progress bar and icon. Connect it to audio/backlight change events. Auto-dismiss after 1.5 seconds with a fade-out animation.

## Let's Build It

```qml
// OSD.qml
PopupWindow {
  id: osd
  width: 300; height: 64
  visible: false

  // Position at center of primary screen
  x: (Quickshell.screens[0].geometry.width - width) / 2
  y: Quickshell.screens[0].geometry.height * 0.4

  property string icon: "🔊"
  property string label: "Volume"
  property double value: 0.5
  property Timer dismissTimer: Timer {
    interval: 1500
    onTriggered: osd.hide()
  }

  function show(iconText, labelText, val) {
    icon = iconText
    label = labelText
    value = val
    visible = true
    opacity = 1.0
    dismissTimer.restart()
  }

  function hide() {
    fadeOut.start()
  }

  PropertyAnimation {
    id: fadeOut
    target: osd; property: "opacity"; to: 0; duration: 300; easing.type: Easing.OutCubic
    onFinished: osd.visible = false
  }

  Rectangle {
    anchors.fill: parent; radius: 12; color: "#1e1e2ee0"

    Row {
      anchors.centerIn: parent; spacing: 16

      Text { text: osd.icon; font.pixelSize: 28; anchors.verticalCenter: parent.verticalCenter }

      Column {
        anchors.verticalCenter: parent.verticalCenter; spacing: 6

        Text { text: osd.label; font.pixelSize: 12; color: "#cdd6f4" }

        Rectangle {
          width: 180; height: 6; radius: 3; color: "#313244"
          Rectangle {
            width: parent.width * osd.value; height: 6; radius: 3
            color: osd.value > 0.8 ? "#fab387" : osd.value < 0.2 ? "#f38ba8" : "#89b4fa"
          }
        }

        Text { text: Math.round(osd.value * 100) + "%"; font.pixelSize: 11; color: "#a6adc8" }
      }
    }
  }
}
```

Connect to audio changes:

```qml
// In your shell
OSD {
  id: osdOverlay

  Connections {
    target: AudioService
    function onVolumeChanged(vol) {
      osdOverlay.show("🔊", "Volume", vol)
    }
  }
}
```

<BuildIt>

The OSD appears center-screen when triggered, shows an icon + label + progress bar, and auto-fades after 1.5 seconds. The color changes based on level (red for low, yellow for high, blue for normal).

</BuildIt>

## Let's Improve It

Add different OSD types for different actions:

```qml
function showVolume(vol) { show("🔊", "Volume", vol) }
function showBrightness(bri) { show("☀️", "Brightness", bri) }
function showMute(muted) { show(muted ? "🔇" : "🔊", "Volume", muted ? 0 : lastVolume) }
function showKbdBright(bri) { show("💡", "Keyboard", bri) }
function showProfile(profile) { show("⚡", "Power Profile", profile === "performance" ? 1 : profile === "balanced" ? 0.5 : 0.2) }
```

<CommonMistake>

**Not positioning correctly.** The OSD should appear at a consistent, comfortable position — typically center-screen at 40% from the top. Use `Quickshell.screens[0].geometry` for calculation.

**Blocking input.** The OSD should not capture clicks or keyboard input. Set `dismissOnClickOutside: false` and ensure it doesn't interfere with the action that triggered it.

**No fade-out animation.** An abrupt `visible = false` is jarring. Always use a fade animation (300ms) for smooth dismissal.

</CommonMistake>

## Under the Hood

The OSD is a `PopupWindow` positioned absolutely on the screen (not relative to another window). It uses `x` and `y` pixel coordinates from `Quickshell.screens[0].geometry`. The fade animation is a `PropertyAnimation` on `opacity`. The dismiss timer ensures the OSD doesn't linger.

## Exercises

<ExerciseBlock :difficulty="1">
Add queuing — if a new OSD event arrives while one is already showing, cancel the fade-out, update the value, and restart the timer. This prevents OSD "stacking" during rapid adjustments.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Support OSD on the correct monitor. Use the screen that contains the mouse pointer (via cursor position from compositor IPC) instead of always showing on the primary screen.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a "media playback OSD" that shows album art, track title, and artist for 3 seconds when the track changes. Use `MprisService` data and display the album art as a small thumbnail on the left.
</ExerciseBlock>

<Recap :points="['OSD shows visual feedback for volume, brightness, and other adjustments', 'Position at center-screen, 40% from top for comfortable viewing', 'Auto-dismiss after 1.5s with 300ms fade-out animation', 'Queue new events to prevent overlapping OSD instances']" next-chapter="/part-11-complete-shell/settings-app" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/ — PopupWindow
- https://doc.qt.io/qt-6/qml-qtquick-propertyanimation.html — PropertyAnimation
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.screens
-->
