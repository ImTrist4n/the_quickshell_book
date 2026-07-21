---
title: "Components"
description: "Reusable QML components — defining, instantiating, and parameterizing custom UI elements"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['Signals']" you-will-build="A reusable button component with customizable appearance" />

## The Problem

As your shell grows, you'll write the same patterns repeatedly: buttons with hover effects, labeled data displays, toggle switches. Copy-pasting the same 20 lines of QML every time is wasteful and makes global style changes impossible — you'd have to find and update every copy.

## The Naive Approach

Inline everything, every time:

```qml
Rectangle {
  width: 100; height: 36; radius: 6
  color: mouseArea.containsMouse ? "#45b7d1" : "#4ecdc4"
  Text { text: "Button 1"; anchors.centerIn: parent; color: "white" }
  MouseArea { anchors.fill: parent; onClicked: { /* action */ } }
}

// Later, elsewhere:
Rectangle {
  width: 100; height: 36; radius: 6
  color: mouseArea.containsMouse ? "#45b7d1" : "#4ecdc4"
  Text { text: "Button 2"; anchors.centerIn: parent; color: "white" }
  MouseArea { anchors.fill: parent; onClicked: { /* different action */ } }
}
```

To change the button style, you edit every instance. To add a feature (like an icon), you edit every instance. This doesn't scale beyond two buttons.

<MentalModel>

Think of components as rubber stamps. You carve the design once (the component), then stamp it wherever you need it. Each stamp can be inked differently — different text, different colors — but the shape and behavior come from the original carving.

</MentalModel>

## The Idea

A **component** is a reusable QML type defined in its own `.qml` file. The filename becomes the type name. You define properties, signals, and internal structure once, then instantiate it anywhere with different property values.

## Let's Build It

First, the component file:

```qml
// StyledButton.qml
import QtQuick

Rectangle {
  id: root

  // Public API
  property string text: "Button"
  property color baseColor: "#4ecdc4"
  property color hoverColor: "#45b7d1"
  property color textColor: "white"
  property int fontSize: 14
  property bool rounded: true

  // Internal state
  property bool private pressed: false

  // Signals
  signal clicked()
  signal pressed()
  signal released()

  width: 120
  height: 40
  radius: rounded ? height / 2 : 4
  color: mouseArea.containsMouse ?
    (pressed ? Qt.darker(hoverColor, 1.2) : hoverColor) : baseColor

  Behavior on color {
    ColorAnimation { duration: 100 }
  }

  Text {
    text: root.text
    anchors.centerIn: parent
    color: root.textColor
    font.pixelSize: root.fontSize
    font.bold: true
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true

    onClicked: root.clicked()
    onPressed: { root.pressed = true; root.pressed() }
    onReleased: { root.pressed = false; root.released() }
  }
}
```

Now use it:

```qml
// main.qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 300
  visible: true
  title: "Components"

  Column {
    anchors.centerIn: parent
    spacing: 12

    StyledButton {
      text: "Primary Action"
      baseColor: "#1a56db"
      hoverColor: "#1e40af"
      onClicked: status.text = "Primary clicked"
    }

    StyledButton {
      text: "Danger"
      baseColor: "#dc2626"
      hoverColor: "#b91c1c"
      onClicked: status.text = "Danger clicked"
    }

    StyledButton {
      text: "Small"
      width: 80; height: 28
      fontSize: 12
      rounded: false
      onClicked: status.text = "Small clicked"
    }

    StyledButton {
      text: "Custom"
      baseColor: "transparent"
      textColor: "#333"
      hoverColor: "#e0e0e0"
      rounded: true
      border { color: "#ccc"; width: 1 }
      onClicked: status.text = "Custom clicked"
    }

    Text {
      id: status
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Click a button"
      color: "#888"
      font.pixelSize: 13
    }
  }
}
```

<BuildIt>

The component pattern:

1. **File = Type.** `StyledButton.qml` becomes the `StyledButton` type. The filename must start with a capital letter.
2. **Properties are the API.** `property string text`, `property color baseColor`, etc. define how users customize the component.
3. **Internal state is private.** `property bool private pressed` — the `private` keyword prevents external access.
4. **Signals for actions.** `signal clicked()`, `signal pressed()`, `signal released()` let users respond to events.
5. **Root object is the component.** Whatever the root object is (here `Rectangle`), that's what gets instantiated. Its properties and children are internal.

</BuildIt>

## Let's Improve It

Components can compose other components:

```qml
// IconButton.qml
import QtQuick

Item {
  property string text: ""
  property string icon: ""
  property color color: "#4ecdc4"
  signal clicked()

  width: iconText.width + labelText.width + 20
  height: 40

  StyledButton {
    anchors.fill: parent
    baseColor: parent.color
    onClicked: parent.clicked()

    Row {
      anchors.centerIn: parent
      spacing: 6

      Text {
        id: iconText
        text: parent.parent.icon
        font.pixelSize: 16
        color: "white"
        visible: text !== ""
      }

      Text {
        id: labelText
        text: parent.parent.text
        font.pixelSize: 14
        font.bold: true
        color: "white"
        visible: text !== ""
      }
    }
  }
}
```

Now you have a hierarchy: `IconButton` uses `StyledButton`, which uses `Rectangle`, `Text`, and `MouseArea`. Each layer adds value without reimplementing the lower layer.

<CommonMistake>

**Using the component file's own name inside itself.** `StyledButton.qml` cannot contain `StyledButton { }` — that would be a recursive definition. Instead, use `id: root`.

**Over-exposing internal details.** If a component's internal structure leaks (e.g., exposing the `MouseArea` as a property), users become dependent on internals that might change. Keep the API narrow: properties + signals.

**Not using a `default property` for children.** If you want `StyledButton { Text { } }` to add children, declare `default property alias contentItem: innerItem.data`. This is advanced but important for container components.

</CommonMistake>

## Under the Hood

When QML loads `StyledButton.qml`, it compiles it into a new `QML type` that inherits from its root object's C++ type (here `QQuickRectangle`). The properties you declare become `Q_PROPERTY` entries with automatic change signals. Each instance of `StyledButton` is a separate `QQuickRectangle` with its own property values.

Because components are compiled into types, they're efficient — the QML engine doesn't re-parse the file for every instance. The internal structure is instantiated once per instance (like a class), but the type definition is compiled once.

## Exercises

<ExerciseBlock :difficulty="1">
Create a `LabeledValue` component that shows a label above a value. Properties: `label`, `value` (both strings), `labelColor`, `valueColor`. The label should be smaller and lighter.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a `ToggleSwitch` component. Properties: `checked` (bool), `onColor`, `offColor`. Signals: `toggled(bool checked)`. The switch should animate between on and off positions.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a `Card` component that has a header area, content area, and footer area using `default property`. The card should have a shadow effect (use nested rectangles with opacity) and rounded corners.
</ExerciseBlock>

<Recap :points="['A component is a .qml file whose filename becomes a reusable type', 'Properties define the public API; internal implementation is encapsulated', 'Components can nest and compose other components', 'Keep the API narrow — expose only what users need to configure']" next-chapter="/part-1-qml/models-and-delegates" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-documents-definetypes.html — Defining QML types
- https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html#property-attributes — Property attributes for components
-->
