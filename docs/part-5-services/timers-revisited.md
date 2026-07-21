---
title: "Timers Revisited"
description: "Advanced timer patterns for polling, debouncing, and scheduled updates"
---

# Timers Revisited

## The Problem

Basic `Timer` usage (set interval, start, repeat) covers simple cases. But real shells need sophisticated timing: debounce rapid input, chain timers sequentially, throttle expensive operations, and synchronize multiple update intervals. The naive single-timer approach breaks under these demands.

## The Naive Approach

Multiple independent timers each polling their own data source:

```qml
Timer { interval: 1000; onTriggered: updateClock() }      // clock
Timer { interval: 5000; onTriggered: updateCpu() }        // CPU
Timer { interval: 30000; onTriggered: updateWeather() }   // weather
```

Each timer wakes up independently, potentially causing N UI updates per second where one would suffice.

<MentalModel>

Multiple timers are like multiple alarm clocks in the same room. They all ring at different times, waking you up constantly. A unified scheduler is a single clock with multiple checkpoints — it rings once and tells you everything you need to do.

</MentalModel>

## The Idea

Consolidate all periodic updates into a single heartbeat timer that delegates to different updaters based on elapsed time thresholds. Use debounce timers for input events and sequential timers for multi-step animations or staggered updates.

## Let's Build It

<BuildIt>

```qml
import Quickshell
import QtQuick
import QtQuick.Layouts

Item {
  id: root

  property int cpuUsage: 0
  property int memUsage: 0
  property int diskUsage: 0
  property int batteryPercent: 0

  // Unified heartbeat — fires every second
  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: {
      var tick = root.TickCounter++
      // Every second: clock only
      updateClock()

      // Every 5 seconds: CPU + memory
      if (tick % 5 === 0) {
        updateCpu()
        updateMemory()
      }

      // Every 30 seconds: disk
      if (tick % 30 === 0) updateDisk()

      // Every 60 seconds: battery
      if (tick % 60 === 0) updateBattery()
    }
  }

  property int TickCounter: 0

  function updateClock() {
    clockText.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
  }

  function updateCpu() { /* process call */ }
  function updateMemory() { /* process call */ }
  function updateDisk() { /* process call */ }
  function updateBattery() { /* process call */ }

  RowLayout {
    anchors { fill: parent; margins: 8 }
    Text { id: clockText; color: "#c0caf5"; font.pixelSize: 14 }
  }
}
```

</BuildIt>

## Let's Improve It

### Debounce Timer

Delay an action until after a pause in activity — perfect for search inputs or resize handlers:

```qml
Item {
  property string searchText: ""

  Timer {
    id: debounceTimer
    interval: 300
    onTriggered: performSearch(searchText)
  }

  onSearchTextChanged: {
    debounceTimer.restart() // Reset the 300ms delay on each keystroke
  }

  function performSearch(query) {
    console.log("Searching for:", query)
  }
}
```

### Sequential Timer Chain

Run timers one after another for staggered animations or progressive loading:

```qml
Item {
  Timer {
    id: step1
    interval: 1000
    onTriggered: {
      console.log("Step 1")
      step2.start()
    }
  }

  Timer {
    id: step2
    interval: 1500
    onTriggered: {
      console.log("Step 2")
      step3.start()
    }
  }

  Timer {
    id: step3
    interval: 2000
    onTriggered: console.log("Step 3 — done")
  }

  function startChain() {
    step1.start()
  }
}
```

### Throttle Timer

Ensure an expensive operation runs at most once per interval, even if triggered frequently:

```qml
Item {
  Timer {
    id: throttleTimer
    interval: 1000
    onTriggered: {
      flushPendingUpdates()
      ready = true
    }
  }

  property bool ready: true

  function requestUpdate() {
    if (ready) {
      ready = false
      throttleTimer.start()
    }
  }

  function flushPendingUpdates() {
    // Aggregate and process all pending changes
  }
}
```

<CommonMistake>

**Timer drift accumulation.** Using `interval: 1000` with `repeat: true` does not guarantee exactly-once-per-second. The timer fires when the event loop gets to it. For precise intervals, calculate the next tick from the current system time rather than relying on counter increments.

**Not resetting debounce timers.** A debounce timer must call `restart()` instead of `start()` on each trigger event. `start()` does nothing if the timer is already running; `restart()` always resets the interval.

**Stopping timers incorrectly.** Calling `stop()` on a one-shot timer before it fires is fine. Calling `stop()` on a repeating timer stops all future ticks. Use `running = false` for property-binding-based control.

</CommonMistake>

## Under the Hood

Each `Timer` creates a `QTimer` in Qt's event loop. The minimum effective interval is ~1ms, but practical reliability starts at ~16ms (60fps cadence). Qt timers are coalesced by the OS — the actual firing time depends on event loop pressure. For sub-millisecond precision, you need a hardware timer or real-time thread, which QML cannot provide.

<UnderTheHood>

When you set `interval: 5000`, `QTimer` calls `startTimer(5000, Qt::CoarseTimer)` by default. Qt uses a timing wheel data structure internally to manage thousands of timers efficiently — O(1) insertion and removal, O(n) dispatch. The timer event is delivered through the normal event loop, meaning slow bindings or JavaScript execution can delay subsequent ticks.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Build a debounced search widget: a `TextField` that waits 400ms after the user stops typing before printing the query to the console.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a heartbeat-driven system monitor that polls CPU every 2 seconds, memory every 5 seconds, and disk every 30 seconds using a single timer with modulus-based dispatch.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a Pomodoro timer with work (25min), short break (5min), and long break (15min) phases using a chain of sequential timers. Display the remaining time in MM:SS format.
</ExerciseBlock>

<Recap :points="['Consolidate periodic updates into a single heartbeat timer with modulus dispatch', 'Use debounce timers (restart on each trigger) for input events', 'Chain timers sequentially for multi-step workflows', 'Throttle timers ensure at-most-once-per-interval execution', 'Timer accuracy depends on event loop pressure — not real-time']" next-chapter="/part-5-services/http-requests-and-caching" />

<!-- Sources verified -->
