---
title: "Singletons"
description: "Mastering the singleton pattern for shared services and global state"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['State management', 'QML Language']" you-will-learn="How to create and use singletons effectively in Quickshell" />

## The Problem

When multiple components need access to the same service instance, you need a way to share it without creating duplicate copies. If you import a QML file normally, each import creates a new instance — wasteful for services that manage state.

## The Naive Approach

Create a new instance every time:

```qml
// CpuWidget.qml
CpuService { id: cpu }
Text { text: cpu.usagePercent.toFixed(1) + "%" }
```

```qml
// RamWidget.qml
CpuService { id: cpu }
Text { text: "CPU: " + cpu.usagePercent.toFixed(1) + "%" }
```

Two instances of `CpuService` means two timers polling `/proc/stat`, two sets of property allocations, and potentially inconsistent readings because they poll at slightly different moments.

<MentalModel>

Think of a singleton like a water tower. Every house in the neighborhood connects to the same tower. If each house built its own tower, the neighborhood would waste resources and water pressure would vary. The singleton is the shared water tower — one source, many consumers.

</MentalModel>

## The Idea

A singleton is a class that can have at most one instance. In QML, you declare a file as a singleton with the `pragma Singleton` directive. The QML engine creates one instance on first access and reuses it for all subsequent imports.

## Creating a Singleton

```qml
// Theme.qml
pragma Singleton
import Quickshell

QtObject {
  readonly property color background: "#1e1e2e"
  readonly property color foreground: "#cdd6f4"
  readonly property color accent: "#89b4fa"
  readonly property color surface: "#313244"

  readonly property int spacing: 8
  readonly property int radius: 6
}
```

Import and use it:

```qml
// Any component
import "Theme.qml" as Theme

Rectangle {
  color: Theme.background
  radius: Theme.radius
}
```

## Singletons in Quickshell vs Plain QML

In plain Qt QML, singletons must be registered in C++ or via a `qmldir` file. Quickshell simplifies this: just add `pragma Singleton` at the top of your file and import it with the `as` keyword.

Quickshell also provides built-in singletons like `Quickshell` itself (the global object) and `SystemClock`.

```qml
Text {
  // Quickshell is a singleton — one instance available everywhere
  text: "Process ID: " + Quickshell.processId
}
```

## When to Use a Singleton

| Use Case | Example |
|---|---|
| Configuration | Theme colors, panel dimensions |
| Hardware data | CPU, memory, battery status |
| External service | Weather API, network manager |
| Global event bus | Signals that many components listen to |
| Resource cache | Icon lookups, font loading |

## When NOT to Use a Singleton

| Scenario | Alternative |
|---|---|
| A component instance with local state | Regular QML type |
| A one-off utility function | `.js` library (no state needed) |
| Data that varies per screen | `Variant` + `modelData` per screen |
| Temporary or modal state | Local property on the parent |

## Common Pitfalls

**Singletons with mutable state.** A singleton with writable properties that multiple components modify is a recipe for chaos. You never know who changed what. Keep singleton properties `readonly`. If mutation is necessary, provide controlled methods.

**Singletons that depend on visual types.** A singleton must be non-visual. It should inherit `QtObject`, not `Item` or `Rectangle`. Visual types have rendering overhead and can't exist without a parent window.

**Circular singleton dependencies.** Singleton A imports Singleton B which imports Singleton A. This creates an initialization deadlock. Break the cycle by merging them or introducing a third singleton.

## Exercises

<ExerciseBlock :difficulty="1">
Convert three of your existing services (e.g., CPU monitoring, weather, theme) to singletons. Ensure they use `pragma Singleton` and inherit `QtObject`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a singleton called `EventBus` with a `signal(string eventName, var payload)`. Components can call `EventBus.emit("theme-changed", "dracula")` and other components can connect with `EventBus.onEventName.connect(...)`. Implement `on()` and `emit()` methods.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a singleton that manages lifecycle — it exposes a `dependencies` array and ensures services are initialized in the correct order. If a service fails to initialize, the lifecycle manager emits a `serviceFailed(string name, string error)` signal and continues with the remaining services.
</ExerciseBlock>

<Recap :points="['pragma Singleton ensures one instance shared across all imports', 'Singletons must inherit QtObject (non-visual) with readonly properties', 'Use singletons for global state, configuration, and shared services', 'Avoid mutable state and circular dependencies in singletons']" next-chapter="/part-10-architecture/theming-systems" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Singleton — Singleton type
- https://quickshell.org/docs/v0.3.0/guide/qml-language/#singletons — Singletons in QML
- https://doc.qt.io/qt-6/qml-qtqml-qtobject.html — QtObject QML Type
-->
