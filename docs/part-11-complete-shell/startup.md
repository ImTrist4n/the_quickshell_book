---
title: "Startup"
description: "Managing autostart applications and startup scripts"
---

<ChapterMeta reading-time="10 min" :difficulty="1" :prerequisites="['Session management', 'Qt.process']" you-will-build="An autostart manager that launches applications on shell startup" />

## The Problem

When the shell starts, users expect their applications to launch automatically — notification daemon, network manager applet, clipboard manager, compositor settings, and more. Without an autostart system, users manually launch each application after login.

## The Naive Approach

List commands directly in `shell.qml`:

```qml
Component.onCompleted: {
  Qt.process(["waybar"])
  Qt.process(["nm-applet"])
  Qt.process(["dunst"])
  Qt.process(["swaync"])
  Qt.process(["blueman-applet"])
}
```

This works but has no ordering, no error handling, no retry logic, and ignores the freedesktop autostart spec (`~/.config/autostart/`).

<MentalModel>

Think of startup like a stage manager before a play. Each actor (application) has a call time (startup order). The stage manager checks that lighting (compositor) is ready before bringing in the set (wallpaper) before calling the actors (applications). A good stage manager has a clipboard and handles last-minute changes.

</MentalModel>

## The Idea

Create an autostart service that reads from the freedesktop `autostart` directory and supports ordered startup, delayed execution, and error handling.

## Let's Build It

```qml
// AutostartService.qml
pragma Singleton
import Quickshell
import QtQml.Models

QtObject {
  id: autostart

  function loadEntries() {
    var dirs = [
      Quickshell.configDir + "/autostart",
      Quickshell.dataDir + "/applications",
      "/etc/xdg/autostart",
      "/usr/share/applications"
    ]
    var entries = []
    dirs.forEach(function(dir) {
      var files = Qt.listDir(dir, "*.desktop")
      files.forEach(function(file) {
        var entry = parseDesktopFile(dir + "/" + file)
        if (entry && entry.enabled) entries.push(entry)
      })
    })
    return entries
  }

  function parseDesktopFile(path) {
    // Simplified .desktop parser
    var content = Qt.open(path, "r")
    if (!content.valid) return null
    var lines = content.readAll().split("\n")
    var entry = { name: "", exec: "", enabled: true, delay: 0 }
    lines.forEach(function(line) {
      if (line.startsWith("Name=")) entry.name = line.substring(5)
      if (line.startsWith("Exec=")) entry.exec = line.substring(5)
      if (line.startsWith("X-GNOME-Autostart-enabled="))
        entry.enabled = line.endsWith("true")
      if (line.startsWith("X-GNOME-Autostart-Delay="))
        entry.delay = parseInt(line.substring(24)) || 0
    })
    return entry
  }

  function addEntry(name, command, delay) {
    var desktopContent = "[Desktop Entry]\nType=Application\nName=" + name + "\nExec=" + command + "\n"
    if (delay > 0) desktopContent += "X-GNOME-Autostart-Delay=" + delay + "\n"
    Qt.writeFile(Quickshell.configDir + "/autostart/" + name.replace(/\s/g, "-") + ".desktop", desktopContent)
  }

  function removeEntry(name) {
    Qt.removeFile(Quickshell.configDir + "/autostart/" + name.replace(/\s/g, "-") + ".desktop")
  }

  function start() {
    var entries = loadEntries()
    // Sort by delay, then execute
    entries.sort(function(a, b) { return a.delay - b.delay })
    entries.forEach(function(entry) {
      Timer {
        interval: entry.delay
        running: true
        repeat: false
        onTriggered: {
          Qt.execDetached({ command: entry.exec })
        }
      }
    })
    autostart.started()
  }

  signal started()
}
```

In your `shell.qml`:

```qml
Component.onCompleted: {
  AutostartService.start()
}
```

<BuildIt>

The autostart service reads `.desktop` files from standard XDG directories, parses them for `Exec` and `X-GNOME-Autostart-Delay`, and launches each application with the specified delay. Users add custom entries by dropping `.desktop` files in `~/.config/quickshell/autostart/`.

</BuildIt>

## Let's Improve It

Add a startup progress indicator and error handling:

```qml
property int totalEntries: 0
property int startedEntries: 0
property var failedEntries: []

function start() {
  var entries = loadEntries()
  totalEntries = entries.length
  startedEntries = 0

  entries.forEach(function(entry) {
    Timer {
      interval: entry.delay
      running: true
      repeat: false
      onTriggered: {
        var result = Qt.execDetached({ command: entry.exec })
        startedEntries++
        if (!result) {
          failedEntries.push(entry.name)
          console.warn("Failed to start: " + entry.name)
        }
      }
    }
  })
}
```

<CommonMistake>

**Launching everything simultaneously.** Ten applications starting at once compete for disk I/O, memory, and CPU. Stagger startup with delays — 1-2 seconds between each launch. The freedesktop spec's `X-GNOME-Autostart-Delay` field exists for exactly this reason.

**Not handling .desktop file variations.** The `Exec` key can contain field codes like `%u` (URL), `%f` (file), `%F` (multiple files). Strip these before executing. Also handle translations: `Name[de]=...` should be parsed for the current locale.

**Assuming sequential execution.** `Qt.process()` is asynchronous. If application A needs to be running before application B starts (e.g., `mpd` before `ncmpcpp`), you need to chain the launches with completion callbacks.

</CommonMistake>

## Under the Hood

The freedesktop autostart specification defines `.desktop` files in `~/.config/autostart/` (user) and `/etc/xdg/autostart/` (system). Each file has `Exec` (the command to run), `TryExec` (check if the binary exists first), `OnlyShowIn` / `NotShowIn` (desktop environment filtering), and various delay/hidden options. Gnome adds `X-GNOME-Autostart-Delay` and `X-GNOME-Autostart-enabled` as non-standard but widely-used extensions.

## Exercises

<ExerciseBlock :difficulty="1">
Create a GUI autostart editor popup. List all autostart entries with enable/disable toggles. Allow users to add new entries (name + command) and remove existing ones. Store changes to `~/.config/autostart/`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add conditional startup — only launch certain applications if specific conditions are met. For example: launch `blueman-applet` only if Bluetooth hardware is detected; launch `megasync` only if the user has logged in before.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a "startup report" popup. After all autostart entries have been processed, show a summary: "12 applications started successfully, 2 failed." Clicking "View Details" shows which applications failed and why.
</ExerciseBlock>

<Recap :points="['Use freedesktop .desktop files for standard-compliant autostart', 'Stagger startup with delays to avoid boot-time resource contention', 'Handle .desktop field codes and translations', 'Provide error feedback for failed launches']" next-chapter="/part-12-advanced/custom-services" />

<!--
Sources verified for this chapter:
- https://specifications.freedesktop.org/autostart-spec/latest/ — freedesktop autostart spec
- https://developer.gnome.org/autostart/ — GNOME autostart extensions
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.process(), Quickshell.execDetached()
-->
