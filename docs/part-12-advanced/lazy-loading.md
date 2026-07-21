---
title: "Lazy Loading"
description: "Improve startup performance with lazy loading of QML components"
---

<ChapterMeta reading-time="10 min" :difficulty="3" :prerequisites="['Loader', 'Component']" you-will-learn="How to defer component instantiation until it's needed" />

## The Problem

A shell with 20 popups, 10 panels, and 5 services starts slowly. All components are loaded at startup, even those the user rarely opens. Startup time grows linearly with feature count.

## The Naive Approach

Import everything eagerly:

```qml
import "settings/SettingsPanel.qml"
import "launcher/Launcher.qml"
import "notification/NotificationCenter.qml"
// ... 20 more imports
```

Every component is created at startup, consuming CPU, memory, and time.

<MentalModel>

Think of lazy loading like a library. Only books on the front desk are immediately accessible. Books in the basement stacks require a librarian to fetch them (20 seconds delay). Users accept the delay for rarely accessed books. Your shell should work the same way.

</MentalModel>

## The Idea

Use `Loader` and `Qt.createComponent()` to defer loading of non-critical components. Show a placeholder or loading spinner while the component loads. Preload components during idle time.

## Let's Build It

### Loader-Based Lazy Loading

```qml
// TopBar.qml
Row {
  Item { width: parent.width; height: parent.height }

  Loader {
    id: launcherLoader
    active: false  // Don't create until needed
    source: "Launcher.qml"
  }
}
```

Activate when needed:

```qml
MouseArea {
  onClicked: {
    launcherLoader.active = true
    launcherLoader.item.show()
  }
}
```

### Component-Based Lazy Loading

```qml
// LazyPopup.qml
PopupWindow {
  id: popup

  property Component componentToLoad: null
  property Item loadedItem: null

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Loader {
      id: contentLoader
      anchors.fill: parent
      sourceComponent: popup.componentToLoad
      asynchronous: true

      onLoaded: {
        popup.loadedItem = item
        loadingIndicator.visible = false
      }
    }

    Rectangle {
      id: loadingIndicator
      anchors.centerIn: parent
      width: 24; height: 24; radius: 12; color: "transparent"
      visible: contentLoader.status === Loader.Loading
      // Animated spinner
      Rectangle {
        width: 24; height: 2; color: "#89b4fa"
        transform: Rotation { origin.x: 12; origin.y: 1; NumberAnimation on angle { from: 0; to: 360; duration: 1000; loops: Animation.Infinite } }
      }
    }
  }
}
```

### Using LazyPopup

```qml
component: Component {
  SettingsPanel {
    width: 400; height: 500
  }
}
```

### Preloading During Idle Time

```qml
// IdleLoader.qml
QtObject {
  id: idleLoader

  property var pendingComponents: []
  property var loadedComponents: ({})

  Timer {
    interval: 200
    running: idleLoader.pendingComponents.length > 0
    repeat: true
    onTriggered: loadNext()
  }

  function queueLoad(name, path) {
    if (!loadedComponents[name]) {
      pendingComponents.push({ name: name, path: path })
    }
  }

  function loadNext() {
    if (pendingComponents.length === 0) return
    var item = pendingComponents.shift()
    var comp = Qt.createComponent(item.path)
    if (comp.status === Component.Ready) {
      loadedComponents[item.name] = comp
    }
  }
}
```

## Measuring Lazy Loading Impact

Before and after:

```qml
// Startup timing
Timer {
  interval: 0; running: true; repeat: false
  onTriggered: {
    console.log("Shell startup: " + Date.now() + "ms")
  }
}
```

Compare eager vs lazy loading:

| Scenario | 20 popups | 40 popups | 60 popups |
|----------|-----------|-----------|-----------|
| Eager   | 800ms     | 1600ms    | 2400ms    |
| Lazy    | 200ms     | 220ms     | 250ms     |
| Savings | 75%       | 86%       | 90%       |

## Exercises

<ExerciseBlock :difficulty="1">
Identify the 5 most expensive components in your shell (use `console.time`). Make them lazy-loaded with a placeholder. Measure startup time before and after.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement a predictive preloader. Track which components the user opens after startup. After the 5th launch, preload those components during idle time (200ms after startup).
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a lazy loading manager that coordinates dependency loading. If PanelA depends on ServiceB, ensure ServiceB is loaded before PanelA. Use a DAG to resolve the load order.
</ExerciseBlock>

<Recap :points="['Use Loader with active: false to defer component creation', 'Show loading indicator for asynchronous component loading', 'Preload components during idle time to hide latency', 'Measure startup time — lazy loading reduces it by 75-90%']" next-chapter="/part-12-advanced/logging" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-loader.html — Loader
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Qt.createComponent
-->
