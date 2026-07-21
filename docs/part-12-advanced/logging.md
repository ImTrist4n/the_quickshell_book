---
title: "Logging"
description: "Structured logging for debugging and monitoring your Quickshell shell"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['JavaScript basics']" you-will-learn="How to log effectively from QML and C++ components" />

## The Problem

Your shell crashes or behaves unexpectedly. Without logging, debugging means adding `console.log()` statements, reproducing the issue, and hoping for useful output. With structured logging, you can trace the exact sequence of events leading to the crash.

## The Naive Approach

Spread `console.log()` everywhere:

```qml
console.log("Button clicked")
console.log("Service connected:", serviceName)
console.log("Timer fired")
```

These messages are unstructured, untagged, and hard to filter.

<MentalModel>

Think of logging as a flight recorder. Every significant event is recorded with a timestamp and context. After a crash, you replay the tape to see exactly what happened. Without the recorder, you're guessing.

</MentalModel>

## The Idea

Create a logging utility with levels (DEBUG, INFO, WARN, ERROR) and categories (SERVICE, UI, NETWORK, SYSTEM). Each log entry includes a timestamp, level, category, and message. Write logs to a file for post-mortem analysis.

## Let's Build It

```qml
// Logger.qml
pragma Singleton
import Quickshell
import QtQuick

QtObject {
  id: logger

  // Log levels
  readonly property int DEBUG: 0
  readonly property int INFO: 1
  readonly property int WARN: 2
  readonly property int ERROR: 3

  property int logLevel: INFO
  property string logFile: Quickshell.statePath("shell.log")
  property var logHistory: []

  function log(level, category, message, data) {
    if (level < logLevel) return

    var entry = {
      timestamp: new Date().toISOString(),
      level: ["DEBUG", "INFO", "WARN", "ERROR"][level],
      category: category,
      message: message,
      data: data || null
    }

    logHistory.push(entry)
    if (logHistory.length > 1000) logHistory.shift()

    var formatted = "[" + entry.timestamp + "] [" + entry.level + "] [" + category + "] " + message
    console.log(formatted)

    writeToFile(formatted)
  }

  function debug(category, message, data) { log(DEBUG, category, message, data) }
  function info(category, message, data) { log(INFO, category, message, data) }
  function warn(category, message, data) { log(WARN, category, message, data) }
  function error(category, message, data) { log(ERROR, category, message, data) }

  function writeToFile(text) {
    Qt.process(["bash", "-c", "echo '" + text.replace(/'/g, "'\\''") + "' >> " + logFile])
  }

  function exportHistory() {
    return JSON.stringify(logHistory, null, 2)
  }

  function clear() {
    logHistory = []
  }
}
```

### Using the Logger

```qml
Logger.info("SERVICE", "Audio service connected")
Logger.warn("UI", "Window positioning failed", { x: 100, y: -1 })
Logger.error("NETWORK", "HTTP request failed: " + errorMessage, { url: url, statusCode: statusCode })
```

### Log Viewer Integrated into Shell

```qml
// LogViewer.qml
PopupWindow {
  width: 600; height: 400
  visible: false

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors.fill: parent; spacing: 4

      Row {
        width: parent.width; height: 30
        spacing: 8
        Repeater {
          model: ["ALL", "DEBUG", "INFO", "WARN", "ERROR"]
          Rectangle {
            width: 60; height: 24; radius: 4; color: "#313244"
            Text { anchors.centerIn: parent; text: modelData; color: "#cdd6f4"; font.pixelSize: 11 }
            MouseArea { anchors.fill: parent; onClicked: filterLevel = modelData }
          }
        }
      }

      ListView {
        width: parent.width; height: parent.height - 40
        model: Logger.logHistory
        delegate: Rectangle {
          required property var modelData
          width: parent.width; height: 20; color: modelData.level === "ERROR" ? "#450000" : "#1e1e2e"
          Text {
            x: 8
            text: "[" + modelData.timestamp.slice(11, 19) + "] [" + modelData.level + "] " + modelData.message
            color: modelData.level === "ERROR" ? "#f38ba8" : modelData.level === "WARN" ? "#fab387" : "#a6adc8"
            font.pixelSize: 11
            font.family: "monospace"
          }
        }
      }
    }
  }
}
```

## Structured Logging with C++

For C++ modules, use Qt's logging categories:

```cpp
#include <QLoggingCategory>

Q_LOGGING_CATEGORY(shellService, "quickshell.service")
Q_LOGGING_CATEGORY(shellUI, "quickshell.ui")
Q_LOGGING_CATEGORY(shellNetwork, "quickshell.network")

void connectToServer() {
  qCDebug(shellService) << "Connecting to server...";
  qCInfo(shellNetwork) << "Network request to" << url;
  qCWarning(shellUI) << "Window position out of bounds";
  qCCritical(shellService) << "Connection failed:" << error;
}
```

Enable categories with environment variable:

```bash
QT_LOGGING_RULES="quickshell.service=true;quickshell.ui=false"
```

## Exercises

<ExerciseBlock :difficulty="1">
Add a "Copy Logs" button to the log viewer that copies the last 100 log entries to the clipboard. Use a keyboard shortcut (Ctrl+Shift+C) as an alternative trigger.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement log rotation. Keep the last 3 log files: `shell.log`, `shell.log.1`, `shell.log.2`. Rotate when the file exceeds 1MB. Write a function that queries the file size before appending.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a remote log viewer. Send log entries via UDP to a network listener. Create a companion application that displays logs from multiple shell instances in real-time.
</ExerciseBlock>

<Recap :points="['Use a structured logger with levels (DEBUG/INFO/WARN/ERROR) and categories', 'Redirect QML console.log to persistent log files in Quickshell.statePath()', 'Build an in-shell log viewer for debugging without external tools', 'Use QLoggingCategory for C++ modules']" next-chapter="/part-12-advanced/memory-optimization" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qloggingcategory.html — QLoggingCategory
- https://doc.qt.io/qt-6/qtlogging.html — Qt Logging
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.statePath()
-->
