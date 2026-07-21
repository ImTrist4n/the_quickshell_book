---
title: "Color Systems"
description: "Building a cohesive color system for your desktop shell"
---

# Color Systems

<ChapterMeta title="Color Systems" icon="palette" />

## Problem

A desktop shell contains dozens of UI elements — panels, buttons, text, icons, backgrounds. Without a color system, each element picks its own colors, leading to visual chaos. Changing the theme becomes a hunt through every file.

## Naive Approach

Hardcode hex colors everywhere. `color: "#5294e2"` in one file, `color: "#4a90d9"` in another. Maintaining this is impossible.

## MentalModel

<MentalModel title="Design Tokens">

A color system maps semantic names to hex values. Instead of `"#5294e2"`, you write `colors.accent`. You define tokens once and reference them everywhere. This is the same pattern used by Material Design, Tailwind CSS, and design systems everywhere.

</MentalModel>

## Idea

Create a `Colors.qml` singleton that exports all colors as `readonly property color` values. Organize them by semantic role: `background`, `surface`, `text`, `accent`, `muted`, `border`, `error`. Import `Colors` wherever you need a color.

## Build It

```qml
// Colors.qml
pragma Singleton
import Quickshell

QtObject {
  readonly property color background: "#1e1e2e"
  readonly property color surface: "#2a2a3e"
  readonly property color surfaceAlt: "#333348"
  readonly property color text: "#cdd6f4"
  readonly property color textMuted: "#6c7086"
  readonly property color accent: "#89b4fa"
  readonly property color accentAlt: "#74c7ec"
  readonly property color border: "#45475a"
  readonly property color error: "#f38ba8"
  readonly property color success: "#a6e3a1"
  readonly property color warning: "#fab387"
}
```

```qml
// Usage in a module
import QtQuick
import "Colors.qml" as Theme

Rectangle {
  color: Theme.Colors.surface

  Text {
    text: "Hello Shell"
    color: Theme.Colors.text
  }

  Rectangle {
    width: 100
    height: 2
    color: Theme.Colors.accent
  }
}
```

## BuildIt Breakdown

The `pragma Singleton` directive makes `Colors` a global singleton accessible anywhere. `readonly property color` ensures tokens cannot be modified at runtime — this prevents accidental color overrides. The QML engine evaluates each property only once and caches it.

## Improve It

Add a `withAlpha(color, alpha)` function. Support dark and light variants by switching the file at build time. Group tokens into nested objects using `QtObject` children. Generate colors from a palette using HSL manipulation.

## CommonMistake

<CommonMistake>

Using `var` instead of `color` type for color properties. `var` bypasses type checking and may cause binding evaluation issues. Always declare `property color` for strict typing.

</CommonMistake>

## Under the Hood

<UnderTheHood>

QML `color` properties are stored as `QColor` internally. `readonly` creates a `QProperty` with no setter. The singleton pattern relies on `pragma Singleton` + a `qmldir` file — Quickshell does not require `qmldir` if the file is imported by path, but adding one improves performance by pre-compiling the singleton.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Create a `Colors.qml` with five tokens and use them in a panel.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Add a `darkMode` property that toggles between dark and light color sets.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Implement a color generator that derives all tokens from a single primary hue using HSL math in JavaScript.

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/typography">

A color system brings visual consistency. Next up: **typography** — choosing and applying type across your shell.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
