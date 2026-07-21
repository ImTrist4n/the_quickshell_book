---
title: "Power Profiles"
description: "Building a power profile manager for laptops and portable devices"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['Audio controls', 'Battery widget']" you-will-build="A power profile switcher for performance/balanced/power-saver modes" />

## The Problem

Laptop users need to switch between performance profiles depending on workload — power-saver on battery, balanced for daily use, performance when plugged in and gaming. Without shell integration, users dig through system settings or run `powerprofilesctl` manually.

## The Naive Approach

Run `cpupower` commands directly:

```qml
function setPerformance() {
  Qt.process(["cpupower", "frequency-set", "-g", "performance"])
}
function setPowerSave() {
  Qt.process(["cpupower", "frequency-set", "-g", "powersave"])
}
```

`cpupower` is CPU-specific and doesn't handle other power-saving measures (screen brightness, PCIe ASPM, NVMe power states, etc.). The modern approach is `power-profiles-daemon`.

<MentalModel>

Think of power profiles as gears in a car. First gear (power-saver) gets you moving efficiently but slowly. Third gear (balanced) handles daily driving. Fifth gear (performance) consumes more fuel but delivers maximum speed. The driver shifts gears based on the road ahead.

</MentalModel>

## The Idea

Use `power-profiles-daemon` (PPD), which provides a D-Bus interface at `org.freedesktop.UPower.PowerProfiles`. It exposes available profiles, the active profile, and supports switching between them with proper system-wide coordination.

## Let's Build It

```qml
// PowerService.qml
pragma Singleton
import Quickshell

QtObject {
  id: power

  readonly property var profiles: ["power-saver", "balanced", "performance"]
  property string activeProfile: "balanced"
  property bool onBattery: false

  function setProfile(profile) {
    if (profiles.indexOf(profile) >= 0) {
      Qt.process(["powerprofilesctl", "set", profile])
      activeProfile = profile
    }
  }

  function cycleProfile() {
    var currentIndex = profiles.indexOf(activeProfile)
    var nextIndex = (currentIndex + 1) % profiles.length
    setProfile(profiles[nextIndex])
  }

  function refresh() {
    Qt.process(["powerprofilesctl", "get"])
      .onStdout.connect(function(data) {
        activeProfile = data.trim()
      })
    Qt.process(["cat", "/sys/class/power_supply/AC0/online"])
      .onStdout.connect(function(data) {
        onBattery = data.trim() !== "1"
      })
  }

  Timer {
    interval: 5000; running: true; repeat: true
    onTriggered: power.refresh()
  }
}
```

Power profile popup:

```qml
// PowerControl.qml
PopupWindow {
  width: 250; height: 160
  anchor.window: panel

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 16 }; spacing: 12

      Text { text: "Power Profile"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }
      Text { text: PowerService.onBattery ? "On Battery" : "Plugged In"; font.pixelSize: 11; color: PowerService.onBattery ? "#fab387" : "#a6e3a1" }

      Repeater {
        model: PowerService.profiles

        delegate: Rectangle {
          required property string modelData
          width: parent.width; height: 32; radius: 6
          color: modelData === PowerService.activeProfile ? "#89b4fa" : "#313244"
          opacity: modelData === PowerService.activeProfile ? 1 : 0.6

          Text {
            text: modelData.charAt(0).toUpperCase() + modelData.slice(1).replace("-", " ")
            anchors.centerIn: parent; color: "white"; font.pixelSize: 12; font.bold: modelData === PowerService.activeProfile
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: PowerService.setProfile(modelData)
          }
        }
      }
    }
  }
}
```

<BuildIt>

The power service reads and sets profiles via `powerprofilesctl`. The popup shows available profiles as selectable buttons with the active one highlighted. AC power status is shown to help users decide which profile to use.

</BuildIt>

## Let's Improve It

Automatically switch profiles based on power source:

```qml
property bool autoSwitch: true

onOnBatteryChanged: {
  if (autoSwitch) {
    if (onBattery) {
      setProfile("power-saver")
    } else {
      setProfile("performance")
    }
  }
}
```

<CommonMistake>

**Assuming `power-profiles-daemon` is installed.** PPD is common on GNOME-centric distros but may not be present on Arch, NixOS, or minimal setups. Check for its availability at startup. Fall back to a warning message if not found.

**Only switching CPU governor.** A power profile is more than CPU frequency. Modern PPD also adjusts: screen brightness, Wi-Fi power save, Bluetooth idle timeout, disk write caching, and GPU power state. Let PPD coordinate all these — don't try to replicate it.

**Not handling AC adapter detection.** On some laptops, `AC0` might be named differently (`AC1`, `ADP1`). Check multiple paths or use `udevadm` to detect the correct power supply device.

</CommonMistake>

## Under the Hood

`power-profiles-daemon` uses D-Bus at `org.freedesktop.UPower.PowerProfiles` with methods `GetProfiles`, `GetActiveProfile`, `SetActiveProfile`, and property `ActiveProfile`. The daemon integrates with systemd-logind for inhibitor handling (certain applications can prevent profile switches). It also coordinates with `thermald` for thermal management and `tuned` for system tuning profiles.

## Exercises

<ExerciseBlock :difficulty="1">
Replace `powerprofilesctl` calls with direct D-Bus calls to `org.freedesktop.UPower.PowerProfiles`. Subscribe to `PropertiesChanged` signals for instant updates without polling.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a battery charge threshold control. For laptops with `charge_control_end_threshold` (common on Lenovo, ASUS), expose a slider in the power popup to limit charging to 80% for battery longevity.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement "per-application profiles" — when a specific application (e.g., a game) is focused, temporarily switch to performance. When it loses focus, revert to balanced. Use `xprop` or `hyprctl` to detect focused window class.
</ExerciseBlock>

<Recap :points="['Use power-profiles-daemon for coordinated system-wide power management', 'Automatically switch profiles on AC plug/unplug for convenience', 'Display available profiles with the active one highlighted', 'Check for PPD availability before showing controls']" next-chapter="/part-11-complete-shell/multi-monitor" />

<!--
Sources verified for this chapter:
- https://www.freedesktop.org/software/power-profiles-daemon/ — PPD documentation
- https://gitlab.freedesktop.org/upower/power-profiles-daemon — PPD GitLab
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.process()
-->
