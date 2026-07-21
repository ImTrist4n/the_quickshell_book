---
title: "Keys & Focus"
description: "Keyboard input handling and focus management in QML"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['Signals']" you-will-build="A keyboard-navigable launcher bar" />

## The Problem

A desktop shell lives and dies by keyboard shortcuts. Super+Space opens the launcher. Super+1–9 switches workspaces. Escape closes a popup. Tab moves focus between controls. Unlike a web app where the browser manages focus automatically, a QML desktop shell must explicitly handle keyboard input and focus.

## The Naive Approach

You could add a `MouseArea` to everything and bind keyboard actions to specific objects:

```qml
Item {
  focus: true
  Keys.onPressed: (event) => {
    if (event.key === Qt.Key_Escape) close()
    if (event.key === Qt.Key_Space && event.modifiers & Qt.MetaModifier) openLauncher()
  }
}
```

But when multiple objects compete for keyboard input, who gets the key press? The answer depends on **focus**.

<MentalModel>

Focus is like a spotlight. Only the object in the spotlight receives keyboard events. You can move the spotlight with Tab, click, or programmatically. The `Keys` attached property lets an object declare what it does when it's in the spotlight.

</MentalModel>

## The Idea

In QML, focus flows through the object tree:

- **`focus: true`** — an item requests focus. Only one item per window can have focus at a time.
- **`Keys.onPressed`** — attached property that handles key events when the item has focus.
- **`KeyNavigation`** — automatic focus movement with Tab/arrow keys.
- **`Shortcut`** — global keyboard shortcuts that work regardless of focus.

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 300
  visible: true
  title: "Keys & Focus"

  // Root item with keyboard handling
  Item {
    anchors.fill: parent
    focus: true

    Keys.onPressed: (event) => {
      if (event.key === Qt.Key_Escape) {
        statusText = "Escape pressed — root handler"
        event.accepted = true
      }
      if (event.key === Qt.Key_F1) {
        statusText = "F1 — show help"
        event.accepted = true
      }
    }
  }

  // Search bar
  Rectangle {
    id: searchBar
    x: 20; y: 20
    width: 460; height: 44
    radius: 8
    color: searchInput.focus ? "white" : "#f5f5f5"
    border.color: searchInput.focus ? "#1a56db" : "#ddd"
    border.width: 2

    Behavior on border.color {
      ColorAnimation { duration: 100 }
    }

    TextInput {
      id: searchInput
      anchors {
        left: parent.left; right: parent.right
        verticalCenter: parent.verticalCenter
        leftMargin: 12; rightMargin: 12
      }

      font.pixelSize: 16
      color: "#333"
      placeholderText: "Search apps..."
      placeholderTextColor: "#aaa"

      // Own keyboard handler
      Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          statusText = "Searching: " + text
          event.accepted = true
        }
        if (event.key === Qt.Key_Escape) {
          focus = false  // Release focus to parent
          event.accepted = true
        }
      }
    }

    // Click to focus
    MouseArea {
      anchors.fill: parent
      onClicked: searchInput.forceActiveFocus()
    }
  }

  // Focusable items
  Row {
    x: 20; y: 90
    spacing: 8

    Repeater {
      model: ["App 1", "App 2", "App 3", "App 4", "App 5"]

      delegate: Rectangle {
        required property string modelData
        required property int index

        width: 80; height: 60; radius: 8
        color: itemFocus.containsFocus ? "#1a56db" :
               itemMouse.containsMouse ? "#4ecdc4" : "#e0e0e8"
        focus: index === 0  // First item starts focused

        Text {
          text: modelData
          anchors.centerIn: parent
          color: itemFocus.containsFocus ? "white" : "#333"
          font.pixelSize: 13
          font.bold: itemFocus.containsFocus
        }

        // Focus handling
        Keys.onPressed: (event) => {
          if (event.key === Qt.Key_Return || event.key === Qt.Key_Space) {
            statusText = "Activated: " + modelData
            event.accepted = true
          }
        }

        // Tab navigation between items
        KeyNavigation.right: index < 4 ? itemAt(index + 1) : null
        KeyNavigation.left: index > 0 ? itemAt(index - 1) : null

        MouseArea {
          id: itemMouse
          anchors.fill: parent
          hoverEnabled: true
          onClicked: parent.focus = true
        }

        // Visual focus indicator
        Rectangle {
          id: itemFocus
          anchors.fill: parent
          color: "transparent"
          border.color: "#1a56db"
          border.width: 2
          radius: 8
          visible: parent.focus
        }
      }
    }
  }

  // Function to get item by index
  function itemAt(index) {
    return appRow.children[index]
  }

  property Item appRow: appRow

  Row {
    id: appRow
    x: 20; y: 90
    spacing: 8
  }

  // Status
  Text {
    id: statusText
    anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
      bottomMargin: 12
      leftMargin: 20
    }
    text: "Tab between items, Enter to select, Esc to clear"
    color: "#888"
    font.pixelSize: 12
  }
}
```

<BuildIt>

Focus patterns:

- **`TextInput`** — automatically requests focus on click. `forceActiveFocus()` programmatically gives it focus.
- **`Keys.onPressed`** — attached to any Item. Receives key events when that item has focus.
- **`KeyNavigation.right` / `.left`** — declare which item gets focus when Tab or arrows are pressed.
- **`parent.focus = true`** — clicking a `MouseArea` assigns focus to its parent.
- **`event.accepted = true`** — prevents the event from propagating to parent handlers.

</BuildIt>

## Global Shortcuts

For shell-wide keyboard shortcuts (regardless of focus), use `Shortcut`:

```qml
Shortcut {
  sequence: "Ctrl+Q"
  onActivated: Qt.quit()
}

Shortcut {
  sequences: ["Meta+Space", "Alt+Space"]
  onActivated: launcher.toggle()
}
```

`Shortcut` from `QtQuick.Controls` works regardless of which item has focus.

<CommonMistake>

**Multiple items with `focus: true`.** Only one item per window can have focus. Setting `focus: true` on two items results in the last one winning. Use `forceActiveFocus()` to explicitly set focus at runtime.

**Not accepting keyboard events.** If you handle a key press but don't set `event.accepted = true`, the event propagates to parent items and may trigger unintended handlers.

**Forgetting `KeyNavigation` for list navigation.** Without `KeyNavigation`, Tab cycles through all focusable items in declaration order, which may not match your visual layout. Use `KeyNavigation` to create logical Tab/arrow flow.

</CommonMistake>

## Under the Hood

Focus is managed by `QQuickWindow`. When a key event arrives from the windowing system, Qt Quick delivers it to the item with `activeFocus`. If that item doesn't handle the event (or sets `event.accepted = false`), the event propagates up the parent chain.

`KeyNavigation` is implemented as a focus-forwarding mechanism: when a key matching a `KeyNavigation` direction is pressed, the source item surrenders focus to the target item.

## Exercises

<ExerciseBlock :difficulty="1">
Add three `TextInput` fields in a row. Use `KeyNavigation.tab` to make Tab cycle through them in order. Add a visual indicator (border color change) for the focused field.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a shortcut using `Shortcut` (from `QtQuick.Controls`) that toggles a dark mode property on the window. The shortcut should work regardless of focus.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a minimal launcher bar: a `TextInput` that, when you type and press Enter, adds the text to a `ListView` below. Arrow keys should navigate the list. Escape clears the input.
</ExerciseBlock>

<Recap :points="['Only the focused item receives keyboard events via Keys.onPressed', 'KeyNavigation enables Tab/arrow-based focus movement', 'Shortcut creates global keyboard shortcuts independent of focus', 'Use event.accepted to prevent event propagation to parent handlers']" next-chapter="/part-1-qml/states" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-keys.html — Keys attached property
- https://doc.qt.io/qt-6/qml-qtquick-keynavigation.html — KeyNavigation type
- https://doc.qt.io/qt-6/qml-qtquick-controls2-shortcut.html — Shortcut type (QtQuick.Controls)
-->
