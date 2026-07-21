---
title: "Project: Design a Premium Panel"
description: "Build a visually polished, premium desktop panel with design system techniques"
---

# Project: Design a Premium Panel

<ChapterMeta title="Project: Design a Premium Panel" icon="project" />

## Problem

Build a top panel that looks premium — not just functional. It must include a clock, workspace indicators, system tray, and a launcher button. It must use the design system: color tokens, typography, spacing, shadows, rounded corners, and motion. It must feel cohesive and polished.

## Naive Approach

A flat, featureless bar with hardcoded colors, no padding, and jarring transitions. Functional but ugly.

## MentalModel

<MentalModel title="Panel as a Design Showcase">

A premium panel is not just a collection of widgets. It is a demonstration of design system principles: consistent spacing, deliberate color usage, smooth motion, and attention to micro-interactions. Every element on the panel should look like it belongs to the same family.

</MentalModel>

## Idea

Build `PremiumPanel.qml` as a `PanelWindow` that imports all design tokens. Use a frosted-glass background. Apply motion tokens to hover effects. Use `ThemeManager` so the panel respects the user's color scheme.

## Build It

```qml
import QtQuick
import Qt5Compat.GraphicalEffects
import "."

PanelWindow {
  id: panel
  width: Screen.width
  height: 44
  anchors.top: true
  anchors.left: true
  anchors.right: true
  exclusiveZone: 44

  Rectangle {
    anchors.fill: parent
    color: ThemeManager.colors.background
    opacity: 0.95
    radius: 0
  }

  Row {
    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
    spacing: Spacing.sm
    padding: Spacing.panelPadding

    Rectangle {
      width: 32
      height: 32
      radius: 8
      color: ThemeManager.colors.accent

      Text {
        anchors.centerIn: parent
        text: "\u2630"
        color: "#ffffff"
        font.pixelSize: 18
      }

      MouseArea {
        anchors.fill: parent
        onClicked: launcherPopup.toggle()
      }

      Behavior on scale {
        enabled: !Motion.reducedMotion
        NumberAnimation { duration: Motion.durationFast; easing.type: Motion.easingEnter }
      }

      HoverHandler {
        onHoveredChanged: parent.scale = hovered ? 1.1 : 1.0
      }
    }

    WorkspaceSwitcher { height: panel.height }
  }

  Row {
    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
    spacing: Spacing.sm
    padding: Spacing.panelPadding

    Clock {}
    SystemTray {}
  }

  layer.enabled: true
  layer.effect: DropShadow {
    transparentBorder: true
    radius: 8
    samples: 12
    color: "#40000000"
    verticalOffset: 2
  }
}
```

## BuildIt Breakdown

The panel uses `ThemeManager.colors` for all colors, `Spacing` for layout gaps, `Motion` for hover animations, and a `DropShadow` layer for depth. The launcher button scales up on hover with a smooth animation. The frosted-glass effect comes from `opacity: 0.95` with the background color — a real blur would use `GaussianBlur` on a `layer` with a translucent background.

## Improve It

Add a real `GaussianBlur` background using Wayland's `kde-blur` protocol. Add a subtle gradient to the background. Implement a "vibrancy" effect with a `ShaderEffect`. Add an ambient pulse animation on the accent color. Support dynamic panel height with `exclusiveZone`.

## CommonMistake

<CommonMistake>

Forgetting `exclusiveZone` on the `PanelWindow`. Without it, maximized windows will cover your panel. Set `exclusiveZone` equal to the panel height so the compositor reserves space.

</CommonMistake>

## Under the Hood

<UnderTheHood>

`PanelWindow` is a Quickshell-specific type that uses the wlr-layer-shell protocol. It requests exclusive zone from the compositor, which tells other windows not to occlude the panel. The `anchors.top: true` pins it to the top edge. Without `anchors.top`, the window floats. On Wayland, the compositor handles the stacking — your panel always stays above normal windows.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Replace the hardcoded opacity with a `ThemeManager` token for panel opacity.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Add a hover-peek effect — the panel hides with `opacity: 0` and appears on mouse hover near the top edge.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Implement a live blur background using `GaussianBlur` on the panel's `layer` with a translucent `Rectangle` underneath.

</ExerciseBlock>

## Recap

<Recap to="/part-9-applications/app-launcher">

Part 8 complete. Your design system produces beautiful, consistent UIs. Next: **Part IX — Building Applications**, starting with an **app launcher**.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
