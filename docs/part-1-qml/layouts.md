---
title: "Layouts"
description: "Using Row, Column, Grid, and other layout elements in QML"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['Anchors']" you-will-build="A widget layout using Row, Column, and Grid" />

## The Problem

Anchors are great for positioning a few items relative to the window edges. But when you have a list of items — icons in a toolbar, widgets in a panel, buttons in a dialog — anchoring each one individually is tedious. If you add or remove an item, you have to reposition everything manually.

## The Naive Approach

You could position each item using `x` and calculate positions:

```qml
Item {
  Rectangle { x: 0; width: 50; height: 50; color: "red" }
  Rectangle { x: 60; width: 50; height: 50; color: "green" }
  Rectangle { x: 120; width: 50; height: 50; color: "blue" }
}
```

If you add a fourth rectangle at position 180, you have to recalculate every subsequent position. If you want equal spacing, you need to know the total width ahead of time.

<MentalModel>

Anchors are like arranging furniture in a room by measuring from the walls. Layouts are like putting items on a shelf — you just place them in order and the shelf handles the spacing. Add more items, and they push each other along; remove one, and the gap closes automatically.

</MentalModel>

## The Idea

Qt Quick provides layout types that arrange children automatically:

- **`Row`** — positions children horizontally, left to right
- **`Column`** — positions children vertically, top to bottom
- **`Grid`** — positions children in a grid with rows and columns
- **`Flow`** — wraps children to the next row/column when space runs out

Each layout has a `spacing` property for gaps between children and `padding` for outer margins.

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 350
  visible: true
  title: "Layouts"

  Column {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 10

    // Toolbar row
    Row {
      width: parent.width
      height: 40
      spacing: 6
      layoutDirection: Qt.LeftToRight

      Rectangle { width: 40; height: 40; radius: 4; color: "#ff6b6b" }
      Rectangle { width: 40; height: 40; radius: 4; color: "#4ecdc4" }
      Rectangle { width: 40; height: 40; radius: 4; color: "#ffe66d" }
      Rectangle { width: 40; height: 40; radius: 4; color: "#45b7d1" }
      Item { width: 40; height: 40 }  // Spacer
      Rectangle {
        width: 80; height: 40; radius: 4
        color: "#95e1d3"
        Text { text: "Action"; anchors.centerIn: parent; color: "#333" }
      }
    }

    // Content area
    Row {
      width: parent.width
      height: 200
      spacing: 10

      // Sidebar column
      Column {
        width: 120
        height: parent.height
        spacing: 6

        Repeater {
          model: ["Files", "Edit", "View", "Help"]
          Rectangle {
            width: parent.width
            height: 36
            radius: 4
            color: "#f0f0f8"

            Text {
              text: modelData
              anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 10
              }
              color: "#333"
              font.pixelSize: 13
            }
          }
        }
      }

      // Main content
      Rectangle {
        width: parent.width - 130
        height: parent.height
        color: "#fafafa"
        radius: 4
        border.color: "#ddd"
        border.width: 1

        Text {
          text: "Main Content"
          anchors.centerIn: parent
          color: "#888"
          font.pixelSize: 16
        }
      }
    }

    // Status bar
    Rectangle {
      width: parent.width
      height: 30
      color: "#e8e8ee"
      radius: 4

      Text {
        text: "Status: Ready | 3 items"
        anchors {
          left: parent.left
          verticalCenter: parent.verticalCenter
          leftMargin: 10
        }
        color: "#666"
        font.pixelSize: 12
      }
    }
  }
}
```

<BuildIt>

- **`Column { spacing: 10 }`** — stacks the toolbar, content area, and status bar vertically with 10px gaps.
- **`Row { spacing: 6 }`** — arranges toolbar buttons horizontally.
- **`Item` as spacer** — an invisible `Item` with fixed width creates a gap without using margins.
- **`layoutDirection`** — controls ordering. `Qt.LeftToRight` (default) or `Qt.RightToLeft`.
- **Nested layouts** — a `Row` containing a `Column` (sidebar) and a `Rectangle` (content) creates complex layouts without `x`/`y` calculations.

</BuildIt>

## Let's Improve It

For more control, use `Layout` attached properties from `QtQuick.Layouts`:

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
  width: 400
  height: 300
  visible: true
  title: "QtQuick Layouts"

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 10
    spacing: 8

    RowLayout {
      Layout.fillWidth: true
      spacing: 8

      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        color: "#4ecdc4"
        radius: 4
      }
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        color: "#ff6b6b"
        radius: 4
      }
      Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        color: "#ffe66d"
        radius: 4
      }
    }

    Rectangle {
      Layout.fillWidth: true
      Layout.fillHeight: true
      color: "#f0f0f8"
      radius: 4

      Text {
        text: "Expands to fill"
        anchors.centerIn: parent
        color: "#666"
      }
    }
  }
}
```

`Layout.fillWidth` and `Layout.fillHeight` let items expand to fill available space, similar to flexbox's `flex-grow`.

<CommonMistake>

**Using `Row` with fixed-width items that exceed the row width.** Items will overflow and clip. Use `Flow` or `Grid` for wrapping, or bind item widths to `parent.width / itemCount - spacing`.

**Forgetting `width` on items inside a `Column`.** A `Column` gives its children their requested `width`. If you don't set `width`, the child may collapse to zero. Use `width: parent.width` to fill the column.

**Confusing `QtQuick` layouts with `QtQuick.Layouts`.** `Row` and `Column` come from `QtQuick` and are always available after `import QtQuick`. `RowLayout` and `ColumnLayout` come from `QtQuick.Layouts` and need a separate import.

</CommonMistake>

## Under the Hood

Layouts work in two phases. In the **polish** phase, the layout calculates the position and size of each child based on its content, spacing, and padding. In the **layout** phase, it applies these values. The polish phase may repeat if any child's implicit size changes (due to text wrapping, image loading, etc.).

`Row` and `Column` use simple sequential positioning. `GridLayout` from `QtQuick.Layouts` uses a more sophisticated algorithm that spans cells and distributes remaining space proportionally.

## Exercises

<ExerciseBlock :difficulty="1">
Build a toolbar with 5 buttons using `Row`. The buttons should be evenly spaced and centered. Use `Item` spacers between them.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a 2x3 grid using `Grid` (from `QtQuick`) with `columns: 3`. Each cell should be a colored rectangle with a number label.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Use `ColumnLayout` and `RowLayout` to build a simple settings panel with two columns: labels on the left and controls on the right. Labels should right-align, controls should left-align.
</ExerciseBlock>

<Recap :points="['Row arranges children horizontally, Column vertically, Grid in a grid pattern', 'Layouts handle positioning automatically — add or remove children without manual recalculations', 'spacing and padding control gaps between and around children', 'QtQuick.Layouts provides more sophisticated sizing with fillWidth and fillHeight']" next-chapter="/part-1-qml/property-bindings" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-row.html — Row type
- https://doc.qt.io/qt-6/qml-qtquick-column.html — Column type
- https://doc.qt.io/qt-6/qml-qtquick-grid.html — Grid type
- https://doc.qt.io/qt-6/qml-qtquick-layouts-columnlayout.html — ColumnLayout type
-->
