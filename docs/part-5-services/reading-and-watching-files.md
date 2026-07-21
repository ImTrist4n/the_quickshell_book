---
title: "Reading & Watching Files"
description: "Reading and watching files for changes in Quickshell"
---

# Reading & Watching Files

## The Problem

Your shell needs to display file contents: brightness values from `/sys/class/backlight/`, battery capacity from `/sys/class/power_supply/`, or configuration values from a JSON file. Polling these files with a `Timer` and `Process` is wasteful and slow to react.

## The Naive Approach

A `Timer` that reads a file every second using a shell command:

```qml
Timer {
  interval: 1000
  running: true
  repeat: true
  onTriggered: {
    var proc = processComponent.createObject(null, {
      command: ["cat", "/sys/class/backlight/intel_backlight/brightness"]
    })
    proc.onStdout = (d) => brightness = parseInt(d.trim())
  }
}
```

This spawns a process every second — terrible for battery life and adds latency.

<MentalModel>

A file watcher is a mail carrier who stands by your mailbox and rings the bell the instant a letter arrives. Polling is you walking to the mailbox every minute to check. Both get the mail, but only the watcher lets you know immediately without wasted trips.

</MentalModel>

## The Idea

Quickshell's `TextFile` type reads a file and emits `onChanged` whenever the file content changes. It uses OS-level file monitoring (`inotify` on Linux, `kqueue` on BSD) to detect changes instantly without polling.

## Let's Build It

<BuildIt>

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts

ColumnLayout {
  spacing: 8

  Text {
    text: "Current Brightness"
    color: "#565f89"
    font.pixelSize: 12
  }

  Text {
    id: brightnessText
    text: brightnessFile.content + "%"
    color: "#c0caf5"
    font.pixelSize: 28
    font.bold: true
  }

  TextFile {
    id: brightnessFile
    path: "/sys/class/backlight/intel_backlight/brightness"
    onContentChanged: {
      // Content is already in .content property
      brightnessText.text = content.trim() + "%"
    }
  }
}
```

</BuildIt>

## Let's Improve It

For structured data like JSON config files, combine `TextFile` with safe JSON parsing:

```qml
Item {
  property string rawConfig: configFile.content
  property var configData: parseJSON(rawConfig)
  property int panelHeight: configData.panel?.height ?? 36

  TextFile {
    id: configFile
    path: "~/.config/quickshell/config.json"
  }

  function parseJSON(text) {
    try { return JSON.parse(text) }
    catch (e) { return {} }
  }
}
```

For binary-unsafe files or files with trailing newlines, use `.trim()` before processing:

```qml
TextFile {
  id: sensorFile
  path: "/sys/class/thermal/thermal_zone0/temp"
  onContentChanged: {
    var raw = content.trim()
    var celsius = parseInt(raw) / 1000
    tempText.text = celsius.toFixed(1) + "°C"
  }
}
```

<CommonMistake>

**Watching files that change too frequently.** Some kernel sysfs files update dozens of times per second. `TextFile` fires `onContentChanged` for every write, which can overwhelm the UI thread. Consider debouncing with a `Timer` that reads the `.content` property at a throttled rate.

**Assuming the file exists.** A `TextFile` with an invalid `path` silently fails. Check the `.exists` property and provide a fallback display.

**Not trimming whitespace.** Sysfs files often have trailing newlines. Always `.trim()` before parsing numeric or comparison operations.

</CommonMistake>

## Under the Hood

`TextFile` uses `QFileSystemWatcher` internally on Qt-supported platforms and `inotify` on Linux through Quickshell's platform abstraction layer. When the file is modified, the OS notifies Quickshell, which re-reads the file content and updates the `.content` property, triggering all dependent bindings.

<UnderTheHood>

`TextFile` reads the entire file into memory on each change. For large files (>1MB), this may cause frame drops. Quickshell does not support `mmap` or incremental reads — for large files, use `Process` with `tail` or a custom streaming approach.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Use `TextFile` to read `/sys/class/power_supply/BAT0/capacity` and display the battery percentage. Make it update automatically when the file changes.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a config-driven panel: read a JSON config file that specifies `backgroundColor`, `height`, and `fontColor`. Apply these properties to a `PanelWindow`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a simple log viewer that tails `/var/log/syslog` using `TextFile`. Add a filter `TextField` that hides lines not matching the search term.
</ExerciseBlock>

<Recap :points="['TextFile reads file contents and watches for changes via inotify/kqueue', 'Use .content property for the current file contents', 'onContentChanged fires when the OS detects a file modification', 'Always trim() sysfs file contents before numeric parsing', 'Debounce rapidly-changing files to avoid UI overload']" next-chapter="/part-5-services/ipc" />

<!-- Sources verified -->
