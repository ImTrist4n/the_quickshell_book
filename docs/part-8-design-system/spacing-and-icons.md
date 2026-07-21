---
title: "Spacing & Icons"
description: "Consistent spacing scales and icon systems for your shell"
---

# Spacing & Icons

<ChapterMeta title="Spacing & Icons" icon="grid" />

## Problem

Inconsistent spacing makes a shell look unprofessional — 8px here, 10px there, 12px somewhere else. Icons have mismatched sizes and styles. A design system needs standardized spacing units and a consistent icon approach.

## Naive Approach

Hardcode `spacing: 5`, `padding: 12`, `iconSize: 16` wherever needed. Changing the spacing scale means editing every file. Icons from different sources look disconnected.

## MentalModel

<MentalModel title="4px Grid">

All spacing values are multiples of a base unit (typically 4px or 8px). Margins, paddings, gaps, and icon sizes all derive from this base. This creates visual rhythm — elements align to an invisible grid. Material Design uses an 8dp grid; you can use 4px for finer control in shell UIs.

</MentalModel>

## Idea

Create a `Spacing.qml` singleton with named spacing tokens: `xs` (4), `sm` (8), `md` (12), `lg` (16), `xl` (24), `xxl` (32). For icons, choose one icon library (Phosphor, Material Icons, Font Awesome) and create an `Icon` component.

## Build It

```qml
// Spacing.qml
pragma Singleton
import Quickshell

QtObject {
  readonly property int base: 4

  readonly property int xs: base
  readonly property int sm: base * 2
  readonly property int md: base * 3
  readonly property int lg: base * 4
  readonly property int xl: base * 6
  readonly property int xxl: base * 8

  // Icon sizes
  readonly property int iconSm: base * 4
  readonly property int iconMd: base * 5
  readonly property int iconLg: base * 8
  readonly property int iconXl: base * 12

  // Padding
  readonly property int panelPadding: sm
  readonly property int sectionPadding: md
  readonly property int cardPadding: lg
}
```

```qml
// Icon.qml
import QtQuick

Item {
  property string icon: ""
  property color iconColor: "#ffffff"
  property int iconSize: 16

  width: iconSize
  height: iconSize

  Text {
    anchors.centerIn: parent
    text: parent.icon
    font.family: "Material Design Icons"
    font.pixelSize: parent.iconSize
    color: parent.iconColor
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
  }
}
```

```qml
// Usage
import QtQuick
import "Spacing.qml" as S
import "Icon.qml" as I

Row {
  spacing: S.Spacing.sm
  padding: S.Spacing.panelPadding

  I.Icon { icon: "\uF013"; iconSize: S.Spacing.iconMd }
  Text { text: "Settings"; font.pixelSize: 14 }
}
```

## BuildIt Breakdown

The 4px base unit generates all spacing values as multiples. This ensures visual rhythm — any element placed next to another will align to the same grid. The `Icon` component wraps a `Text` element using an icon font. This is the simplest approach; an alternative is using SVG icons via `AnimatedImage` or `Image`.

## Improve It

Use SVG icons instead of icon fonts for sharper rendering at all scales. Add an `icon` property that takes a string name and maps to a file path. Support icon rotation and animation. Add a `Spacer` component that creates flexible space using `Item` with `Layout.fillWidth`.

## CommonMistake

<CommonMistake>

Stacking multiple spacing approaches — using both `spacing` on a `Row` and `Layout.preferredWidth` with margins. Pick one convention (spacing properties) and use it consistently.

</CommonMistake>

## Under the Hood

<UnderTheHood>

The 4px grid works because most screens have integer pixel ratios at standard DPIs. Fractional spacing values can trigger sub-pixel rendering and anti-aliasing artifacts. Icon fonts are scaled by `font.pixelSize` — ensure the font file is loaded via `FontLoader` or included in the system. For SVG icons, Qt's `Image` element renders them natively using QPainter.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Build a menu using spacing tokens instead of hardcoded values.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Create an `Icon` component that supports both icon fonts and SVG files.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Build a `Stack` component that lays out children on a 4px grid with configurable columns.

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/shadows-blur-rounded-corners">

Spacing and icons create structure and clarity. Next: **shadows, blur, and rounded corners** — making your shell feel polished.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
