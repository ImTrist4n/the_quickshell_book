---
title: "Properties"
description: "Working with properties in QML — int, string, color, and custom properties"
---

<ChapterMeta reading-time="6 min" :difficulty="1" :prerequisites="['Objects']" you-will-build="A colored box whose appearance you control through property changes" />

## The Problem

Every visual aspect of a QML object — its size, color, position, text, opacity — is controlled by properties. You've already used properties like `width`, `color`, and `text`. But properties in QML are more powerful than simple assignments: they can hold expressions that update automatically, they can be animated, and you can define your own.

## The Naive Approach

In most programming languages, you set an object's attributes once and they stay fixed:

```javascript
rect.width = 200
rect.color = "blue"
```

If something changes that should affect those values, you write code to update them. For a desktop shell with constantly changing data (clock, battery, workspace), this means endless manual updates.

<MentalModel>

Properties in QML are not static assignments — they're like spreadsheet cells. If cell A1 contains `=B1 + C1`, changing B1 automatically recalculates A1. QML properties work the same way: you can bind one property to an expression involving other properties, and the runtime keeps the result current.

</MentalModel>

## The Idea

A QML property has a name, a type, and a value. Types include basic ones like `int`, `real`, `string`, `color`, `bool`, and `url`, as well as complex types like `font` and `rect`. Properties can be:

- **Set to a constant value:** `width: 200`
- **Bound to an expression:** `width: parent.width * 0.5`
- **Animated:** via `Behavior` or `Animation` types
- **Custom:** declared on your own objects with `property type name`

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 300
  visible: true
  title: "Properties"

  property string greeting: "Hello!"
  property int count: 0

  Rectangle {
    id: box
    x: 50; y: 50
    width: 300
    height: 100
    color: count % 2 === 0 ? "#4ecdc4" : "#ff6b6b"
    radius: 8

    Text {
      text: parent.parent.greeting + " Count: " + parent.parent.count
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 18
    }
  }

  Text {
    text: "Click the window to increment"
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: 20
    color: "#888"
    font.pixelSize: 12
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      count = count + 1
    }
  }
}
```

Click the window. Each click increments `count`. The rectangle's `color` expression re-evaluates, flipping between teal and red. The `Text` inside the box re-reads `greeting` and `count` and displays the updated string.

<BuildIt>

Key property types shown here:

- **`color`** — accepts named colors (`"white"`, `"red"`), hex codes (`"#4ecdc4"`), and `Qt.rgba()`.
- **Expression bindings** — `color: count % 2 === 0 ? "#4ecdc4" : "#ff6b6b"` is not evaluated once. It re-evaluates every time `count` changes.
- **Custom properties** — `property string greeting: "Hello!"` and `property int count: 0` are custom properties on the `Window`. They're accessible from any child via `parent.parent.propertyName`.

</BuildIt>

## Let's Improve It

Custom properties can also be read-only:

```qml
property int count: 0
readonly property string label: "Clicks: " + count
```

Now `label` updates automatically when `count` changes, but you can't assign to `label` directly — it's computed from `count` by the binding. Use `readonly` for properties derived from other state.

Common built-in property types:

```qml
Rectangle {
  // Basic types
  property int integerValue: 42
  property real realValue: 3.14
  property string textValue: "hello"
  property bool booleanValue: true
  property color colorValue: "#ff0000"
  property url urlValue: "https://example.com"

  // Complex types
  property variant genericValue: [1, 2, 3]
  property font fontValue: Qt.font({ pixelSize: 14, bold: true })
  property rect rectValue: Qt.rect(0, 0, 100, 100)
  property point pointValue: Qt.point(50, 50)
  property size sizeValue: Qt.size(100, 100)
}
```

## Under the Hood

Each property in QML is backed by a C++ `Q_PROPERTY` in the underlying Qt type. When you write `color: "#ff6b6b"`, the QML engine calls `QObject::setProperty("color", QColor("#ff6b6b"))`. For expression bindings, the engine creates a hidden `QQmlBinding` object that monitors all dependencies — when a dependency's `NOTIFY` signal fires, the binding re-evaluates and calls the appropriate setter.

Custom properties declared with `property` in QML create a new `Q_PROPERTY` on the fly, complete with a `NOTIFY` signal that other bindings can depend on.

<CommonMistake>

**Using `=` instead of `:`.** In QML, property assignment uses the colon syntax (`property: value`), not equals. Using `=` is a syntax error.

**Treating properties as strings when they have specific types.** `color: "red"` works because `color` accepts a string and converts it. But `font.pixelSize: "16"` will fail — `pixelSize` expects an `int`. Use unquoted numbers for numeric properties.

</CommonMistake>

## Exercises

<ExerciseBlock :difficulty="1">
Add a custom `color` property to the `Window` named `boxColor`. Set it to `"#45b7d1"`. Use it as the `Rectangle`'s default color instead of the ternary expression.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a `readonly property string statusMessage` that combines `greeting` and `count` into a sentence like "Hello! You've clicked 5 times." Display it in a second `Text` element.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a `property variant colors: ["#ff6b6b", "#4ecdc4", "#ffe66d", "#45b7d1"]` and make clicking cycle through the array instead of flipping between two colors.
</ExerciseBlock>

<Recap :points="['Properties are named, typed attributes that control object appearance and behavior', 'Expression bindings re-evaluate automatically when dependencies change', 'Custom properties use the property type name syntax', 'readonly properties are computed from bindings and cannot be assigned directly']" next-chapter="/part-1-qml/ids" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html — QML property attributes
- https://doc.qt.io/qt-6/qtqml-cppintegration-data.html — QML value types
- https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html — Property bindings
-->
