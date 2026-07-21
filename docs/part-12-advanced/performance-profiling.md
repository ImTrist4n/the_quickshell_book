---
title: "Performance Profiling"
description: "Profile and optimize your Quickshell shell for smooth animations and low latency"
---

<ChapterMeta reading-time="14 min" :difficulty="4" :prerequisites="['Lazy Loading', 'Memory Optimization']" you-will-learn="How to profile QML rendering, identify bottlenecks, and optimize frame rates" />

## The Problem

Your shell feels sluggish. Animations stutter, popups take time to appear, and CPU usage spikes when the clock ticks. Without profiling, you're guessing at the cause.

## The Naive Approach

Add more `console.log` statements:

```qml
console.log("Animation started: " + Date.now())
```

Logging timestamps gives a rough idea but doesn't identify rendering bottlenecks, layout passes, or binding evaluation costs.

<MentalModel>

Think of profiling as a mechanic's diagnostic tool. The engine sputters. You could guess it's the spark plugs, fuel filter, or oxygen sensor. Or you can plug in an OBD-II scanner and get exact error codes. Profiling is the OBD-II scanner for your shell.

</MentalModel>

## Profiling Tools

### 1. Qt Quick Profiler

```bash
# Start with profiling enabled
quickshell --qmljsdebugger port:3768

# Connect from Qt Creator: Analyze > QML Profiler
# Or from command line with:
qmlprofiler -p 3768
```

### 2. Frame Rate Monitor

```qml
// FpsMonitor.qml
Text {
  id: fpsText
  property real fps: 0
  property var frameTimes: []
  property int frameCount: 0
  color: fps >= 55 ? "#a6e3a1" : fps >= 30 ? "#fab387" : "#f38ba8"
  font.pixelSize: 11

  Timer {
    interval: 1000; running: true; repeat: true
    onTriggered: {
      var avg = fpsText.frameTimes.reduce(function(a,b) { return a+b }, 0) / fpsText.frameTimes.length
      fpsText.fps = avg > 0 ? 1000 / avg : 0
      fpsText.text = fpsText.fps.toFixed(0) + " FPS"
      fpsText.frameTimes = []
    }
  }

  // Track frame rendering time
  Connections {
    target: fpsText
    function onFrameChanged() {
      var now = Date.now()
      if (fpsText.frameTimes.length > 0) {
        var elapsed = now - fpsText.frameTimes[fpsText.frameTimes.length - 1].timestamp
        fpsText.frameTimes.push(elapsed)
      }
      fpsText.frameTimes.push({ timestamp: now })
      if (fpsText.frameTimes.length > 60) fpsText.frameTimes.shift()
    }
  }
}
```

### 3. Frame Recording with Quickshell

```qml
// ProfileCapture.qml
QtObject {
  id: profiler

  property var frames: []
  property bool recording: false

  function startRecording() {
    frames = []
    recording = true
    captureFrame()
  }

  function stopRecording() {
    recording = false
    return analyzeFrames()
  }

  function captureFrame() {
    if (!recording) return
    frames.push({
      timestamp: Date.now(),
      cpuUsage: CpuService.usagePercent,
      memoryUsage: processMemoryUsage()
    })
    Timer.callLater(captureFrame)
  }

  function analyzeFrames() {
    var result = {
      totalFrames: frames.length,
      avgCpu: frames.reduce(function(s, f) { return s + f.cpuUsage }, 0) / frames.length,
      duration: frames.length > 1 ? frames[frames.length-1].timestamp - frames[0].timestamp : 0
    }
    return result
  }
}
```

## Identifying Bottlenecks

### Binding Overhead

```qml
// Bad: expensive expression evaluated on every change
Text { text: parent.width * parent.height / CpuService.usagePercent / 100 * 2 }

// Good: precompute in a property
property int computed: parent.width * parent.height
Text { text: computed / CpuService.usagePercent / 100 * 2 }
```

### Layout Passes

```qml
// Bad: triggers relayout on every pixel change
Anchors { left: parent.left; right: parent.right; leftMargin: someAnimatedProperty }

// Good: use transforms instead of changing margins
Transform.translate: Translate { x: someAnimatedProperty }
```

### Expensive Delegates

```qml
// Bad: each delegate creates a heavy component tree
delegate: Column {
  Rectangle { width: 200; height: 200; Image { source: modelData.largeIcon } }
  Text { text: modelData.name }
  Text { text: modelData.description } // Rarely visible
}

// Good: simplify delegate, show details on demand
delegate: Row {
  Rectangle { width: 40; height: 40; Image { source: modelData.thumbnail; sourceSize.width: 40 } }
  Text { text: modelData.name }
}
```

## Optimization Checklist

| Check | Tool | Action |
|-------|------|--------|
| Frame rate < 55 | FpsMonitor | Simplify animations, reduce overdraw |
| Binding evaluation > 1ms | QML Profiler | Cache expressions, use property bindings |
| Memory growth | ps/rss | Fix leaks, add lazy loading |
| Layout passes > 10/s | QML Profiler | Use fixed sizes, avoid anchors in animations |
| Image loading | Qt Quick Inspector | Set sourceSize, use asynchronous |

## Exercises

<ExerciseBlock :difficulty="1">
Add the FpsMonitor to your shell. Run it for 10 minutes while using your computer. Record the minimum and average FPS. Identify the top 3 frame drops and their causes.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Use Qt Creator's QML Profiler to record a 30-second session. Find the function with the longest binding evaluation time. Optimize it using caching or alternative expression.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a performance dashboard that logs FPS, CPU, and memory every second. Export to CSV. Analyze trends over a 1-hour session. Identify memory leaks (steadily increasing memory without corresponding usage increase).
</ExerciseBlock>

<Recap :points="['Use Qt Quick Profiler and QML Profiler in Qt Creator for deep analysis', 'Add an FPS monitor overlay to detect stuttering in real-time', 'Avoid expensive bindings — cache intermediate computations as properties', 'Use transforms instead of anchor margins for animated properties', 'Simplify delegates in ListView/GridView to reduce per-item overhead']" next-chapter="/part-12-advanced/testing-and-debugging" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-debugging.html — QML Debugging
- https://doc.qt.io/qt-6/qtquick-profiling.html — QML Profiling
- https://doc.qt.io/qt-6/qtquick-performance.html — Qt Quick Performance
-->
