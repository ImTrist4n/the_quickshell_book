---
title: "State Management"
description: "Managing application state across components without chaos"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['Singleton pattern', 'Property bindings']" you-will-learn="Patterns for sharing state between components predictably" />

## The Problem

As your shell grows, multiple components need access to the same data. The clock widget needs the time. The calendar popup needs the time. The lock screen needs the time. If each component fetches time independently, you have redundant data fetching and inconsistent values.

## The Naive Approach

Each component manages its own state:

```qml
// ClockWidget.qml
Timer {
  interval: 1000; running: true; repeat: true
  onTriggered: display.text = new Date().toLocaleTimeString()
}

// CalendarPopop.qml
Timer {
  interval: 1000; running: true; repeat: true
  onTriggered: model.update()
}
```

Both timers run independently, potentially desyncing by milliseconds. If the user's locale changes, only one updates. Multiply this by every component that needs time, and you have dozens of redundant timers.

<MentalModel>

Think of state like a radio station. The station broadcasts a signal (state). Any radio (component) within range can tune in and play the music. Radios don't produce their own signal — they receive it. If you need a new radio, you just add one that tunes to the same frequency.

</MentalModel>

## The Patterns

### 1. Singleton Service (Global State)

The most common pattern. A singleton holds state and components read it via property bindings.

```qml
// TimeService.qml
pragma Singleton
import Quickshell

QtObject {
  readonly property date currentDate: clock.date
  readonly property string timeString: Qt.formatDateTime(clock.date, "hh:mm AP")

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}
```

Components read from the singleton:

```qml
// ClockWidget.qml
import "TimeService.qml" as Time

Text {
  text: Time.timeString
}
```

**Use when:** State is truly global (time, theme, locale).

### 2. Property Passing (Local State)

Pass data from parent to child via properties.

```qml
Item {
  property string userName: "Alice"

  ChildComponent {
    name: parent.userName
  }
}
```

**Use when:** State is scoped to a subtree. Avoid passing state through more than 2-3 levels of nesting — it becomes "prop drilling."

### 3. Signal-Based Communication (Event-Driven)

Components emit signals; other components respond.

```qml
Item {
  signal brightnessChanged(int value)

  Slider {
    onValueChanged: parent.brightnessChanged(value)
  }

  BrightnessWidget {
    onBrightnessChanged: updateDisplay(value)
  }
}
```

**Use when:** Components need to notify peers of actions without direct coupling.

### 4. Service Locator

A central registry that holds references to services.

```qml
// ServiceRegistry.qml
QtObject {
  property var weatherService: WeatherService {}
  property var wallpaperService: WallpaperService {}
  property var config: Config {}
}
```

Components access services through the registry rather than importing them directly.

**Use when:** You want to swap service implementations (e.g., mock services in tests).

## Choosing the Right Pattern

| Scenario | Pattern |
|---|---|
| Current time, used by 5 components | Singleton |
| A user's name in the profile widget | Property passing |
| "User clicked logout" event | Signal |
| Switching between mock and real API | Service locator |

## Anti-patterns

**Global mutable state.** A singleton with writable properties that multiple components modify is a debugging nightmare. Prefer read-only properties with centralized mutation points.

**Prop drilling through 10 levels.** If you pass `config.fontSize` through 10 nested components, you're doing it wrong. Either pull from the singleton directly or use a context-like pattern.

**State duplication.** If two components hold the same data, they will inevitably desync. There should be one source of truth.

## Under the Hood

QML's property binding system is itself a state management mechanism. When a component reads `Time.timeString`, it automatically subscribes to changes on that property. When `SystemClock` updates `clock.date`, the binding re-evaluates and `ClockWidget` re-renders — no explicit notification needed.

This is the same reactive engine that drives Qt's `QProperty` system. Understanding that bindings are automatic and transitive helps you design without unnecessary `onPropertyChanged` handlers.

## Exercises

<ExerciseBlock :difficulty="1">
Identify all state in your current shell. Classify each piece as global (singleton), local (property), or event-based (signal). Move any misplaced state to the correct pattern.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Refactor a chain of nested property passing (>3 levels) to use a singleton instead. Verify the behavior is identical.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a lightweight reactive store (similar to Vuex or Redux) using a `QtObject` singleton with a `dispatch(action)` method. Components call `dispatch({ type: "SET_THEME", payload: "dracula" })`. The store updates state and components re-bind automatically.
</ExerciseBlock>

<Recap :points="['Use singleton services for global state, property passing for local state', 'Signals enable decoupled event-driven communication', 'One source of truth — never duplicate state across components', 'QML bindings are automatic and transitive; leverage them']" next-chapter="/part-10-architecture/singletons" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/qml-language — QML Language
- https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html — Property Binding
- https://quickshell.org/docs/v0.3.0/types/Quickshell/SystemClock — SystemClock
-->
