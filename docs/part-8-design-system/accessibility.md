---
title: "Accessibility"
description: "Making your Quickshell shell accessible — contrast, focus, screen readers"
---

# Accessibility

<ChapterMeta title="Accessibility" icon="accessible" />

## Problem

Desktop shells must be usable by everyone, including people with visual impairments, motor disabilities, or color blindness. Poor contrast, tiny targets, and keyboard-only navigation gaps exclude users.

## Naive Approach

Design only for the ideal user. Small gray text on a dark background. Buttons that require pixel-perfect mouse clicks. No keyboard navigation. Your shell is beautiful but unusable for many.

## MentalModel

<MentalModel title="Universal Design Ladder">

Accessibility is a ladder. Bottom rung: basic contrast and font sizes. Middle rung: keyboard navigation and focus indicators. Top rung: screen reader support and reduced motion preferences. Each rung adds users without removing value for existing ones.

</MentalModel>

## Idea

Implement the basics: WCAG AA contrast ratio (4.5:1 for text), minimum touch target 44x44px, visible focus rings, keyboard navigation with Tab and arrow keys, support for `prefers-reduced-motion`.

## Build It

```qml
import QtQuick
import QtQuick.Controls
import "Colors.qml" as C
import "Spacing.qml" as S

FocusScope {
  property bool reducedMotion: false

  Item {
    focus: true
    Keys.onLeftPressed: previousItem.forceActiveFocus()
    Keys.onRightPressed: nextItem.forceActiveFocus()
  }

  Rectangle {
    id: myButton
    width: 120
    height: 44
    radius: 8
    color: activeFocus ? C.Colors.accent : C.Colors.surface
    border.color: activeFocus ? C.Colors.accent : "transparent"
    border.width: activeFocus ? 2 : 0

    Text {
      text: "Click Me"
      anchors.centerIn: parent
      color: C.Colors.text
      font.pixelSize: 14
    }

    MouseArea {
      anchors.fill: parent
      onClicked: console.log("clicked")
    }

    Behavior on color {
      enabled: !reducedMotion
      ColorAnimation { duration: 150 }
    }
  }
}
```

## BuildIt Breakdown

`FocusScope` manages keyboard focus. `Keys.onLeftPressed` / `onRightPressed` enables arrow-key navigation. The button has a minimum 44px height (touch target). `activeFocus` changes the button color — this is the focus indicator. The `Behavior` is conditionally disabled when `reducedMotion` is true, checked against the user's `prefers-reduced-motion` system setting.

## Improve It

Check `Qt.application.layoutDirection` for RTL support. Use `Accessible` properties on all interactive elements. Add `screenReaderName` and `screenReaderRole`. Test with a screen reader (Orca on Linux). Provide a high-contrast theme variant.

## CommonMistake

<CommonMistake>

Relying solely on color to convey state (e.g., red = error, green = success). Color-blind users (8% of men) cannot distinguish these. Always add icons, text labels, or patterns alongside color.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Qt Quick supports `Accessible` via the `QAccessible` interface, bridging to AT-SPI on Linux. When you set `Accessible.role` and `Accessible.name`, Qt emits the correct accessibility events. Focus navigation is handled by Qt's `FocusScope` engine — items with `activeFocus` receive key events. `prefers-reduced-motion` is read from the compositor via the `fractional-scale-v1` or `wp-alpha-compositor` protocols if supported.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Add visible focus indicators to all interactive elements in a panel.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Implement keyboard navigation through a workspace switcher using arrow keys.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Wire up `Accessible` properties for all widgets and test with a screen reader.

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/project-premium-panel">

Accessibility ensures no one is left behind. Now let's apply everything — **design a premium panel** project.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
