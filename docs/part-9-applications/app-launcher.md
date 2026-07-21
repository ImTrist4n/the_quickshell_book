---
title: "App Launcher"
description: "Building a keyboard-driven application launcher inspired by rofi/wofi"
---

# App Launcher

<ChapterMeta title="App Launcher" icon="grid-3x3" />

## Problem

Users need a fast, keyboard-driven way to launch applications. A launcher must search installed apps, display results instantly, and execute on selection. It should feel as snappy as rofi or wofi but built entirely in Quickshell.

## Naive Approach

Parse `.desktop` files at startup, store them in a JS array, and filter with a `RegExp` on each keystroke. No icons, no categories, no keyboard navigation.

## MentalModel

<MentalModel title="Search-Execute Loop">

A launcher is a loop: user types characters, results filter in real time, user selects one, application launches. The model is the desktop entry database. The view is the filtered list. The controller is the keyboard input.

</MentalModel>

## Idea

Parse `.desktop` files using `Process` and `xgd-utils` or read them directly from `/usr/share/applications/`. Display results in a `ListView` with a text input. Filter using JavaScript `String.includes()` for simplicity. Launch with `Process.exec()`.

## Build It

```qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services

FloatingWindow {
  width: 500
  height: 400
  visible: false

  property var apps: []
  property var filteredApps: []

  Component.onCompleted: loadApps()

  function loadApps() {
    var result = Process.exec("sh", ["-c", "ls /usr/share/applications/*.desktop"])
    var files = result.stdout.split("\n").filter(f => f.length > 0)
    var parsed = []
    for (var i = 0; i < files.length; i++) {
      var content = Process.exec("cat", [files[i]]).stdout
      var name = content.match(/^Name=(.+)$/m)
      var exec = content.match(/^Exec=(.+)$/m)
      var icon = content.match(/^Icon=(.+)$/m)
      if (name && exec) {
        parsed.push({ name: name[1], exec: exec[1], icon: icon ? icon[1] : "" })
      }
    }
    apps = parsed
    filteredApps = parsed
  }

  Column {
    anchors.fill: parent
    padding: 8

    TextField {
      id: searchField
      width: parent.width
      placeholderText: "Search applications..."
      onTextChanged: filterApps(text)
    }

    ListView {
      id: resultsList
      width: parent.width
      height: parent.height - searchField.height - 16
      model: filteredApps
      delegate: Item {
        width: parent.width
        height: 36
        Row {
          spacing: 8
          padding: 8
          Text { text: modelData.name; font.pixelSize: 14 }
        }
        MouseArea {
          anchors.fill: parent
          onClicked: launchApp(modelData)
        }
      }
    }
  }

  function filterApps(query: string) {
    if (query.length === 0) {
      filteredApps = apps
    } else {
      var q = query.toLowerCase()
      filteredApps = apps.filter(a => a.name.toLowerCase().includes(q))
    }
  }

  function launchApp(app: var) {
    Process.exec("sh", ["-c", app.exec])
    visible = false
  }

  Shortcut {
    sequence: "Alt+Space"
    onActivated: { visible = !visible; searchField.forceActiveFocus() }
  }
}
```

## BuildIt Breakdown

`Process.exec()` runs shell commands synchronously. `.desktop` files are parsed with regex to extract `Name`, `Exec`, and `Icon`. The `TextField` filters `filteredApps` on every keystroke — cheap for ~100-500 desktop entries. `ListView` renders only visible items. Launching calls `Process.exec()` with the Exec line.

## Improve It

Use `Process.onResult` for async `.desktop` loading. Add icon rendering via `Icon` component. Cache parsed apps to a JSON file. Add fuzzy matching (fzf-style). Support desktop actions and file associations.

## CommonMistake

<CommonMistake>

Blocking the UI thread with synchronous `Process.exec()` calls. Loading 500 `.desktop` files synchronously takes ~100ms — acceptable on startup but unacceptable during use. Load asynchronously with `Process` signals.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Qt's `Process` wraps low-level `posix_spawn`. Synchronous `exec()` uses a nested event loop — it processes events while waiting, which can re-enter QML code. Always prefer the signal-based API for production. The `.desktop` file format is standardized by freedesktop.org and includes `Name`, `GenericName`, `Exec`, `Icon`, `Categories`, and `MimeType` fields.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Build a simple app launcher that lists all installed applications and launches on click.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Add keyboard navigation — arrow keys to move through results, Enter to launch, Escape to close.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Implement fuzzy search using the `fzf` algorithm in JavaScript with scoring and substring highlighting.

</ExerciseBlock>

## Recap

<Recap to="/part-9-applications/dashboard">

Your app launcher is fast and keyboard-driven. Next: a **notification center** to collect and display alerts.

</Recap>

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/introduction/ — PanelWindow, PopupWindow documentation
- https://quickshell.org/docs/v0.3.0/ — Quickshell API documentation
-->
