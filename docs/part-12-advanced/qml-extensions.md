---
title: "QML Extensions"
description: "Extending QML with custom C++ types and JavaScript modules"
---

<ChapterMeta reading-time="14 min" :difficulty="4" :prerequisites="['D-Bus integration', 'C++ basics']" you-will-learn="How to write C++ extensions for Quickshell" />

## The Problem

QML and JavaScript can't access everything. File system watching, low-level hardware access, cryptographic hashing, native HTTP requests with custom headers — these require C++. Every time you hit QML's limits, you'd need to either shell out to a CLI tool or write a C++ plugin.

## The Naive Approach

Shell out for everything:

```qml
Qt.process(["sha256sum", filePath]).onStdout.connect(function(data) {
  var hash = data.split(" ")[0]
})
```

Every command spawns a process, parses stdout, and runs synchronously for the duration. For a file hash, this is microseconds. For a complex operation, it adds up.

<MentalModel>

Think of QML extensions like adding new tools to your toolbox. QML gives you a hammer, screwdriver, and measuring tape (basic UI primitives). C++ plugins add a power drill, circular saw, and laser level (advanced capabilities). You can build anything with the basic tools, but the power tools are faster.

</MentalModel>

## When to Extend

| Need | Solution |
|---|---|
| Simple transformation | JavaScript utility |
| Complex calculation | JavaScript utility |
| File I/O | `Qt.open()` / `Qt.writeFile()` |
| Network request | `Qt.process(["curl", ...])` |
| Hardware access | C++ plugin |
| System call | `Qt.process()` |
| Performance-critical loop | C++ plugin |
| Native UI integration | C++ plugin |

## Creating a C++ Plugin

Quickshell supports Qt's QML extension system. Create a shared library that registers C++ types with the QML engine.

```cpp
// FileHasher.h
#pragma once
#include <QObject>
#include <QCryptographicHash>

class FileHasher : public QObject {
  Q_OBJECT
  Q_PROPERTY(QString lastHash READ lastHash NOTIFY hashChanged)

public:
  explicit FileHasher(QObject *parent = nullptr);
  QString lastHash() const;

  Q_INVOKABLE QString sha256(const QString &filePath);
  Q_INVOKABLE QString md5(const QString &filePath);

signals:
  void hashChanged(const QString &hash);

private:
  QString m_lastHash;
};
```

```cpp
// FileHasher.cpp
#include "FileHasher.h"
#include <QFile>
#include <QFileInfo>

FileHasher::FileHasher(QObject *parent) : QObject(parent) {}

QString FileHasher::lastHash() const { return m_lastHash; }

QString FileHasher::sha256(const QString &filePath) {
  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly)) return "";
  QCryptographicHash hash(QCryptographicHash::Sha256);
  hash.addData(&file);
  m_lastHash = hash.result().toHex();
  emit hashChanged(m_lastHash);
  return m_lastHash;
}

QString FileHasher::md5(const QString &filePath) {
  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly)) return "";
  QCryptographicHash hash(QCryptographicHash::Md5);
  hash.addData(&file);
  m_lastHash = hash.result().toHex();
  emit hashChanged(m_lastHash);
  return m_lastHash;
}
```

Register the type in your plugin entry point:

```cpp
// Plugin.cpp
#include <QQmlEngine>
#include <qqmlextensionplugin.h>
#include "FileHasher.h"

class QuickshellExtensionsPlugin : public QQmlEngineExtensionPlugin {
  Q_OBJECT
  Q_PLUGIN_METADATA(IID QQmlEngineExtensionPlugin_iid)

public:
  void initializeEngine(QQmlEngine *engine, const char *uri) override {
    Q_UNUSED(engine)
    Q_UNUSED(uri)
  }

  void registerTypes(const char *uri) override {
    qmlRegisterType<FileHasher>(uri, 1, 0, "FileHasher");
  }
};

#include "Plugin.moc"
```

Build with CMake:

```cmake
cmake_minimum_required(VERSION 3.16)
project(quickshell-extensions)

find_package(Qt6 REQUIRED COMPONENTS Core Qml)

qt_add_library(quickshell-extensions SHARED
  Plugin.cpp FileHasher.cpp FileHasher.h
)

target_link_libraries(quickshell-extensions PRIVATE
  Qt6::Core Qt6::Qml
)

qt_generate_qml_plugin_import(quickshell-extensions)
```

Use in QML:

```qml
import quickshell.extensions 1.0

FileHasher {
  id: hasher
}

Text { text: "SHA256: " + hasher.sha256("/path/to/file") }
```

<BuildIt>

C++ plugins extend Quickshell with native performance. The `FileHasher` example uses Qt's `QCryptographicHash` to compute file hashes without shelling out to `sha256sum`. Register with `qmlRegisterType()` and import in QML.

</BuildIt>

## Inline C++ (Qt 6.5+)

For simple cases, use `QML_ELEMENT` with CMake's automatic registration:

```cpp
#pragma once
#include <QObject>
#include <QProcess>

class SystemInfo : public QObject {
  Q_OBJECT
  QML_ELEMENT

public:
  Q_INVOKABLE double uptimeSeconds() {
    QProcess proc;
    proc.start("cat", {"/proc/uptime"});
    proc.waitForFinished();
    return proc.readAll().split(' ')[0].toDouble();
  }
};
```

## JavaScript Module Extensions

For pure logic that doesn't need C++, use `.js` libraries:

```js
// util/geometry.js
.pragma library

function pointInRect(px, py, rx, ry, rw, rh) {
  return px >= rx && px <= rx + rw && py >= ry && py <= ry + rh
}

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value))
}

function lerp(a, b, t) {
  return a + (b - a) * t
}
```

```qml
import "util/geometry.js" as Geo

Item {
  onClicked: {
    if (Geo.pointInRect(mouseX, mouseY, 0, 0, 100, 100)) {
      console.log("Clicked in top-left corner")
    }
  }
}
```

<CommonMistake>

**Over-engineering.** Before writing a C++ plugin, ask: "Can I do this with `Qt.process()` or a JavaScript utility?" If the answer is yes and performance is acceptable, skip C++. C++ plugins add build complexity and distribution overhead.

**Missing QML_ELEMENT registration.** In Qt 6.5+, `QML_ELEMENT` in the header plus `qt_add_qml_module()` in CMake handles registration. Don't manually call `qmlRegisterType()` if you use `QML_ELEMENT`.

**Not handling thread safety.** C++ methods called from QML run on the main thread. Long operations block the UI. Use `QtConcurrent::run()` for background work and emit signals on completion.

</CommonMistake>

## Under the Hood

QML extensions are shared libraries (`.so` on Linux, `.dylib` on macOS, `.dll` on Windows) that implement `QQmlEngineExtensionPlugin`. The QML engine loads them on first `import`. Types registered via `qmlRegisterType()` become available in QML like any built-in type, with full support for property bindings, signals, and invokable methods.

## Exercises

<ExerciseBlock :difficulty="1">
Write a C++ plugin called `ImageAnalyzer` that exposes a `dominantColors(imagePath)` method returning the top 3 RGB values from an image. Use Qt's `QImage` for pixel access.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a `FileWatcher` C++ type that wraps `QFileSystemWatcher`. Emit a `fileChanged(path)` signal when a file is modified. Use it to hot-reload your config when `settings.json` changes.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a JavaScript library for date math: `daysBetween(date1, date2)`, `isWeekend(date)`, `nextOccurrence(dayOfWeek)`. Publish it as a standalone `.js` file that can be imported into any QML project.
</ExerciseBlock>

<Recap :points="['Use C++ plugins for performance-critical or low-level operations QML cannot do', 'Register types with qmlRegisterType() or QML_ELEMENT for QML import', 'Keep C++ extensions focused — prefer Qt.process() or JS utilities for simple tasks', 'JavaScript .js libraries are the simplest extension mechanism for pure functions']" next-chapter="/part-12-advanced/testing" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-modules-cppplugins.html — C++ QML plugins
- https://doc.qt.io/qt-6/qtqml-qmlelement.html — QML_ELEMENT macro
- https://doc.qt.io/qt-6/qml-qtqml-javascript.html — JavaScript in QML
-->
