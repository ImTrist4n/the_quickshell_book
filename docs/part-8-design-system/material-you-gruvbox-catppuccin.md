---
title: "Material You, Gruvbox, Catppuccin"
description: "Implementing popular color schemes — Material You, Gruvbox, and Catppuccin"
---

# Material You, Gruvbox, Catppuccin

<ChapterMeta title="Material You, Gruvbox, Catppuccin" icon="swatch" />

## Problem

Users want their favorite color scheme. Manually maintaining a version of your shell for Material You, Gruvbox, Catppuccin (Mocha, Latte), and others means duplicating every `.qml` file per scheme.

## Naive Approach

Copy your entire shell into `shell-materiayou/`, `shell-gruvbox/`, `shell-catppuccin/`. Each copy diverges over time. Maintenance nightmare.

## MentalModel

<MentalModel title="Theme Swap via Token Replacement">

A design token system maps semantic roles to values. Swapping themes means swapping the token values — not the UI code. Your `Colors.qml` becomes a palette that changes at startup (or runtime) based on user preference. The UI layer never knows which scheme is active.

</MentalModel>

## Idea

Create one `Colors.qml` per scheme: `ColorsMaterialYou.qml`, `ColorsGruvbox.qml`, `ColorsCatppuccin.qml`. Use a `ThemeManager` singleton that imports the correct one based on a config file or environment variable.

## Build It

```qml
// ColorsCatppuccinMocha.qml
pragma Singleton
import Quickshell

QtObject {
  readonly property color background: "#1e1e2e"
  readonly property color surface: "#313244"
  readonly property color text: "#cdd6f4"
  readonly property color textMuted: "#6c7086"
  readonly property color accent: "#89b4fa"
  readonly property color border: "#45475a"
  readonly property color error: "#f38ba8"
  readonly property color success: "#a6e3a1"
}
```

```qml
// ThemeManager.qml
import QtQuick
import QtQuick.Controls
import "."

QtObject {
  property string currentTheme: "catppuccin-mocha"

  readonly property QtObject colors: {
    if (currentTheme === "catppuccin-mocha") return CatppuccinMocha
    if (currentTheme === "catppuccin-latte") return CatppuccinLatte
    if (currentTheme === "gruvbox-dark") return GruvboxDark
    if (currentTheme === "material-you") return MaterialYou
    return CatppuccinMocha
  }
}
```

```qml
// Usage — bind to ThemeManager.colors
import QtQuick
import "."

Rectangle {
  color: ThemeManager.colors.surface
  Text {
    text: "Themed text"
    color: ThemeManager.colors.text
  }
}
```

## BuildIt Breakdown

Each scheme file is a `pragma Singleton` with identical property names but different values. `ThemeManager` uses JavaScript object lookup (`{ ... }`) as a reactive switch — when `currentTheme` changes, the `colors` binding re-evaluates and all bound UIs update automatically. No import paths change; every file binds to `ThemeManager.colors.*`.

## Improve It

Read `currentTheme` from a JSON config file using `FileReader`. Add a theme preview panel. Support hybrid schemes (Catppuccin surfaces with Gruvbox accent). Generate schemes from a wallpaper color extractor (like Material You's monet engine).

## CommonMistake

<CommonMistake>

Using dynamic `import` to switch theme files. Dynamic imports in QML are asynchronous and break property bindings. The `ThemeManager` approach with a JS switch is synchronous and fully reactive.

</CommonMistake>

## Under the Hood

<UnderTheHood>

QML singletons with identical property names share the same C++ meta-object structure. When `ThemeManager.colors` re-evaluates, QML's binding engine invalidates all dependent bindings in a single pass. No memory is leaked because all singleton references are compile-time resolved. The JS `{ }` object is not a QML binding — it is a getter function that re-runs when `currentTheme` changes.

</UnderTheHood>

## Exercises

<ExerciseBlock level="beginner">

Add a Catppuccin Latte (light) variant to your existing dark theme.

</ExerciseBlock>

<ExerciseBlock level="intermediate">

Build a theme switcher UI with radio buttons that changes `currentTheme` at runtime.

</ExerciseBlock>

<ExerciseBlock level="advanced">

Implement a color extraction algorithm that generates a theme from a user-provided wallpaper image.

</ExerciseBlock>

## Recap

<Recap to="/part-8-design-system/accessibility">

Color schemes make your shell personal. Next: **accessibility** — ensuring everyone can use your shell.

</Recap>

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-positioning-anchors.html — anchor layout
- https://doc.qt.io/qt-6/qtquick-demos.html — Qt Quick styling concepts
-->
