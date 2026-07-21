---
title: "States"
description: "Managing UI states in QML — when, how, and why to use them"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['Property Bindings']" you-will-build="A panel section that transitions between collapsed, normal, and expanded states" />

## The Problem

Your shell elements have distinct visual modes: a collapsed system tray vs. an expanded one, a notification center that's either open or closed, a workspace indicator that highlights the active workspace. Managing these modes with individual property bindings becomes messy when multiple properties change together.

## The Naive Approach

You toggle individual properties in JavaScript:

```qml
onClicked: {
  if (state === "expanded") {
    panel.width = 48
    panel.opacity = 0.5
    label.visible = false
    icon.rotation = 0
  } else {
    panel.width = 300
    panel.opacity = 1
    label.visible = true
    icon.rotation = 180
  }
}
```

The logic is scattered, you must remember to reset everything when toggling back, and adding a new property means editing every branch.

<MentalModel>

A state is like a snapshot of your UI. Name it "expanded," and entering that state applies all property changes in the snapshot. Leave the state, and properties revert to defaults — no manual cleanup.

</MentalModel>

## The Idea

QML **states** are named sets of property changes. Set `state: "expanded"` to apply them; switch to another state (or `""`) to revert. States are declared with `State` objects in a `states` array, each containing `PropertyChanges` targets.

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 450
  visible: true
  title: "States"

  Rectangle {
    anchors.centerIn: parent
    width: 320
    height: 380
    radius: 12
    color: "#f0f0f8"

    // Panel that has states
    Rectangle {
      id: panel
      anchors.centerIn: parent
      width: 280
      height: 48
      radius: 8
      color: "#1a1a2e"
      clip: true

      // The state property
      state: "collapsed"

      // State definitions
      states: [
        State {
          name: "collapsed"
          PropertyChanges { target: panel; height: 48 }
          PropertyChanges { target: contentArea; opacity: 0 }
          PropertyChanges { target: expandIcon; rotation: 0 }
          PropertyChanges { target: headerText; text: "Click to expand" }
        },
        State {
          name: "normal"
          PropertyChanges { target: panel; height: 200 }
          PropertyChanges { target: contentArea; opacity: 1 }
          PropertyChanges { target: expandIcon; rotation: 180 }
          PropertyChanges { target: headerText; text: "System Info" }
        },
        State {
          name: "expanded"
          PropertyChanges { target: panel; height: 320 }
          PropertyChanges { target: contentArea; opacity: 1 }
          PropertyChanges { target: expandIcon; rotation: 270 }
          PropertyChanges { target: headerText; text: "Detailed View" }
          PropertyChanges { target: detailArea; opacity: 1 }
        }
      ]

      // Header bar (always visible)
      Rectangle {
        id: header
        width: parent.width
        height: 48
        color: "transparent"

        Text {
          id: headerText
          anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: 16
          }
          color: "white"
          font.pixelSize: 14
          font.bold: true
        }

        Text {
          id: expandIcon
          anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: 16
          }
          text: "▼"
          color: "white"
          font.pixelSize: 12
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (panel.state === "collapsed") panel.state = "normal"
            else if (panel.state === "normal") panel.state = "expanded"
            else panel.state = "collapsed"
          }
        }
      }

      // Content area
      Item {
        id: contentArea
        anchors {
          top: header.bottom
          left: parent.left
          right: parent.right
          bottom: parent.bottom
          margins: 16
        }
        opacity: 0

        Column {
          spacing: 8
          width: parent.width

          Repeater {
            model: ["CPU: 23%", "RAM: 4.2/16 GB", "Disk: 45%", "Temp: 52°C"]

            delegate: Rectangle {
              required property string modelData
              width: parent.width; height: 32; radius: 4
              color: "#2a2a3e"
              Text {
                text: modelData
                anchors.verticalCenter: parent.verticalCenter
                leftMargin: 10
                color: "#ccc"
                font.pixelSize: 13
              }
            }
          }

          // Detail section (only in "expanded" state)
          Item {
            id: detailArea
            width: parent.width; height: 80
            opacity: 0

            Rectangle {
              width: parent.width; height: 60; radius: 4
              color: "#2a2a3e"
              anchors.top: parent.top

              Text {
                text: "Processes: 187\nUptime: 3h 42m\nLoad: 1.2"
                anchors.centerIn: parent
                color: "#888"
                font.pixelSize: 12
                lineHeight: 1.6
              }
            }
          }
        }
      }
    }
  }
}
```

<BuildIt>

- **`state: "collapsed"`** — initial state. `PropertyChanges` in the "collapsed" state set panel height to 48, content invisible.
- **Click cycles** through collapsed → normal → expanded → collapsed.
- Each `PropertyChanges` block lists only the properties that change in that state. Unlisted properties keep their default values or values from the previous state.
- The `detailArea` only appears at opacity 1 in the "expanded" state.

</BuildIt>

## Let's Improve It

States can also `extend` other states:

```qml
State {
  name: "expanded"
  extend: "normal"  // Inherits all changes from "normal"
  PropertyChanges { target: panel; height: 320 }
  PropertyChanges { target: detailArea; opacity: 1 }
}
```

This avoids repeating the shared "normal" property changes in "expanded".

You can also use `when` to activate states based on conditions:

```qml
states: [
  State {
    name: "highlighted"
    when: mouseArea.containsMouse
    PropertyChanges { target: card; color: "#4ecdc4"; scale: 1.05 }
  }
]
```

This state activates automatically when `containsMouse` is true, no imperative `state =` assignment needed.

<CommonMistake>

**Forgetting the `""` (default) state.** If you set `state: "normal"` and then set `state: ""`, all properties revert to their base values (the values declared in the QML object definition). Without a base state definition, undefined states may leave properties in unexpected configurations.

**Putting state-dependent bindings in `PropertyChanges` when they should be regular bindings.** If a property's value is always determined by state, use a binding: `color: state === "active" ? "blue" : "gray"`. Reserve `PropertyChanges` for properties that only change in certain states and revert to defaults otherwise.

**Overusing states.** For simple toggles (two-state), a single `property bool expanded` with bindings is cleaner than a state with two `PropertyChanges`. States shine with 3+ modes or many simultaneously changing properties.

</CommonMistake>

## Under the Hood

When the `state` property changes, the QML engine:

1. Saves the current state name
2. Evaluates the new state's `PropertyChanges` entries
3. Applies each change to the target objects
4. Emits `stateChanged` signal

When reverting to `""` (base state), the engine restores each property to the value it had before any state was applied — the value from the original QML declaration. This is tracked via internal "default" property values stored when the object is created.

## Exercises

<ExerciseBlock :difficulty="1">
Add a fourth state called "minimal" that shows only the header text "Minimal" with a panel height of 32.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Use `StateGroup` (from `QtQuick`) to manage states on a non-root item. Create a card that has "default", "hovered", and "pressed" states, activated by `when` conditions on `MouseArea` properties.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a multi-tab panel. Each tab click sets a state. Each state shows different content below the tab bar. Use at least 4 tabs with distinct content per tab.
</ExerciseBlock>

<Recap :points="['States are named sets of property changes applied when state is set', 'PropertyChanges specifies which properties change in each state', 'States can extend other states to inherit their changes', 'Use when for conditionally-activated states without imperative code']" next-chapter="/part-1-qml/transitions" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-states-and-transitions.html — States and transitions
- https://doc.qt.io/qt-6/qml-qtquick-state.html — State type
- https://doc.qt.io/qt-6/qml-qtquick-propertychanges.html — PropertyChanges type
-->
