---
title: "Custom Modules"
description: "Creating custom Quickshell modules in C++ and QML"
---

<ChapterMeta reading-time="14 min" :difficulty="4" :prerequisites="['QML Extensions', 'C++ basics']" you-will-learn="How to create reusable QML modules for Quickshell" />

## The Problem

As your shell grows, you'll create reusable components that you want to share across projects. Without a module system, sharing means copying files. Modules provide versioned, importable packages.

## The Naive Approach

Copy files between projects:

```bash
cp ~/project1/widgets/WeatherWidget.qml ~/project2/widgets/
```

When you fix a bug in one project, you must remember to copy the fix to all other projects that use the same component.

<MentalModel>

Think of a module as a published book. You don't hand-copy pages from one book to another. You reference the book by title (import statement). When the author publishes a new edition (version update), all readers get the update automatically.

</MentalModel>

## The Idea

Create a QML module directory with a `qmldir` file that declares types, versions, and dependencies. The module can be imported from any Quickshell config by adding it to the `QML2_IMPORT_PATH`.

## Let's Build It

### Module Structure

```
quickshell-widgets/
  qmldir
  CpuWidget.qml
  MemoryWidget.qml
  ClockWidget.qml
  BatteryWidget.qml
```

### The qmldir File

```qml
// qmldir
module org.quickshell.widgets 1.0
CpuWidget 1.0 CpuWidget.qml
MemoryWidget 1.0 MemoryWidget.qml
ClockWidget 1.0 ClockWidget.qml
BatteryWidget 1.0 BatteryWidget.qml
```

### Module Components

```qml
// CpuWidget.qml — part of the module
import QtQuick
import Quickshell.Services.Hardware

Item {
  property bool showLabel: true
  property color barColor: "#89b4fa"

  width: 120; height: 24

  Row {
    spacing: 6
    Text { text: showLabel ? "CPU:" : ""; color: "#cdd6f4"; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }

    Rectangle { width: 80; height: 8; radius: 4; color: "#313244"; anchors.verticalCenter: parent.verticalCenter
      Rectangle {
        width: parent.width * (CpuService.usagePercent / 100)
        height: 8; radius: 4
        color: barColor
        Behavior on width { NumberAnimation { duration: 200 } }
      }
    }

    Text { text: CpuService.usagePercent.toFixed(0) + "%"; color: "#a6adc8"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
  }
}
```

### Using the Module

```bash
export QML2_IMPORT_PATH=/path/to/quickshell-widgets:$QML2_IMPORT_PATH
quickshell
```

```qml
// shell.qml
import org.quickshell.widgets 1.0

Row {
  CpuWidget { barColor: "#f38ba8" }
  MemoryWidget { showLabel: true }
  ClockWidget {}
}
```

<BuildIt>

The module system uses a `qmldir` file to register QML types. Types are versioned and importable by name. Multiple configs can share the same module installation.

</BuildIt>

## Module with C++ Plugin

For modules that need C++ types, create a QML extension plugin:

```cmake
# CMakeLists.txt
find_package(Qt6 REQUIRED COMPONENTS Core Qml Quick)
qt_add_qml_module(quickshell-stats
  URI org.quickshell.stats
  VERSION 1.0
  QML_FILES GpuWidget.qml
  SOURCES
    GpuStats.cpp GpuStats.h
)
```

The `qt_add_qml_module` macro automatically generates the `qmldir` file and registers the C++ types.

## Publishing Modules

Share your module on:

- **GitHub** — tag releases with version numbers
- **AUR** — package as `quickshell-{module-name}`
- **Nixpkgs** — add a derivation

Users install and set `QML2_IMPORT_PATH`:

```bash
# ~/.bashrc
export QML2_IMPORT_PATH=$HOME/.local/share/quickshell/modules:$QML2_IMPORT_PATH
```

## Exercises

<ExerciseBlock :difficulty="1">
Create a module called `org.quickshell.theme` that exports a `Theme` singleton with colors, spacing, and typography. Import it in your shell and use it in all components.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Write a C++ module that exposes a `FileSearcher` type. The type has an `search(path, pattern)` method that uses `QDirIterator` for fast recursive file searching. Register it as a module.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Publish your module to GitHub. Add a `README.md` with installation instructions, a `LICENSE` file, and a version tag. Create an AUR package if you use Arch Linux.
</ExerciseBlock>

<Recap :points="['QML modules use a qmldir file to register types with versions', 'Import via module URI: import org.quickshell.widgets 1.0', 'Share modules via QML2_IMPORT_PATH environment variable', 'Use qt_add_qml_module for C++ plugin modules']" next-chapter="/part-12-advanced/lazy-loading" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-modules-qmldir.html — qmldir files
- https://doc.qt.io/qt-6/qtqml-modules-cppplugins.html — C++ QML plugins
- https://doc.qt.io/qt-6/qt-add-qml-module.html — qt_add_qml_module
-->
