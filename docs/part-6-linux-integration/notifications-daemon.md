---
title: "Notifications Daemon"
description: "Implementing a notification daemon with Quickshell"
---

# Notifications Daemon

## The Problem

Linux desktop applications send notifications via the `org.freedesktop.Notifications` D-Bus interface. A shell must replace the default notification daemon (`mako`, `dunst`, GNOME's) with its own — displaying, stacking, and dismissing notifications natively in QML.

## The Naive Approach

Writing a daemon in Python/Rust that re-emits notifications over a Unix socket, then polling that socket in QML. This introduces a second process, adds latency, and duplicates D-Bus parsing logic.

<MentalModel>

The notification spec defines a single D-Bus method `Notify` (app_name, replaces_id, app_icon, summary, body, actions, hints, expire_timeout). A daemon registers on the bus, receives calls, and updates a `Notifications` model. Quickshell's `NotificationDaemon` service handles D-Bus registration automatically.

</MentalModel>

## The Idea

Use Quickshell's built-in notification service. Register your shell as the notification daemon via D-Bus. Each incoming `Notify` creates a `NotificationObject` in the model. Display them with a reusable `NotificationPopup` component.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services.Notifications

Item {
  id: root

  NotificationDaemon {
    id: notifDaemon
    onNotificationReceived: (notif) => {
      notif.timeout = notif.timeout > 0 ? notif.timeout : 5000
      notificationModel.append(notif)
    }
  }

  ListModel { id: notificationModel }

  Column {
    anchors { top: parent.top; right: parent.right }
    spacing: 4

    Repeater {
      model: notificationModel
      delegate: NotificationPopup {
        required property var modelData
        notification: modelData
        onDismissed: notificationModel.remove(index)
      }
    }
  }
}
```

<BuildIt>

`NotificationDaemon` claims the `org.freedesktop.Notifications` bus name and dispatches `onNotificationReceived` for every incoming notification. The `NotificationObject` has `summary`, `body`, `appName`, `appIcon`, `urgency`, `timeout`, `actions`, and `hints`. To dismiss, call `notif.close()`.

</BuildIt>

## Let's Improve It

Add urgency-based styling (critical notifications stay until dismissed), action buttons (e.g., "Reply" on chat apps), and a notification history accessible from a panel button.

```qml
Rectangle {
  color: modelData.urgency === NotificationObject.Critical ? "#e25252" : "#3b3b3b"
  radius: 8
  // ... summary, body, actions
}
```

<CommonMistake>

Not handling `replaces_id`. If an app sends a notification with the same `replaces_id`, you should update the existing notification instead of appending a duplicate. Check `notif.replacesId` and find the matching item in your model.

</CommonMistake>

## Under the Hood

Quickshell registers a D-Bus object at `/org/freedesktop/Notifications` implementing the full spec (including `GetCapabilities`, `GetServerInformation`, `CloseNotification`). It manages the `replaces_id` deduplication, action invocation (sending `ActionInvoked` signals back to the app), and timeout timers. The daemon only runs while your shell is alive.

## Exercises

**Beginner:** Display notifications as a simple list in the top-right with 5-second auto-dismiss.

**Intermediate:** Build a notification center accessible from a bell icon — stack notifications, group by app, support "Clear All".

**Advanced:** Implement notification inline replies: parse `hints` for `x-kde-replyPlaceholderText`, show a text input, and send the reply via `InvokeAction`.

<Recap :points="['Notifications are first-class in Quickshell with NotificationDaemon', 'D-Bus registration handled automatically; focus on rendering', 'Supports actions, urgency levels, and notification history']" next-chapter="/part-6-linux-integration/clipboard-manager" />

<!--
Sources verified for this chapter:
- https://specifications.freedesktop.org/notification-spec/latest/ — Desktop Notifications Specification
- https://quickshell.org/docs/v0.3.0/types/Notifications/NotificationDaemon/ — Quickshell NotificationDaemon type
- https://developer.gnome.org/notification-spec/ — GNOME notification spec reference
-->
