---
title: "ListView"
description: "Scrollable, efficient lists with QML ListView — the workhorse of shell UI"
---

<ChapterMeta reading-time="8 min" :difficulty="2" :prerequisites="['Repeaters']" you-will-build="A scrollable list of notification items" />

## The Problem

`Repeater` creates every delegate immediately. For a workspace indicator with 10 items, that's fine. For a notification center with hundreds of entries, or a contact list, or a file browser — instantiating hundreds of delegates at once wastes memory and slows startup. You need a view that creates only what's visible on screen.

## The Naive Approach

You could use `Repeater` with a `ScrollView` and clip the overflow:

```qml
ScrollView {
  Repeater {
    model: 200  // 200 items
    delegate: TallItem { ... }  // Each 60px tall
  }
}
```

This creates 200 delegate instances. If each takes 2KB of QML overhead, that's 400KB for the delegates alone — unnecessarily large when only about 10 are visible at a time.

<MentalModel>

`Repeater` is like printing every page of a book to read one page. `ListView` is like a book with page-turning — it only shows you the current page and reuses pages as you turn them. The book has 200 pages, but you only ever hold two at a time (the current one and the next one being prepared).

</MentalModel>

## The Idea

`ListView` is a scrollable, virtualizing view. It creates only enough delegates to fill the visible area, plus a few extra for preloading. As the user scrolls, it **recycles** delegates — detaching them from old items and reattaching them to new ones. This keeps memory usage proportional to the viewport size, not the model size.

## Let's Build It

```qml
import QtQuick
import QtQuick.Window
import QtQml.Models

Window {
  width: 400
  height: 500
  visible: true
  title: "ListView"

  // Generate sample notification data
  ListModel {
    id: notificationModel

    ListElement {
      appName: "System"
      title: "Update Available"
      body: "System updates are ready to install."
      urgent: false
      time: "2m ago"
    }
    ListElement {
      appName: "Slack"
      title: "New message from Alice"
      body: "Hey, are you coming to the meeting?"
      urgent: false
      time: "5m ago"
    }
    ListElement {
      appName: "Calendar"
      title: "Meeting in 15 minutes"
      body: "Stand-up with the team"
      urgent: true
      time: "10m ago"
    }
    ListElement {
      appName: "Spotify"
      title: "Now Playing"
      body: "Currents — Tame Impala"
      urgent: false
      time: "12m ago"
    }
    ListElement {
      appName: "Weather"
      title: "Rain Alert"
      body: "Rain expected in your area in 30 minutes."
      urgent: true
      time: "15m ago"
    }
  }

  Column {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    Text {
      text: "Notifications (" + notificationModel.count + ")"
      font.pixelSize: 18
      font.bold: true
      color: "#333"
    }

    ListView {
      id: listView
      width: parent.width
      height: parent.height - 40

      model: notificationModel
      spacing: 6
      clip: true

      delegate: Rectangle {
        required property string appName
        required property string title
        required property string body
        required property bool urgent
        required property string time
        required property int index

        width: listView.width
        height: 80
        radius: 8
        color: urgent ? "#fff0f0" : "#fafafa"
        border.color: urgent ? "#ff6b6b" : "#eee"
        border.width: urgent ? 2 : 1

        Column {
          anchors {
            left: parent.left; right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: 12; rightMargin: 12
          }
          spacing: 4

          Row {
            width: parent.width
            spacing: 8

            Text {
              text: appName
              font.pixelSize: 12
              font.bold: true
              color: urgent ? "#dc2626" : "#1a56db"
            }

            Text {
              text: "•"
              color: "#ccc"
              font.pixelSize: 10
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              text: time
              font.pixelSize: 11
              color: "#aaa"
              anchors.verticalCenter: parent.verticalCenter
            }

            Item { width: 1; height: 1 }

            Text {
              text: urgent ? "🔴" : ""
              font.pixelSize: 12
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Text {
            text: title
            font.pixelSize: 14
            font.bold: true
            color: "#1c1917"
            elide: Text.ElideRight
            width: parent.width
          }

          Text {
            text: body
            font.pixelSize: 12
            color: "#57534e"
            elide: Text.ElideRight
            width: parent.width
            maximumLineCount: 2
            wrapMode: Text.Wrap
          }
        }

        // Delete button on hover
        Rectangle {
          anchors {
            right: parent.right; top: parent.top
            rightMargin: 8; topMargin: 8
          }
          width: 20; height: 20; radius: 10
          color: mouseArea.containsMouse ? "#ff6b6b" : "#eee"
          visible: mouseArea.containsMouse

          Text {
            text: "✕"
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 11
          }

          MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
              notificationModel.remove(index)
            }
          }
        }
      }

      // Scroll indicators
      ScrollBar.vertical: ScrollBar {
        active: true
      }
    }
  }
}
```

<BuildIt>

Essential `ListView` properties:

- **`model`** — the data source. Use `ListModel` for dynamic data that needs add/remove/update operations.
- **`spacing`** — gap between delegate items.
- **`clip: true`** — prevents items outside the viewport from painting outside the `ListView` bounds.
- **`ScrollBar.vertical`** — attaches a scroll bar.

The delegate uses `elide` and `maximumLineCount` to handle variable content gracefully — long titles get ellipses, long bodies wrap up to 2 lines then truncate.

</BuildIt>

## Let's Improve It

`ListView` supports **sections** — grouping items by a common property:

```qml
ListView {
  section.property: "urgent"
  section.delegate: Rectangle {
    width: listView.width
    height: 30
    color: "#f0f0f8"
    Text {
      text: section === "true" ? "🔴 Urgent" : "Info"
      anchors.verticalCenter: parent.verticalCenter
      leftMargin: 12
    }
  }
}
```

This groups notifications into "Urgent" and "Info" sections with header delegates.

Key `ListView` properties for production use:

| Property | Purpose |
|---|---|
| `cacheBuffer` | Pixels of preloading above/below viewport (default 0) |
| `snapMode` | Snap to items (useful for carousels) |
| `highlight` | Component for the current item highlight |
| `preferredHighlightBegin/End` | Where the highlight sits in the viewport |
| `footer` / `header` | Static items at start/end of list |

<CommonMistake>

**Not setting `clip: true`.** Without clipping, delegate items that extend beyond the `ListView`'s bounds will paint over neighboring UI. Always set `clip: true` on a `ListView`.

**Using `Repeater` inside a `ListView` delegate.** Delegates are already repeating items. Nesting a `Repeater` inside a delegate creates N delegates per visible item — exponential blowup.

**Heavy delegates.** `ListView` recycles delegates during scrolling. If your delegate does expensive work (image loading, complex layout), this work runs every time an item scrolls into view. Keep delegates lightweight.

</CommonMistake>

## Under the Hood

`ListView` uses `QQuickListView` which maintains a pool of delegate instances. During scrolling, it:

1. Removes delegates that have scrolled out of the cache window
2. Returns them to the reuse pool
3. Assigns recycled delegates to newly visible items
4. Updates the delegate's model data roles

This recycling happens at the C++ level and is very fast. The delegate's `Component.onCompleted` runs only on initial creation, not on reuse. Use `onModelDataChanged` or property bindings (not `Component.onCompleted`) to react to data changes during recycling.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "Clear All" button above the `ListView` that removes all items from the model. The view should update automatically.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement sections: group notifications by `urgent` (true/false) with section headers that show "Urgent" and "Others".
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a `ListView` with `snapMode: ListView.SnapOneItem` and `orientation: ListView.Horizontal` to build a horizontal carousel. Each delegate should be a wide card with an image placeholder and label.
</ExerciseBlock>

<Recap :points="['ListView recycles delegates for memory-efficient scrolling of large datasets', 'Use ListModel for dynamic data with add/remove/update operations', 'Always set clip: true to prevent overflow painting', 'Keep delegates performant — they are created and recycled during scrolling']" next-chapter="/part-1-qml/mousearea" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-listview.html — ListView type
- https://doc.qt.io/qt-6/qml-qtquick-listview.html#section.property-prop — ListView sections
- https://doc.qt.io/qt-6/qml-qtqml-models-listmodel.html — ListModel type
-->
