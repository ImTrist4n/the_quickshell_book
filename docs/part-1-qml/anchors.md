---
title: "Anchors"
description: "Positioning elements with QML anchors — left, right, top, bottom, center, and margins"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['IDs']" you-will-build="A panel-like layout using only anchors" />

## The Problem

In the Objects chapter, you positioned rectangles using `x` and `y` coordinates. That works for simple layouts, but it breaks when the window resizes. If the window is 400 pixels wide and you place a rectangle at `x: 300`, it looks fine at 400px but falls off the edge if the window shrinks. You need a way to say "keep this 20 pixels from the right edge" regardless of window size.

## The Naive Approach

You could bind `x` to `parent.width` minus some offset:

```qml
Rectangle {
  x: parent.width - width - 20
}
```

This works but gets unwieldy when you need to position multiple items relative to each other and to the parent. The expressions become nested and hard to read.

<MentalModel>

Think of anchors like magnets. Each side of an object (left, right, top, bottom) has a magnet, and you can attach it to the corresponding magnet on another object. When the target moves, your object follows. You don't calculate positions — you describe attractions.

</MentalModel>

## The Idea

The `anchors` property on every QML `Item` provides a complete system for relative positioning:

- `anchors.left`, `anchors.right`, `anchors.top`, `anchors.bottom` — attach a side to another object's side
- `anchors.horizontalCenter`, `anchors.verticalCenter` — center-align to another object
- `anchors.centerIn` — shortcut for centering in both axes
- `anchors.fill` — match another object's size exactly
- `anchors.margins` — space between attached sides

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 400
  visible: true
  title: "Anchors"

  Rectangle {
    id: header
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
    }
    height: 50
    color: "#1a1a2e"

    Text {
      text: "Header"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 18
      font.bold: true
    }
  }

  Rectangle {
    id: sidebar
    anchors {
      left: parent.left
      top: header.bottom
      bottom: parent.bottom
    }
    width: 120
    color: "#16213e"

    Text {
      text: "Sidebar"
      anchors.centerIn: parent
      color: "#aaa"
      font.pixelSize: 14
    }
  }

  Rectangle {
    id: content
    anchors {
      left: sidebar.right
      right: parent.right
      top: header.bottom
      bottom: parent.bottom
      leftMargin: 1
    }
    color: "#f0f0f8"

    Text {
      text: "Content Area"
      anchors.centerIn: parent
      color: "#333"
      font.pixelSize: 16
    }
  }

  Rectangle {
    id: statusBar
    anchors {
      left: sidebar.right
      right: parent.right
      bottom: parent.bottom
    }
    height: 30
    color: "#e0e0e8"

    Text {
      text: "Status: Ready"
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
```

Resize the window. The header stays at the top, sidebar on the left, content fills the remaining space. Nothing falls off the edge.

<BuildIt>

The anchor syntax can be grouped:

```qml
anchors {
  left: parent.left
  right: parent.right
  top: parent.top
}
```

This is equivalent to:

```qml
anchors.left: parent.left
anchors.right: parent.right
anchors.top: parent.top
```

The grouped form is preferred for readability when setting multiple anchors.

Key anchor relationships:

- **`header.bottom`** — the bottom of header. `sidebar`'s `top` is attached here, so sidebar starts right below header.
- **`sidebar.right`** — the right edge of sidebar. `content`'s `left` attaches here, so content starts where sidebar ends.
- **`leftMargin: 1`** — a 1-pixel gap between sidebar and content.

</BuildIt>

## Let's Improve It

Anchors can chain. The status bar is anchored to `sidebar.right` on the left and `parent.right` on the right. If sidebar's width changes, the status bar follows:

```qml
// Changing sidebar width later:
sidebar.width = 200
// statusBar automatically adjusts because its left edge is bound to sidebar.right
```

You can also anchor to the center of another object:

```qml
Rectangle {
  id: circle
  width: 100; height: 100
  radius: width / 2
  color: "#4ecdc4"

  Text {
    text: "Centered"
    anchors.centerIn: parent  // Shortcut for horizontalCenter + verticalCenter
  }
}
```

<CommonMistake>

**Conflicting anchors.** You can't anchor both `left` and `right` to different objects if those objects are at fixed positions — you'll get a conflict. If you set `anchors.fill: parent`, don't also set `anchors.left: otherObject`.

**Forgetting `anchors.margins` applies to all sides.** Setting `anchors.margins: 10` adds 10px margin to left, right, top, and bottom. Use individual `leftMargin`, `rightMargin`, etc. for per-side control.

**Over-anchoring.** You rarely need all four anchors. Often two are enough: `anchors.left: parent.left; anchors.right: parent.right` plus a `height` or `anchors.top/anchors.bottom`.

</CommonMistake>

## Under the Hood

The `anchors` property is implemented by `QQuickItem`, the base type for all visual QML objects. Each anchor is a `QQmlAnchorLineProxy` that resolves to another item's edge at evaluation time. The Qt Quick scene graph uses these anchor relationships during the layout pass, which happens before the render pass.

If item A's `left` is anchored to item B's `right`, the layout pass calculates A's horizontal position as `B.x + B.width`. This is a directed relationship — if you change B's width, A moves. But the reverse is not automatically tracked unless B also anchors to A, which would create a circular dependency.

## Exercises

<ExerciseBlock :difficulty="1">
Add a footer rectangle below the content area, anchored to the bottom of the window. Give it a height of 40 and a dark background.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a flexible layout with three columns that each take up one third of the window width. Use anchors (no `x` coordinates). Each column should have a different color.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a dialog box that's centered in the window using `anchors.centerIn`. Add a close button (a `Text` element with "✕") anchored to the top-right corner of the dialog.
</ExerciseBlock>

<Recap :points="['Anchors define relationships between object edges rather than fixed coordinates', 'Common anchors: left, right, top, bottom, horizontalCenter, verticalCenter, fill, centerIn', 'Margins add spacing between anchored edges', 'Anchor relationships survive window resizes and layout changes', 'Avoid conflicting anchors by choosing the minimum set needed']" next-chapter="/part-1-qml/layouts" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-item.html#anchors.property — anchors property documentation
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout documentation
-->
