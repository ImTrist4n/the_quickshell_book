---
title: "MouseArea"
description: "Handling mouse clicks, hovers, and drags with MouseArea"
---

<ChapterMeta reading-time="6 min" :difficulty="2" :prerequisites="['Signals']" you-will-build="A draggable panel element with click and hover interactions" />

## The Problem

Your shell needs to respond to the mouse — clicking buttons, hovering over items to show tooltips, dragging the panel to reposition it, right-clicking for context menus. `MouseArea` is how you capture all of these interactions.

## The Naive Approach

Some UI frameworks handle mouse events at the element level — every element decides what to do with a click. This leads to conflicts: which element gets the click when they overlap? QML takes a different approach: mouse handling is explicit, delegated to dedicated `MouseArea` objects.

<MentalModel>

`MouseArea` is like a transparent sticker you place over a section of your UI. The sticker captures all mouse events in that rectangle and decides what to do with them. Without the sticker, mouse events pass through to whatever is underneath — the sticker isn't there.

</MentalModel>

## The Idea

`MouseArea` defines a rectangular region that intercepts mouse events. It's invisible (doesn't render anything) but can respond to:

- **`clicked`, `doubleClicked`, `pressAndHold`** — tap interactions
- **`pressed`, `released`** — press state tracking
- **`containsMouse`** — hover state (with `hoverEnabled: true`)
- **`drag`** — drag-and-drop behavior
- **`wheel`** — scroll events
- **`cursorShape`** — cursor changes

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 400
  visible: true
  title: "MouseArea"

  property string statusText: ""

  // A draggable card
  Rectangle {
    id: card
    x: 50; y: 50
    width: 200
    height: 120
    radius: 12
    color: mouseArea.containsMouse ? "#4ecdc4" : "#45b7d1"
    border.color: "#3aa8a0"
    border.width: pressed ? 2 : 0

    // Status text inside card
    Text {
      id: cardText
      text: "Drag me"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 16
      font.bold: true
    }

    // Main interaction area
    MouseArea {
      id: mouseArea
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor

      // Drag behavior
      drag.target: card
      drag.axis: Drag.XAndYAxis
      drag.minimumX: 0
      drag.maximumX: parent.width - card.width
      drag.minimumY: 0
      drag.maximumY: parent.height - card.height

      // Click
      onClicked: {
        statusText = "Clicked at (" + mouse.x + ", " + mouse.y + ")"
        cardText.text = "Clicked!"
      }

      onDoubleClicked: {
        statusText = "Double-clicked!"
        cardText.text = "⚡ Double!"
      }

      onPressAndHold: {
        statusText = "Held for " + mouseArea.pressAndHoldInterval + "ms"
        cardText.text = "🔒 Held"
      }

      // Track press for border
      onPressedChanged: {
        card.pressed = pressed
        if (!pressed) cardText.text = "Drag me"
      }
    }
  }

  // Right-click area
  Rectangle {
    x: 300; y: 50
    width: 150; height: 120
    radius: 12
    color: "#f0f0f8"

    Text {
      text: "Right-click me"
      anchors.centerIn: parent
      color: "#666"
      font.pixelSize: 14
    }

    MouseArea {
      anchors.fill: parent
      acceptedButtons: Qt.RightButton

      onClicked: {
        statusText = "Right-clicked at (" + mouse.x + ", " + mouse.y + ")"
      }
    }
  }

  // Hover to reveal area
  Rectangle {
    x: 50; y: 220
    width: 400; height: 80
    radius: 8
    color: hoverArea.containsMouse ? "#a29bfe" : "#dfe6e9"

    Behavior on color {
      ColorAnimation { duration: 200 }
    }

    Text {
      text: hoverArea.containsMouse ? "👋 Hovering!" : "Hover over me"
      anchors.centerIn: parent
      color: hoverArea.containsMouse ? "white" : "#888"
      font.pixelSize: 16
    }

    MouseArea {
      id: hoverArea
      anchors.fill: parent
      hoverEnabled: true

      onEntered: {
        statusText = "Mouse entered"
      }
      onExited: {
        statusText = "Mouse exited"
      }
    }
  }

  // Status bar
  Rectangle {
    anchors {
      left: parent.left; right: parent.right
      bottom: parent.bottom
    }
    height: 30
    color: "#333"

    Text {
      text: statusText
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 12
      }
      color: "#eee"
      font.pixelSize: 12
    }
  }
}
```

<BuildIt>

Important `MouseArea` features:

- **`hoverEnabled: true`** — enables `containsMouse`, `entered`, `exited`. Without it, `MouseArea` only responds when a button is pressed.
- **`cursorShape`** — changes the mouse cursor. `Qt.PointingHandCursor` for clickable areas, `Qt.ArrowCursor` for default.
- **`drag`** — enables click-and-drag. `drag.target` specifies which item moves. `drag.axis` restricts to X, Y, or both. Min/max values constrain the drag area.
- **`acceptedButtons`** — which mouse buttons to respond to. Default is `Qt.LeftButton`. Use `Qt.RightButton` or `Qt.MiddleButton` for other buttons.
- **`mouse.x` / `mouse.y`** — coordinates of the event relative to the `MouseArea`.

</BuildIt>

## Let's Improve It

`MouseArea` supports event propagation control:

```qml
MouseArea {
  anchors.fill: parent
  propagateComposedEvents: true  // Let events pass through to items below

  onClicked: (mouse) => {
    // Handle locally, then let it propagate
    mouse.accepted = false  // Don't consume the event
  }
}
```

This is useful for overlapping clickable areas — like a close button on a notification that's inside a clickable notification card.

<CommonMistake>

**Nested `MouseArea` conflicts.** If a child and parent both have `MouseArea`, the child's area gets the event first. If the child handles it and calls `mouse.accepted = true`, the parent won't see it. For overlapping independent click zones, manage `acceptedButtons` and `propagateComposedEvents` carefully.

**Forgetting `hoverEnabled`.** By default, `MouseArea` only activates on button press. If your hover-dependent UI isn't working (e.g., `containsMouse` is always false), check that `hoverEnabled: true` is set.

**Dragging without constraints.** An unconstrained drag can move the target off-screen. Always set `drag.minimumX/Y` and `drag.maximumX/Y` if the drag container has bounds.

</CommonMistake>

## Under the Hood

`MouseArea` is a `QQuickMouseArea` that registers itself with the Qt Quick event delivery system. When the scene graph processes an input event, it walks the visual tree from top to bottom (reverse z-order), asking each `MouseArea` if it wants the event. The first `MouseArea` to accept it (by not calling `mouse.accepted = false`) claims the event.

The `drag` property creates an internal state machine that tracks press position, delta, and constraints. On each mouse move during a drag, it updates the target's `x` and `y` by the delta, clamped to the min/max bounds.

## Exercises

<ExerciseBlock :difficulty="1">
Create a resizable rectangle. Use a small `MouseArea` at the bottom-right corner (`width/height: 10`) that, when dragged, changes the rectangle's `width` and `height`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a color picker: a 200×200 rectangle with a `MouseArea` that reads `mouse.x` and `mouse.y` and uses them to compute an HSL color. Display the color in a preview swatch and show the hex value.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a simple button with `pressAndHold` that fires a custom signal after holding for 1 second. Show a progress ring (using `Canvas` or a `Rectangle` width animation) that fills up during the hold.
</ExerciseBlock>

<Recap :points="['MouseArea is an invisible region that captures mouse events', 'Enable hoverEnabled for hover tracking; cursorShape for cursor changes', 'drag provides built-in drag-and-drop with constraints', 'acceptedButtons controls which mouse buttons are handled', 'Nested MouseAreas need careful accept/propagate management']" next-chapter="/part-1-qml/keys-and-focus" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-mousearea.html — MouseArea type
-->
