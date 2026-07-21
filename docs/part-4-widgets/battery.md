---
title: "Battery"
description: "Displaying battery status and percentage using UPower"
---

## The Problem

Laptop users need to know their battery level at a glance. A battery widget must read charge percentage, charging status, remaining time, and handle multiple batteries (some laptops have two). It also needs to warn when the battery is critically low.

## The Naive Approach

Parse `/sys/class/power_supply/BAT0/uevent` with a shell command and a `Timer`. This works but is fragile: paths differ between machines (BAT0 vs BAT1, hid-ffb0000-battery, etc.), polling a file every few seconds is wasteful, and you miss transition events (plugged in, unplugged, low charge).

```qml
Timer {
  interval: 5000
  running: true
  repeat: true
  onTriggered: {
    // read /sys/class/power_supply/BAT0/uevent
    // parse capacity, status, etc.
  }
}
```

<MentalModel>

A battery widget is like a car's fuel gauge. You don't need real-time updates — checking every 5-30 seconds is fine. But you must react instantly when the charging cable is plugged in (the icon should change immediately, not 30 seconds later).

</MentalModel>

## The Idea

Quickshell provides `UPower` integration via the `UPower` singleton. It handles multi-battery aggregation, change signals, and standardized status reporting. No shell commands, no polling, no fragile paths.

## Let's Build It

A battery widget using `UPower`:

<BuildIt>

```qml
import Quickshell
import Quickshell.Host

Row {
  spacing: 6

  property var battery: UPower.devices[0]
  property int charge: battery ? battery.percent : -1
  property bool charging: battery ? battery.status === "charging" : false
  property bool pluggedIn: battery ? battery.status === "fully-charged" || battery.status === "charging" : false

  Text {
    text: {
      if (!battery) return ""
      if (battery.status === "charging") return ""
      if (battery.percent <= 10) return ""
      if (battery.percent <= 35) return ""
      if (battery.percent <= 65) return ""
      if (battery.percent <= 85) return ""
      return ""
    }
    font.pixelSize: 14
    color: {
      if (!battery) return "#6c7086"
      if (battery.percent <= 10) return "#f38ba8"
      if (battery.percent <= 20) return "#fab387"
      return "#a6e3a1"
    }
  }

  Text {
    text: battery ? battery.percent + "%" : ""
    font.pixelSize: 13
    color: "#cdd6f4"
    visible: battery !== undefined
  }
}
```

</BuildIt>

## Let's Improve It

Add remaining time estimation and a critical battery warning:

```qml
Row {
  spacing: 6

  property var battery: UPower.devices[0]

  Text {
    text: {
      if (!battery || !battery.available) return ""
      if (battery.status === "charging") return ""
      var pct = battery.percent
      if (pct <= 10) return ""
      if (pct <= 35) return ""
      if (pct <= 65) return ""
      if (pct <= 85) return ""
      return ""
    }
    font.pixelSize: 14
    color: (!battery || !battery.available) ? "#6c7086"
         : battery.percent <= 10 ? "#f38ba8"
         : battery.percent <= 20 ? "#fab387"
         : "#a6e3a1"
  }

  Text {
    text: battery ? battery.percent + "%" : ""
    font.pixelSize: 13
    color: "#cdd6f4"
  }

  Text {
    text: {
      if (!battery || battery.status === "fully-charged") return ""
      var secs = battery.timeRemaining
      if (secs <= 0) return ""
      var hours = Math.floor(secs / 3600)
      var mins = Math.floor((secs % 3600) / 60)
      return (battery.status === "charging" ? "+" : "-") + hours + "h " + mins + "m"
    }
    font.pixelSize: 11
    color: "#585b70"
  }

  Timer {
    interval: 30000
    running: battery && battery.percent <= 10 && battery.status !== "charging"
    repeat: true
    onTriggered: {
      // Emit a notification or flash the widget
      print("Battery critical: " + battery.percent + "%")
    }
  }
}
```

<CommonMistake>

**Assuming a single battery device.** `UPower.devices` is an array. Some laptops have BAT0 and BAT1. Use `UPower`'s aggregate properties or iterate the array. Never hardcode index 0.

**Polling `UPower` manually.** `UPower` properties are reactive. Bind directly to `UPower.devices[0].percent` — the UI updates automatically when the value changes. Don't add a `Timer`.

**Ignoring `available`.** A desktop PC with no battery returns undefined devices. Check `battery && battery.available` before accessing properties to avoid null errors.

</CommonMistake>

## Under the Hood

`UPower` is a Quickshell module that wraps the D-Bus interface (`org.freedesktop.UPower`). It listens for `DeviceChanged` and `PropertiesChanged` signals. When you bind a QML property to `UPower.devices[0].percent`, Quickshell's property binding engine connects to the underlying D-Bus property change signal — no polling required.

<UnderTheHood>

`UPower` internally iterates `UPower.GetDisplayDevice` for the aggregate battery. Each device object is a `QsUPowerDevice` that maps D-Bus properties (`Percentage`, `State`, `TimeToEmpty`, `TimeToFull`) to QML properties. Property changes are forwarded through Qt's meta-object system, triggering QML binding re-evaluation.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Show a horizontal progress bar behind the battery percentage. Color it green above 30%, yellow between 15-30%, and red below 15%.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Handle multiple batteries: sum their charge percentages (weighted by capacity) and display the combined value. Show individual status in a tooltip.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a battery history graph. Record charge percentage every minute into a list, then render the last 60 minutes as a sparkline using the `Canvas` type. Persist across shell restarts using a local file.
</ExerciseBlock>

<Recap :points="['UPower replaces fragile sysfs parsing with reactive D-Bus bindings', 'Bind directly to UPower properties — no Timer needed', 'Handle multiple batteries, desktop PCs, and unavailable devices', 'Color-code icons based on charge level for quick scanning', 'Critical-level warnings should trigger notifications']" next-chapter="/part-4-widgets/cpu" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

