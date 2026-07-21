---
title: "Clipboard Manager"
description: "Building a clipboard history manager with persistence and search"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['Clipboard widget', 'ListView', 'Reading & Watching Files']" you-will-build="A persistent clipboard history manager with search and favorites" />

## The Problem

The system clipboard holds only one item. Copy a second thing and the first is gone. For anyone who copies code snippets, URLs, or text frequently, this is frustrating. A clipboard manager stores history so you can retrieve anything you've copied in the past hour, day, or week.

## The Naive Approach

Poll the clipboard every second with a Timer and store changes in a JavaScript array:

```qml
property var history: []
Timer {
  interval: 1000
  running: true
  repeat: true
  onTriggered: {
    if (Clipboard.text !== "" && Clipboard.text !== lastItem) {
      history.unshift(Clipboard.text)
      lastItem = Clipboard.text
    }
  }
}
```

This wastes CPU polling and misses transient clipboard data that's been cleared before the next tick.

<MentalModel>

Think of a clipboard manager as a DVR for your copies. The system clipboard is "live TV" — only what's currently showing. A clipboard manager records everything so you can rewind and replay any moment. The DVR (your storage) can be in memory (recent items) or on disk (persistent history).

</MentalModel>

## The Idea

Use `Clipboard.text` property binding (reactive, no polling) combined with a `ListModel` for display and JSON file for persistence. Debounce rapid updates (some apps fire multiple clipboard events for one copy), and serialize to `~/.cache/quickshell/clipboard.json`.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services
import QtQml.Models
import Qt.labs.platform

PopupWindow {
  id: root
  width: 380
  height: 450
  visible: false

  property string clipboardText: Clipboard.text
  property var history: loadHistory()

  // Debounce timer
  property string lastSaved: ""
  Timer {
    id: debounce
    interval: 300
    onTriggered: {
      if (root.clipboardText !== "" && root.clipboardText !== root.lastSaved) {
        root.history = [root.clipboardText].concat(
          root.history.filter(item => item !== root.clipboardText)
        ).slice(0, 100)
        root.lastSaved = root.clipboardText
        saveHistory()
      }
    }
  }

  onClipboardTextChanged: {
    debounce.restart()
  }

  function loadHistory() {
    var path = Quickshell.cachePath("clipboard.json")
    try {
      var file = Qt.readFile(path)
      return JSON.parse(file) || []
    } catch (e) {
      return []
    }
  }

  function saveHistory() {
    var path = Quickshell.cachePath("clipboard.json")
    Qt.writeFile(path, JSON.stringify(history))
  }

  Rectangle {
    anchors.fill: parent; color: "#1e1e2e"; radius: 8

    Column {
      anchors.fill: parent; anchors.margins: 12; spacing: 8

      Text { text: "Clipboard History"; font.pixelSize: 16; font.bold: true; color: "#cdd6f4" }
      Text { text: history.length + " items"; font.pixelSize: 11; color: "#6c7086" }

      ListView {
        width: parent.width; height: parent.height - 60
        model: history
        spacing: 4
        clip: true

        delegate: Rectangle {
          required property var modelData
          required property int index

          width: parent.width; height: 48; radius: 6
          color: "#313244"

          Text {
            anchors { fill: parent; margins: 8 }
            text: modelData
            color: "#cdd6f4"; font.pixelSize: 12
            elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              Clipboard.text = modelData
              root.visible = false
            }
          }
        }

        ScrollBar.vertical: ScrollBar { active: true }
      }
    }
  }
}
```

<BuildIt>

`Quickshell.cachePath()` returns `~/.cache/quickshell/` — the standard location for non-essential app data. `JSON.stringify/parse` serializes the history array for persistence. The debounce timer prevents duplicate entries from clipboard event storms.

</BuildIt>

## Let's Improve It

Add search filtering, pinned favorites, and keyboard navigation:

```qml
property string searchText: ""

TextField {
  id: searchField
  width: parent.width; height: 32
  placeholderText: "Search clipboard..."
  onTextChanged: root.searchText = text
}

ListView {
  model: history.filter(item =>
    item.toLowerCase().includes(searchText.toLowerCase())
  )
  // ...
}
```

<CommonMistake>

**Not handling binary clipboard data.** `Clipboard.text` only handles text. Images, files, and rich text use separate MIME types. A production clipboard manager should use `Clipboard.mimeTypes` and handle `image/png`, `text/html`, and `text/uri-list`.

**Writing to cache on every copy.** If you copy 100 times in a minute, writing JSON to disk each time is wasteful. Debounce writes (save every 5 seconds if changes are pending) or batch writes on exit.

**Storing passwords in clipboard history.** Clipboard managers should exclude entries from known password managers or entries longer than 500 characters that look like passwords. Offer a "Clear Sensitive Data" option.

</CommonMistake>

## Under the Hood

The Wayland clipboard protocol (`wl_data_device`) uses a "data offer" model. When you copy, the source application creates a `wl_data_source` and offers it to the compositor. Other clients (like your clipboard manager) receive a `wl_data_offer` and can request the data in any advertised MIME type. Quickshell's `Clipboard.text` requests `text/plain;charset=utf-8` from the offer. For image support, you'd need to request `image/png` or `image/bmp` and decode the resulting bytes.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "Clear All" button that empties the history and deletes the cache file. Also add a "Remove" button on each item for selective deletion.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement "paste on click" — instead of just restoring to clipboard, simulate Ctrl+V (or Cmd+V) after clicking an item. Use `Qt.keyClick()` or spawn `ydotool key 29:1 47:1 47:0 29:0` for this.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a full clipboard manager with image preview. Use `Canvas` to render scaled thumbnails of copied images. Show a grid view (using `GridView`) for image items and a list view for text items, with automatic type detection.
</ExerciseBlock>

<Recap :points="['Use Clipboard.text binding for reactive clipboard watching — no polling needed', 'Debounce clipboard changes to filter rapid duplicate updates', 'Persist history as JSON to Quickshell.cachePath()', 'Add search filtering for usability with large histories']" next-chapter="/part-9-applications/control-center" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell base type with cachePath
- https://wayland.app/protocols/wayland#wl_data_device — Wayland clipboard protocol
- https://doc.qt.io/qt-6/qml-qtquick-listview.html — ListView type
-->
