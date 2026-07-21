---
title: "Calendar"
description: "A calendar popup or widget using QML Date/Time types"
---

## The Problem

A panel clock is nice, but users often need to see the full month — what day of the week the 15th falls on, how many days are in February, or what next week looks like. Building a calendar grid manually means computing day offsets, leap years, and month boundaries.

## The Naive Approach

Hardcode a grid of 42 cells (6 weeks) and manually compute which day of the week the 1st falls on. Use JavaScript arithmetic to fill in dates. It works, but the code is fragile and hard to read.

```qml
Grid {
  columns: 7
  // Manually compute day offsets with Date arithmetic
  // Lots of reusable JS that's easy to get wrong
}
```

<MentalModel>

A calendar is like a printed wall calendar. You know January always has 31 days, but which day of the week it starts on changes yearly. The grid itself is just a table — the hard part is figuring out what goes in each cell.

</MentalModel>

## The Idea

QML gives you access to JavaScript's `Date` object, plus `Qt.locale()` for day/month names. You can compute the first day of the month, walk through each day, and build a grid. Quickshell doesn't provide a built-in calendar — you compose it from `Grid`, `Text`, and date arithmetic.

## Let's Build It

A month-view calendar component with navigation:

<BuildIt>

```qml
import QtQuick
import QtQuick.Layouts

Column {
  id: calendar

  property date currentMonth: new Date()
  property color textColor: "#cdd6f4"
  property color accentColor: "#89b4fa"
  property color dimColor: "#585b70"

  function daysInMonth(d) {
    return new Date(d.getFullYear(), d.getMonth() + 1, 0).getDate()
  }

  function monthStartDay(d) {
    return new Date(d.getFullYear(), d.getMonth(), 1).getDay()
  }

  Row {
    spacing: 8
    Text {
      text: "<"
      color: calendar.accentColor
      font.pixelSize: 16
      MouseArea {
        anchors.fill: parent
        onClicked: calendar.currentMonth = new Date(
          calendar.currentMonth.getFullYear(),
          calendar.currentMonth.getMonth() - 1, 1)
      }
    }
    Text {
      text: calendar.currentMonth.toLocaleDateString(Qt.locale(), "MMMM yyyy")
      font.pixelSize: 16
      color: calendar.textColor
    }
    Text {
      text: ">"
      color: calendar.accentColor
      font.pixelSize: 16
      MouseArea {
        anchors.fill: parent
        onClicked: calendar.currentMonth = new Date(
          calendar.currentMonth.getFullYear(),
          calendar.currentMonth.getMonth() + 1, 1)
      }
    }
  }

  Grid {
    columns: 7
    spacing: 4
    topPadding: 8

    Repeater {
      model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

      Text {
        text: modelData
        font.pixelSize: 11
        color: calendar.dimColor
        horizontalAlignment: Text.AlignHCenter
        width: 32
      }
    }

    Repeater {
      model: {
        var days = daysInMonth(calendar.currentMonth)
        var startDay = monthStartDay(calendar.currentMonth)
        var cells = []
        for (var i = 0; i < startDay; i++) cells.push(0)
        for (var d = 1; d <= days; d++) cells.push(d)
        while (cells.length % 7 !== 0) cells.push(0)
        return cells
      }

      Rectangle {
        width: 32; height: 28
        radius: 4
        color: {
          var today = new Date()
          if (modelData === today.getDate() &&
              calendar.currentMonth.getMonth() === today.getMonth() &&
              calendar.currentMonth.getFullYear() === today.getFullYear())
            return calendar.accentColor
          return "transparent"
        }

        Text {
          anchors.centerIn: parent
          text: modelData > 0 ? modelData : ""
          font.pixelSize: 12
          color: modelData > 0 ? calendar.textColor : "transparent"
        }
      }
    }
  }
}
```

</BuildIt>

## Let's Improve It

Add event dots (highlight days with scheduled events) and keyboard navigation:

```qml
// Extend the day cell with an event indicator
Rectangle {
  // ... base properties ...

  Rectangle {
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    width: 4; height: 4; radius: 2
    color: "#f9e2af"
    visible: eventDays.indexOf(modelData) >= 0
  }
}

// Add KeyNavigation for arrow-key traversal
property int focusedDay: 1
Keys.onLeftPressed: focusedDay = Math.max(1, focusedDay - 1)
Keys.onRightPressed: focusedDay = Math.min(daysInMonth(currentMonth), focusedDay + 1)
```

<CommonMistake>

**Off-by-one in day index.** JavaScript's `getDay()` returns 0 for Sunday, 1 for Monday. Your grid column mapping must match. If you label columns "Mon" through "Sun", adjust by shifting the index.

**Forgetting trailing cells.** A 31-day month starting on Friday fills 5 weeks but leaves 2 empty cells at the end. Without padding, the grid misaligns. Always pad to a multiple of 7.

**Date mutation.** JavaScript `Date` methods like `setMonth()` mutate the original. Always create a new `Date` for navigation to avoid unpredictable side effects in bindings.

</CommonMistake>

## Under the Hood

The calendar grid is a `Repeater` over a computed model array. Each time `currentMonth` changes, the model recomputes. QML's binding engine re-evaluates the `model` expression, the `Repeater` destroys old delegates and creates new ones. For a 42-cell grid this is fast, but for year-at-a-glance views, consider `ListView` with cached delegates.

<UnderTheHood>

`Repeater` creates all delegates synchronously during evaluation. For a single month (42 items), this is fine. The `model` expression creates a new `Array` each time, which triggers a full delegate rebuild — there's no diffing. If you add animations, wrap the grid in a `StackView` or use `opacity` transitions to smooth month changes.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Add a button to jump back to today's date. Highlight the current day with a filled circle instead of a rounded rectangle.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement week-number display (ISO 8601) on the left edge of each row. Compute week numbers using JavaScript's date arithmetic.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a year-at-a-glance view: 12 mini calendars arranged in a 4x3 grid. Each mini calendar shows the month name and day cells at a 0.5x scale. Animate between month and year views.
</ExerciseBlock>

<Recap :points="['Calendar grids are built with Grid + Repeater over a computed array', 'Day-of-week index (getDay) must match column order', 'Pad model array to multiples of 7 to avoid alignment issues', 'Create new Date objects instead of mutating shared state', 'Event indicators highlight days with scheduled items']" next-chapter="/part-4-widgets/battery" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

