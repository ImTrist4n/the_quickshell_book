---
title: "Notification Daemon"
description: "Implementing a notification daemon compatible with the freedesktop spec"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['PopupWindow', 'D-Bus concepts']" you-will-build="A full notification daemon with history and Do Not Disturb" />

## The Problem

Applications send notifications via the freedesktop notification spec (D-Bus interface `org.freedesktop.Notifications`). Without a notification daemon, users miss alerts from messaging apps, email clients, and system updates.

## The Naive Approach

Poll for notifications:

```qml
Timer {
  interval: 500
  running: true; repeat: true
  onTriggered: {
    var result = Qt.process(["dbus-send", "--session", "--dest=org.freedesktop.Notifications", ...])
    // parse and display
  }
}
```

Polling D-Bus is wasteful, slow, and misses the event-driven nature of the spec.

<MentalModel>

Think of the notification daemon as your mail carrier. Applications (senders) hand notifications to the carrier. The carrier sorts them and delivers them to your shell (receiver). The receiver decides whether to show them immediately, stack them, or file them for later.

</MentalModel>

## The Idea

Implement `org.freedesktop.Notifications` on D-Bus using Quickshell's D-Bus integration. Listen for `Notify` method calls, display them as popup bubbles, and support actions, urgency levels, and history.

## Let's Build It

```qml
// NotificationService.qml
pragma Singleton
import Quickshell
import QtQml.Models

QtObject {
  id: notifService

  property ListModel notifications: ListModel {}

  signal notificationReceived(var notification)

  function addNotification(appName, summary, body, urgency, actions, hints) {
    var id = Date.now()
    var notif = {
      id: id,
      appName: appName,
      summary: summary,
      body: body,
      urgency: urgency,
      actions: actions || [],
      hints: hints || {},
      timestamp: new Date()
    }
    notifications.insert(0, notif)
    notificationReceived(notif)
    return id
  }

  function closeNotification(id) {
    for (var i = 0; i < notifications.count; i++) {
      if (notifications.get(i).id === id) {
        notifications.remove(i)
        break
      }
    }
  }

  function dismissAll() {
    notifications.clear()
  }
}
```

Create a notification popup bubble:

```qml
// NotificationPopop.qml
PopupWindow {
  id: root
  width: 360
  height: 100
  anchor.window: mainPanel
  anchor.rect.x: parentWindow.width - width - 12
  anchor.rect.y: 48

  property var notification: null

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#313244"

    Column {
      anchors { fill: parent; margins: 12 }; spacing: 4
      Text { text: notification ? notification.appName : ""; font.pixelSize: 11; color: "#89b4fa" }
      Text { text: notification ? notification.summary : ""; font.pixelSize: 13; font.bold: true; color: "#cdd6f4" }
      Text { text: notification ? notification.body : ""; font.pixelSize: 12; color: "#a6adc8"; wrapMode: Text.WordWrap }

      Row {
        spacing: 8; visible: notification && notification.actions.length > 0
        Repeater {
          model: notification ? notification.actions : []
          delegate: Button {
            required property var modelData
            text: modelData
            height: 24; radius: 4; color: "#45475a"
            onClicked: Qt.dbusCall("org.freedesktop.Notifications", "InvokeAction", notification.id, modelData)
          }
        }
      }
    }
  }

  Timer {
    interval: 5000; running: root.visible; repeat: false
    onTriggered: root.visible = false
  }
}
```

<BuildIt>

The notification service manages a `ListModel` of notifications. Bubbles display the latest notification with a 5-second auto-dismiss. Action buttons (e.g., "Reply", "Mark as Read") call back to the application via D-Bus.

</BuildIt>

## Let's Improve It

Add Do Not Disturb mode, urgency-based display, and notification history:

```qml
// NotificationService.qml
property bool doNotDisturb: false
property int maxHistory: 100

function addNotification(appName, summary, body, urgency, actions, hints) {
  var notif = { /* ... as above ... */ }

  // Cap history
  while (notifications.count >= maxHistory) {
    notifications.remove(notifications.count - 1)
  }

  notifications.insert(0, notif)

  if (!doNotDisturb) {
    notificationReceived(notif)
  }

  return notif.id
}
```

Urgency levels control display behavior:

| Level | Value | Behavior |
|---|---|---|
| Low | 0 | Silent, goes to history only |
| Normal | 1 | Shows bubble, auto-dismisses |
| Critical | 2 | Stays visible until dismissed |

<CommonMistake>

**Not implementing `CloseNotification`.** The spec requires that closing a notification (user dismisses it) sends a `NotificationClosed` signal with a reason code. Apps depend on this to stop showing in-app indicators.

**Blocking on image data.** Some notifications include image data (album art, avatar) as raw PNG in hints. Displaying these requires conversion to `QImage`. Load them asynchronously to avoid blocking the UI.

**Forgetting notification IDs.** Every `Notify` call returns a unique ID. The same ID is used for `CloseNotification` and `NotificationClosed`. Using `Date.now()` is acceptable for simple cases; a proper implementation uses a counter.

</CommonMistake>

## Under the Hood

The freedesktop notification spec uses D-Bus method calls. Quickshell can interact with D-Bus via `Qt.dbusCall()` and `Qt.dbusRegister()`. For a full daemon, you'd register as the service owner on `org.freedesktop.Notifications` and implement the `Notify`, `CloseNotification`, `GetCapabilities`, `GetServerInformation` methods. The spec also defines signal-based notification delivery via `org.freedesktop.DBus.Properties`.

## Exercises

<ExerciseBlock :difficulty="1">
Implement `GetCapabilities` and `GetServerInformation` for your notification daemon. Report support for "body", "actions", "urgency", and "icon-static". Test with `notify-send "Hello"`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a notification history popup. Show the last 50 notifications in a `ListView` with a "Clear All" button. Persist history to `Quickshell.statePath("notification-history.json")`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement notification grouping — notifications from the same app within 5 seconds are stacked into a single bubble showing "3 new messages from Slack". Support expanding the group on click.
</ExerciseBlock>

<Recap :points="['Implement org.freedesktop.Notifications via D-Bus for spec compliance', 'Use urgency levels (Low, Normal, Critical) to control display behavior', 'Support notification actions (buttons) for interactive notifications', 'Provide Do Not Disturb mode and history for user control']" next-chapter="/part-11-complete-shell/audio-controls" />

<!--
Sources verified for this chapter:
- https://specifications.freedesktop.org/notification-spec/latest/ — freedesktop notification spec
- https://quickshell.org/docs/v0.3.0/guide/qml-language — QML Language
- https://doc.qt.io/qt-6/qml-qtqml-models-listmodel.html — ListModel
-->
