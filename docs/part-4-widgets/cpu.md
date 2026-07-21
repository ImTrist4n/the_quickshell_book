---
title: "CPU"
description: "Monitoring CPU usage in your desktop shell"
---

## The Problem

Users want to know when their CPU is pegged — is that compile job still running? Did a process go haywire? A CPU widget should show per-core or total utilization without itself consuming noticeable CPU time.

## The Naive Approach

Read `/proc/stat` in a `Timer` and compute deltas between idle and total ticks. This is the standard Linux approach, but parsing text files and doing division every second adds overhead. More importantly, naive polling can miss short spikes.

```qml
Timer {
  interval: 1000
  running: true
  repeat: true
  onTriggered: {
    // Read /proc/stat, parse lines, compute delta
    // Store prev total and prev idle
  }
}
```

<MentalModel>

Think of CPU usage like a restaurant kitchen. Total "tick" count is the number of orders taken. Idle ticks are the moments when no orders are being cooked. Utilization is (1 - idle/total) — how busy the kitchen was during the last measurement period.

</MentalModel>

## The Idea

Read `/proc/stat` at regular intervals, compute the delta of total and idle ticks between readings, and calculate utilization as `(total - idle) / total * 100`. Use a `Timer` but keep the work minimal. For per-core views, iterate `/proc/stat` lines starting with "cpu0", "cpu1", etc.

## Let's Build It

A total-CPU usage widget:

<BuildIt>

```qml
import Quickshell
import QtQuick

Row {
  spacing: 6

  property real cpuUsage: 0
  property var prevTotal: 0
  property var prevIdle: 0

  function updateCpu() {
    var lines = readFile("/proc/stat").split("\n")
    var parts = lines[0].trim().split(/\s+/)
    var idle = parseInt(parts[4]) + parseInt(parts[5])
    var total = 0
    for (var i = 1; i < parts.length; i++) total += parseInt(parts[i])

    var deltaTotal = total - prevTotal
    var deltaIdle = idle - prevIdle
    cpuUsage = deltaTotal > 0 ? Math.round((1 - deltaIdle / deltaTotal) * 100) : 0

    prevTotal = total
    prevIdle = idle
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: updateCpu()
  }

  Text {
    text: ""
    font.pixelSize: 14
    color: cpuUsage > 80 ? "#f38ba8" : cpuUsage > 60 ? "#fab387" : "#89b4fa"
  }

  Text {
    text: cpuUsage + "%"
    font.pixelSize: 13
    color: "#cdd6f4"
  }
}
```

</BuildIt>

## Let's Improve It

Add a sparkline graph and per-core breakdown:

```qml
Column {
  spacing: 4

  property var history: []
  property int coreCount: 0
  property var coreUsage: []

  function readCpuStats() {
    var lines = readFile("/proc/stat").split("\n")
    var results = []
    for (var i = 0; i < lines.length; i++) {
      if (!lines[i].startsWith("cpu")) break
      results.push(parseCpuLine(lines[i]))
    }
    return results
  }

  // ... delta computation for each core ...

  Canvas {
    width: 60; height: 24
    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      ctx.strokeStyle = "#89b4fa"
      ctx.lineWidth = 1.5
      ctx.beginPath()
      for (var i = 0; i < history.length; i++) {
        var x = i / Math.max(1, history.length - 1) * width
        var y = height - (history[i] / 100 * height)
        if (i === 0) ctx.moveTo(x, y)
        else ctx.lineTo(x, y)
      }
      ctx.stroke()
    }
  }

  Row {
    spacing: 4
    Repeater {
      model: coreUsage
      Text {
        text: "C" + index + ": " + modelData + "%"
        font.pixelSize: 10
        color: "#585b70"
      }
    }
  }
}
```

<CommonMistake>

**Parsing `/proc/stat` every frame.** Reading files is I/O. A 200ms interval is the fastest you should go. Every 1-2 seconds is plenty for a panel widget.

**Not handling the first reading.** On the first call, `prevTotal` is 0, producing nonsense. Use `triggeredOnStart: true` but skip computation until `prevTotal > 0`.

**Confusing guest time.** `/proc/stat` includes guest and guest_nice in both idle and total depending on kernel version. Stick to the simple model (total = sum of all columns, idle = idle + iowait) for broad compatibility.

</CommonMistake>

## Under the Hood

`/proc/stat` is a virtual file exposed by the Linux kernel's scheduler. Column 1 is `user`, column 2 `nice`, column 3 `system`, column 4 `idle`, column 5 `iowait`, and so on. The values are `USER_HZ` (typically 100Hz) ticks since boot. By comparing snapshots, you get utilization over that window.

<UnderTheHood>

Quickshell's `readFile()` reads the file synchronously. For a 2-second interval, this is fine. The `Canvas` sparkline repaints only when `history` changes. Store a rolling window of 30-60 samples to keep memory constant.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Display the per-core usage as a horizontal bar for each core. Color bars from green (low) to red (high) based on percentage.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a CPU frequency widget instead — read `/proc/cpuinfo` or `/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq`. Show min/avg/max across all cores.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a top-processes popup: when the user hovers over the CPU widget, show a list of top 5 CPU-consuming processes (parsed from `ps` or `/proc/*/stat`). Update the list every 3 seconds only while the popup is visible.
</ExerciseBlock>

<Recap :points="['CPU usage comes from /proc/stat delta between total and idle ticks', 'Read every 1-2 seconds to keep I/O low', 'Handle first-reading edge case with prevTotal > 0 guard', 'Canvas sparklines visualize usage history', 'Per-core views require parsing cpu0, cpu1, etc. lines']" next-chapter="/part-4-widgets/ram" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

