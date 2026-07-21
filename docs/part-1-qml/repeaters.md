---
title: "Repeaters"
description: "Using Repeater to dynamically generate multiple QML items from a model"
---

<ChapterMeta reading-time="6 min" :difficulty="2" :prerequisites="['Models & Delegates']" you-will-build="A dynamic grid of colored tiles using Repeater" />

## The Problem

In the previous chapter, you used `Repeater` with a model and delegate. But `Repeater` deserves its own focus because it's the simplest and most versatile way to generate repetitive UIs — and it has behaviors you need to understand to use it correctly.

## The Naive Approach

Without `Repeater`, you'd write out every item:

```qml
Row {
  Rectangle { width: 40; height: 40; color: "#ff6b6b" }
  Rectangle { width: 40; height: 40; color: "#ff9f43" }
  Rectangle { width: 40; height: 40; color: "#ffe66d" }
  Rectangle { width: 40; height: 40; color: "#4ecdc4" }
  Rectangle { width: 40; height: 40; color: "#45b7d1" }
}
```

This works for five items but becomes unwieldy at fifty. And if you want to change all rectangles from 40×40 to 48×48, you edit five lines instead of one.

<MentalModel>

`Repeater` is like a printing press. You design one delegate (the printing plate), and the press stamps out copies for every item in the model. Change the plate, and every copy changes the next time you print.

</MentalModel>

## The Idea

`Repeater` creates one delegate instance per item in its model. It's the simplest view type — no scrolling, no virtualization, no selection model. It's ideal for:

- Toolbar buttons
- Color swatches
- Tab headers
- Small notification lists
- Any UI with a known, small number of items

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 400
  visible: true
  title: "Repeater"

  // Different model types
  property var colors: ["#ff6b6b", "#ff9f43", "#ffe66d", "#4ecdc4", "#45b7d1",
                         "#a29bfe", "#fd79a8", "#6c5ce7", "#00cec9", "#fab1a0"]

  Column {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 16

    Text {
      text: "Toolbar (int model)"
      font.pixelSize: 14
      font.bold: true
      color: "#333"
    }

    // Integer model: generates indices 0..4
    Row {
      spacing: 6
      Repeater {
        model: 5
        delegate: Rectangle {
          required property int index

          width: 44; height: 44; radius: 6
          color: colors[index % colors.length]

          Text {
            text: parent.parent.index // index from Repeater, not delegate
            anchors.centerIn: parent
            color: "white"
            font.bold: true
          }
        }
      }
    }

    Text {
      text: "Color swatches (array model)"
      font.pixelSize: 14
      font.bold: true
      color: "#333"
    }

    // Array model with Flow for wrapping
    Flow {
      width: parent.width
      spacing: 6

      Repeater {
        model: colors

        delegate: Rectangle {
          required property var modelData
          required property int index

          width: 48; height: 48; radius: 24
          color: modelData

          MouseArea {
            anchors.fill: parent
            onClicked: {
              swatchInfo.text = "Color #" + (index + 1) + ": " + modelData
            }
          }
        }
      }
    }

    Text {
      id: swatchInfo
      text: "Click a swatch"
      color: "#888"
      font.pixelSize: 13
    }

    Text {
      text: "Dynamic items"
      font.pixelSize: 14
      font.bold: true
      color: "#333"
    }

    // Dynamic model using ListModel
    Row {
      spacing: 6

      Repeater {
        model: ListModel {
          ListElement { label: "A"; color: "#ff6b6b" }
          ListElement { label: "B"; color: "#4ecdc4" }
          ListElement { label: "C"; color: "#45b7d1" }
        }

        delegate: Rectangle {
          required property string label
          required property string color

          width: 60; height: 60; radius: 8
          color: color

          Text {
            text: label
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 24
            font.bold: true
          }
        }
      }
    }
  }
}
```

<BuildIt>

Three model types shown:

1. **Integer model: `model: 5`** — generates indices 0 through 4. Useful for quick n-item layouts.
2. **Array model: `model: colors`** — delegates access each element via `modelData`.
3. **ListModel** — structured data with named roles (`label`, `color`) accessible directly in the delegate.

`Repeater` inside a `Flow` automatically wraps items to the next row when they exceed the container width — useful for dynamic toolbars.

</BuildIt>

## Let's Improve It

`Repeater` can work with `positioner` types beyond `Row` and `Column`:

```qml
// Grid with Repeater
Grid {
  columns: 3
  spacing: 8

  Repeater {
    model: 9
    delegate: Rectangle {
      required property int index
      width: 80; height: 80; radius: 4
      color: Qt.hsla(index / 9, 0.7, 0.6, 1)

      Text {
        text: index + 1
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 24
        font.bold: true
      }
    }
  }
}
```

The `Grid` arranges the 9 items in a 3×3 grid automatically.

<CommonMistake>

**Using `Repeater` for large lists.** `Repeater` instantiates *all* delegates immediately. For lists over ~50 items, use `ListView` which recycles delegates. A shell workspace indicator with 10 items is fine; a notification history with 500 items is not.

**Expecting `Repeater` to update when the model reference changes.** If you reassign the model property (e.g., `model = newArray`), `Repeater` will recreate all delegates. For incremental updates, use `ListModel` with `append`/`remove`/`setProperty`.

**Accessing `index` without declaring it.** In modern QML, you must use `required property int index` in the delegate. Older examples omit this, but the engine now requires explicit `required` for injected properties.

</CommonMistake>

## Under the Hood

`Repeater` is a `QQuickRepeater` that creates one delegate instance per model item during the polishing phase. It connects to the model's `rowsInserted`, `rowsRemoved`, and `modelReset` signals. When the model changes, `Repeater` creates or destroys delegates accordingly.

Each delegate is a child of the `Repeater`'s parent (not of the `Repeater` itself). The `Repeater` positions children only if it's inside a positioner (`Row`, `Column`, `Grid`, `Flow`). If you use `Repeater` inside a plain `Item`, you must position delegates manually.

## Exercises

<ExerciseBlock :difficulty="1">
Use `Repeater` with an integer model of 8 to create a row of 8 colored squares. Each square should use `Qt.hsla(index / 8, 0.7, 0.6, 1)` for a rainbow effect.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a dynamic toolbar using `Flow` + `Repeater` + a `ListModel`. Add a "New Button" button that appends a new color button to the toolbar.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a simple pagination control. Use `Repeater` with an integer model (total pages) inside a `Row`. The current page should be highlighted. Clicking a page number emits a signal.
</ExerciseBlock>

<Recap :points="['Repeater creates one delegate per model item, ideal for small known-sized lists', 'Models can be integers (indices), arrays (modelData), or ListModel (named roles)', 'Repeater instantiates all delegates immediately — not suitable for large lists', 'Use inside Row, Column, Grid, or Flow for automatic positioning']" next-chapter="/part-1-qml/listview" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-repeater.html — Repeater type
- https://doc.qt.io/qt-6/qml-qtquick-flow.html — Flow type
- https://doc.qt.io/qt-6/qml-qtquick-grid.html — Grid type
-->
