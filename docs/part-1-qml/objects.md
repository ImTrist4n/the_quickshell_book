---
title: "Objects"
description: "Understanding QML objects — the building blocks of any QML interface"
---

<ChapterMeta reading-time="5 min" :difficulty="1" :prerequisites="['Hello World']" you-will-build="A nested object tree with rectangles and text" />

## The Problem

In the previous chapter, you wrote a `Window` containing a `Rectangle` containing a `Text`. This nesting of objects — objects inside objects — is the fundamental structure of every QML file. Understanding what an "object" is and how they compose is essential before you can build anything real.

## The Naive Approach

If you think of QML as a markup language (like HTML), you'd write tags and expect the runtime to handle the rest. But QML is a *language* — objects are real instances with properties, methods, and signals, not just markup nodes. Every `{ ... }` block creates an actual object in memory.

## The Idea

In QML, **everything is an object**. Numbers, strings, colors are values, but anything with a `{ }` is an object instance. Objects have:

- **Properties** — named attributes that configure the object (like `width`, `color`, `text`)
- **Methods** — functions that do things
- **Signals** — events the object can emit
- **Child objects** — nested objects that belong to the parent

The object tree is also the scene graph. A `Rectangle` inside a `Window` appears inside that window. If you remove the `Rectangle`, the content disappears. This is not a coincidence — the structure *is* the layout.

<MentalModel>

Think of QML objects as Russian nesting dolls. The outer doll (the Window) contains the next doll (the Rectangle), which contains smaller dolls (Text, Button, etc.). Each doll keeps its own state — its position, size, color — and can be pulled out and examined independently.

</MentalModel>

## Let's Build It

Create `objects.qml`:

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 300
  visible: true
  title: "QML Objects"

  Rectangle {
    x: 20
    y: 20
    width: 150
    height: 100
    color: "#ff6b6b"
    radius: 8

    Text {
      text: "Box 1"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 16
    }
  }

  Rectangle {
    x: 200
    y: 20
    width: 150
    height: 100
    color: "#4ecdc4"
    radius: 8

    Text {
      text: "Box 2"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 16
    }
  }

  Rectangle {
    x: 20
    y: 150
    width: 330
    height: 100
    color: "#ffe66d"
    radius: 8

    Text {
      text: "Wide Box"
      anchors.centerIn: parent
      color: "#333"
      font.pixelSize: 16
    }
  }
}
```

This creates three rectangles at different positions. Each is a separate object with its own position, size, color, and child text.

<BuildIt>

Key points about objects here:

- **Positioning is explicit.** `x` and `y` set the top-left corner relative to the parent's top-left. `x: 20; y: 20` means "20 pixels from the left, 20 from the top."

- **Each object is independent.** Changing `Box 1`'s color doesn't affect `Box 2`. Each maintains its own property values.

- **Child objects are indented.** The `Text` inside each `Rectangle` is indented to show ownership. QML doesn't require this, but it's the universal convention — it makes the object tree visually clear.

- **Coordinates are relative.** `anchors.centerIn: parent` uses the immediate parent. The `Text` doesn't know about the `Window` — it only knows about its `Rectangle`.

</BuildIt>

## Let's Improve It

Objects can also contain non-visual children. Let's add a `Timer` and a `MouseArea`:

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 300
  visible: true
  title: "Interactive Objects"

  Rectangle {
    id: box
    x: 100; y: 80
    width: 200; height: 140
    color: "#4ecdc4"
    radius: 12

    Text {
      id: label
      text: "Click me!"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 20
      font.bold: true
    }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        box.color = "#ff6b6b"
        label.text = "Clicked!"
      }
    }

    Timer {
      interval: 1000
      running: false
      onTriggered: {
        box.color = "#4ecdc4"
        label.text = "Click me!"
      }
    }
  }
}
```

Click the box. It turns red and the text changes. After 1 second, the `Timer` fires and resets everything. The `MouseArea` and `Timer` are non-visual objects — they don't render anything but they respond to events and control the visual objects.

<CommonMistake>

**Confusing parent with the containing object.** In QML, "parent" means the enclosing object. A `Text` inside a `Rectangle` has that `Rectangle` as its parent. `anchors.centerIn: parent` means the center of the `Rectangle`, not the `Window`.

**Forgetting that order matters for z-index.** Objects declared later in the file appear on top of objects declared earlier. If `Wide Box` was declared first, it would be behind `Box 1` and `Box 2` where they overlap.

</CommonMistake>

## Under the Hood

QML objects are backed by C++ classes from the Qt Quick module. When the QML engine encounters `Rectangle { ... }`, it:

1. Looks up the `Rectangle` type in the registered QML types
2. Calls the C++ constructor for `QQuickRectangle`
3. Sets the properties you declared (`width`, `color`, etc.)
4. Recursively processes child objects, each becoming a child QML object

The object tree mirrors a scene graph. Qt Quick's rendering engine traverses this graph every frame, issuing OpenGL/Vulkan draw calls for each visual node. Non-visual nodes (`Timer`, `MouseArea`) are part of the QML object tree but don't contribute to the scene graph.

## Exercises

<ExerciseBlock :difficulty="1">
Add a fourth rectangle to the first example. Position it at `x: 20; y: 80` with a different color and text.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Modify the interactive example so clicking the box cycles through three colors: teal → red → gold → back to teal.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a row of 5 small rectangles, each with a different color. Use `x` positioning to space them evenly. Then, write a `Timer` that shifts all colors to the right every second (like a color marquee).
</ExerciseBlock>

<Recap :points="['Every { } block in QML creates an object instance', 'Objects have properties, methods, signals, and child objects', 'Child objects are positioned relative to their parent', 'Non-visual objects like Timer and MouseArea add behavior without rendering', 'The object tree mirrors the scene graph that Qt renders each frame']" next-chapter="/part-1-qml/properties" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-text.html — Text type
- https://doc.qt.io/qt-6/qml-qtquick-rectangle.html — Rectangle type
- https://doc.qt.io/qt-6/qml-qtquick-mousearea.html — MouseArea type
- https://doc.qt.io/qt-6/qml-qtqml-timer.html — Timer type
-->
