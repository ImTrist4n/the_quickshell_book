---
title: "QML Cheatsheet"
description: "Quick reference for QML syntax and Quickshell-specific types"
---

# QML Cheatsheet

## Syntax Basics

### Property Declarations
```qml
property int count: 0
property string name: "hello"
property color bgColor: "#1e1e2e"
property var anything: [1, "two", true]
readonly property double pi: 3.14159
required property string modelData
```

### Property Bindings
```qml
// Automatic binding
Rectangle { width: parent.width * 0.5; height: width * 0.75 }

// Imperative binding (preserve after JS assignment)
height = Qt.binding(function() { return width * 0.75 })
```

### Signal Handlers
```qml
onClicked: console.log("clicked")
onTextChanged: function(newText) { search(newText) }

// Custom signal
signal activated(string item)
onActivated: function(item) { console.log(item) }
```

### Functions
```qml
function add(a, b) { return a + b }
```

### Import Types
```qml
import Quickshell                                                 // Core types
import Quickshell.Services.Hardware                               // CPU, Memory
import "util/format.js" as Format                                  // JS library
import "Theme.qml" as Theme                                       // Singleton
import qs.widgets                                                  // Module (v0.2.0+)
```

## Quickshell Types Quick Reference

| Type | Import | Use |
|---|---|---|
| `PanelWindow` | `Quickshell` | Main bar/panel attached to screen edge |
| `PopupWindow` | `Quickshell` | Popup relative to a parent window |
| `FloatingWindow` | `Quickshell` | Standard desktop window |
| `ShellRoot` | `Quickshell` | Root element of every config |
| `Variants` | `Quickshell` | Create one delegate per model item |
| `Scope` | `Quickshell` | Create a child scope |
| `Singleton` | `Quickshell` | Singleton type reference |
| `Quickshell` | `Quickshell` | Global singleton with paths, screens |
| `SystemClock` | `Quickshell` | Time service |

## Common QML Components

| Type | Import | Use |
|---|---|---|
| `Item` | `QtQuick` | Invisible container |
| `Rectangle` | `QtQuick` | Colored rectangle |
| `Text` | `QtQuick` | Text label |
| `Image` | `QtQuick` | Image display |
| `MouseArea` | `QtQuick` | Mouse click/hover events |
| `ListView` | `QtQuick` | Scrollable list |
| `Grid` | `QtQuick` | Grid layout |
| `Row` | `QtQuick` | Horizontal layout |
| `Column` | `QtQuick` | Vertical layout |
| `Timer` | `QtQuick` | Delayed/repeated execution |
| `Loader` | `QtQuick` | Dynamic component loading |
| `Connections` | `QtQuick` | Connect to signals from another object |
| `Binding` | `QtQml` | Create imperative binding |
| `ListModel` | `QtQml` | Data model for ListView |

## Built-in Services

| Service | Import | Key Properties |
|---|---|---|
| `CpuService` | `Quickshell.Services.Hardware` | `usagePercent` |
| `MemoryService` | `Quickshell.Services.Hardware` | `usedPercent`, `totalKB`, `availableKB` |
| `BatteryService` | `Quickshell.Services.Hardware` | `percent`, `charging`, `state` |
| `SystemClock` | `Quickshell` | `date`, `precision` |
| `MprisService` | `Quickshell.Services.Mpris` | `players`, `title`, `artist` |

## Useful Qt Functions

```qml
Qt.formatDateTime(date, "hh:mm AP")     // Format dates
Qt.binding(function() { return ... })    // Create binding
Qt.quit()                                // Exit the application
Qt.open(path, mode)                      // Open file for reading/writing
Qt.process(array)                        // Run command (async)
Qt.execDetached(object)                  // Run command (detached)
Qt.dbusCall(bus, path, iface, method)    // D-Bus method call
```

## CSS-like Colors

```qml
color: "#1e1e2e"            // Hex
color: Qt.rgba(0.1, 0.1, 0.2, 1.0)  // RGBA
color: Qt.lighter(color, 1.2)        // Brighten by 20%
color: Qt.darker(color, 1.2)         // Darken by 20%
color: Qt.tint(color, Qt.rgba(1, 0, 0, 0.2))  // Tint with red
color: "transparent"         // Fully transparent
```

<Recap :points="['QML property declarations use property type name: value syntax', 'Import qs.module for directory-wide imports (v0.2.0+)', 'PanelWindow needs at least 2 opposite anchors', 'Use Qt.process([...]) for async commands, Qt.execDetached() for fire-and-forget']" next-chapter="/appendix/configuration-samples" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/qml-language — QML Language Reference
- https://doc.qt.io/qt-6/qmlreference.html — QML Reference
- https://quickshell.org/docs/v0.3.0/types/ — Type reference
-->
