---
title: "Core Types"
description: "Deep dive into Quickshell's core QML types and their C++ implementations"
---

<ChapterMeta reading-time="12 min" :difficulty="4" :prerequisites="['Architecture overview', 'C++ basics']" you-will-learn="How Quickshell's core QML types work internally" />

## The Quickshell Singleton

The `Quickshell` singleton is the entry point for all Quickshell functionality. It is implemented by the `QuickshellGlobal` class and registered as a QML singleton via `QML_NAMED_ELEMENT(Quickshell)`.

**C++ class:** `src/core/qmlglobal.hpp`
**QML type:** `import Quickshell` → `Quickshell`

**Key properties and their C++ sources:**

| QML Property | C++ Implementation |
|---|---|
| `screens` | `QVector<QuickshellScreenInfo*>` maintained by `QuickshellTracked` |
| `processId` | `QCoreApplication::applicationPid()` |
| `shellDir` | Directory containing the loaded shell entrypoint |
| `dataDir` | Per-shell data dir: `~/.local/share/quickshell/by-shell/<id>` |
| `stateDir` | Per-shell state dir: `~/.local/state/quickshell/by-shell/<id>` |
| `cacheDir` | Per-shell cache dir: `~/.cache/quickshell/by-shell/<id>` |
| `appId` | Desktop application ID (default `org.quickshell`) |
| `shellId` | Stable identifier derived from config path |
| `clipboardText` | System clipboard (Wayland: only when focused) |
| `workingDirectory` | Configurable via `QuickshellSettings` |

**Settings access:** The `QuickshellSettings` singleton (accessed via `ShellRoot.settings` or `pragma`) provides `workingDirectory` and `watchFiles` properties.

**Internal mechanism:**

```cpp
// qmlglobal.hpp (simplified)
class QuickshellGlobal: public QObject {
  Q_OBJECT;
  Q_PROPERTY(qint32 processId READ processId CONSTANT);
  Q_PROPERTY(QString shellId READ shellId CONSTANT);
  Q_PROPERTY(QString appId READ appId CONSTANT);
  Q_PROPERTY(QString shellDir READ shellDir CONSTANT);
  Q_PROPERTY(QQmlListProperty<QuickshellScreenInfo> screens READ screens NOTIFY screensChanged);
  QML_SINGLETON;
  QML_NAMED_ELEMENT(Quickshell);

public:
  Q_INVOKABLE void reload(bool hard);
  Q_INVOKABLE QVariant env(const QString& variable);
  Q_INVOKABLE static void execDetached(QList<QString> command);
};
```

## ShellRoot

`ShellRoot` is the optional root element of a Quickshell configuration. It extends `ReloadPropagator` and provides access to `QuickshellSettings`.

**C++ class:** `src/core/shell.hpp`

```cpp
// shell.hpp
class ShellRoot: public ReloadPropagator {
  Q_OBJECT;
  Q_PROPERTY(QuickshellSettings* settings READ settings CONSTANT);
  QML_ELEMENT;

public:
  explicit ShellRoot(QObject* parent = nullptr): ReloadPropagator(parent) {}
  [[nodiscard]] QuickshellSettings* settings() const;
};
```

Key behavior:
- **Settings provider.** `ShellRoot.settings` exposes `QuickshellSettings` for configuring working directory and file watching.
- **Optional.** Not required — you can write a shell without `ShellRoot`. It is only needed when you need to set configuration pragmas inline.
- **Relay.** As a `ReloadPropagator`, it participates in Quickshell's reload mechanism but does not own windows directly.

## Variants

`Variants` is Quickshell's mechanism for creating multiple instances of a component — one per screen, one per output, etc. It is similar to `QtQuick.Repeater` but works with non-`Item` objects and acts as a reload scope.

**C++ class:** `src/core/variants.hpp`

```cpp
// variants.hpp (simplified)
class Variants: public Reloadable {
  Q_OBJECT;
  Q_PROPERTY(QQmlComponent* delegate MEMBER mDelegate);
  Q_PROPERTY(QVariant model READ model WRITE setModel NOTIFY modelChanged);
  Q_PROPERTY(QQmlListProperty<QObject> instances READ instances NOTIFY instancesChanged);
  QML_ELEMENT;

public:
  explicit Variants(QObject* parent = nullptr): Reloadable(parent) {}
};
```

The `modelData` property is injected into each delegate instance, containing the current item from the model.

## WindowInterface

`WindowInterface` is the base class for all Quickshell windows (`PanelInterface`, `PopupWindow`, `FloatingWindow`, `ProxyWindow`). It manages the Wayland surface, layer-shell role, and window geometry.

**C++ class:** `src/window/windowinterface.hpp`

Key properties:
- `visible` / `backingWindowVisible` — window show/hide state
- `implicitWidth` / `implicitHeight` — desired dimensions
- `devicePixelRatio` — ratio of logical to monitor pixels
- `screen` — the `QuickshellScreenInfo` the window occupies
- `contentItem` — the root QQuickItem for adding child items

Key responsibilities:
- Creating a `wl_surface` via `wl_compositor_create_surface()`
- Requesting a layer-surface role via `zwlr_layer_shell_v1_get_layer_surface()`
- Mapping/unmapping the surface (attaching buffers)
- Handling configure events (acknowledge with serial)
- Managing the surface's input region and opacity

```cpp
// windowinterface.hpp (simplified)
class WindowInterface: public Reloadable {
  Q_OBJECT;
  Q_PROPERTY(QQuickItem* contentItem READ contentItem CONSTANT);
  Q_PROPERTY(bool visible READ isVisible WRITE setVisible NOTIFY visibleChanged);
  Q_PROPERTY(qint32 implicitWidth READ implicitWidth WRITE setImplicitWidth NOTIFY implicitWidthChanged);
  Q_PROPERTY(qint32 implicitHeight READ implicitHeight WRITE setImplicitHeight NOTIFY implicitHeightChanged);
  Q_PROPERTY(QuickshellScreenInfo* screen READ screen WRITE setScreen NOTIFY screenChanged);
  Q_PROPERTY(qreal devicePixelRatio READ devicePixelRatio NOTIFY devicePixelRatioChanged);
  QML_ELEMENT;
};
```

## Exercises

<ExerciseBlock :difficulty="1">
Read `src/core/qmlglobal.hpp` and find the `QuickshellGlobal` class. Trace how `screens` is populated — find `QuickshellTracked::updateScreens()` in `src/core/qmlglobal.cpp`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Examine the `Variants` implementation in `src/core/variants.hpp` and `src/core/variants.cpp`. Explain how it creates QML components dynamically using `QQmlComponent::create()` and injects `modelData`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Add a new property to `QuickshellGlobal` called `platformName` that returns the Wayland compositor name (from `wl_display_get_name()`). Rebuild and access it from QML as `Quickshell.platformName`.
</ExerciseBlock>

<Recap :points="['QuickshellGlobal singleton manages paths, screens, and lifecycle', 'ShellRoot provides optional config via settings property', 'Variants creates delegate instances per model item (e.g., per screen)', 'WindowInterface is the C++ base for all window types']" next-chapter="/part-13-source-tour/window-system" />

<!--
Sources verified for this chapter:
- https://github.com/quickshell-mirror/quickshell/tree/master/src/core — Core source
- https://github.com/quickshell-mirror/quickshell/tree/master/src/window — Window source
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell type
-->
