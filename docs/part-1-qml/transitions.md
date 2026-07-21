---
title: "Transitions"
description: "Smooth state changes with QML Transitions"
---

<ChapterMeta reading-time="6 min" :difficulty="2" :prerequisites="['States']" you-will-build="A panel with animated transitions between states" />

## The Problem

In the previous chapter, the panel jumps between states — collapsed, normal, expanded. The height snaps, the opacity blinks on and off, the icon rotates instantly. For a production shell, these transitions should be smooth: the panel should slide open, content should fade in, icons should rotate gracefully.

## The Naive Approach

You could use `Behavior` on every property:

```qml
Rectangle {
  Behavior on height { NumberAnimation { duration: 300 } }
  Behavior on opacity { NumberAnimation { duration: 200 } }
}
```

This works, but `Behavior` applies the same animation to *every* property change, not just state changes. And you can't have different animations for entering vs. leaving a state.

<MentalModel>

If states are photographs of your UI, transitions are the movie that plays between photographs. They control *how* the UI moves from one state to the next — which properties animate, for how long, and with what easing.

</MentalModel>

## The Idea

**Transitions** are animations that play automatically when the state changes. Each transition can specify:

- **`from`** — the source state (or `*` for any)
- **`to`** — the target state (or `*` for any)
- **`PropertyAnimation`** children — which properties to animate and how

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 450
  visible: true
  title: "Transitions"

  Rectangle {
    anchors.centerIn: parent
    width: 320
    height: 380
    radius: 12
    color: "#f0f0f8"

    Rectangle {
      id: panel
      anchors.centerIn: parent
      width: 280
      height: 48
      radius: 8
      color: "#1a1a2e"
      clip: true
      state: "collapsed"

      states: [
        State {
          name: "collapsed"
          PropertyChanges { target: panel; height: 48 }
          PropertyChanges { target: contentArea; opacity: 0 }
          PropertyChanges { target: expandIcon; rotation: 0 }
          PropertyChanges { target: headerText; text: "Click to expand" }
        },
        State {
          name: "expanded"
          PropertyChanges { target: panel; height: 320 }
          PropertyChanges { target: contentArea; opacity: 1 }
          PropertyChanges { target: expandIcon; rotation: 180 }
          PropertyChanges { target: headerText; text: "System Info" }
        }
      ]

      // Transitions animate between states
      transitions: [
        Transition {
          from: "collapsed"
          to: "expanded"
          reversible: true  // Same animation in reverse

          ParallelAnimation {
            NumberAnimation {
              target: panel
              property: "height"
              duration: 300
              easing.type: Easing.InOutQuad
            }
            NumberAnimation {
              target: contentArea
              property: "opacity"
              duration: 400
              easing.type: Easing.InQuad
            }
            NumberAnimation {
              target: expandIcon
              property: "rotation"
              duration: 300
              easing.type: Easing.OutBounce
            }
          }
        },
        Transition {
          from: "expanded"
          to: "collapsed"

          // Sequential: first close content, then collapse panel
          SequentialAnimation {
            NumberAnimation {
              target: contentArea
              property: "opacity"
              duration: 150
              easing.type: Easing.InQuad
            }
            NumberAnimation {
              target: panel
              property: "height"
              duration: 250
              easing.type: Easing.InQuad
            }
            NumberAnimation {
              target: expandIcon
              property: "rotation"
              duration: 200
            }
          }
        }
      ]

      // Header
      Rectangle {
        id: header
        width: parent.width; height: 48; color: "transparent"

        Text {
          id: headerText
          anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 16 }
          color: "white"; font.pixelSize: 14; font.bold: true
        }

        Text {
          id: expandIcon
          anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 16 }
          text: "▼"; color: "white"; font.pixelSize: 12
        }

        MouseArea {
          anchors.fill: parent
          onClicked: panel.state = panel.state === "collapsed" ? "expanded" : "collapsed"
        }
      }

      // Content
      Item {
        id: contentArea
        anchors { top: header.bottom; left: parent.left; right: parent.right; bottom: parent.bottom; margins: 16 }
        opacity: 0

        Column {
          spacing: 8; width: parent.width
          Repeater {
            model: ["CPU: 23%", "RAM: 4.2 GB", "Disk: 45%", "Temp: 52°C"]
            delegate: Rectangle {
              required property string modelData
              width: parent.width; height: 32; radius: 4; color: "#2a2a3e"
              Text { text: modelData; anchors.verticalCenter: parent.verticalCenter; leftMargin: 10; color: "#ccc"; font.pixelSize: 13 }
            }
          }
        }
      }
    }
  }
}
```

<BuildIt>

Key transition features:

- **`reversible: true`** — the same animation plays forward for collapse→expand and backwards for expand→collapse. Removes the need for a separate reverse transition.
- **`ParallelAnimation`** — all property animations run simultaneously. The panel expands while content fades in while the icon rotates.
- **`SequentialAnimation`** — animations run one after another. Useful for "fade out, then collapse" patterns.
- **`easing.type`** — controls the acceleration curve. `Easing.OutBounce` gives a playful bounce at the end. `Easing.InOutQuad` starts and ends slow.

</BuildIt>

## Let's Improve It

Combine `from: "*"` and `to: "*"` for a catch-all transition:

```qml
transitions: [
  Transition {
    from: "*"; to: "*"
    NumberAnimation { properties: "height,opacity"; duration: 250 }
  }
]
```

This animates `height` and `opacity` for any state change. Use this as a base transition and add specific transitions for more control.

<CommonMistake>

**Forgetting that `PropertyChanges` in states override animations.** If a `PropertyChanges` sets `opacity: 1` and you have an animation on opacity, the animation interpolates between the old value and 1. The animation doesn't run if the current value already equals the target value.

**Animating properties that don't interpolate.** `color` needs `ColorAnimation`, not `NumberAnimation`. `rotation` needs `NumberAnimation` (it's a number). Strings can't be animated.

</CommonMistake>

## Exercises

<ExerciseBlock :difficulty="1">Add a third state "minimal" (height 32, no text) with transitions from each existing state.</ExerciseBlock>
<ExerciseBlock :difficulty="2">Replace `ParallelAnimation` with `SequentialAnimation` in the collapse transition to fade content out before shrinking the panel.</ExerciseBlock>
<ExerciseBlock :difficulty="3">Use `PauseAnimation` in a sequence to create a delayed reveal effect where content appears 200ms after the panel finishes expanding.</ExerciseBlock>

<Recap :points="['Transitions animate property changes between states', 'Use reversible: true for bidirectional animations with one definition', 'ParallelAnimation runs animations simultaneously; SequentialAnimation runs them in order', 'Easing types control acceleration curves for natural motion']" next-chapter="/part-1-qml/animations" />
