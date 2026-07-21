---
title: "Clock"
description: "Building a live-updating clock widget for your panel"
---

## The Problem

Every desktop panel needs a clock. It seems trivial — show the current time, update it every second. But there are edge cases: timezone changes, locale formatting, 12h vs 24h modes, and making sure the timer doesn't drift or accumulate lag.

## The Naive Approach

Poll the current time in a tight loop or use a `Timer` with a 1-second interval. Both work, but a naive timer can drift: if your update function takes 50ms to run, the next tick starts at 1050ms instead of 1000ms. Over hours, the clock visibly falls behind.

```qml
Text {
  id: clockDisplay
  text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: clockDisplay.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
  }
}
```

<MentalModel>

Imagine a person looking at their watch and shouting the time every second. If they take half a second to speak, the next shout starts half a second late. Over an hour, they've drifted by minutes. A good clock corrects itself — it looks at the real time each tick rather than adding a fixed increment.

</MentalModel>

## The Idea

Use QML's `Timer` to trigger updates, but always read the current wall-clock time via `new Date()` rather than incrementing a counter. This self-corrects: even if a tick is delayed, the displayed time snaps back to the correct value.

## Let's Build It

A panel clock with date tooltip and automatic locale formatting:

<BuildIt>

```qml
import Quickshell
import QtQuick

Text {
  id: clockItem

  property bool showSeconds: true
  property string format: "HH:mm"
  property string dateFormat: "dddd, MMMM d"

  text: new Date().toLocaleTimeString(Qt.locale(), showSeconds ? format + ":ss" : format)
  font.pixelSize: 14
  color: "#cdd6f4"
  horizontalAlignment: Text.AlignHCenter

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: clockItem.text = new Date().toLocaleTimeString(
      Qt.locale(), clockItem.showSeconds ? clockItem.format + ":ss" : clockItem.format
    )
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true

    Rectangle {
      id: tooltip
      visible: parent.containsMouse
      width: dateLabel.width + 20
      height: dateLabel.height + 10
      radius: 4
      color: "#181825"
      border.color: "#313244"
      z: 10
      y: -height - 6

      Text {
        id: dateLabel
        anchors.centerIn: parent
        text: new Date().toLocaleDateString(Qt.locale(), clockItem.dateFormat)
        font.pixelSize: 12
        color: "#a6adc8"
      }
    }
  }
}
```

</BuildIt>

## Let's Improve It

Add a right-click context menu to toggle seconds and switch between 12h/24h formats:

```qml
Text {
  id: clockItem

  property bool showSeconds: true
  property bool use24h: true

  text: {
    var date = new Date()
    var opts = { hour: "2-digit", minute: "2-digit" }
    if (showSeconds) opts.second = "2-digit"
    if (!use24h) opts.hour12 = true
    return date.toLocaleTimeString(Qt.locale(), opts)
  }

  font.pixelSize: 14
  color: "#cdd6f4"

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: clockItem.text = clockItem.text // trigger re-evaluation
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.RightButton
    onClicked: contextMenu.open()

    Menu {
      id: contextMenu
      MenuItem {
        text: clockItem.showSeconds ? "Hide seconds" : "Show seconds"
        onTriggered: clockItem.showSeconds = !clockItem.showSeconds
      }
      MenuItem {
        text: clockItem.use24h ? "Use 12h format" : "Use 24h format"
        onTriggered: clockItem.use24h = !clockItem.use24h
      }
    }
  }
}
```

<CommonMistake>

**Not using `triggeredOnStart: true`.** Without it, the first update waits one full interval. The clock appears blank for a whole second on shell load.

**Formatting inside the `text` property binding instead of the `Timer` handler.** If you write `text: new Date().toLocaleTimeString(...)` directly as a binding, it evaluates only once. The binding doesn't re-evaluate until a dependency changes. You must use the `Timer.onTriggered` to reassign the text.

**Assuming `toLocaleTimeString` is free.** It does locale data lookup. Running it 60 times per second in a binding would hurt. Once per second is fine.

</CommonMistake>

## Under the Hood

QML's `Timer` uses Qt's `QTimer` internally, which fires on the main event loop. When the timer fires, it calls your callback synchronously. The actual time is fetched via JavaScript's `Date` object, which maps to the system clock (`clock_gettime` on Linux). The display never drifts because each tick reads the authoritative system time, not an accumulated offset.

<UnderTheHood>

The `text` property reassignment in `onTriggered` triggers QML's scene graph to mark the `Text` node as dirty. On the next frame, Qt Quick renders it using the pre-shaped text layout. Since the text content changed, the texture is re-uploaded to the GPU. For a once-per-second update, this overhead is negligible.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Display the current date below the time in a smaller font size. Update both independently using a single Timer that fires once per minute for the date and once per second for the time.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add an analog clock face using QML's `Canvas` type. Draw hour and minute hands that rotate based on the current time. Update the canvas every second.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a world-clock component that shows times for three timezones simultaneously. Store timezone offsets in a list and render each as a row with a city label and time. Handle DST transitions gracefully.
</ExerciseBlock>

<Recap :points="['Timer with 1000ms interval updates the display each second', 'Always read new Date() to prevent drift', 'triggeredOnStart: true shows the time immediately', 'Locale formatting respects user regional settings', 'Right-click menus can toggle format preferences']" next-chapter="/part-4-widgets/calendar" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

