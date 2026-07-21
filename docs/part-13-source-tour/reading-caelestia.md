---
title: "Reading Caelestia"
description: "A guided tour through outfoxxed's Caelestia shell configuration"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['Qt Quick', 'QML basics']" you-will-learn="How Caelestia is structured and the design decisions behind it" />

## Overview

Caelestia is the flagship Quickshell configuration, built by outfoxxed (the creator of Quickshell). It's a fully-featured desktop shell with a bottom bar, notification center, application launcher, and extensive theming support.

## Architecture

```
caelestia/
  shell.qml          — Entry point
  config.json        — User-facing settings
  components/        — Reusable UI components
    bar/             — Bottom bar panels
    launcher/        — Application launcher
    notifications/   — Notification center
    music/           — MPRIS music controls
    osd/             — On-screen display
    quick-settings/  — Quick settings toggles
  services/          — Backend services (singletons)
    audio.qml
    bluetooth.qml
    battery.qml
    network.qml
    screenRecord.qml
    notifications.qml
  lib/               — Utility functions
    color.qml
    easing.qml
    keys.qml
  styles/            — Theme definitions
    catppuccin.json
    dracula.json
    nord.json
```

## Key Design Patterns

### 1. Centralized Configuration

```json
// config.json
{
  "theme": "catppuccin-mocha",
  "bar": {
    "height": 36,
    "position": "bottom",
    "modules": ["workspaces", "clock", "tray", "music", "quick-settings"]
  },
  "launcher": {
    "enabled": true,
    "shortcut": "Super+Space"
  },
  "blur": {
    "enabled": true,
    "strength": 8,
    "noise": 0.01
  }
}
```

All user-facing settings are in `config.json`. The shell reads this at startup and binds UI properties to it.

### 2. Theme System

```qml
// Caelestia uses Catppuccin colors defined in styles/
readonly property var colors: {
  "catppuccin-mocha": {
    "base": "#1e1e2e",
    "surface0": "#313244",
    "overlay0": "#6c7086",
    "text": "#cdd6f4",
    "subtext0": "#a6adc8",
    "blue": "#89b4fa",
    "green": "#a6e3a1",
    "red": "#f38ba8",
    "yellow": "#f9e2af",
    "peach": "#fab387",
    "mauve": "#cba6f7"
  }
}
```

### 3. Animation System

```qml
// lib/easing.qml — Custom easing curves
readonly property var easings: {
  "spring": Qt.Spring,
  "snap": Qt.bezierCurve(0.25, 0.1, 0.25, 1.0),
  "smooth": Qt.bezierCurve(0.4, 0.0, 0.2, 1.0),
  "bounce": Qt.bezierCurve(0.68, -0.55, 0.27, 1.55)
}
```

### 4. Component Architecture

Each bar module is a separate QML file:

```qml
// components/bar/workspaces.qml
Row {
  Repeater {
    model: HyprlandWorkspaceService.workspaces
    delegate: Rectangle {
      required property var modelData
      width: 24; height: 24; radius: 6
      color: modelData.active ? colors.blue : colors.surface0
      Text { anchors.centerIn: parent; text: modelData.name; color: colors.text }
      MouseArea {
        anchors.fill: parent
        onClicked: HyprlandWorkspaceService.switchToWorkspace(modelData.id)
      }
    }
  }
}
```

## What Makes Caelestia Great

1. **Consistent theming** — All components read from the same color palette
2. **Responsive animations** — Spring-like easing that feels natural
3. **Modular bar** — Users can enable/disable bar modules via config
4. **Built-in notification daemon** — No external dependency
5. **Active development** — Regular updates with new features

## Exercises

<ExerciseBlock :difficulty="1">
Clone Caelestia. Run it with a minimal config (enable only the clock module in the bar). Study how the bar reads from `config.json` and creates only the enabled modules.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a custom theme for Caelestia. Create a `styles/gruvbox.json` with Gruvbox colors. Add a "gruvbox" option to the config and verify all components use the new colors correctly.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Compare Caelestia's notification system with the system notification daemon (mako/dunst). List the pros and cons of each approach. Write a report on which approach you'd recommend for a new shell.
</ExerciseBlock>

<Recap :points="['Caelestia uses config.json for all user-facing settings', 'Components are modular, swappable bar modules', 'Theme system with Catppuccin, Dracula, and Nord themes', 'Custom easing curves for fluid animations']" next-chapter="/part-13-source-tour/reading-illogical-impulse" />

<!--
Sources verified for this chapter:
- https://github.com/outfoxxed/caelestia — Caelestia source
- https://github.com/catppuccin/catppuccin — Catppuccin theme
-->
