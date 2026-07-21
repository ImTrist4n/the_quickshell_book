---
title: "Disk"
description: "Monitoring disk usage and space in your panel"
---

## The Problem

A disk widget shows filesystem usage — how full is the root partition? What about `/home`? Users need to know when disk space drops below a safe threshold before they lose the ability to write files.

## The Naive Approach

Run `df -h /` in a `Timer`, parse the output line, and extract the "Use%" column. This spawns a subprocess every poll interval, which is expensive. The parsing is fragile because `df` output formatting varies by locale and filesystem type.

```qml
Timer {
  interval: 60000
  onTriggered: {
    // "df -h /" and parse, but what about locale issues?
  }
}
```

<MentalModel>

Disk space is like closet storage. The total closet size is your partition capacity. Used space is the clothes you own. Available space is the empty shelves — you won't notice until you try to store a winter coat and find no room.

</MentalModel>

## The Idea

Read `/proc/mounts` to find mounted filesystems, then read `/sys/fs/*/stats` or use the `statfs()` syscall via Quickshell's `FsInfo` utility if available. More practically, call `df` once at startup and at a slow interval (30-60s), filtering to real filesystems (ext4, btrfs, xfs) and ignoring pseudo-fs (proc, sys, tmpfs).

## Let's Build It

A disk usage widget for the root partition:

<BuildIt>

```qml
import Quickshell
import QtQuick

Row {
  spacing: 6

  property string target: "/"
  property real total: 0
  property real used: 0
  property real usedPercent: 0

  function updateDisk() {
    var result = exec("df", ["-k", target])
    var lines = result.stdout.trim().split("\n")
    if (lines.length < 2) return
    var parts = lines[1].split(/\s+/)
    total = parseInt(parts[1]) * 1024
    used = parseInt(parts[2]) * 1024
    usedPercent = total > 0 ? Math.round(used / total * 100) : 0
  }

  Timer {
    interval: 30000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: updateDisk()
  }

  Text {
    text: ""
    font.pixelSize: 14
    color: usedPercent > 90 ? "#f38ba8" : usedPercent > 75 ? "#fab387" : "#89dceb"
  }

  Text {
    text: usedPercent + "%"
    font.pixelSize: 13
    color: "#cdd6f4"
    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      Rectangle {
        id: tooltip
        visible: parent.containsMouse
        width: details.width + 20
        height: details.height + 10
        radius: 4
        color: "#181825"
        border.color: "#313244"
        z: 10
        y: -height - 6

        Text {
          id: details
          anchors.centerIn: parent
          text: {
            function toG(b) { return (b / 1073741824).toFixed(1) + "G" }
            return "Used: " + toG(disk.used) + " / " + toG(disk.total)
          }
          font.pixelSize: 11
          color: "#a6adc8"
        }
      }
    }
  }
}
```

</BuildIt>

## Let's Improve It

Monitor multiple mount points and show the most critical one:

```qml
property var mounts: ["/", "/home"]
property var diskData: ({})

function updateAll() {
  var result = exec("df", ["-k"].concat(mounts))
  var lines = result.stdout.trim().split("\n")
  for (var i = 1; i < lines.length; i++) {
    var parts = lines[i].split(/\s+/)
    var mount = parts[parts.length - 1]
    var total = parseInt(parts[1]) * 1024
    var used = parseInt(parts[2]) * 1024
    diskData[mount] = { total: total, used: used, pct: total > 0 ? used / total : 0 }
  }
}

// Show the mount with highest usage percentage
property var worst: {
  var maxPct = 0
  var worstKey = ""
  for (var key in diskData) {
    if (diskData[key].pct > maxPct) {
      maxPct = diskData[key].pct
      worstKey = key
    }
  }
  return worstKey ? diskData[worstKey] : null
}
```

<CommonMistake>

**Parsing `df` output with regex in locale-aware environments.** The "Use%" column may have a trailing `%` or locale-specific formatting. Use `-k` flag for consistent KB output and `--no-sync` to avoid filesystem sync delays.

**Monitoring pseudo-filesystems.** `/proc`, `/sys`, `/dev`, `/run`, and `tmpfs` mount points change constantly and are not real disks. Filter to known filesystem types (ext4, btrfs, xfs, ntfs, vfat).

**Polling too fast.** Disk space changes on the order of megabytes per second during large writes, but your widget doesn't need sub-second updates. 30-second intervals are standard.

</CommonMistake>

## Under the Hood

`exec()` from Quickshell runs the `df` command in a subprocess, captures stdout, and returns it. Unlike a raw `Timer` + shell approach, Quickshell's `exec()` is async-safe and can be throttled. The `-k` flag ensures output is in kilobytes regardless of the system locale.

<UnderTheHood>

`df` itself reads `/proc/mounts` and calls `statfs()` on each mount point. By calling `df` instead of reimplementing `statfs()`, we leverage a well-tested tool. The subprocess overhead (fork+exec) is acceptable at 30-second intervals — roughly 2-5ms of CPU time per call.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Show disk space for `/` and `/home` as two separate progress bars. Color them independently.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a disk I/O indicator — read `/proc/diskstats` for read/write sector counts and compute a throughput rate (MB/s) for the main disk.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a filesystem explorer popup: when clicking the disk widget, show all mounted filesystems with used/total/available, filesystem type, and mount options. Auto-refresh every 60 seconds.
</ExerciseBlock>

<Recap :points="['df -k gives consistent KB output across locales', '30-second polling is sufficient for disk usage', 'Filter to real filesystems to avoid noise', 'exec() spawns a subprocess — cheap at slow intervals', 'Show the most critical mount point in the panel']" next-chapter="/part-4-widgets/network" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

