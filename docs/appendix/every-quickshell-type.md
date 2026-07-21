---
title: "Every Quickshell Type"
description: "Reference documentation for all Quickshell QML types"
---

<ChapterMeta reading-time="20 min" :difficulty="1" :prerequisites="['QML basics']" you-will-learn="A complete reference of every QML type provided by Quickshell" />

## Overview

This appendix lists every QML type exposed by the `Quickshell` import and its sub-modules. Use this as a quick reference when building your shell.

## Core Types (import Quickshell)

### Quickshell

```qml
import Quickshell
```

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `configPath(path)` | method | Resolve a path relative to the config directory |
| `statePath(path)` | method | Resolve a path relative to the state directory |
| `screens` | array | List of available screens |
| `process(opts)` | method | Execute a process (returns QProcess handle) |
| `execDetached(opts)` | method | Execute a process without waiting |
| `application` | object | Application metadata |
| `platform` | string | Current platform name |
| `version` | string | Quickshell version string |

### PopupWindow

```qml
import Quickshell
```

| Property | Type | Description |
|----------|------|-------------|
| `visible` | bool | Show/hide the popup |
| `width` | int | Window width |
| `height` | int | Window height |
| `x`, `y` | int | Window position |
| `anchor` | object | Anchor configuration (window, margins, edges) |
| `type` | enum | Window type (Normal, Dock, Tooltip, PopupMenu) |
| `margins` | rect | Margins from anchor |

### Rectangle (Extended)

Quickshell extends Qt's Rectangle with:

| Property | Type | Description |
|----------|------|-------------|
| `radius` | real | Corner radius |
| `border.width` | int | Border width |
| `border.color` | color | Border color |
| `clip` | bool | Enable clipping |

## Service Types

### Hardware Services (import Quickshell.Services.Hardware)

| Type | Description |
|------|-------------|
| `CpuService` | CPU usage, frequency, temperature |
| `MemoryService` | RAM usage, total, available |
| `BatteryService` | Battery percentage, charging status |
| `DiskService` | Disk usage by mount point |
| `GpuService` | GPU utilization, temperature |

### Audio Service (import Quickshell.Services.Audio)

| Type | Description |
|------|-------------|
| `AudioService` | Volume control, mute, sinks, sources, applications |

### Network Service (import Quickshell.Services.Network)

| Type | Description |
|------|-------------|
| `NetworkService` | Wi-Fi scanning, connection management, ethernet status |

### Bluetooth Service (import Quickshell.Services.Bluetooth)

| Type | Description |
|------|-------------|
| `BluetoothService` | Adapter power, device scanning, pairing, connections |

### Power Service (import Quickshell.Services.Power)

| Type | Description |
|------|-------------|
| `PowerService` | Power profiles, sleep, hibernate |

### Notifications Service (import Quickshell.Services.Notifications)

| Type | Description |
|------|-------------|
| `NotificationService` | Receive and send notifications |
| `Notification` | Individual notification object (app, title, body, urgency, actions) |

### MPRIS Service (import Quickshell.Services.MPRIS)

| Type | Description |
|------|-------------|
| `MprisService` | Media player information, playback control |
| `MprisPlayer` | Individual player (name, status, title, artist, album, art) |

### Input Service (import Quickshell.Services.Input)

| Type | Description |
|------|-------------|
| `InputService` | Keyboard layout, input methods |

### Hyprland Service (import Quickshell.Services.Hyprland)

| Type | Description |
|------|-------------|
| `HyprlandEventStream` | Listen for Hyprland IPC events |
| `HyprlandWorkspaceService` | Workspace management |
| `HyprlandWindowService` | Window management |
| `HyprlandMonitorService` | Monitor configuration |

<CommonMistake>

**Importing services incorrectly.** Always use `import Quickshell.Services.Hardware` (plural), not `import Quickshell.Service.Hardware`. Service names are PascalCase and capitalized.

**Not checking service availability.** Some services require specific backends (e.g., PipeWire for Audio, Hyprland for workspace management). Always check `service.available` before using.

</CommonMistake>

## Utility Types

| Type | Module | Description |
|------|--------|-------------|
| `Process` | Quickshell | Process execution and output handling |
| `Settings` | Quickshell | Persistent key-value settings store |
| `Timer` | QtQuick | Timer with configurable interval and repeat |
| `Animation` | QtQuick | Property animation framework |

## Exercises

<ExerciseBlock :difficulty="1">
Write a QML file that lists all available service types and their properties. Use a combination of `Object.keys()` and `typeof` to enumerate them dynamically at runtime.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a "Service Inspector" panel. For each available service, display its name, whether it's available, and all its property names and current values. Update in real-time.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Document any types you discover that are not listed here. Submit a correction to the Quickshell documentation or this book via a pull request.
</ExerciseBlock>

<Recap :points="['Quickshell provides ~20 QML types across core and service modules', 'Service types require specific backends (PipeWire, Hyprland, BlueZ)', 'Use import Quickshell.Services.{Category} to access service types', 'Reference this appendix when you need to know available properties']" next-chapter="/appendix/common-errors" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/ — Quickshell type reference
- https://quickshell.org/docs/ — Quickshell documentation
-->
