---
title: "Shadows, Blur, Rounded Corners"
description: "Visual effects — shadows, backdrop blur, and rounded corners in QML"
---

# Shadows, Blur, Rounded Corners

<ChapterMeta title="Shadows, Blur, Rounded Corners" icon="eye" />

## Problem

Modern shells use depth: shadows separate popups from backgrounds, blur creates frosted-glass effects, rounded corners soften edges. QML provides these effects, but applying them without performance impact requires care.

## Naive Approach

Wrap everything in `DropShadow`, `GaussianBlur`, and set `radius` everywhere. Your shell drops to 15 FPS because every pixel is being blurred in software.

## MentalModel

<MentalModel title="Layered Compositing">

Every visual effect adds a render pass. Qt's scene graph draws items from back to front. Shadows and blur require off-screen rendering, reading pixels back, and re-compositing. The cost is proportional to the pixel area covered. Small, sparse effects are cheap; full-screen blur is expensive.

</MentalModel>

## Idea

Use Qt's `DropShadow` for shadows, `GaussianBlur` (from `Qt5Compat.GraphicalEffects` or Quickshell's built-in) for blur, and `radius` on `Rectangle` for corners. Limit blur to small areas like popup backgrounds. Use `ShaderEffect` for efficient blur if Quickshell provides it.

## Build It

```qml
import QtQuick
import Qt5Compat.GraphicalEffects

PopupWindow {
  width: 300
  height: 400

  Rectangle {
    anchors.fill: parent
    radius: 12
    color: "#ee1e1e2e"

    layer.enabled: true
    layer.effect: GaussianBlur {
      radius: 8
      samples: 16
    }
  }

  Text {
    text: "Frosted content"
    anchors.centerIn: parent
    color: "#ffffff"
  }

  layer.enabled: true
  layer.effect: DropShadow {
    transparentBorder: true
    radius: 16
    samples: 24
    color: "#80000000"
    horizontalOffset: 0
    verticalOffset: 4
  }
}
```

## BuildIt Breakdown

The outer `layer.effect` applies a `DropShadow` to the entire popup. The inner `Rectangle` uses `layer.enabled: true` with a `GaussianBlur` effect for the frosted-glass background. `samples` controls quality — higher values look smoother but are slower. The background color includes alpha (`#ee...`) so the blur shows through.

## Improve It

Cache blurred layers by rendering once and reusing. Use Quickshell's `BlurBehind` property on windows when available (Wayland compositor-side blur). Reduce blur radius on low-end GPUs. Add a `shadowSpread` property to control shadow softness.

## CommonMistake

<CommonMistake>

Applying blur to the root item of every window. Full-window blur forces a full-screen render-to-texture pass on every frame. Keep blur confined to small overlay panels.

</CommonMistake>

## Under the Hood

<UnderTheHood>

Qt's `DropShadow` and `GaussianBlur` use GLSL shaders via the Qt Quick scene graph. `layer.enabled: true` redirects the item subtree to an off-screen `FBO` (framebuffer object). The effect shader samples this FBO as a texture. On Wayland, Quickshell's `PanelWindow` can request `kde-blur` or `background-blur` protocols — these are compositor-side effects that bypass Qt's rendering pipeline entirely and are essentially free.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Add a drop shadow to a panel window.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Create a popup menu with frosted-glass background using `GaussianBlur` on only the background rectangle.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Build a `GlassPanel` component that combines blur, shadow, and a subtle border glow with configurable tint and opacity.

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/motion">

Visual effects add polish. Now let's make them **move** — motion design for your shell.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
