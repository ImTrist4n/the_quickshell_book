---
title: "Memory Optimization"
description: "Reduce memory usage in large Quickshell shells"
---

<ChapterMeta reading-time="12 min" :difficulty="3" :prerequisites="['Service Architecture', 'Lazy Loading']" you-will-learn="Techniques to reduce memory footprint of your QML shell" />

## The Problem

A shell with multiple panels, popups, and services can consume 500MB+ of RAM. Complex delegates, cached images, and service singletons accumulate over time. On low-end hardware, this causes swapping and sluggishness.

## The Naive Approach

Ignore memory usage:

```qml
Image { source: "large-background.jpg" } // 1920x1080, loaded once
// 20 more images across different panels
```

Each `Image` element loads a full-resolution version into GPU memory. On a 4K display, a single background can consume 32MB.

<MentalModel>

Think of memory like desk space. Each component you create takes up physical space on your desk. If you have too many things on your desk, you can't find anything. The solution: put rarely-used items in drawers (lazy loading), share tools (singletons), and throw away trash (garbage collection).

</MentalModel>

## Key Memory Optimization Techniques

### 1. Image Optimization

```qml
// Bad: loads full resolution
Image { source: "wallpaper.jpg"; width: 100; height: 80 }

// Good: loads at target resolution
Image { source: "image://thumbnail/wallpaper.jpg"; width: 100; height: 80 }

// Good: cache only what's visible
Image { source: visible ? "wallpaper.jpg" : "" }

// Good: release memory when hidden
Image {
  source: "wallpaper.jpg"
  sourceSize.width: width; sourceSize.height: height
}
```

### 2. Delegate Recycling

Use `ListView` with recycling instead of `Column` or `Grid`:

```qml
// Bad: creates delegates for all items
Column {
  Repeater { model: 1000; delegate: ItemDelegate {} }
}

// Good: recycles visible delegates only
ListView {
  model: 1000
  delegate: ItemDelegate {}
  // By default recycles delegates outside viewport
}
```

### 3. Component Reuse with Pooling

```qml
// ObjectPool.qml
QtObject {
  id: pool

  property var poolMap: ({})

  function acquire(type) {
    if (poolMap[type] && poolMap[type].length > 0) {
      return poolMap[type].pop()
    }
    return null
  }

  function release(type, obj) {
    if (!poolMap[type]) poolMap[type] = []
    obj.visible = false
    poolMap[type].push(obj)
  }

  function warmup(type, count, component) {
    poolMap[type] = []
    for (var i = 0; i < count; i++) {
      var obj = component.createObject(null)
      obj.visible = false
      poolMap[type].push(obj)
    }
  }
}
```

### 4. Service Lifecycle Management

Services that are never used should not consume memory:

```qml
// Lazily initialize services
QtObject {
  id: serviceRegistry

  property var _services: ({})

  function get(name) {
    if (!_services[name]) {
      _services[name] = createService(name)
    }
    return _services[name]
  }

  function unload(name) {
    if (_services[name]) {
      _services[name].destroy()
      delete _services[name]
    }
  }
}
```

### 5. Timer Cleanup

Timers that are no longer needed should be stopped:

```qml
PopupWindow {
  // Timer created only when popup is visible
  Timer {
    id: refreshTimer
    interval: 1000
    running: parent.visible
    repeat: true
  }

  onVisibleChanged: {
    if (!visible) refreshTimer.running = false
  }
}
```

## Measuring Memory

Use QML profiler and system tools:

```bash
# Watch memory of running shell
ps -o rss,pid -p $(pgrep quickshell)

# Monitor with top
top -p $(pgrep quickshell)
```

```qml
// In-shell memory display
Text {
  text: "Memory: " + memoryUsage.toFixed(0) + "MB"
  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: {
      Qt.process(["ps", "-o", "rss=", "-p", String(Qt.application.pid)])
        .onStdout.connect(function(data) {
          memoryUsage = parseInt(data.trim()) / 1024
        })
    }
  }
}
```

## Memory Comparison

| Technique | Before | After | Savings |
|-----------|--------|-------|---------|
| Lazy load 20 popups | 500MB | 120MB | 76% |
| Recycle ListView delegates | 400MB | 200MB | 50% |
| Unload unused services | 350MB | 180MB | 49% |
| Image sourceSize | 300MB | 150MB | 50% |

## Exercises

<ExerciseBlock :difficulty="1">
Add a memory profiler panel to your shell. Track memory usage over time. Identify the top 3 memory consumers. Optimize each one using the techniques above.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a service that unloads idle components. If a popup hasn't been opened in 5 minutes, unload its component tree. Reload when opened again.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build an image cache manager. Cache images asynchronously with configurable max cache size (e.g., 50MB). Evict least recently used images when the cache is full.
</ExerciseBlock>

<Recap :points="['Set sourceSize on Image elements to avoid full resolution loads', 'Use ListView with delegate recycling for large models', 'Use object pooling for frequently created/destroyed components', 'Unload unused services and components', 'Measure memory usage with ps and in-shell displays']" next-chapter="/part-12-advanced/performance-profiling" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-performance.html — Qt Quick Performance
- https://doc.qt.io/qt-6/qml-qtquick-image.html#sourceSize-prop — Image sourceSize
- https://doc.qt.io/qt-6/qml-qtquick-listview.html#cacheBuffer-prop — ListView recycling
-->
