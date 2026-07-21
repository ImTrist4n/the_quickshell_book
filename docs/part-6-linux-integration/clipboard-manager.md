---
title: "Clipboard Manager"
description: "Building a clipboard manager that stores history and provides paste functionality"
---

# Clipboard Manager

## The Problem

Wayland's security model prevents clients from reading the clipboard without focus. The clipboard contents are owned by the last client that copied text — if that client closes, the content is lost. A shell needs a persistent clipboard manager that stores history and re-owns the selection.

## The Naive Approach

Polling `wl-paste -p` every second. This only works when the shell window is focused (Wayland data-device protocol), consumes CPU, and loses entries between copies.

<MentalModel>

Wayland's `wlr-data-control-unstable-v1` protocol (supported by wlroots-based compositors like Hyprland, Sway) allows a privileged client to read the selection at any time. Quickshell's `Clipboard` service uses this protocol to capture clipboard content when it changes, without focus requirements.

</MentalModel>

## The Idea

Use Quickshell's `Clipboard` service to monitor clipboard changes. Store each unique entry in a history list. Display recent entries in a popup. On click, write the selected entry back to the clipboard via `Clipboard.setText()`.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services.Clipboard

Column {
  spacing: 6

  ClipboardManager {
    id: clipManager
    maxHistory: 50
  }

  Button {
    text: "Clipboard History"
    onClicked: historyPopup.open()
  }

  PopupWindow {
    id: historyPopup

    Column {
      Repeater {
        model: clipManager.history
        delegate: Rectangle {
          required property var modelData
          width: 300; height: 32; radius: 4
          color: mouse.containsMouse ? "#5294e2" : "#2b2b2b"
          Text {
            text: modelData.text.length > 40 ? modelData.text.substring(0, 40) + "..." : modelData.text
            anchors.centerIn: parent
            elide: Text.ElideRight
          }
          TapHandler {
            onTapped: {
              Clipboard.setText(modelData.text)
              historyPopup.close()
            }
          }
          HoverHandler { id: mouse }
        }
      }
    }
  }
}
```

<BuildIt>

`ClipboardManager` (from `Quickshell.Services.Clipboard`) monitors the `wlr-data-control` protocol. Every clipboard change fires `onClipboardChanged`. The `history` property is a `ListModel` of `{ text, timestamp }` objects. `Clipboard.setText()` writes the selected entry back to the Wayland selection.

</BuildIt>

## Let's Improve It

Add support for images (Pixmap entries) and pinning favorites. Show a thumbnail for image entries. Add a "clear" button and search filtering.

```qml
TextField {
  placeholderText: "Search clipboard..."
  onTextChanged: clipManager.filter(text)
}
```

<CommonMistake>

Assuming clipboard content is always text. Wayland supports multiple MIME types (text, images, files). Always check `entry.mimeType` before rendering. Images may need to be displayed via `Image { source: entry.data }` if the data is a URL or blob.

</CommonMistake>

## Under the Hood

The `wlr-data-control` protocol works via a Wayland global. Quickshell creates a `zwlr_data_control_source_v1` and `zwlr_data_control_offer_v1`. When the selection changes, it reads all offered MIME types and stores the content in memory. Text is decoded as UTF-8, images as raw bytes storable as `QByteArray`. The clipboard is also re-seated when the shell reappears after a compositor restart.

## Exercises

**Beginner:** Show the last 5 clipboard entries in a simple popup.

**Intermediate:** Add a "favorites" system where pinned entries survive a history clear. Support drag-and-drop reordering.

**Advanced:** Implement a clipboard sync across machines using a custom SSH-based protocol or a pastebin service.

<Recap :points="['Clipboard on Wayland requires wlr-data-control protocol', 'Quickshell ClipboardManager captures text/image with history', 'Supports paste, favorites, and persistence across restarts']" next-chapter="/part-6-linux-integration/authentication" />

<!--
Sources verified for this chapter:
- https://wayland.app/protocols/wlr-data-control — wlr-data-control protocol specification
- https://quickshell.org/docs/v0.3.0/types/Clipboard/ClipboardManager/ — Quickshell ClipboardManager type
- https://wayland-book.com/ — Wayland book
-->
