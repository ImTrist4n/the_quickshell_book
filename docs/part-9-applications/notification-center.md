---
title: "Notification Center"
description: "A notification center that collects and displays notification history"
---

# Notification Center

<ChapterMeta title="Notification Center" icon="bell" />

## Problem

Desktop notifications appear and disappear. Users miss them. A notification center collects notification history, allowing users to review missed alerts, dismiss them, or take action.

## Naive Approach

Display each notification as a toast that auto-dismisses. No history. Miss one notification and it is gone forever.

## MentalModel

<MentalModel title="Inbox Model">

A notification center is an inbox: notifications arrive, are stored in a list, and can be read, dismissed, or cleared. Each notification has a source app, title, body, urgency, timestamp, and optional actions.

</MentalModel>

## Idea

Use Quickshell's `Notifications` service to receive notifications. Store them in a `ListModel`. Display them in a popup window with a `ListView`. Support dismiss-all and per-notification dismissal.

## Build It

```qml
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications

PopupWindow {
  id: notifCenter
  width: 380
  height: 500

  ListModel { id: notificationModel }

  Connections {
    target: Notifications
    function onNotificationReceived(notif: Notification) {
      notificationModel.insert(0, {
        id: notif.id,
        appName: notif.appName,
        summary: notif.summary,
        body: notif.body,
        urgency: notif.urgency,
        timestamp: new Date()
      })
    }
  }

  Column {
    anchors.fill: parent
    padding: 8

    Row {
      width: parent.width
      Text { text: "Notifications"; font.pixelSize: 16; font.bold: true }
      Item { width: parent.width - 200; height: 1 }
      Button {
        text: "Clear All"
        onClicked: notificationModel.clear()
      }
    }

    ListView {
      width: parent.width
      height: parent.height - 40
      model: notificationModel
      delegate: Rectangle {
        width: parent.width
        height: 72
        color: "#2a2a3e"
        radius: 8
        border.color: "#45475a"

        Column {
          padding: 8
          spacing: 4
          Text { text: modelData.appName; font.pixelSize: 11; color: "#888888" }
          Text { text: modelData.summary; font.pixelSize: 14; font.bold: true }
          Text { text: modelData.body; font.pixelSize: 12; elide: Text.ElideRight; maxLines: 2 }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: notificationModel.remove(index)
        }
      }
    }
  }
}
```

## BuildIt Breakdown

`Notifications` service connects to the system notification daemon via D-Bus. `onNotificationReceived` fires when any app sends a notification. Each notification is inserted at position 0 (newest first). The `ListView` renders them with app name, summary, and body. Clicking a notification dismisses it. "Clear All" empties the model.

## Improve It

Group notifications by app. Add urgency-based styling (critical = red border). Show notification icons. Add action buttons. Support persistent notifications that stay until manually dismissed. Implement "Do Not Disturb" mode.

## CommonMistake

<CommonMistake>

Holding references to `Notification` objects after they are closed. The `Notification` object becomes invalid after dismissal. Copy the data you need (id, summary, body) into the model, do not store the object reference.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Quickshell's `Notifications` service implements the `org.freedesktop.Notifications` D-Bus specification. It registers as a notification server, replacing services like `mako` or `dunst`. Notifications arrive as D-Bus method calls on the `Notify` interface. The service parses hints (urgency, category, resident) and emits `notificationReceived`. Action IDs are tracked for button callbacks.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Build a notification toast popup that appears for 5 seconds and is clickable.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Add a notification count badge to the top bar that shows unread notification count.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Implement notification grouping — collapse notifications from the same app into a single expandable item.

</ExerciseBlock>

## Recap

<Recap to="/part-9-applications/power-menu">

Notifications are now collected and reviewable. Next: a **control center** for quick toggles.

</Recap>

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/introduction/ — PanelWindow, PopupWindow documentation
- https://quickshell.org/docs/v0.3.0/ — Quickshell API documentation
-->
