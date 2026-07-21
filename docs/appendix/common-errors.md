---
title: "Common Errors"
description: "Solutions to frequently encountered Quickshell errors and problems"
---

# Common Errors

This appendix catalogs the most common errors you'll encounter while building a Quickshell shell, along with their causes and solutions.

## QML Errors

### "module "Quickshell" is not installed"

```
qrc:/shell.qml:1:1: module "Quickshell" is not installed
```

**Cause**: Quickshell is not installed, or the QML import path doesn't include Quickshell.

**Solution**: Install Quickshell:
```bash
# From source
cmake --build build && cmake --install build

# Arch Linux
yay -S quickshell-git

# Nix
nix profile install github:outfoxxed/quickshell
```

### "Cannot assign to non-existent property"

```
qrc:/components/bar.qml:42: ReferenceError: foo is not defined
```

**Cause**: Typo in property name, or property doesn't exist on the object.

**Solution**: Check the property name in the Quickshell documentation. Common typos: `visibile` → `visible`, `postition` → `position`, `backgrund` → `background`.

### "TypeError: Property 'volume' of object AudioService is not a function"

```
qrc:/services/audio.qml:15: TypeError: Property 'volume' of object AudioService is not a function
```

**Cause**: Calling a property as a function.

**Solution**: Read properties, call methods:
```qml
// Correct
var vol = AudioService.volume

// Incorrect
var vol = AudioService.volume()
```

### "Maximum call stack size exceeded"

```
qrc:/components/top-bar.qml:15: RangeError: Maximum call stack size exceeded
```

**Cause**: Circular binding or infinite recursion.

**Solution**: Avoid bindings that reference themselves directly or indirectly:
```qml
// Bad: circular binding
property int a: b + 1
property int b: a + 1

// Good: independent properties
property int a: 5
property int b: a + 1
```

## Runtime Errors

### PopupWindow not showing

**Cause**: Missing `anchor.window` or incorrect anchor configuration.

**Solution**:
```qml
PopupWindow {
  anchor.window: topBar  // Must reference a valid Window
  visible: true
}
```

### Process execution fails silently

**Cause**: Command not found, or process exits with error but output is not checked.

**Solution**:
```qml
Qt.process(["which", "swww"]).onExit.connect(function(code) {
  if (code !== 0) {
    console.warn("swww not available, using fallback")
  }
})
```

### Timer not firing

**Cause**: Timer is not running, or interval is 0.

**Solution**:
```qml
Timer {
  interval: 1000  // Must be > 0
  running: true   // Must be set to true
  repeat: true
  onTriggered: { /* your code */ }
}
```

## Configuration Errors

### config.json not found

**Cause**: Shell starts but config file is missing.

**Solution**: Provide defaults:
```qml
property var config: ({})

Component.onCompleted: {
  Qt.process(["cat", Quickshell.configPath("config.json")])
    .onStdout.connect(function(data) {
      config = JSON.parse(data)
    })
}
```

### Duplicate import paths

**Cause**: Same path added multiple times to `QML2_IMPORT_PATH`.

**Solution**: Check for duplicates:
```bash
echo $QML2_IMPORT_PATH | tr ':' '\n' | sort -u
```

## Debugging Checklist

When something doesn't work:

1. Check the terminal for error messages
2. Verify Quickshell is installed: `which quickshell`
3. Check the import path: `echo $QML2_IMPORT_PATH`
4. Test with a minimal `shell.qml` that only shows a window
5. Add `console.log()` statements to narrow down the issue
6. Check the Quickshell GitHub issues for similar problems
7. Ask in the Quickshell Discord (#help channel)

## Exercises

<ExerciseBlock :difficulty="1">
Create a "minimal reproduction" of your error. Strip away all components until only the broken part remains. Share this minimal file when asking for help — it makes debugging much faster for others.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Write a startup diagnostic script that checks: Quickshell version, available services, config file validity (JSON syntax), and import paths. Output a formatted report.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Collect 5 errors you encountered while building your shell. Document each with cause, solution, and a minimal reproduction. Submit as a PR to this book's repository.
</ExerciseBlock>

<Recap :points="['Most QML errors are typos or incorrect property names', 'Check Process exit codes — failures often go silent', 'Verify Timer has interval > 0 and running: true', 'Debug with minimal reproductions before asking for help']" next-chapter="/appendix/debugging-guide" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-syntax-imports.html — QML imports
- https://quickshell.org/docs/ — Quickshell documentation
-->
