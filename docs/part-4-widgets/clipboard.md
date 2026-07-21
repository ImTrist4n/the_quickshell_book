---
title: "Clipboard"
description: "Reading and writing the system clipboard in Quickshell"
---

<ChapterMeta reading-time="6 min" :difficulty="2" :prerequisites="['Text, Icon, Button', 'Signals']" you-will-build="A clipboard history widget that stores recent copies" />

## The Problem

A desktop shell needs clipboard access: copy text from a launcher, paste a password manager entry, show a clipboard history popup. Without clipboard integration, users have to alt-tab to a terminal to copy anything.

## The Naive Approach

You could spawn `xclip` or `wl-clipboard` via a shell command for every clipboard operation:

```qml
// Spawn wl-copy for every copy
process = Qt.process("wl-copy", [text])
// Spawn wl-paste for every paste
process = Qt.process("wl-paste")
```

This works but adds 100-200ms latency per operation (process spawn overhead), doesn't handle image data, and won't work if those tools aren't installed.

<MentalModel>

Think of the clipboard as a shared scratchpad between applications. One app writes to it, another reads from it. The compositor acts as a moderator — it controls which app has access and notifies watchers when the content changes.

</MentalModel>

## The Idea

Quickshell provides clipboard access through the `Clipboard` singleton from `Quickshell.Services`. It wraps the Wayland data device protocol (`wl_data_device`) and gives you reactive QML bindings for clipboard content.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services

PanelWindow {
  width: 300; height: 400
  color: "#1e1e2e"
  visible: true

  // Watch clipboard text
  property string clipboardText: Clipboard.text

  // Clipboard state
  property bool hasClipboard: clipboardText !== ""
  property int lastCopyTime: 0

  Column {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    Text {
      text: "Clipboard"
      font.pixelSize: 16
      font.bold: true
      color: "#cdd6f4"
    }

    Rectangle {
      width: parent.width
      height: 80
      radius: 6
      color: "#313244"

      Text {
        anchors {
          fill: parent
          margins: 8
        }
        text: parent.parent.clipboardText || "Nothing copied"
        color: parent.parent.clipboardText ? "#cdd6f4" : "#6c7086"
        font.pixelSize: 13
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
      }
    }

    Text {
      text: "Listening for clipboard changes..."
      color: "#6c7086"
      font.pixelSize: 11
    }
  }
}
```

<BuildIt>

- **`Clipboard.text`** — a reactive property that updates whenever the clipboard content changes. You bind to it like any QML property.
- No polling, no subprocesses — the Wayland protocol pushes clipboard changes to your shell automatically.

</BuildIt>

## Let's Improve It

Add clipboard history. Store recent entries using an array and display them in a `ListView`:

```qml
import Quickshell
import Quickshell.Services
import QtQml.Models

Item {
  property string clipboardText: Clipboard.text
  property var history: []

  // Track changes with a debounce
  onClipboardTextChanged: {
    if (clipboardText === "") return
    var now = Date.now()
    // Debounce: ignore rapid changes within 500ms
    if (now - lastCopyTime < 500) return
    lastCopyTime = now

    // Add to history (avoid duplicates)
    if (history.length === 0 || history[0] !== clipboardText) {
      history = [clipboardText].concat(history.filter(
        item => item !== clipboardText
      ))
      // Keep max 20 entries
      if (history.length > 20) history = history.slice(0, 20)
    }
  }

  property int lastCopyTime: 0
}
```

<CommonMistake>

**Polling the clipboard.** Don't set a `Timer` to check clipboard content every second. Use `Clipboard.text` binding — it updates via signals from the Wayland data device protocol, which is instant and zero-cost when idle.

**Forgetting that images are separate.** `Clipboard.text` only watches text content. Images use `Clipboard.image` or the MIME-based API. If your shell needs image paste support, check `Clipboard.mimeTypes` for available formats before reading.

**Not debouncing clipboard updates.** Some applications fire multiple clipboard updates when you copy (once for text/plain, once for text/html, etc.). Debounce with a timer short enough not to miss real copies.

</CommonMistake>

## Under the Hood

The `Clipboard` singleton wraps the `wl_data_device` Wayland protocol. When the compositor detects a new data offer (from Ctrl+C or programmatic copy), it sends a `wl_data_device.data_offer` event to all listening clients. Quickshell's clipboard implementation receives this event, reads the offered MIME types, and emits a change signal. The `text` property is updated lazily — the clipboard content isn't fetched until a binding actually reads it.

## Exercises

<ExerciseBlock :difficulty="1">
Display the clipboard text in a panel tooltip. When clipboard changes, show a brief "Copied: ..." notification that auto-dismisses after 2 seconds.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a "Clear" button that empties the clipboard history and clears the system clipboard (write empty string to Clipboard.text).
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a clipboard manager that shows the history in a `ListView`, lets you click an item to restore it to the clipboard, and persists history to a file so it survives a reboot.
</ExerciseBlock>

<Recap :points="['Clipboard.text is a reactive binding to system clipboard content', 'No polling needed — Wayland data device protocol pushes changes', 'Debounce clipboard changes to filter rapid duplicate updates', 'Images use a separate API path via mimeTypes']" next-chapter="/part-4-widgets/notifications" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

