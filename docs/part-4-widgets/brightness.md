---
title: "Brightness"
description: "Screen brightness control via DDC/backlight interfaces"
---

## The Problem

Laptop users need to adjust screen brightness frequently — moving from a dark room to sunlight changes visibility instantly. A brightness widget must read current brightness, allow setting a new level, and work across different backlight interfaces (acpi_video0, intel_backlight, amdgpu_bl0, etc.).

## The Naive Approach

Read and write `/sys/class/backlight/intel_backlight/brightness` directly. This works but has issues: the device name varies by hardware, the max brightness value differs, and writing invalid values can leave the screen unreadably dark.

```qml
function setBrightness(val) {
  exec("bash", ["-c", "echo " + val + " > /sys/class/backlight/intel_backlight/brightness"])
  // Requires root? Or udev rules for permission
}
```

<MentalModel>

Backlight control is like a dimmer switch for a lamp. The slider position maps to the lamp's brightness. The range (0 to max) corresponds to how many steps the dimmer has. Turning it all the way down doesn't break the lamp — it's just off.

</MentalModel>

## The Idea

Find the correct backlight device by probing `/sys/class/backlight/*`, read `max_brightness` and `brightness`, and write to `brightness` to change the level. Use `exec()` with appropriate permissions (or `chmod` + udev rules for non-root access).

## Let's Build It

A brightness slider widget:

<BuildIt>

```qml
import Quickshell
import QtQuick

Row {
  spacing: 8

  property string backlightPath: ""
  property int maxBrightness: 0
  property int currentBrightness: 0
  property real brightnessPercent: 0

  function probeBacklight() {
    var entries = listDir("/sys/class/backlight")
    if (entries.length === 0) return
    backlightPath = "/sys/class/backlight/" + entries[0]
    maxBrightness = parseInt(readFile(backlightPath + "/max_brightness").trim())
    updateBrightness()
  }

  function updateBrightness() {
    if (backlightPath === "") return
    currentBrightness = parseInt(readFile(backlightPath + "/brightness").trim())
    brightnessPercent = maxBrightness > 0 ? currentBrightness / maxBrightness : 0
  }

  function setBrightness(fraction) {
    if (backlightPath === "") return
    var clamped = Math.max(0, Math.min(1, fraction))
    var value = Math.round(clamped * maxBrightness)
    var result = exec("tee", [backlightPath + "/brightness"])
    // Alternatively use udev with proper group permissions
    currentBrightness = value
    brightnessPercent = clamped
  }

  Timer {
    interval: 1000
    running: backlightPath !== ""
    repeat: true
    onTriggered: updateBrightness()
  }

  Component.onCompleted: probeBacklight()

  Text {
    text: ""
    font.pixelSize: 14
    color: brightnessPercent > 0.7 ? "#f9e2af" : "#585b70"
  }

  Rectangle {
    width: 80; height: 6
    radius: 3
    color: "#313244"
    anchors.verticalCenter: parent.verticalCenter

    Rectangle {
      width: parent.width * brightnessPercent
      height: parent.height
      radius: 3
      color: "#f9e2af"
      Behavior on width { SmoothedAnimation { duration: 80 } }
    }

    MouseArea {
      anchors.fill: parent
      onPressed: mouse => setBrightness(mouse.x / width)
      onPositionChanged: mouse => setBrightness(mouse.x / width)
    }
  }

  Text {
    text: Math.round(brightnessPercent * 100) + "%"
    font.pixelSize: 12
    color: "#a6adc8"
  }
}
```

</BuildIt>

## Let's Improve It

Add keyboard shortcut support and smooth fade between brightness levels:

```qml
// Keyboard shortcuts (place on a parent Item with focus)
Item {
  focus: true
  Keys.onPressed: function(event) {
    if (event.key === Qt.Key_BrightnessDown || (event.key === Qt.Key_F2)) {
      setBrightness(brightnessPercent - 0.1)
    }
    if (event.key === Qt.Key_BrightnessUp || (event.key === Qt.Key_F3)) {
      setBrightness(brightnessPercent + 0.1)
    }
  }
}
```

<CommonMistake>

**Hardcoding the backlight device.** Your `intel_backlight` is someone else's `amdgpu_bl0` or `acpi_video0`. Always probe `/sys/class/backlight/*` and use the first entry (or let the user configure it).

**Writing without permissions.** By default, only root can write to `brightness`. Add a udev rule: `ACTION=="add", SUBSYSTEM=="backlight", RUN+="/bin/chmod 666 /sys/class/backlight/%k/brightness"`. Or add your user to the `video` group.

**Not clamping the value.** Writing a value greater than `max_brightness` or less than 0 will fail silently or produce unexpected results. Always clamp before writing.

</CommonMistake>

## Under the Hood

The Linux backlight subsystem (`/sys/class/backlight/`) is provided by the GPU driver (i915, amdgpu, nouveau) or the ACPI video driver. `max_brightness` varies: typical values are 100 (percentage-based drivers) or 937 (hardware register-based). Writing to `brightness` triggers the driver to adjust PWM duty cycle or register value, which controls the physical backlight.

<UnderTheHood>

`readFile()` and `writeFile()` in Quickshell access sysfs synchronously. For brightness, this is fine since the files are small and the write returns immediately. The `tee` command is used for writing with elevated permissions; a better approach is to use Quickshell's `writeFile()` if available, or configure udev for group-writable backlight.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Add an "auto-brightness" toggle that adjusts brightness based on the time of day (higher during daylight hours, lower at night) using a simple sine-curve model.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Handle multiple monitors with separate backlight controllers. Detect each backlight device, show them as separate sliders labeled by device name (eDP-1, HDMI-1, etc.).
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a gamma/color temperature widget that adjusts `gammastep` or `wlsunset` parameters via exec. Show a color temperature slider from 6500K (daylight) to 3500K (night).
</ExerciseBlock>

<Recap :points="['Probe /sys/class/backlight/* instead of hardcoding device names', 'Read max_brightness to scale slider to actual hardware range', 'Writing brightness requires permissions — use udev or tee', 'Clamp values to safe range before writing', 'Keyboard shortcuts make brightness control faster']" next-chapter="/part-4-widgets/weather" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

