---
title: "Performance Basics"
description: "Keeping your shell fast and responsive from day one"
---

<ChapterMeta reading-time="14 min" :difficulty="2" :prerequisites="['Property bindings', 'Timer component']" you-will-learn="Performance best practices for QML shell development" />

## The Problem

A shell runs constantly — every millisecond of CPU time spent on rendering or bindings is time not available for your applications. A slow shell makes the entire desktop feel sluggish. Unlike a web app that users tolerate loading for 2 seconds, a shell must be instant and stay fast indefinitely.

## The Naive Approach

Update everything every frame:

```qml
Timer {
  interval: 16  // ~60 FPS
  running: true; repeat: true
  onTriggered: {
    cpuPercent.text = readCpuUsage()
    memPercent.text = readMemUsage()
    networkSpeed.text = readNetworkSpeed()
    diskFree.text = readDiskFree()
    batteryPercent.text = readBatteryPercent()
    temperature.text = readTemperature()
    fanSpeed.text = readFanSpeed()
  }
}
```

This polls every hardware sensor 60 times per second. Even if nothing changed, you're burning CPU re-reading files and re-rendering strings. On a laptop, this drains battery. On a desktop, it steals cycles from your actual work.

<MentalModel>

Think of performance like water conservation. Every property binding is a pipe, every update is a drop of water. You want enough pipes to deliver water when needed, but not so many that they leak constantly. A well-designed shell trickles — it doesn't gush.

</MentalModel>

## The Principles

### 1. Update at the Right Frequency

Different data needs different update rates:

| Data | Recommended Interval | Why |
|---|---|---|
| Clock (seconds) | 1000 ms | One tick per second |
| Clock (minutes only) | 60000 ms | One tick per minute |
| CPU usage | 1000-2000 ms | Smooth enough for a bar |
| Memory usage | 2000-5000 ms | Changes slowly |
| Disk usage | 10000-30000 ms | Almost static during a session |
| Network speed | 1000-2000 ms | Shows activity, not precision |
| Battery level | 30000-60000 ms | Changes over minutes/hours |
| Weather | 600000 ms (10 min) | Updates from API |
| Music track info | On change via MPRIS | No polling needed |

### 2. Stop Updating When Hidden

A popup that's not visible shouldn't update its contents:

```qml
Timer {
  interval: 1000
  running: popup.visible  // Only runs when popup is open
  repeat: true
}
```

### 3. Avoid Expensive Operations in Bindings

Bindings re-evaluate whenever their dependencies change. Keep them cheap:

```qml
// Bad — regex in a binding
Text { text: someString.replace(/[aeiou]/gi, "").toUpperCase() }

// Better — do it in a service once
Text { text: MyService.transformedString }
```

### 4. Use `readonly` When Possible

Marking properties `readonly` lets the QML engine optimize memory access:

```qml
readonly property string formattedTime: Qt.formatDateTime(clock.date, "hh:mm")
```

### 5. Lazy-Load Non-Essential UI

Not every widget needs to load at startup. Use `LazyLoader` for sections that aren't immediately visible:

```qml
LazyLoader {
  source: "WeatherWidget.qml"
  active: weatherEnabled
}
```

The component is created only when `active` becomes true.

## Profiling Your Shell

To find performance issues, enable the QML profiler:

```bash
export QML_DEBUG=1
quickshell
```

Or use `QML_LOGGING=1` to see binding evaluation counts. Look for bindings that evaluate hundreds of times per second — they're your hotspots.

## Common Bottlenecks

| Problem | Symptom | Fix |
|---|---|---|
| Polling timer in hidden popup | CPU spike on desktop idle | Check `visible` before updating |
| Complex binding in delegate | Lag when scrolling | Precompute values, use `Loader` |
| Image decoding on load | UI freeze at startup | Set `asynchronous: true` on `Image` |
| Frequent `Qt.process()` calls | Shell feels jittery | Batch calls, cache results |
| No `clip: true` on ListView | Visual artifacts, overdraw | Add `clip: true` |

<CommonMistake>

**Optimizing too early.** Before profiling, you don't know what's slow. Write clean code first, profile to find the 1-2 hotspots, and optimize those. Premature optimization of non-hot paths adds complexity without benefit.

**Ignoring timer accumulation.** If a timer fires every 16ms and the callback takes 20ms, you'll have 2 overlapping callbacks. Use `Timer { running: true; repeat: true; triggeredOnStart: false }` and check that you're not queuing work faster than you can process it.

</CommonMistake>

## Under the Hood

The QML engine batches binding evaluations. When a property changes, the engine doesn't immediately re-evaluate every dependent binding. Instead, it marks them as "dirty" and evaluates them in a cleanup pass. This means changing three properties that all affect the same binding costs one evaluation, not three.

Understanding this batching helps you avoid premature optimization — changing a property once vs. three times doesn't matter much if they're all in the same event handler.

## Exercises

<ExerciseBlock :difficulty="1">
Profile your current shell. Add a `console.profile("shell")` / `console.profileEnd("shell")` pair around a 5-second window. Identify the three most expensive bindings and optimize them.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Replace all 16ms timers with appropriate intervals based on the data they fetch. Implement visibility-based stopping for popup timers. Measure CPU usage before and after.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a performance dashboard widget that shows: FPS, binding count, timer count, and estimated power draw. Use it while testing your shell under different conditions (idle, heavy load, with popups open).
</ExerciseBlock>

<Recap :points="['Match update frequency to data volatility', 'Stop timers when popups are hidden to save CPU and battery', 'Avoid expensive operations in property bindings', 'Use LazyLoader for non-essential UI, profile before optimizing']" next-chapter="/part-11-complete-shell/keyboard-shortcuts" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/guide/qml-language/#lazy-loading — LazyLoader
- https://doc.qt.io/qt-6/qtquick-performance.html — Qt Quick Performance
- https://doc.qt.io/qt-6/qtquick-debugging.html — QML Debugging and Profiling
-->
