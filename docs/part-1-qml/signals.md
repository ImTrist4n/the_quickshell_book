---
title: "Signals"
description: "Event communication in QML through signals and signal handlers"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['JavaScript in QML']" you-will-build="A custom component that emits signals when clicked" />

## The Problem

You've used `onClicked` on `MouseArea` — that's a signal handler. But signals in QML go far beyond mouse clicks. Any object can emit signals when *anything* happens: data arrives, state changes, a timer fires. Signals are the primary way objects communicate in a QML application.

## The Naive Approach

Without signals, you'd poll objects for changes or couple them directly:

```qml
// Tight coupling: one object reaches into another
Timer {
  interval: 100
  running: true
  repeat: true
  onTriggered: {
    if (sensor.temperature !== lastTemp) {
      display.temperature = sensor.temperature
      lastTemp = sensor.temperature
    }
  }
}
```

This is wasteful (polling), fragile (depends on `sensor` and `display` IDs), and doesn't scale.

<MentalModel>

Signals are like a PA system. The announcer (the signal emitter) doesn't need to know who's listening. Anyone interested tunes in and responds. New listeners can join without the announcer changing anything. This decoupling is what makes signals powerful.

</MentalModel>

## The Idea

A **signal** is an event that an object emits. Other objects can connect to it with handlers. QML provides two syntaxes:

1. **`on<SignalName>`** — inline handler for signals on a specific object:
   ```qml
   Button {
     onClicked: console.log("clicked")
   }
   ```

2. **`connect()`** — programmatic connection from anywhere:
   ```qml
   someObject.signalName.connect(handlerFunction)
   ```

## Let's Build It

First, create a custom component with its own signals:

```qml
// ClickBox.qml
import QtQuick

Rectangle {
  id: root

  // Custom signals
  signal clicked(int x, int y)
  signal doubleClicked()
  signal hoveredChanged(bool hovering)

  property string label: "Box"
  property color defaultColor: "#4ecdc4"
  property color hoverColor: "#45b7d1"

  width: 150
  height: 100
  radius: 8
  color: mouseArea.containsMouse ? hoverColor : defaultColor

  Text {
    text: root.label
    anchors.centerIn: parent
    color: "white"
    font.pixelSize: 16
    font.bold: true
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true

    onClicked: (mouse) => {
      root.clicked(mouse.x, mouse.y)
    }

    onDoubleClicked: {
      root.doubleClicked()
    }

    onContainsMouseChanged: {
      root.hoveredChanged(containsMouse)
    }
  }
}
```

Now use it in a main file:

```qml
// main.qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 300
  visible: true
  title: "Signals"

  property int clickCount: 0

  Row {
    anchors.centerIn: parent
    spacing: 20

    ClickBox {
      id: box1
      label: "Box 1"

      // Inline signal handlers
      onClicked: (x, y) => {
        clickCount++
        status.text = "Box 1 clicked at (" + x + ", " + y + ")"
      }
      onDoubleClicked: {
        status.text = "Box 1 double-clicked!"
      }
    }

    ClickBox {
      id: box2
      label: "Box 2"
      defaultColor: "#ff6b6b"
      hoverColor: "#e05555"

      onClicked: {
        clickCount++
        status.text = "Box 2 clicked"
      }
      onHoveredChanged: (hovering) => {
        if (hovering) status.text = "Hovering over Box 2"
      }
    }
  }

  // Status label
  Text {
    id: status
    anchors {
      bottom: parent.bottom
      horizontalCenter: parent.horizontalCenter
      bottomMargin: 20
    }
    text: "Click a box"
    color: "#888"
    font.pixelSize: 14
  }

  // Counter connected via the signal approach
  Text {
    anchors {
      top: parent.top
      right: parent.right
      topMargin: 10
      rightMargin: 10
    }
    text: "Clicks: " + clickCount
    color: "#333"
    font.pixelSize: 14
  }
}
```

<BuildIt>

Custom signals are declared with `signal`:

```qml
signal clicked(int x, int y)
signal doubleClicked()
signal hoveredChanged(bool hovering)
```

Each signal can carry typed parameters. The handler name follows the pattern `on<SignalName>` with the first letter capitalized:

```qml
onClicked: (x, y) => { ... }
onDoubleClicked: { ... }
onHoveredChanged: (hovering) => { ... }
```

Signal parameters become handler function parameters. You can name them anything, but the types must match the signal declaration.

</BuildIt>

## Connecting from JavaScript

For dynamic connections, use the `connect()` method:

```qml
// Connnect to a signal programmatically
Component.onCompleted: {
  box1.clicked.connect(function(x, y) {
    console.log("Dynamic handler: clicked at", x, y)
  })
}
```

To disconnect:

```qml
var handler = function(x, y) { console.log(x, y) }
box1.clicked.connect(handler)
// Later:
box1.clicked.disconnect(handler)
```

## Let's Improve It

Signals can also carry *any* type using `var`:

```qml
signal dataReceived(var payload)

// Emit with any JavaScript value:
dataReceived({ temperature: 22, humidity: 60 })

// Handle it:
onDataReceived: (payload) => {
  tempDisplay.text = payload.temperature
  humDisplay.text = payload.humidity
}
```

<CommonMistake>

**Signal name clashes.** QML types come with built-in signals (`clicked`, `pressed`, `released` on `MouseArea`, etc.). If you declare a custom signal with the same name as a built-in one, you shadow the built-in. Check the type's documentation before naming custom signals.

**Forgetting to emit signals.** A signal declaration doesn't fire automatically — you must call `signalName()` somewhere. If a handler never fires, check that the signal is being emitted.

**Case sensitivity.** Signal names are case-sensitive. `signal DataReady()` creates a handler `onDataReady`, not `OnDataready`.

</CommonMistake>

## Under the Hood

Signals in QML are backed by Qt's meta-object system (`QMetaObject`). When you declare `signal clicked(int x, int y)`, Qt generates:

- A `clicked(int, int)` method that you call to emit the signal
- A `clicked` signal in the meta-object system
- Automatic generation of `onClicked` handler property

The `connect()` method wires the signal to any compatible callable (a JavaScript function, another QML signal, or a C++ slot). The meta-object system handles type checking and conversion.

## Exercises

<ExerciseBlock :difficulty="1">
Add a `signal rightClicked(string label)` to `ClickBox` that fires on right-click. Handle it in the main file to show a context menu message.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a `TemperatureSensor` component (non-visual `Item`) with a `signal temperatureChanged(real celsius)`. Use a `Timer` to emit it every second with a random temperature. Connect it to a visual `Text` display.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a mediator object — an `Item` with a signal that multiple other objects connect to. When the signal fires, three different UI elements should update. This demonstrates loosely coupled communication.
</ExerciseBlock>

<Recap :points="['Signals are events that objects emit; handlers respond to them', 'Custom signals are declared with the signal keyword, optionally with typed parameters', 'Inline handlers use on<SignalName> syntax; dynamic connections use connect()', 'Emit a signal by calling it like a function: mySignal(args)']" next-chapter="/part-1-qml/components" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-syntax-signals.html — Signal documentation
- https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html#signal-attributes — Signal attributes
-->
