---
title: "Typography"
description: "Choosing and applying fonts, sizes, and text styles in your shell"
---

# Typography

<ChapterMeta title="Typography" icon="font" />

## Problem

Text appears everywhere in a shell — clock, workspace labels, app names, notification bodies, launcher search. Without a typography system, font sizes become inconsistent: one label is 13px, another is 14px, headings vary arbitrarily.

## Naive Approach

Set `font.pixelSize` on every `Text` element individually. Change the font family in one place, forget to update the others.

## MentalModel

<MentalModel title="Type Scale">

A type scale is a set of predefined font sizes with semantic names. `h1` (large heading), `body` (normal text), `caption` (small labels). Each size is derived from a base value multiplied by a ratio (typically 1.25). This is the same approach used by Material Design and Tailwind.

</MentalModel>

## Idea

Create a `Typography.qml` singleton with `readonly property` groups for font families and sizes. Also export helper functions for `Text` component configuration.

## Build It

```qml
// Typography.qml
pragma Singleton
import Quickshell

QtObject {
  readonly property string fontFamily: "Inter, sans-serif"
  readonly property string monoFamily: "JetBrains Mono, monospace"

  readonly property real baseSize: 14

  // Type scale (1.25 ratio)
  readonly property real h1: Math.round(baseSize * 1.953)
  readonly property real h2: Math.round(baseSize * 1.563)
  readonly property real h3: Math.round(baseSize * 1.25)
  readonly property real body: baseSize
  readonly property real small: Math.round(baseSize * 0.8)
  readonly property real caption: Math.round(baseSize * 0.64)

  readonly property real weightNormal: 400
  readonly property real weightMedium: 500
  readonly property real weightBold: 700
}
```

```qml
// Usage
import QtQuick
import "Typography.qml" as T

Column {
  spacing: 4

  Text {
    text: "Section Title"
    font.pixelSize: T.Typography.h3
    font.family: T.Typography.fontFamily
    font.weight: T.Typography.weightBold
  }

  Text {
    text: "This is body text at the base size."
    font.pixelSize: T.Typography.body
    font.family: T.Typography.fontFamily
  }

  Text {
    text: "Small caption text"
    font.pixelSize: T.Typography.caption
    color: "#888888"
  }
}
```

## BuildIt Breakdown

The type scale uses a 1.25 ratio (major third) — the same as Material Design. `Math.round` ensures integer pixel sizes for crisp rendering. `font.family` supports fallback with `"sans-serif"` after the named font. Additional properties like `letterSpacing` and `lineHeight` can be added per size.

## Improve It

Add `TextStyle` QML components that pre-configure a `Text` with typography tokens. Add `letterSpacing` variants for display text. Support variable font weight axes. Add a `mono` helper for code snippets.

## CommonMistake

<CommonMistake>

Setting `font.pixelSize` with a non-integer value. Sub-pixel font sizes cause anti-aliasing artifacts and inconsistent rendering across monitors. Always round to an integer.

</CommonMistake>

## Under the Hood

<UnderTheHood>

QML's `Text` element uses Qt's text rendering engine. `font.family` accepts comma-separated fallbacks. The font is resolved at render time using platform fontconfig. `font.weight` maps to OpenType weight values (100-900). `pixelSize` is absolute; use `font.pointSize` for DPI-aware sizing if your shell needs to scale across displays.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Create a `Typography.qml` with body and caption sizes, then use them in a clock widget.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Build a `Label` component that accepts a `variant` property (h1, h2, body, caption) and applies typography tokens automatically.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Implement DPI-aware font scaling that adjusts the base size based on `Screen.devicePixelRatio`.

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/spacing-and-icons">

Typography gives text structure. Next: **spacing and icons** — consistent whitespace and iconography for your shell.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
