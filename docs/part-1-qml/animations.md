---
title: "Animations"
description: "Animating properties with NumberAnimation, OpacityAnimator, SequentialAnimation, and more"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['Transitions']" you-will-build="An animated loading indicator and pulsing notification dot" />

## The Problem

Transitions handle state changes, but not all animations are state-driven. A loading spinner spins continuously. A notification dot pulses when a new alert arrives. A volume bar animates smoothly when you change the level. These are **standalone animations** — they run on their own schedule, not in response to state changes.

## The Naive Approach

You could use a `Timer` to manually update property values:

```qml
Timer {
  interval: 16; repeat: true
  onTriggered: {
    spinner.rotation = (spinner.rotation + 6) % 360
  }
}
```

This works but reinvents the wheel. You're writing animation logic that QML's animation framework already provides — with better performance and less code.

<MentalModel>

Standalone animations are like ceiling fans: they run continuously at a set speed, independent of anything else. State-driven animations (transitions) are like automatic doors: they only move when triggered by a state change.

</MentalModel>

## The Idea

QML provides animation types that control property values over time:

- **`NumberAnimation`** — animates numeric properties
- **`ColorAnimation`** — animates color properties
- **`OpacityAnimator`** — specialized opacity animation (runs on the rendering thread)
- **`RotationAnimator`** — specialized rotation animation (runs on the rendering thread)
- **`SequentialAnimation`** — runs child animations one after another
- **`ParallelAnimation`** — runs child animations simultaneously
- **`PropertyAnimation`** — base type for any property animation

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 400
  visible: true
  title: "Animations"

  Row {
    anchors.centerIn: parent
    spacing: 40

    // 1. Spinning loader
    Rectangle {
      id: spinner
      width: 60; height: 60; radius: 30
      color: "transparent"
      border.color: "#4ecdc4"; border.width: 4

      Rectangle {
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        width: 6; height: 16; radius: 3
        color: "#4ecdc4"
      }

      // Continuous rotation
      NumberAnimation on rotation {
        from: 0; to: 360
        duration: 1000
        loops: Animation.Infinite
      }
    }

    // 2. Pulsing dot
    Rectangle {
      id: dot
      width: 40; height: 40; radius: 20
      color: "#ff6b6b"

      Rectangle {
        anchors.fill: parent; radius: parent.radius
        color: "#ff6b6b"; opacity: 0.3

        NumberAnimation on scale {
          from: 0.8; to: 1.8
          duration: 800
          loops: Animation.Infinite
          easing.type: Easing.InOutQuad
        }
        NumberAnimation on opacity {
          from: 0.5; to: 0
          duration: 800
          loops: Animation.Infinite
          easing.type: Easing.InOutQuad
        }
      }
    }

    // 3. Bouncing ball
    Column {
      spacing: 6
      Text { text: "Bounce"; color: "#888"; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter }

      Rectangle {
        id: ball
        width: 40; height: 40; radius: 20
        color: "#ffe66d"
        y: 0

        SequentialAnimation on y {
          loops: Animation.Infinite

          NumberAnimation {
            to: 80
            duration: 400
            easing.type: Easing.OutQuad
          }
          NumberAnimation {
            to: 0
            duration: 400
            easing.type: Easing.InQuad
          }
          PauseAnimation { duration: 200 }
        }
      }
    }
  }

  // 4. Color-cycling bar
  Rectangle {
    anchors { bottom: parent.bottom; left: parent.left; right: parent.right; bottomMargin: 20; margins: 20 }
    height: 8
    radius: 4

    ColorAnimation on color {
      from: "#ff6b6b"
      to: "#4ecdc4"
      duration: 2000
      loops: Animation.Infinite
    }
  }

  // 5. Property animation via Behavior
  Rectangle {
    id: animatedBox
    x: 20; y: 20
    width: 100; height: 60; radius: 8
    color: "#45b7d1"

    Behavior on x {
      NumberAnimation { duration: 300; easing.type: Easing.OutBounce }
    }
    Behavior on y {
      NumberAnimation { duration: 300; easing.type: Easing.OutBounce }
    }

    Text { text: "Click"; anchors.centerIn: parent; color: "white"; font.bold: true }

    MouseArea {
      anchors.fill: parent
      onClicked: {
        animatedBox.x = Math.random() * (parent.width - 100)
        animatedBox.y = Math.random() * (parent.height - 80)
      }
    }
  }
}
```

<BuildIt>

Animation patterns:

- **`NumberAnimation on rotation { loops: Animation.Infinite }`** — infinite looping animation. `from` and `to` define the range.
- **`SequentialAnimation`** — runs child animations in order. Here, bouncing down with `OutQuad` easing, then up with `InQuad` easing, then pause.
- **`Behavior on x { NumberAnimation { ... } }`** — whenever `x` changes, animate to the new value. The animation plays for *any* change, not just state changes.
- **`ColorAnimation`** — cycles the bar's color between red and teal continuously.

</BuildIt>

## Easing Curves

The easing type dramatically changes how an animation feels:

| Easing | Feel |
|---|---|
| `Linear` | Mechanical, constant speed |
| `InQuad` / `OutQuad` | Gentle acceleration/deceleration |
| `InOutQuad` | Smooth start and end (most natural) |
| `OutBounce` | Bounces at the end (playful) |
| `OutElastic` | Overshoots and snaps back |
| `InBack` | Pulls back before moving forward |

## Common Mistake

**Animating on the UI thread causing jank.** `OpacityAnimator` and `RotationAnimator` run on the scene graph's render thread, not the UI thread. Use them for performance-critical animations. `NumberAnimation` runs on the UI thread and can jank if the UI thread is busy.

**Forgetting `alwaysRunToEnd`.** If you stop an animation (by setting `running: false`), it jumps to the final value immediately. Set `alwaysRunToEnd: true` on the animation to let it finish gracefully.

## Exercises

<ExerciseBlock :difficulty="1">Create a pulsing heart shape (using unicode ❤️) that scales from 1.0 to 1.3 and back every 500ms using SequentialAnimation.</ExerciseBlock>
<ExerciseBlock :difficulty="2">Build a progress bar that fills from 0% to 100% over 3 seconds when a button is clicked. Use NumberAnimation on the fill rectangle's width.</ExerciseBlock>
<ExerciseBlock :difficulty="3">Create a particle effect using a Repeater of 20 small rectangles, each with its own SequentialAnimation, spawning at staggered intervals using PauseAnimation.</ExerciseBlock>

<Recap :points="['Standalone animations run continuously or on-demand via NumberAnimation, ColorAnimation, etc.', 'Use SequentialAnimation and ParallelAnimation to compose complex animations', 'Behavior animates property changes wherever they originate', 'Animator types (OpacityAnimator, RotationAnimator) run on the render thread for better performance']" next-chapter="/part-1-qml/timers" />
