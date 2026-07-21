---
title: "Timers"
description: "Scheduled and repeating actions with QML Timer"
---

<ChapterMeta reading-time="5 min" :difficulty="2" :prerequisites="['Signals']" you-will-build="A live clock with configurable update intervals" />

## The Problem

A desktop shell needs scheduled actions: update the clock every second, poll the battery status every 30 seconds, auto-dismiss notifications after 5 seconds, refresh the weather every 15 minutes. These are **timed events** — actions that run after a delay, on an interval, or both.

## The Naive Approach

You could use `setInterval` from JavaScript:

```qml
property var timerId: 0

Component.onCompleted: {
  timerId = setInterval(function() {
    clock.text = new Date().toLocaleTimeString()
  }, 1000)
}
```

This works but has drawbacks: `setInterval` runs in the JavaScript engine and can drift over time. It's also not declarative — you can't express "update every second" as part of your UI description.

<MentalModel>

A `Timer` is like an egg timer. You set the interval, decide whether it repeats, and tell it what to do when it rings. Start it, and it ticks away independently, ringing on schedule regardless of what else is happening.

</MentalModel>

## The Idea

`Timer` is a QML type that fires a `triggered` signal after a specified `interval`. It can fire once (`repeat: false`) or repeatedly (`repeat: true`). Start it with `running: true` or call `start()` / `stop()`.

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 350
  visible: true
  title: "Timers"

  property int secondsElapsed: 0

  Column {
    anchors.centerIn: parent
    spacing: 20

    // 1. Live clock — updates every second
    Column {
      spacing: 4
      anchors.horizontalCenter: parent.horizontalCenter

      Text {
        text: "Live Clock"
        font.pixelSize: 12
        color: "#888"
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: clock
        text: new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        font.pixelSize: 36
        font.bold: true
        color: "#1a56db"
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: dateLabel
        text: new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat)
        font.pixelSize: 14
        color: "#888"
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
          var now = new Date()
          clock.text = now.toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
          dateLabel.text = now.toLocaleDateString(Qt.locale(), Locale.LongFormat)
        }
      }
    }

    // 2. Countdown
    Column {
      spacing: 8
      anchors.horizontalCenter: parent.horizontalCenter

      Text {
        text: "Countdown"
        font.pixelSize: 12
        color: "#888"
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        id: countdown
        text: "5"
        font.pixelSize: 28
        font.bold: true
        color: "#ff6b6b"
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Rectangle {
        width: 120; height: 36; radius: 6
        color: countdownTimer.running ? "#ccc" : "#4ecdc4"
        anchors.horizontalCenter: parent.horizontalCenter

        Text {
          text: countdownTimer.running ? "Running..." : "Start"
          anchors.centerIn: parent
          color: countdownTimer.running ? "#888" : "white"
          font.pixelSize: 14; font.bold: true
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            if (!countdownTimer.running) {
              countdown.text = "5"
              countdownTimer.start()
            }
          }
        }

        Timer {
          id: countdownTimer
          interval: 1000
          repeat: true

          onTriggered: {
            var val = parseInt(countdown.text) - 1
            countdown.text = String(val)
            if (val <= 0) {
              stop()
              countdown.text = "Go!"
            }
          }
        }
      }
    }

    // 3. One-shot delayed action
    Text {
      id: delayedMessage
      text: "Click to schedule a message"
      color: "#888"
      font.pixelSize: 13
      anchors.horizontalCenter: parent.horizontalCenter

      Timer {
        id: delayTimer
        interval: 2000
        onTriggered: {
          delayedMessage.text = "⏰ 2 seconds later..."
          delayedMessage.color = "#4ecdc4"
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          delayedMessage.text = "⏳ Waiting 2s..."
          delayedMessage.color = "#888"
          delayTimer.start()
        }
      }
    }
  }
}
```

<BuildIt>

Timer patterns:

- **`interval: 1000; running: true; repeat: true`** — fires every second. The clock updates on each tick.
- **`countdownTimer.start()`** — programmatic start. The `repeat: true` timer ticks until `stop()` is called.
- **One-shot** — `repeat: false` (default). Fires once after the interval, then stops automatically.

</BuildIt>

## Let's Improve It

For better performance, especially with many timers, consolidate updates into a single timer:

```qml
Timer {
  interval: 1000
  running: true
  repeat: true
  onTriggered: {
    // Single tick updates everything
    clock.text = formatTime()
    batteryWidget.checkStatus()
    weatherWidget.refreshIfStale()
  }
}
```

This is more efficient than 3 separate timers all waking up at slightly different times.

<CommonMistake>

**Timer drift.** A `Timer` with `interval: 1000` fires approximately every second, but JavaScript execution and event loop load can cause drift. Over an hour, a clock driven by `new Date()` every tick will be accurate (it reads the actual time each tick), but a counter (`count++`) will drift. Always read the actual system time for clocks and countdowns.

**Not stopping timers.** If you create a `Timer` that runs forever without a stop condition, it keeps firing even if the component is not visible. Use `running: visible` or stop timers in `Component.onDestruction` for components that are created and destroyed dynamically.

**Setting `interval` too low.** QML timers are not real-time. An `interval` below ~16ms (60fps) won't be reliable. For frame-rate-driven animations, use the animation framework instead.

</CommonMistake>

## Under the Hood

`Timer` is a `QQuickTimer` wrapping `QTimer` from Qt Core. Each timer creates a system timer that fires on the Qt event loop. Accuracy depends on the OS and event loop load — typical accuracy is within 1–15ms of the requested interval for intervals above 50ms.

For intervals below 50ms, Qt uses `QElapsedTimer` internally and adjusts for drift, but the event loop's minimum resolution becomes the limiting factor.

## Exercises

<ExerciseBlock :difficulty="1">Create a stopwatch with Start, Stop, and Reset buttons using Timer with interval: 10 (for 100Hz updates).</ExerciseBlock>
<ExerciseBlock :difficulty="2">Build a typing idle-detector: a TextInput where a Timer resets every time you type. If you stop typing for 2 seconds, display "User idle" above the input.</ExerciseBlock>
<ExerciseBlock :difficulty="3">Create a session timer (Pomodoro-style) with 25-minute work and 5-minute break intervals. Use two timers that chain: when the work timer fires, start the break timer and vice versa.</ExerciseBlock>

<Recap :points="['Timer fires a triggered signal after a specified interval', 'repeat: true for repeating timers, repeat: false (default) for one-shot', 'Use start(), stop(), and restart() for programmatic control', 'Consolidate periodic updates into a single timer for efficiency']" next-chapter="/part-1-qml/project-calculator" />
