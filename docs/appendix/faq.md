---
title: "FAQ"
description: "Frequently asked questions about Quickshell and building shells"
---

# FAQ

## General Questions

### What is Quickshell?

Quickshell is a Qt Quick-based desktop shell toolkit. It provides QML types and C++ services for building Wayland desktop shells — bars, launchers, notification centers, and complete desktop environments.

### How is Quickshell different from other shell toolkits?

| Toolkit | Language | Protocol | Purpose |
|---------|----------|----------|---------|
| Quickshell | QML/C++ | Wayland layer-shell | Desktop shells |
| EWW | Elisp/XML | X11/Wayland (window) | Widgets/bars |
| AGS | GJS/TypeScript | Wayland layer-shell | Desktop shells |
| Waybar | C/CSS | Wayland layer-shell | Bars (read-only) |

Quickshell is unique in offering fully interactive UIs with QML's animation and layout engine.

### Does Quickshell work with my compositor?

Quickshell uses the layer-shell protocol (zwlr-layer-shell-v1). Compatible compositors: Hyprland, Sway, River, Wayfire, KWin (Wayland). Not compatible: GNOME Mutter (no layer-shell).

### Is Quickshell stable?

Quickshell is in active development (pre-v1.0). The API is subject to change, but breaking changes are documented in release notes.

## Technical Questions

### How do I set up Quickshell?

```bash
# Install dependencies
sudo pacman -S base-devel git cmake ninja qt6-base qt6-wayland qt6-svg qt6-declarative

# Clone and build
git clone https://github.com/outfoxxed/quickshell
cd quickshell
cmake -B build -G Ninja
cmake --build build
sudo cmake --install build

# Test
quickshell -c /path/to/shell.qml
```

### How do I debug my shell?

See the [Debugging Guide](/appendix/debugging-guide) for a comprehensive walkthrough. Quick start:

```bash
quickshell --qmljsdebugger port:3768
# Connect from Qt Creator: Analyze > QML Profiler
```

### How do I add a service not included in Quickshell?

Create a singleton QML component:

```qml
pragma Singleton
import QtQuick
import Quickshell

QtObject {
  // Your service properties and methods
}
```

Register it in `qmldir`:

```
singleton MyService 1.0 MyService.qml
```

For C++ services, see [QML Extensions](/part-12-advanced/qml-extensions).

### Why is my PopupWindow not showing?

1. Is `anchor.window` set to a valid `Window`?
2. Is `visible` set to `true`?
3. Check compositor supports layer-shell
4. Check terminal for warnings

### How do I run a shell command from QML?

```qml
// Run and capture output
Qt.process(["ls", "-la", "/tmp"])
  .onStdout.connect(function(data) { console.log(data) })

// Run and forget
Qt.execDetached({ command: "firefox", args: ["https://quickshell.org"] })
```

### Can I use JavaScript libraries in QML?

QML uses Qt's JavaScript engine (based on V8). You can import JS files:

```qml
import "lib/utils.js" as Utils

function doSomething() {
  var result = Utils.formatTime(Date.now())
}
```

ES6 modules are not supported. Use Qt's `import` for JS files.

## Community Questions

### Where can I get help?

- **GitHub Issues**: Bug reports and feature requests
- **Discord**: `#quickshell` channel on the Qt Discord
- **GitHub Discussions**: Q&A and show-and-tell
- **Matrix**: `#quickshell:matrix.org`

### Can I contribute?

Yes! Quickshell welcomes contributions:

1. **Code**: Fix bugs, add features, improve documentation
2. **Configs**: Share your shell configuration
3. **Themes**: Create and share themes
4. **Documentation**: Improve this book or the official docs

### Are there pre-built shells I can use?

See [Community Shells](/part-13-source-tour/other-community-shells) for a list of popular configurations. The most popular is [Caelestia](https://github.com/outfoxxed/caelestia).

## Exercises

<ExerciseBlock :difficulty="1">
Add 3 more questions to this FAQ based on issues you encountered while building your shell. Submit them as a PR to this book.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Categorize each question by frequency (daily, weekly, monthly during shell development). Identify the top 5 most common questions and consider how the documentation could answer them more proactively.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a "Help" panel for your shell that links to relevant FAQ sections based on context. If an error occurs, show the relevant FAQ entry automatically.
</ExerciseBlock>

<Recap :points="['Quickshell uses Wayland layer-shell protocol, works with Hyprland, Sway, River', 'Debug with --qmljsdebugger and connect from Qt Creator', 'Create custom services as singleton QML files', 'Get help on GitHub, Discord, Matrix, and GitHub Discussions']" next-chapter="/appendix/architecture-diagrams" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/ — Quickshell documentation
- https://github.com/outfoxxed/quickshell — Quickshell repository
- https://discord.gg/qt — Qt Discord
-->
