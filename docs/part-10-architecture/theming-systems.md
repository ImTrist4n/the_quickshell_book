---
title: "Theming Systems"
description: "Building flexible, runtime-switchable theming for your shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['Configuration', 'Singletons']" you-will-learn="How to design a theming system that supports multiple color schemes" />

## The Problem

Your shell needs to look good in different lighting conditions and match different desktop aesthetics. Users want dark mode, light mode, and custom color schemes. Hardcoded colors mean every user forks your code to change the palette.

## The Naive Approach

Define colors in each component:

```qml
Rectangle { color: "#1e1e2e" }  // dark bg
Text { color: "#cdd6f4" }       // light fg
```

Changing the theme means finding and updating every hex value across every file. With 50+ components, this is impractical.

<MentalModel>

Think of theming like a coat of paint. The structure of your house (components) stays the same, but you can repaint the walls (theming) without rebuilding. A good theming system is a well-organized paint shelf — every color has a name and a swatch, and you can grab a different can to change the whole look.

</MentalModel>

## The Idea

Create a theme singleton that maps semantic color names to specific values. Components reference the semantic names (`bg`, `fg`, `accent`). The theme object resolves them to actual colors. Switching themes means swapping the theme object, not editing components.

## Let's Build It

```qml
// Theme.qml
pragma Singleton
import Quickshell

QtObject {
  readonly property string currentTheme: "mocha"

  // Semantic colors — components use these names
  readonly property color bg:        themed.bg
  readonly property color bgAlt:     themed.bgAlt
  readonly property color fg:        themed.fg
  readonly property color fgAlt:     themed.fgAlt
  readonly property color accent:    themed.accent
  readonly property color surface:   themed.surface
  readonly property color error:     themed.error
  readonly property color warning:   themed.warning
  readonly property color success:   themed.success

  // Theme definitions
  readonly property var themes: ({
    "mocha": {
      bg: "#1e1e2e", bgAlt: "#181825",
      fg: "#cdd6f4", fgAlt: "#a6adc8",
      accent: "#89b4fa", surface: "#313244",
      error: "#f38ba8", warning: "#fab387", success: "#a6e3a1"
    },
    "latte": {
      bg: "#eff1f5", bgAlt: "#e6e9ef",
      fg: "#4c4f69", fgAlt: "#5c5f77",
      accent: "#1e66f5", surface: "#ccd0da",
      error: "#d20f39", warning: "#fe640b", success: "#40a02b"
    },
    "dracula": {
      bg: "#282a36", bgAlt: "#21222c",
      fg: "#f8f8f2", fgAlt: "#bd93f9",
      accent: "#bd93f9", surface: "#44475a",
      error: "#ff5555", warning: "#ffb86c", success: "#50fa7b"
    }
  })

  readonly property var themed: themes[currentTheme] || themes["mocha"]
}
```

Components use semantic names:

```qml
import "Theme.qml" as Theme

Rectangle {
  color: Theme.bg
  Text {
    text: "Hello"
    color: Theme.fg
  }
  Rectangle {
    color: Theme.surface
    border.color: Theme.accent
  }
}
```

<BuildIt>

The theme system maps semantic names (`bg`, `fg`, `accent`) to actual hex values. Components only reference semantic names, never hex values directly. Adding a new theme means adding a new entry to the `themes` object.

</BuildIt>

## Let's Improve It

Add dark/light auto-detection based on the system preference:

```qml
readonly property string systemPreference: detectSystemTheme()

function detectSystemTheme() {
  try {
    var result = Qt.process(["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"])
    return result.stdout.includes("dark") ? "mocha" : "latte"
  } catch (e) {
    return "mocha"  // default fallback
  }
}

readonly property string currentTheme: config.themeOverride || systemPreference
```

Support per-component overrides for special cases:

```qml
// A special widget that needs different styling
Rectangle {
  color: Theme.bg
  Rectangle {
    color: Qt.lighter(Theme.surface, 1.2)  // 20% lighter variant
  }
}
```

<CommonMistake>

**Using color names, not semantic names.** `theme.red`, `theme.blue`, `theme.green` is useless when you switch from a dark theme that used "red" for errors to a light theme that uses "red" for accents. Use `theme.error`, `theme.bg`, `theme.accent` instead.

**Hardcoding theme overrides.** A component that does `color: Theme.bg || "#000000"` defeats the purpose of theming. If a theme doesn't define `bg`, fix the theme, not the component.

**Forgetting contrast.** A theme that looks good on your monitor may have poor contrast on another. Test themes at different brightness levels. `theme.fgAlt` should always be readable against `theme.bg`.

</CommonMistake>

## Under the Hood

The theme system is a singleton that holds a data dictionary. When the user changes themes, you update `currentTheme` and QML's reactive engine automatically re-evaluates all bindings that reference `Theme.fg`, `Theme.bg`, etc. Every component re-renders with the new colors — no manual refresh needed.

For advanced theming, you can extend this to include font families, spacing scales, border widths, and animation curves — anything that varies between visual styles.

## Exercises

<ExerciseBlock :difficulty="1">
Extend the theme singleton to include font family and font size. Create a "compact" theme with smaller fonts and tighter spacing, and a "comfortable" theme with larger fonts and more padding.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a theme preview popup. Show a grid of available themes with live previews. Clicking a theme applies it immediately (saved to config). Use a `PropertyAnimation` to smoothly transition colors.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a "dynamic" theme that extracts accent colors from the current wallpaper. Use a tool like `color-thief` or `ImageMagick` to analyze the wallpaper's dominant colors, then set `accent`, `surface`, and `bgAlt` to complementary values.
</ExerciseBlock>

<Recap :points="['Use semantic color names (bg, fg, accent) instead of literal hex values', 'The theme singleton holds all color definitions in one place', 'Auto-detect system dark/light preference for initial theme', 'QML bindings automatically re-render components on theme change']" next-chapter="/part-10-architecture/performance-basics" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Singleton — Singleton type
- https://doc.qt.io/qt-6/qtquick-visualconsole-visualperformance.html — Qt Quick performance
- https://quickshell.org/docs/guide/qml-language — QML Language
-->
