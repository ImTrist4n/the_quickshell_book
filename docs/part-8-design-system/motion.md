---
title: "Motion"
description: "Intentional motion design for your shell — when to animate and when to stay still"
---

# Motion

<ChapterMeta title="Motion" icon="animation" />

## Problem

Animation makes a shell feel alive, but too much motion feels chaotic. Haphazard animations (some elements slide, others fade, durations vary) break the user's mental model. Motion needs a system.

## Naive Approach

Every developer picks their own animation duration and easing. One popup uses 200ms, another uses 500ms. Some use `Ease.InOutQuad`, others use `Ease.OutBounce`. The result is a jarring, inconsistent experience.

## MentalModel

<MentalModel title="Motion Language">

A motion language defines standard curves, durations, and types for specific interactions. Material Design's motion system is a good reference: elements enter with `easeOutCubic` (fast start, slow end), exit with `easeInCubic` (slow start, fast end), and move with `easeInOut`. Distinguish between choreographic motion (guiding the eye) and expressive motion (delight).

</MentalModel>

## Idea

Create a `Motion.qml` singleton with named easings and durations. `enter` (150ms), `exit` (100ms), `move` (200ms), `expand` (250ms). Define `Easing` objects for each use case.

## Build It

```qml
// Motion.qml
pragma Singleton
import QtQuick

QtObject {
  // Durations
  readonly property int durationInstant: 50
  readonly property int durationFast: 100
  readonly property int durationNormal: 200
  readonly property int durationSlow: 350
  readonly property int durationExpand: 250

  // Easings
  readonly property Easing easingEnter: Easing.OutCubic
  readonly property Easing easingExit: Easing.InCubic
  readonly property Easing easingMove: Easing.InOutCubic
  readonly property Easing easingExpand: Easing.OutBack
  readonly property Easing easingSoft: Easing.OutSine
}
```

```qml
// Usage
import QtQuick
import "Motion.qml" as M

Rectangle {
  width: 100
  height: 100
  color: "#5294e2"
  radius: 8

  NumberAnimation on x {
    to: 200
    duration: M.Motion.durationNormal
    easing.type: M.Motion.easingMove
  }

  Behavior on opacity {
    NumberAnimation {
      duration: M.Motion.durationFast
      easing.type: M.Motion.easingEnter
    }
  }
}
```

## BuildIt Breakdown

The motion tokens separate what you animate from how you animate. `Behavior on opacity` with a `NumberAnimation` makes every opacity change smooth without manual animation blocks. `easing.type` uses Qt's built-in easing curves. The `.qml` singleton gives you autocomplete and type checking.

## Improve It

Add spring physics using `SpringAnimation` for bouncy effects. Create a `Transition` component that groups enter/exit animations for popups. Add `OpacityMask` for wipe transitions. Use `ParallelAnimation` for choreographed multi-property motion.

## CommonMistake

<CommonMistake>

Animating `layout` or `anchor` changes — these already trigger expensive re-layouts. Animating them on every frame compounds the cost. Animate `opacity`, `scale`, `x`, `y`, and `color` instead.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Qt Quick animations run on the scene graph's animation driver, which syncs to the display's refresh rate. `Behavior` animations are syntactic sugar for `onPropertyChanged` + `NumberAnimation`. `SpringAnimation` uses a damped harmonic oscillator simulation — it does not use predefined easing curves. QML evaluates animation frames as part of the render loop, not on a timer, eliminating jank from timer drift.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Add a `Behavior on opacity` to a button so it fades in and out.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Create a slide-in panel using `NumberAnimation` on `x` with `easingEnter` for show and `easingExit` for hide.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Build a `MotionController` component that orchestrates sequenced animations (enter elements one by one with stagger delays).

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/material-you-gruvbox-catppuccin">

Motion brings your shell to life. Next: implementing **Material You, Gruvbox, and Catppuccin** color schemes.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
