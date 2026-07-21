---
title: "Hello World"
description: "Your first QML program — a simple window with text"
---

<ChapterMeta reading-time="5 min" :difficulty="1" you-will-build="A window displaying Hello World text" />

## The Problem

Every programming journey starts with a simple program that proves the toolchain works. For QML, that's a window with "Hello, World!" displayed in it. This chapter walks through every character so you understand the structure before we add complexity.

## The Naive Approach

If you come from web development, you might expect to write an HTML file with a `<script>` tag linking to a QML runtime. If you come from systems programming, you might expect to write a `main.cpp` that creates a `QQuickView`. Neither is right.

In QML, the source file *is* the program. You write a `.qml` file and the runtime executes it directly.

## The Idea

A QML file describes a tree of visual objects. The root object is the window itself. Inside it, you place child objects — text, rectangles, images — that form the UI. The QML runtime reads the file, creates the objects, and displays them.

## Let's Build It

Create a file named `hello.qml`:

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 320
  height: 240
  visible: true
  title: "Hello World"

  Text {
    text: "Hello, World!"
    anchors.centerIn: parent
    font.pixelSize: 24
    color: "#333333"
  }
}
```

Run it with:

```bash
qml6 hello.qml
```

A window appears, 320 by 240 pixels, titled "Hello World," with the text centered inside.

<BuildIt>

Line by line:

- `import QtQuick` — imports the core Qt Quick module. This gives you access to basic types like `Text`, `Rectangle`, and `Item`.
- `import QtQuick.Window` — imports the `Window` type specifically.
- `Window { ... }` — the root object. This is the actual OS window.
- `width: 320; height: 240` — the window dimensions in pixels.
- `visible: true` — windows are invisible by default in QML (you build them up before showing them).
- `title: "Hello World"` — the window title bar text.
- `Text { text: "Hello, World!" ... }` — a text label inside the window.
- `anchors.centerIn: parent` — positions the text at the center of the `Window`.
- `font.pixelSize: 24` — sets the text size.
- `color: "#333333"` — dark gray text color.

</BuildIt>

## Let's Improve It

Let's make it more visually interesting:

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 300
  visible: true
  title: "Hello World"

  Rectangle {
    anchors.fill: parent
    color: "#f0f0f8"

    Text {
      text: "Hello, World!"
      anchors.centerIn: parent
      font.pixelSize: 32
      font.bold: true
      color: "#1a56db"
    }

    Text {
      text: "Welcome to QML"
      anchors {
        top: parent.verticalCenter
        horizontalCenter: parent.horizontalCenter
        topMargin: 40
      }
      font.pixelSize: 14
      color: "#888888"
    }
  }
}
```

The `Rectangle` fills the window and provides a background color. Two `Text` elements are positioned at different vertical offsets.

<CommonMistake>

**Forgetting `visible: true`.** The window is created but never shown. If you run your QML file and see no window, check that `visible: true` is set.

**Omitting imports.** Without `import QtQuick`, the `Text` type is not available. Without `import QtQuick.Window`, `Window` is not available. The error message will say "TypeName is not a type."

</CommonMistake>

## Under the Hood

When you run `qml6 hello.qml`, the QML runtime:

1. Parses the file into an abstract syntax tree
2. Resolves the imports (`QtQuick`, `QtQuick.Window`)
3. Instantiates the `Window` object, which creates an OS window via the platform plugin
4. Sets properties (`width`, `height`, `visible`, `title`)
5. Instantiates the child `Text` object
6. Evaluates the `anchors.centerIn: parent` binding, positioning the text
7. Enters the Qt event loop, which handles window system events (paint, resize, input)

The `Text` element measures the string, selects a font, rasterizes the glyphs, and submits them to the window's scene graph for rendering.

## Exercises

<ExerciseBlock :difficulty="1">
Change the window title to "My First QML App" and increase the width to 500 pixels.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a third `Text` element below the subtitle that displays the text "🚀" (or any emoji). Use `anchors.top` to position it below the subtitle with some margin.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Replace the solid `color` on `Rectangle` with a `gradient` (use `Gradient` and `GradientStop` from QtQuick). Make a vertical gradient from light blue to white.
</ExerciseBlock>

<Recap :points="['QML files describe a tree of objects, with Window as the root', 'import QtQuick and import QtQuick.Window bring the core types into scope', 'Properties like width, height, visible, title configure the window', 'anchors.centerIn positions an element at its parent center', 'qml6 launches a QML file directly without compilation']" next-chapter="/part-1-qml/objects" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-window-window.html — Window type
- https://doc.qt.io/qt-6/qml-qtquick-text.html — Text type
- https://doc.qt.io/qt-6/qml-qtquick-rectangle.html — Rectangle type
-->
