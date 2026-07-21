---
title: "Folder Structure"
description: "Organizing your Quickshell project for maintainability and scalability"
---

<ChapterMeta reading-time="10 min" :difficulty="1" :prerequisites="['Components vs Services vs Utilities']" you-will-learn="How to structure a multi-file Quickshell project" />

## The Problem

When your shell starts with one `shell.qml` file and grows to dozens of components, a flat directory becomes unmanageable. Files are hard to find, imports are fragile, and there's no convention for where new files should go.

## The Naive Approach

```
~/.config/quickshell/
  shell.qml
  bar.qml
  clock.qml
  cpu-widget.qml
  ram-widget.qml
  network-widget.qml
  weather-service.qml
  theme-utils.qml
  ...
```

Everything is in one folder. Imports use `"foo.qml"` as relative paths. There's no way to tell if something is a component, service, or utility without reading its contents.

<MentalModel>

Think of your project folder like a workshop. Components are the finished tools on the wall — ready to grab and use. Services are the workbench — they transform raw materials. Utilities are the storage bins — organized by type (nuts, bolts, screws). A messy workshop leads to lost time finding the right tool.

</MentalModel>

## Recommended Structure

```
quickshell/
  shell.qml                      # Entry point
  config.qml                     # User configuration singleton
  theme.qml                      # Color palette and sizing

  bar/
    MainBar.qml                  # Main panel window
    LeftSection.qml              # Workspace indicators, launcher
    CenterSection.qml            # Clock, date
    RightSection.qml             # System tray, quick toggles

  popups/
    AppLauncher.qml              # Application launcher popup
    NotificationCenter.qml       # Notification list popup
    ControlCenter.qml            # Quick settings popup
    CalendarPopop.qml            # Calendar/date picker

  widgets/
    CpuWidget.qml                # CPU usage bar
    RamWidget.qml                # Memory usage bar
    DiskWidget.qml               # Disk usage bar
    NetworkWidget.qml            # Network speed indicator
    BatteryWidget.qml            # Battery percentage and icon
    ClockWidget.qml              # Digital clock display
    MprisWidget.qml              # Now-playing media widget

  services/
    WeatherService.qml           # Weather data singleton
    WallpaperService.qml         # Wallpaper rotation
    UpdateService.qml            # Package update checker

  util/
    format.js                    # Number/date formatting helpers
    color.js                     # Color manipulation utilities
    math.js                      # Math helper functions

  assets/
    icons/                       # Custom SVG icons
    fonts/                       # Bundled font files
    images/                      # Wallpapers, backgrounds

  tests/
    test-format.js               # Unit tests for utilities
```

## Why This Works

**Separation by concern.** Each directory groups files by their architectural role (`bar/`, `popups/`, `widgets/`, `services/`, `util/`). A developer opening the project for the first time knows where to find each piece.

**Implicit imports via folders.** Quickshell supports `qs.` module imports (v0.2.0+):

```qml
import qs.widgets
import qs.services
import qs.popups
import "util/format.js" as Format
```

This is cleaner than listing every individual file path.

**No circular imports.** Services live in `services/` and never import from `widgets/` or `bar/`. Components import from services. Utilities import nothing from the project.

**Assets are discoverable.** Icons, fonts, and images have dedicated directories instead of being scattered across the project.

## File Naming Conventions

| Pattern | Example | Rule |
|---|---|---|
| PascalCase for types | `CpuWidget.qml` | Every QML type starts with uppercase |
| camelCase for instances | `cpuWidget` | `id` properties use camelCase |
| kebab-case for assets | `battery-icon.svg` | Assets use lowercase dash-separated |
| `.js` for utilities | `format.js` | Pure JS files use lowercase |

## The `qs` Module Import

In Quickshell v0.2.0+, the `qs` import prefix lets you import an entire directory as a module:

```qml
import qs.widgets

// Now use any QML file in widgets/ directly:
CpuWidget {}
RamWidget {}
```

This replaces explicit relative imports like `import "../widgets/CpuWidget.qml"` and makes refactoring easier — move a file within `widgets/` and all `import qs.widgets` statements still work.

## Exercises

<ExerciseBlock :difficulty="1">
Convert a flat shell project to the recommended structure. Move each file to its appropriate subdirectory and update all import paths.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a `config.qml` singleton to the project root that exposes user preferences (panel height, colors, enabled widgets). Import it as `import qs` and read values throughout your components.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Set up a `tests/` directory with automated QML tests. Write a test for `format.js` that verifies `bytesToHuman(1024)` returns `"1.0 KB"`. Integrate the test into a CI pipeline using `qmllint` and `qmltestrunner`.
</ExerciseBlock>

<Recap :points="['Group files by architectural role (bar, popups, widgets, services, util)', 'Use qs. module imports for clean, refactorable paths', 'Follow naming conventions: PascalCase for types, camelCase for ids', 'Keep assets in dedicated directories, not mixed with source code']" next-chapter="/part-10-architecture/configuration" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/qml-language#module-imports — qs module import syntax
- https://quickshell.org/docs/v0.3.0/guide/qml-language/ — QML Language Reference
- https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html — QML Object Attributes
-->
