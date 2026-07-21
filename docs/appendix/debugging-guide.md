---
title: "Debugging Guide"
description: "Comprehensive debugging techniques for Quickshell shells"
---

# Debugging Guide

This appendix provides a systematic approach to debugging Quickshell shells, from simple logging to advanced profiling.

## Quick Reference

| Symptom | First Check | Tool |
|---------|-------------|------|
| Shell doesn't start | Terminal error output | `quickshell 2>&1` |
| Popup not visible | `console.log(popup.visible)` | QML Debugger |
| Animation stutter | FPS overlay | FpsMonitor |
| Wrong colors | `console.log(JSON.stringify(colors))` | Property Watch |
| Service not responding | `console.log(service.available)` | Service Check |
| Crash on action | Error boundaries | try/catch in QML |

## Step 1: Terminal Output

Always run `quickshell` from a terminal first:

```bash
quickshell -c ~/.config/quickshell/shell.qml 2>&1 | tee /tmp/quickshell.log
```

This captures all output. Common messages:

- `module "X" is not installed` → Missing import
- `file:///path error` → File not found
- `TypeError` → Wrong type usage
- `ReferenceError` → Undefined variable

## Step 2: Console Logging

Strategic `console.log()` placement:

```qml
// Trace execution
console.log("=== Shell startup ===")
console.log("Config loaded:", JSON.stringify(config))
console.log("Services available:", {
  audio: AudioService.available,
  bluetooth: BluetoothService.available
})

// Trace function calls
function setVolume(v) {
  console.log("setVolume called with:", v, "current:", volume)
  // ... implementation
}

// Trace signal emissions
Connections {
  target: AudioService
  function onVolumeChanged(newVol) {
    console.log("Volume changed:", newVol)
  }
}
```

## Step 3: QML Debugger

Start with debugger enabled:

```bash
quickshell --qmljsdebugger port:3768
```

Then connect from Qt Creator: **Analyze > QML Profiler > Connect...**

Available debugging features:
- Breakpoints in QML
- Property value inspection
- Binding evaluation tracing
- Frame-by-frame animation stepping

## Step 4: Visual Inspector

Build an inspector overlay (toggle with F12):

```qml
// Inspector.qml
Rectangle {
  id: inspector
  visible: false
  anchors.fill: parent
  color: "transparent"

  property Item hoveredItem: null

  Rectangle {
    id: tooltip
    visible: inspector.hoveredItem != null
    x: mouseArea.mouseX + 10
    y: mouseArea.mouseY + 10
    width: 300; height: 200; radius: 6; color: "#1e1e2ee0"

    Column {
      anchors.fill: parent; margins: 8; spacing: 2
      Text { text: "Item: " + (inspector.hoveredItem ? inspector.hoveredItem : "none"); color: "#cdd6f4"; font.pixelSize: 11 }
      Text { text: "x: " + (inspector.hoveredItem ? inspector.hoveredItem.x : 0); color: "#a6adc8"; font.pixelSize: 10 }
      Text { text: "y: " + (inspector.hoveredItem ? inspector.hoveredItem.y : 0); color: "#a6adc8"; font.pixelSize: 10 }
      Text { text: "opacity: " + (inspector.hoveredItem ? inspector.hoveredItem.opacity : 0); color: "#a6adc8"; font.pixelSize: 10 }
      Text { text: "visible: " + (inspector.hoveredItem ? inspector.hoveredItem.visible : false); color: "#a6adc8"; font.pixelSize: 10 }
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    onPositionChanged: {
      inspector.hoveredItem = inspector.childAt(mouseX, mouseY)
      tooltip.x = mouseX + 10
      tooltip.y = mouseY + 10
    }
  }
}
```

## Step 5: Network Debugging

For services that make network requests:

```bash
# Monitor HTTP traffic
tcpdump -i any port 80 or port 443 -A | grep "quickshell"

# Proxy for inspection
mitmproxy --mode transparent --listen-port 8080
https_proxy=localhost:8080 quickshell
```

## Step 6: Profiling

When performance is the issue:

1. Add FPS overlay
2. Record frame times with `console.time()`
3. Profile with Qt Creator
4. Compare before/after optimizations

## Debugging Checklist

- [ ] Run from terminal, capture all output
- [ ] Check Quickshell version: `quickshell --version`
- [ ] Verify all import paths
- [ ] Test with minimal shell.qml
- [ ] Add console.log at entry points
- [ ] Check service.available before use
- [ ] Inspect property values
- [ ] Test on clean config directory

## Exercises

<ExerciseBlock :difficulty="1">
Simulate a broken shell. Create a circular binding, a missing import, and a TypeError. Practice using each debugging technique to identify the root cause.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a "Crash Reporter" component. Catch unhandled exceptions with `Qt.application.onException`. Show a dialog with the error message and a "Copy Report" button.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Write a diagnostic export function. Collect: Quickshell version, config files, available services, recent logs, and system info. Output a JSON report for sharing when asking for help.
</ExerciseBlock>

<Recap :points="['Always run quickshell from terminal first to see error output', 'Use --qmljsdebugger port for Qt Creator breakpoints and inspection', 'Build a visual inspector overlay for runtime property inspection', 'Systematic checklist approach prevents overlooking basic issues']" next-chapter="/appendix/faq" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-debugging.html — QML Debugging
- https://quickshell.org/docs/ — Quickshell docs
-->
