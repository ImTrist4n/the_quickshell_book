---
title: "Notifications"
description: "Building a notification display widget for desktop notifications"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['Text, Icon, Button', 'ListView']" you-will-build="A notification popup widget that displays incoming alerts" />

## The Problem

Applications send notifications for messages, alerts, calendar reminders, and media playback. Without a notification daemon, these disappear into the void. Your shell needs to intercept these events and display them in a non-intrusive way.

## The Naive Approach

You could run `mako` or `dunst` alongside your shell — standalone notification daemons. But they draw their own windows with their own styling, which won't match your shell's theme. You also can't add custom behavior like "reply inline" or "snooze for 1 hour."

## The Idea

Quickshell provides the `NotificationService` from `Quickshell.Services` that implements the `org.freedesktop.Notifications` D-Bus spec. It captures notification events from any application and exposes them as a QML model you can bind to and display.

<MentalModel>

Think of notifications as telegrams arriving at a switchboard. The `NotificationService` is the switchboard operator who receives every telegram, categorizes it, and hands it to you. You decide which telegrams to display, how to display them, and when to dismiss them.

</MentalModel>

## Let's Build It

```qml
import Quickshell
import Quickshell.Services
import QtQml.Models

PanelWindow {
  width: 350; height: 48
  color: "#1e1e2e"
  visible: true

  property var notifications: NotificationService.notifications
  property int notificationCount: notifications.length

  Row {
    anchors {
      left: parent.left; right: parent.right
      verticalCenter: parent.verticalCenter
      margins: 12
    }

    Text {
      text: "Notifications"
      font.pixelSize: 14
      font.bold: true
      color: "#cdd6f4"
    }

    Item { width: 1; height: 1 }

    Text {
      text: notificationCount > 0 ? notificationCount + " new" : ""
      color: "#89b4fa"
      font.pixelSize: 12
    }
  }
}
```

<BuildIt>

`NotificationService` is a singleton that maintains a list of active notifications. Each notification has properties: `appName`, `summary`, `body`, `urgency`, `icon`, and `actions`. When an app sends a notification via D-Bus, Quickshell picks it up automatically.

</BuildIt>

## Let's Improve It

Build a full notification popup with dismiss and action buttons:

```qml
import Quickshell
import Quickshell.Services
import QtQml.Models

PopupWindow {
  id: root
  width: 380
  height: Math.min(notificationList.contentHeight + 20, 500)

  // Auto dismiss after timeout
  property int dismissTimeout: 5000

  Timer {
    interval: root.dismissTimeout
    running: true
    onTriggered: dismiss()
  }

  function dismiss() {
    root.visible = false
  }

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 8

    Column {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 8

      Repeater {
        model: NotificationService.notifications

        delegate: Rectangle {
          required property var modelData
          width: parent.width
          height: 80
          radius: 6
          color: "#313244"

          Column {
            anchors {
              fill: parent; margins: 10
            }
            spacing: 4

            Row {
              width: parent.width; spacing: 8

              Text {
                text: modelData.appName
                font.pixelSize: 11
                font.bold: true
                color: "#89b4fa"
              }

              Text {
                text: modelData.summary
                font.pixelSize: 13
                font.bold: true
                color: "#cdd6f4"
                elide: Text.ElideRight
                width: parent.width - 60
              }

              Text {
                text: "✕"
                color: "#f38ba8"
                font.pixelSize: 12
                MouseArea {
                  anchors.fill: parent
                  onClicked: NotificationService.dismiss(modelData.id)
                }
              }
            }

            Text {
              text: modelData.body
              font.pixelSize: 12
              color: "#a6adc8"
              wrapMode: Text.WordWrap
              maximumLineCount: 2
              elide: Text.ElideRight
              width: parent.width
            }

            Row {
              spacing: 6
              Repeater {
                model: modelData.actions
                delegate: Rectangle {
                  required property string modelData
                  width: 60; height: 24; radius: 4
                  color: "#45475a"
                  Text {
                    text: modelData
                    anchors.centerIn: parent
                    color: "#cdd6f4"
                    font.pixelSize: 11
                  }
                  MouseArea {
                    anchors.fill: parent
                    onClicked: NotificationService.invokeAction(modelData.id, modelData)
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
```

<CommonMistake>

**Not dismissing notifications.** Notifications accumulate in the service model until dismissed. If you never call `dismiss()` or `close()`, old notifications pile up and consume memory. Always dismiss after displaying or on user action.

**Ignoring notification urgency.** The `urgency` field (Low, Normal, Critical) lets you prioritize alerts. A critical notification from your calendar ("Meeting in 1 minute!") should look different from a low-urgency news alert.

**Assuming all apps use notification actions.** Many apps send static notifications without interactive buttons. Handle both cases: render actions when available, but don't break the display when they're empty.

</CommonMistake>

## Under the Hood

NotificationService implements `org.freedesktop.Notifications` on the D-Bus session bus. When an application calls `Notify()` on the D-Bus interface, Quickshell receives the call, parses the notification parameters (summary, body, urgency, actions, hints), creates a notification object, and appends it to the model. The model is a `QAbstractListModel` — changes emit proper signals so QML views update reactively.

The service also sends `NotificationClosed` signals back to applications when you dismiss a notification, so apps know not to expect a user response.

## Exercises

<ExerciseBlock :difficulty="1">
Style notifications by urgency: critical notifications get a red left border, normal get blue, low get gray.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a "Do Not Disturb" toggle. When enabled, notifications are still received but not shown — counter increments silently in the background. Show them when the user clicks the counter.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a notification history. Store all received notifications in a `ListModel` (even after dismiss). Show a "History" view that lists the last 50 notifications with timestamps. Let users clear individual entries or the entire history.
</ExerciseBlock>

<Recap :points="['NotificationService implements the freedesktop notification spec via D-Bus', 'Notifications have appName, summary, body, urgency, icon, and actions properties', 'Always dismiss notifications after display to prevent memory leaks', 'Use urgency to visually prioritize critical notifications']" next-chapter="/part-5-services/http-requests-and-caching" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

