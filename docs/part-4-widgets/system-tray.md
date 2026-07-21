---
title: "System Tray"
description: "Integrating the system tray (StatusNotifier) into your shell"
---

## The Problem

The system tray hosts icons from background applications — Discord, Telegram, Nextcloud, Bluetooth manager, and more. These apps register as `StatusNotifierItem`s over D-Bus. Your shell needs to discover them, render their icons, and forward click events back.

## The Naive Approach

Ignore the system tray entirely — many Wayland shells do. But users expect tray icons for apps that don't have other notification mechanisms. Without a tray, those apps become invisible in a Pure Wayland session.

```qml
// Just skip it — users will complain
```

<MentalModel>

The system tray is like a bulletin board in a shared office. Each application pins its icon to the board. When you click an icon, you're knocking on that app's door — it can respond by showing a menu or opening a window. The board itself just holds the pins.

</MentalModel>

## The Idea

Quickshell provides a `SystemTray` type that implements the `StatusNotifierWatcher` D-Bus service. It discovers all registered `StatusNotifierItem`s and exposes them as a model you can bind to in QML. Each item provides icons, tooltips, and activation methods.

## Let's Build It

A system tray widget:

<BuildIt>

```qml
import Quickshell
import Quickshell.SystemTray
import QtQuick

Row {
  spacing: 4

  Repeater {
    model: SystemTrayModel {}

    Item {
      width: 24; height: 24

      Image {
        anchors.fill: parent
        source: modelData.icon
        sourceSize.width: 20
        sourceSize.height: 20
        fillMode: Image.PreserveAspectFit
        smooth: true

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton
          onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton)
              modelData.activate()
            else
              modelData.contextMenu()
          }
        }
      }

      Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 6; height: 6; radius: 3
        color: "#a6e3a1"
        visible: modelData.status === "Active" || modelData.status === "NeedsAttention"
      }
    }
  }
}
```

</BuildIt>

## Let's Improve It

Add tooltip support, attention indicators, and a popup menu renderer:

```qml
Item {
  width: 28; height: 28

  Image {
    anchors.fill: parent
    anchors.margins: 2
    source: modelData.icon
    sourceSize.width: 24
    sourceSize.height: 24
    fillMode: Image.PreserveAspectFit

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      onClicked: function(mouse) {
        if (mouse.button === Qt.LeftButton)
          modelData.activate()
        else
          modelData.contextMenu()
      }
    }
  }

  Rectangle {
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    width: 6; height: 6; radius: 3
    color: modelData.status === "NeedsAttention" ? "#f38ba8" : "#a6e3a1"
    visible: modelData.status !== "Passive"
  }

  Rectangle {
    id: tooltipPopup
    visible: parent.containsMouse && modelData.tooltip !== ""
    width: tooltipLabel.width + 16
    height: tooltipLabel.height + 8
    radius: 4
    color: "#1e1e2e"
    border.color: "#313244"
    y: -height - 6
    z: 100

    Text {
      id: tooltipLabel
      anchors.centerIn: parent
      text: modelData.tooltip
      font.pixelSize: 11
      color: "#cdd6f4"
    }
  }
}
```

<CommonMistake>

**Assuming all tray items provide a PNG icon.** Some apps provide themed icons by name (e.g., "discord") rather than a direct file path. The `SystemTray` model may return a `themeIcon` property. Use a fallback: try `modelData.icon` first, then `modelData.themeIcon`.

**Forgetting `sourceSize`.** Without `sourceSize`, the `Image` loads the full icon resolution (often 64x64 or 128x128) and downscales. This wastes VRAM. Always set `sourceSize` to the display size.

**Hardcoding left-click behavior.** Some tray items expect left-click to toggle, others to open a menu. Always call `modelData.activate()` on left click (which lets the app decide the response) and `modelData.contextMenu()` on right click.

</CommonMistake>

## Under the Hood

`SystemTray` implements the `org.kde.StatusNotifierWatcher` D-Bus service. Applications register as `StatusNotifierItem` on the session bus. When a new item appears, Quickshell creates a proxy object and adds it to the model. The `icon` property resolves via:
1. A direct image path (if the app provides URL)
2. A themed icon name (resolved via `QtQuick` theme engine)
3. A pixmap serialized over D-Bus (base64-encoded PNG)

<UnderTheHood>

The `SystemTrayModel` is a custom QML model that wraps Quickshell's `QsSystemTray` C++ backend. It emits `itemAdded` and `itemRemoved` signals when D-Bus registrations change. The model is lazily populated — items are created only when Quickshell receives their registration. Each item's properties are bound to D-Bus `PropertiesChanged` signals.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Add a "highlight on hover" effect for tray icons. Use a semi-transparent rounded rectangle behind the icon that appears when the mouse enters.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement drag-to-reorder tray icons. Track drag start/move/end events on each `MouseArea` and swap positions in a persistent order list.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a tray icon overflow popover. When the number of tray icons exceeds a configurable limit (e.g., 8), hide extras behind a ">>" button that shows a popup grid with all icons.
</ExerciseBlock>

<Recap :points="['SystemTrayModel exposes StatusNotifierItems as a QML model', 'Use Image with sourceSize to display icons efficiently', 'Left-click activates, right-click opens context menu', 'Tooltip text comes from the modelData.tooltip property', 'Status property indicates Active, Passive, or NeedsAttention']" next-chapter="/part-4-widgets/notifications" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

