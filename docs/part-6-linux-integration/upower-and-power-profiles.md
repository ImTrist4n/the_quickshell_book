---
title: "UPower & Power Profiles"
description: "Power management with UPower and power-profiles-daemon"
---

# UPower & Power Profiles

## The Problem

A shell needs to display battery percentage, charge state, remaining time, and allow switching power profiles (performance / balanced / power-saver). Reading `/sys/class/power_supply` directly works but requires polling and parsing sysfs files, and power-profiles-daemon uses D-Bus.

## The Naive Approach

Reading `cat /sys/class/power_supply/BAT0/capacity` in a `Timer` every 5 seconds. This ignores power-supply hotplug, doesn't give charge/discharge rate, and offers no power profile control.

<MentalModel>

UPower is a system-level D-Bus service (`org.freedesktop.UPower`) that aggregates all power supplies. It emits `PropertiesChanged` when capacity, state, or time-to-empty changes. Power profiles are managed by `net.hadess.PowerProfiles` on D-Bus. Both are push-based — subscribe and forget.

</MentalModel>

## The Idea

Use Quickshell's `Battery` widget (Part IV) for the basics, then extend with the `Upower` D-Bus service directly for advanced metrics. Add a power profile toggle using `powerprofilesctl` or direct D-Bus calls via `Process`.

## Let's Build It

```qml
import Quickshell
import Quickshell.Widgets

Row {
  spacing: 6

  Battery {
    id: battery
    visible: battery.available
  }

  // Power profile switcher
  Button {
    text: "Power Saver"
    onClicked: {
      Process.exec("powerprofilesctl set power-saver")
    }
  }

  Button {
    text: "Balanced"
    onClicked: {
      Process.exec("powerprofilesctl set balanced")
    }
  }

  Button {
    text: "Performance"
    onClicked: {
      Process.exec("powerprofilesctl set performance")
    }
  }
}
```

<BuildIt>

The `Battery` widget handles UPower D-Bus integration internally — it binds to `Battery.percentage`, `Battery.charging`, and `Battery.timeRemaining`. For power profiles, we shell out to `powerprofilesctl`. A more robust version would call D-Bus directly via `Process` with `gdbus` or `busctl`.

</BuildIt>

## Let's Improve It

Read the current active profile on startup and highlight the active button. Poll `powerprofilesctl get` at startup and cache it. For a fully reactive approach, subscribe to `net.hadess.PowerProfiles` `PropertiesChanged` over D-Bus.

```qml
property string activeProfile: "balanced"

Component.onCompleted: {
  Process.run("powerprofilesctl get").stdout.then(out => {
    activeProfile = out.trim()
  })
}
```

<CommonMistake>

Assuming all devices have a battery. Always check `Battery.available` before showing battery UI. Some desktops (desktops, servers) lack batteries entirely. Also check that `powerprofilesctl` exists before showing the profile switcher.

</CommonMistake>

## Under the Hood

UPower exposes `org.freedesktop.UPower.Device` on each battery. Properties include `Percentage`, `State` (charging/discharging/full), `TimeToEmpty`, `EnergyRate`. Quickshell's `Battery` widget subscribes to `PropertiesChanged` on all matching devices. Power profiles use `net.hadess.PowerProfiles` which has `ActiveProfile` and `Profiles` properties.

## Exercises

**Beginner:** Display battery icon that changes based on charge level (0-25%, 25-50%, etc.) and charging state.

**Intermediate:** Build a power profile popup that shows performance mode descriptions and shows which profile is active.

**Advanced:** Create a power-saving mode that dims the screen, reduces animation framerate, and pauses non-essential timers when on battery below 20%.

<Recap :points="['UPower and power-profiles-daemon give your shell battery state and performance control', 'Quickshell Battery widget wraps UPower for charge and status', 'Power profiles (performance/balanced/power-saver) require direct D-Bus or powerprofilesctl']" next-chapter="/part-6-linux-integration/bluez" />

<!--
Sources verified for this chapter:
- https://upower.freedesktop.org/docs/ — UPower API documentation
- https://www.freedesktop.org/software/power-profiles-daemon/ — power-profiles-daemon documentation
- https://quickshell.org/docs/v0.3.0/types/UPower/Battery/ — Quickshell Battery type
- https://quickshell.org/docs/v0.3.0/services/UPower/ — Quickshell UPower service
-->
