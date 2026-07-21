---
title: "Configuration"
description: "Designing a user-friendly configuration system for your shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['Singleton pattern', 'Folder structure']" you-will-learn="How to design a configuration system that users can customize" />

## The Problem

Every user wants a slightly different shell. Some want a dark theme, others light. Some want the clock on the left, others on the right. Hardcoding these choices makes your shell inflexible. A good configuration system lets users customize without editing your QML source.

## The Naive Approach

Hardcode all values:

```qml
Rectangle {
  color: "#1e1e2e"  // Catppuccin Mocha base
  height: 36
}
```

When a user wants a different color or height, they must edit your file directly. Any mistake breaks the shell, and their changes are lost on update.

<MentalModel>

Think of configuration as a control panel for your shell. The user adjusts knobs (color, height, position) and the shell responds. Your job is to expose the right knobs — not every internal variable, but the ones that meaningfully change the experience — and provide sensible defaults for everything else.

</MentalModel>

## The Idea

Create a `config.qml` singleton that holds all user-configurable values. Components read from this singleton rather than using hardcoded values. Users override specific properties in their own `config.qml` without touching your component code.

## Let's Build It

```qml
// config.qml — Singleton configuration
pragma Singleton
import Quickshell

QtObject {
  readonly property string theme: "catppuccin-mocha"

  // Panel
  readonly property int panelHeight: 36
  readonly property int panelFontSize: 13
  readonly property string panelPosition: "top" // "top" or "bottom"

  // Colors
  readonly property color bgColor: "#1e1e2e"
  readonly property color fgColor: "#cdd6f4"
  readonly property color accentColor: "#89b4fa"
  readonly property color errorColor: "#f38ba8"
  readonly property color warningColor: "#fab387"

  // Widgets
  readonly property bool showCpu: true
  readonly property bool showRam: true
  readonly property bool showNetwork: true
  readonly property bool showBattery: true
  readonly property bool showClock: true
  readonly property bool showMpris: true

  // Clock format — using Qt.formatDateTime syntax
  readonly property string clockFormat: "hh:mm AP"
  readonly property string dateFormat: "ddd MMM d"

  // Popup behavior
  readonly property int popupAnimationMs: 150
  readonly property bool dismissOnClickOutside: true
}
```

Register the singleton in your `shell.qml`:

```qml
// shell.qml
import Quickshell
import "config.qml" as Config

ShellRoot {
  Variants {
    model: Quickshell.screens
    PanelWindow {
      required property var modelData
      screen: modelData
      height: Config.panelHeight

      Rectangle {
        anchors.fill: parent
        color: Config.bgColor

        Text {
          text: "Hello"
          color: Config.fgColor
          font.pixelSize: Config.panelFontSize
        }
      }
    }
  }
}
```

<BuildIt>

The `config.qml` singleton separates policy from mechanism. Components know *how* to render; the config knows *what* values to use. Users can create their own `config.qml` that imports and overrides specific properties.

</BuildIt>

## Let's Improve It

Support configuration profiles — different themes that swap entire color sets:

```qml
// config.qml
readonly property string theme: loadThemeSetting()

function loadThemeSetting() {
  // Read from a JSON config file
  var file = Qt.open("~/.config/quickshell/settings.json", "r")
  if (file.valid) {
    var data = JSON.parse(file.readAll())
    return data.theme || "catppuccin"
  }
  return "catppuccin"
}

readonly property var themes: ({
  "catppuccin": {
    bg: "#1e1e2e", fg: "#cdd6f4", accent: "#89b4fa",
    error: "#f38ba8", warning: "#fab387"
  },
  "dracula": {
    bg: "#282a36", fg: "#f8f8f2", accent: "#bd93f9",
    error: "#ff5555", warning: "#ffb86c"
  },
  "nord": {
    bg: "#2e3440", fg: "#d8dee9", accent: "#88c0d0",
    error: "#bf616a", warning: "#d08770"
  }
})

readonly property var currentTheme: themes[theme] || themes["catppuccin"]
readonly property color bgColor: currentTheme.bg
readonly property color fgColor: currentTheme.fg
readonly property color accentColor: currentTheme.accent
```

<CommonMistake>

**Exposing everything as config.** Every config property is a promise of stability — changing it later breaks users. Only expose values that users genuinely want to change (colors, sizes, positions). Internal constants (timeout durations, animation curves) should stay in the component.

**Not providing defaults.** A config system must work without any user configuration. Every property should have a reasonable default. Users opt in to overriding.

**Mixing config with state.** Configuration is static (user sets it once). State is dynamic (changes during the session). Don't put `batteryPercent` or `cpuUsage` in `config.qml`. Use services for that.

</CommonMistake>

## Under the Hood

Configuration in QML works through the singleton pattern. The singleton is evaluated once at startup and its properties are read-only to prevent accidental mutation during the session. For live config reloading, you can connect a file watcher that re-evaluates the config when the file changes, then emit a signal that components respond to.

## Exercises

<ExerciseBlock :difficulty="1">
Create a `settings.json` file in `~/.config/quickshell/`. Write a `loadConfig()` function in `config.qml` that reads it and overrides default values. Handle the case where the file doesn't exist.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a live config watcher. Use `Qt.process(["inotifywait", ...])` or a `Timer` that checks file modification time every 5 seconds. When the config changes, emit a `configChanged()` signal that components can connect to for hot-reloading.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a GUI settings panel (as a `PopupWindow`) that lets users change theme, panel height, and widget visibility. Save changes to `settings.json`. The panel should preview changes before applying them.
</ExerciseBlock>

<Recap :points="['Use a config.qml singleton to separate policy from mechanism', 'Every config property needs a sensible default', 'Only expose values users genuinely want to customize', 'Keep configuration static — use services for dynamic state']" next-chapter="/part-10-architecture/state-management" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Singleton — Singleton type
- https://quickshell.org/docs/guide/qml-language — QML Language Reference
- https://doc.qt.io/qt-6/qml-qtqml-qtobject.html — QtObject QML Type
-->
