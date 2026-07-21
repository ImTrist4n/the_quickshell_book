---
title: "Migration Guide"
description: "Upgrading your Quickshell configuration between versions"
---

# Migration Guide

This guide covers breaking changes between Quickshell versions and how to update your configuration.

## v0.1.0 → v0.2.0

### Import Syntax Changed

**Old (v0.1.0):**
```qml
import "folder/MyComponent.qml"
```

**New (v0.2.0+):**
```qml
import qs.folder
```

The `qs.` prefix enables module imports. Files in the imported directory become available as types.

### PopupWindow Anchoring

**Old (v0.1.0):**
```qml
PopupWindow {
  parentWindow: panel
  x: 100
  y: 50
}
```

**New (v0.2.0+):**
```qml
PopupWindow {
  anchor.window: panel
  anchor.rect.x: 100
  anchor.rect.y: 50
}
```

The `parentWindow`, `x`, and `y` properties are deprecated in favor of `anchor.window` and `anchor.rect`.

### Exclusion Zone Property

**Old (v0.1.0):**
```qml
PanelWindow {
  exclusionZone: 36
}
```

**New (v0.2.0+):**
```qml
PanelWindow {
  exclusionMode: ExclusionMode.Normal
  // Set zone implicitly via opposite anchors + height
  anchors { top: true; left: true; right: true }
  implicitHeight: 36
}
```

`exclusionZone` is replaced by `exclusionMode` and automatic zone calculation from window geometry.

## v0.2.0 → v0.3.0

### Singleton Syntax

**Old (v0.2.0):**
```qml
// WeatherService.qml
pragma Singleton
Item {
  property double temperature: 0
}
```

**New (v0.3.0+):**
```qml
// WeatherService.qml
pragma Singleton
import Quickshell

QtObject {
  property double temperature: 0
}
```

Singletons should now inherit `QtObject` instead of `Item`. Non-visual singletons using `Item` cause unnecessary rendering overhead. Import `Quickshell` to access `QtObject`.

### Process API

**Old (v0.2.0):**
```qml
Qt.process("command arg1 arg2")
```

**New (v0.3.0+):**
```qml
Qt.process(["command", "arg1", "arg2"])
```

The process API now accepts an array of arguments instead of a single string. This avoids shell injection and handles arguments with spaces correctly.

### Screen Property

**Old (v0.2.0):**
```qml
PanelWindow {
  screen: Quickshell.screens[0]
}
```

**New (v0.3.0+):**
```qml
PanelWindow {
  required property var modelData
  screen: modelData
}
```

When using `Variants`, the screen item is now assigned via `modelData` with `required property`. This follows QML best practices.

## General Tips

- **Always run `qmllint`** after upgrading. It catches most syntax and type errors.
- **Read the release notes** on the Quickshell GitHub page for each version.
- **Test in a separate config directory** before migrating your main config:
  ```bash
  quickshell --path /tmp/test-config/shell.qml
  ```
- **Check the type reference** at [quickshell.org/docs/types](https://quickshell.org/docs/v0.3.0/types/) for updated property signatures.

## Deprecated Features

| Feature | Deprecated In | Replacement |
|---|---|---|
| `PopupWindow.parentWindow` | v0.2.0 | `anchor.window` |
| `PopupWindow.x` / `PopupWindow.y` | v0.2.0 | `anchor.rect.x` / `anchor.rect.y` |
| `PanelWindow.exclusionZone` | v0.2.0 | `exclusionMode` + geometry |
| `Qt.process(string)` | v0.3.0 | `Qt.process(array)` |
| Singleton inheriting `Item` | v0.3.0 | Inherit `QtObject` |

<Recap :points="['Import syntax changed from relative paths to qs. module imports', 'PopupWindow anchoring moved from direct properties to anchor object', 'Singletons should inherit QtObject, not Item', 'Qt.process() now takes an array of arguments']" next-chapter="/appendix/troubleshooting" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/qml-language — QML Language
- https://quickshell.org/docs/v0.3.0/guide/qml-language/ — v0.3.0 QML
- https://quickshell.org/docs/v0.2.1/types/Quickshell/PopupWindow/ — PopupWindow v0.2.1
-->
