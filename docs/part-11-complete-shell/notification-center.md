---
title: "Notification Center"
description: "A notification center for the complete desktop shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'ListView', 'Notifications daemon']" you-will-build="A scrollable notification center with history and grouping" />

## The Problem

Desktop notifications appear and disappear. Users miss alerts when they're away from their keyboard. A notification center stores notification history, groups by application, and allows users to review missed notifications at their convenience.

## The Naive Approach

Show notifications as ephemeral popups that disappear after 5 seconds:

```qml
Timer { interval: 5000; onTriggered: popup.visible = false }
```

No history, no grouping, no way to find a notification the user missed while grabbing coffee.

<MentalModel>

Think of the notification center as your email inbox. Notifications (emails) arrive throughout the day. Some are important (critical urgency), some are spam (low urgency). The inbox groups by sender (app name), marks unread, and lets you review or dismiss each one.

</MentalModel>

## The Idea

Create a `PopupWindow` that opens when clicking a bell icon in the top bar. It shows a `ListView` of all notifications received during the session, grouped by application, with clear-all and dismiss actions.

## Let's Build It

```qml
// NotificationCenter.qml
PopupWindow {
  id: center
  width: 360; height: 480
  anchor.window: topBar
  anchor.rect.y: parentWindow.height
  visible: false
  dismissOnClickOutside: true

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 12 }; spacing: 8

      // Header
      Row {
        width: parent.width; spacing: 8
        Text { text: "Notifications"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4"; anchors.verticalCenter: parent.verticalCenter }
        Item { width: parent.width - 160; height: 1 }
        Text { text: notifications.count + " new"; font.pixelSize: 11; color: "#6c7086"; anchors.verticalCenter: parent.verticalCenter }
        Rectangle { width: 60; height: 24; radius: 4; color: "#313244"
          Text { anchors.centerIn: parent; text: "Clear All"; color: "#f38ba8"; font.pixelSize: 11 }
          MouseArea { anchors.fill: parent; onClicked: center.clearAll() }
        }
      }

      // Notification list
      ListView {
        id: notifList
        width: parent.width; height: parent.height - 50
        model: notifications
        spacing: 4; clip: true

        delegate: Rectangle {
          required property var modelData
          required property int index
          width: parent.width; height: 70; radius: 6; color: "#313244"

          Column {
            anchors { fill: parent; margins: 10 }; spacing: 4

            Row {
              spacing: 6
              Rectangle {
                width: 6; height: 6; radius: 3
                color: modelData.urgency === 2 ? "#f38ba8" : modelData.urgency === 1 ? "#fab387" : "#6c7086"
                anchors.verticalCenter: parent.verticalCenter
              }
              Text { text: modelData.appName || "System"; font.pixelSize: 11; color: "#89b4fa" }
              Item { width: parent.width - 150; height: 1 }
              Text { text: formatTime(modelData.timestamp); font.pixelSize: 10; color: "#6c7086" }
            }

            Text { text: modelData.summary || ""; font.pixelSize: 13; font.bold: true; color: "#cdd6f4"; elide: Text.ElideRight }
            Text { text: modelData.body || ""; font.pixelSize: 11; color: "#a6adc8"; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.WordWrap }

            // Action buttons
            Row {
              spacing: 6; visible: modelData.actions && modelData.actions.length > 0
              Repeater {
                model: modelData.actions || []
                delegate: Rectangle {
                  required property string modelData
                  width: Math.min(80, modelData.length * 8 + 16); height: 20; radius: 3; color: "#45475a"
                  Text { anchors.centerIn: parent; text: modelData; color: "#cdd6f4"; font.pixelSize: 10 }
                  MouseArea { anchors.fill: parent; onClicked: Qt.dbusCall("org.freedesktop.Notifications", "InvokeAction", modelData.id, modelData) }
                }
              }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: { notifications.remove(index); center.dismissed(modelData.id) }
          }
        }

        ScrollBar.vertical: ScrollBar { active: true }
      }
    }
  }

  property var notifications: ListModel {}

  signal dismissed(int id)
  signal clearAll()

  function formatTime(date) {
    if (!date) return ""
    return date.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
  }

  function addNotification(n) {
    notifications.insert(0, n)
    // Keep max 100
    while (notifications.count > 100) notifications.remove(notifications.count - 1)
  }
}
```

<BuildIt>

The notification center stores notifications in a `ListModel`. Each notification shows app name, urgency dot, summary, body, optional action buttons, and timestamp. "Clear All" dismisses everything. Clicking a notification removes it individually.

</BuildIt>

## Let's Improve It

Add notification grouping by application:

```qml
function addNotification(n) {
  // Group by app — find existing group or create new
  for (var i = 0; i < notifications.count; i++) {
    var g = notifications.get(i)
    if (g.appName === n.appName && g.isGroup) {
      g.count++
      g.lastNotification = n
      notifications.set(i, g)
      return
    }
  }
  notifications.insert(0, { isGroup: true, appName: n.appName, count: 1, lastNotification: n })
}
```

<CommonMistake>

**No limit on history.** Storing thousands of notifications eventually consumes all available memory. Cap at 100-200 entries. Persist to disk if you need permanent history.

**Forgetting urgency colors.** Critical notifications should be visually distinct from low-priority ones. Use color-coded urgency dots and maybe a different background tint.

**Not handling action callbacks.** Notification actions (Reply, Mark Read, Open) require D-Bus calls back to the sending application. Parse `modelData.actions` and call `InvokeAction` with the correct ID.

</CommonMistake>

## Under the Hood

The notification center receives notifications from the notification daemon (which implements `org.freedesktop.Notifications` on D-Bus). Each notification has a unique ID, app name, summary, body, urgency level (0=low, 1=normal, 2=critical), and optional action buttons. The center stores them for the session duration.

## Exercises

<ExerciseBlock :difficulty="1">
Add "Do Not Disturb" mode. When enabled, notifications are still stored in the center but no popup bubble is shown. Add a toggle button in the notification center header.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Persist notification history to `Quickshell.statePath("notifications.json")`. Load on startup so users see notifications from previous sessions.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement notification inline replies. Some messaging apps send notifications with `x-kde-replyPlaceholderText` and `x-kde-replySubmitButtonText` hints. Show a text input and submit button in the notification delegate. Send the reply via `InvokeAction`.
</ExerciseBlock>

<Recap :points="['Notification center stores session notifications in a ListModel', 'Group by application for cleaner display', 'Show urgency level with color-coded dots', 'Cap history at 100-200 entries to manage memory']" next-chapter="/part-11-complete-shell/osd" />

<!--
Sources verified for this chapter:
- https://specifications.freedesktop.org/notification-spec/latest/ — Notification spec
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/ — PopupWindow
- https://doc.qt.io/qt-6/qml-qtqml-models-listmodel.html — ListModel
-->
