---
title: "Testing and Debugging"
description: "Systematic testing and debugging approaches for Quickshell shells"
---

<ChapterMeta reading-time="12 min" :difficulty="3" :prerequisites="['Logging', 'Qt Quick basics']" you-will-learn="How to test QML components and debug common issues" />

## The Problem

Shells are complex UIs with many interacting components. A change to one panel can break another. Without tests, regressions go unnoticed until users report them. Debugging without tools is painful.

## The Naive Approach

Manual testing:

```bash
# Change code, restart shell, hope it works
quickshell -c ~/.config/quickshell/shell.qml
```

Manual testing is slow, inconsistent, and doesn't scale. You can't manually test every state of every component after each change.

<MentalModel>

Think of testing as a safety net for a tightrope walker. You could walk without it (if you're confident). But one wrong step and you fall. The net catches you so you can try again. Tests catch regressions before they reach users.

</MentalModel>

## Testing Approaches

### 1. Unit Testing with Qt Test (C++)

For C++ modules, use Qt Test:

```cpp
#include <QtTest>
#include "AudioService.h"

class TestAudioService : public QObject {
  Q_OBJECT

private slots:
  void testVolumeRange() {
    AudioService service;
    service.setVolume(50);
    QCOMPARE(service.volume(), 50);

    service.setVolume(150);
    QVERIFY(service.volume() <= 100); // Clamped
  }

  void testMuteToggle() {
    AudioService service;
    service.setMuted(true);
    QVERIFY(service.isMuted());
    service.toggleMute();
    QVERIFY(!service.isMuted());
  }
};

QTEST_MAIN(TestAudioService)
```

### 2. QML Component Testing

Use `qmltestrunner` with Qt Quick Test:

```qml
// tst_clock.qml
import QtQuick
import QtTest
import "../components"

Item {
  id: root
  width: 200; height: 50

  ClockWidget { id: clock }

  TestCase {
    name: "ClockWidget Tests"
    when: windowShown

    function test_clock_format() {
      // Clock should display time in HH:MM format
      var timeText = clock.text
      verify(/^\d{2}:\d{2}$/.test(timeText),
        "Clock should match HH:MM format, got: " + timeText)
    }

    function test_clock_updates() {
      var before = clock.text
      wait(1000) // Wait for 1 second
      var after = clock.text
      verify(before !== after,
        "Clock should update every second")
    }
  }
}
```

Run tests:

```bash
qmltestrunner -input tests/
```

### 3. Service Mocking

For testing components that depend on services, create mock services:

```qml
// MockAudioService.qml
pragma Singleton
import QtQuick

QtObject {
  property int volume: 50
  property bool muted: false
  property string defaultSink: "alsa_output.pci-0000_00_1f.3.analog-stereo"

  function setVolume(v) { volume = Math.max(0, Math.min(100, v)) }
  function toggleMute() { muted = !muted }
  function setDefaultSink(s) { defaultSink = s }
}
```

Use the mock by changing the import path:

```bash
QML2_IMPORT_PATH=mocks:$QML2_IMPORT_PATH qmltestrunner -input tests/
```

## Debugging Techniques

### 1. Visual Debug Overlay

```qml
// DebugOverlay.qml
Rectangle {
  id: debugOverlay
  visible: false
  anchors.fill: parent; color: "#00000080"

  property var selectedItem: null

  Rectangle {
    x: 8; y: 8; width: 400; height: 300; radius: 8; color: "#1e1e2e"
    Column {
      anchors.fill: parent; margins: 12; spacing: 4
      Text { text: "Debug Inspector"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }
      Text { id: infoText; color: "#a6adc8"; font.pixelSize: 11; font.family: "monospace" }

      Row { spacing: 8
        Button { text: "Inspect"; onClicked: enableInspector() }
        Button { text: "Reload"; onClicked: reloadShell() }
        Button { text: "Close"; onClicked: debugOverlay.visible = false }
      }
    }
  }

  function enableInspector() {
    // Highlight items on click
    infoText.text = "Click on any element to inspect"
  }

  function reloadShell() {
    // Reload QML without restarting
    // This is compositor-dependent
    infoText.text = "Reload requested"
  }
}

// Toggle with F12
Item { Shortcut { sequence: "F12"; onActivated: debugOverlay.visible = !debugOverlay.visible } }
```

### 2. Property Watch

```qml
// PropertyWatcher.qml
QtObject {
  id: watcher

  property var watched: ({})

  function watch(obj, propertyName) {
    var key = obj.toString() + "." + propertyName
    watched[key] = obj
    var getter = obj[propertyName]
    obj[propertyName + "Changed"].connect(function() {
      console.log("Property changed: " + propertyName + " = " + obj[propertyName])
      logToFile(key + " = " + obj[propertyName])
    })
  }
}
```

### 3. Error Boundaries

Wrap components that might crash:

```qml
// ErrorBoundary.qml
Item {
  id: boundary

  property Component content: null
  property string fallbackMessage: "An error occurred"

  Loader {
    id: contentLoader
    anchors.fill: parent
    sourceComponent: boundary.content
    onStatusChanged: {
      if (status === Loader.Error) {
        console.error("Error boundary caught:", contentLoader.errorString())
        errorOverlay.visible = true
      }
    }
  }

  Rectangle {
    id: errorOverlay
    anchors.fill: parent; color: "#450000"; visible: false; radius: 8
    Text { anchors.centerIn: parent; text: boundary.fallbackMessage; color: "#f38ba8" }
  }
}
```

## Exercises

<ExerciseBlock :difficulty="1">
Write a unit test for your AudioService. Test volume clamping (0-100), mute toggle, and default sink. Use Qt Test C++ framework. Run with `qmltestrunner`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a mock WeatherService. Simulate API responses: sunny, rainy, error (network failure). Test your WeatherWidget with each mock response. Verify the UI shows the correct icon and message.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a visual regression test suite. Use `qtquick-compiler` to capture screenshots of each panel. Compare with baseline images on each build. Fail the build if screenshots differ by more than 1% pixels.
</ExerciseBlock>

<Recap :points="['Use Qt Test (C++) and qmltestrunner (QML) for unit testing', 'Create mock services to test components in isolation', 'Build debug overlay with inspector and reload capability', 'Use error boundaries to handle component crashes gracefully']" next-chapter="/part-13-source-tour/architecture-overview" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-test.html — Qt Quick Test
- https://doc.qt.io/qt-6/qttest-index.html — Qt Test
- https://doc.qt.io/qt-6/qtquick-debugging.html — QML Debugging
-->
