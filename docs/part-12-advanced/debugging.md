---
title: "Debugging"
description: "Techniques and tools for debugging Quickshell configurations"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['Performance basics', 'Testing']" you-will-learn="How to diagnose and fix common Quickshell issues" />

## The Problem

Your shell crashes, a widget shows wrong data, a popup doesn't appear, or the panel renders at the wrong size. Without debugging tools, you're guessing at the cause. QML's dynamic nature makes errors silent — a binding that fails just shows nothing.

## The Naive Approach

Add random `console.log()` statements:

```qml
function refresh() {
  console.log("refresh called")
  console.log("cpu = " + cpuValue)
  console.log("about to call Qt.process...")
  Qt.process(["..."]).onStdout.connect(function(data) {
    console.log("got data: " + data)
  })
}
```

`console.log()` works, but it's noisy, easy to forget, and doesn't help with rendering issues or binding failures.

<MentalModel>

Think of debugging like detective work. You have witnesses (logs), forensic evidence (crash dumps), surveillance cameras (profiler), and interrogation (interactive shell). Each tool reveals a different angle. Using only one tool misses crucial clues.

</MentalModel>

## Essential Debugging Tools

### 1. The QML Console

Quickshell prints QML errors to stderr. Run with visible stderr:

```bash
quickshell 2>&1 | tee quickshell.log
```

Look for:
- `TypeError: Cannot read property 'x' of null` — null reference
- `ReferenceError: foo is not defined` — typo or missing import
- `QML PanelWindow: Cannot anchor to an item that is a sibling or ancestor` — layout issue

### 2. `console.log()` and Friends

```qml
console.log("simple string")
console.debug("debug: " + value)
console.warn("warning: " + value)
console.error("error: " + value)
console.trace()  // Print stack trace
console.time("label") / console.timeEnd("label")  // Timing
console.count("label")  // Count calls
console.profile("label") / console.profileEnd("label")  // Profile
```

### 3. Visual Debug Overlays

Add a debug mode that shows bounding boxes:

```qml
// shell.qml
Rectangle {
  anchors.fill: parent
  color: "transparent"
  border.color: "red"
  border.width: debugMode ? 1 : 0
}
```

### 4. Property Dump

Create a debug panel that shows all service properties:

```qml
// DebugOverlay.qml
PopupWindow {
  visible: debugMode

  ListView {
    model: [
      "CPU: " + CpuService.usagePercent.toFixed(1) + "%",
      "RAM: " + MemoryService.usedPercent.toFixed(1) + "%",
      "Battery: " + BatteryService.percent + "%",
      "Time: " + TimeService.timeString
    ]
    delegate: Text { text: modelData; color: "lime"; font.pixelSize: 10 }
  }
}
```

### 5. QML Inspector

Quickshell may support the Qt QML Inspector (port 3768 by default):

```bash
QML_DEBUG=1 quickshell
# Connect with Qt Creator or qmldbg
```

## Common Bugs and Fixes

| Symptom | Likely Cause | Fix |
|---|---|---|
| Panel not visible | Missing anchors | Add at least 2 opposite anchors |
| Popup shows at (0,0) | No anchor set | Set `anchor.window` and `anchor.rect` |
| Property shows "undefined" | Binding failed, property doesn't exist | Check spelling and import |
| Timer not firing | `repeat: false` or wrong interval | Set `repeat: true` and check interval |
| Component not loading | Wrong path or circular import | Check file path and dependency chain |
| Crash on startup | Missing import or bad QML syntax | Run `qmllint` on your files |
| Wrong colors | Theme not applied | Check `import "Theme.qml" as Theme` syntax |
| Layout clipping | No `clip: true` on container | Add `clip: true` to ListView/Grid |

## Debugging Bindings

Enable binding removal warnings to find accidental overwrites:

```bash
export QT_LOGGING_RULES="qt.qml.binding.removal.info=true"
quickshell
```

Watch for: `QML Binding: Binding loop detected for property "height"`.

## Debugging D-Bus

Monitor D-Bus traffic:

```bash
dbus-monitor --session   # Session bus
dbus-monitor --system    # System bus
```

Filter for specific services:

```bash
dbus-monitor "interface=org.mpris.MediaPlayer2.Player"
```

## Exercises

<ExerciseBlock :difficulty="1">
Add a keyboard shortcut (Ctrl+Shift+D) that toggles a debug overlay. The overlay shows: FPS, binding count, timer count, memory usage, and last error message. Keep it visible during normal use to catch intermittent issues.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a "binding visualizer" popup that lists every property binding in a selected component. Show the binding expression, its current value, and how many times it evaluated. Use `QML_DEBUG=1` to access binding metadata.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement crash recovery. If your shell crashes, respawn automatically. Save the error log to `crash-{timestamp}.log`. On the next startup, show a "Recovered from crash" notification with a link to the log.
</ExerciseBlock>

<Recap :points="['Use console.log, console.warn, console.error, and console.trace for logging', 'Enable QML debug mode with QML_DEBUG=1 for the QML Inspector', 'Add visual debug overlays for real-time property monitoring', 'Monitor D-Bus traffic with dbus-monitor for integration debugging']" next-chapter="/part-12-advanced/distribution" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-debugging.html — QML Debugging
- https://doc.qt.io/qt-6/debugging-techniques.html — Qt Debugging
- https://quickshell.org/docs/guide/install-setup — Quickshell setup with qmllint
-->
