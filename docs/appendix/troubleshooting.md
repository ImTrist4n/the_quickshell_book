---
title: "Troubleshooting"
description: "Solutions to common Quickshell problems and errors"
---

# Troubleshooting

## Panel Not Visible

**Problem:** Your `PanelWindow` doesn't appear on screen.

**Check:**
1. **Anchors.** You need at least two opposite anchors for the panel to have a size:
   ```qml
   // Correct — anchors span the screen width
   anchors { top: true; left: true; right: true }
   ```
   ```qml
   // Wrong — no horizontal anchors, panel has zero width
   anchors { top: true }
   ```

2. **Screen.** If using `Variants`, verify `screen: modelData` is set.
3. **Compositor support.** Verify your compositor supports `wlr-layer-shell`:
   ```bash
   dbus-monitor --session | grep layer_shell
   ```
   If no output, the compositor doesn't support the protocol.

## Popup Shows at (0,0)

**Problem:** The popup appears in the top-left corner of the screen instead of near its parent.

**Fix:** Set the anchor:
```qml
PopupWindow {
  anchor.window: parentPanel
  anchor.rect.x: parentWindow.width / 2 - width / 2
  anchor.rect.y: parentWindow.height
}
```

## "TypeError: Cannot read property"

**Problem:** A binding fails with a TypeError.

**Check:**
1. Is the property spelled correctly? QML property names are case-sensitive.
2. Is the object actually created? A `Loader` with `active: false` doesn't create its child.
3. Is the import correct? You need `import Quickshell.Services.Hardware` for `CpuService`.

## Timer Not Firing

**Problem:** A `Timer` doesn't trigger its `onTriggered` handler.

**Check:**
```qml
Timer {
  interval: 1000
  running: true    // Must be true
  repeat: true     // Must be true for repeated firing
  onTriggered: console.log("tick")
}
```

**Common mistake:** Setting `repeat: false` (the default) and expecting the timer to fire repeatedly.

## QML Syntax Errors

Run `qmllint` on your files:

```bash
qmllint shell.qml
```

Common issues:
- **Unmatched braces:** Every `{` needs a `}`
- **Missing commas in arrays:** `[1, 2, 3]` not `[1 2 3]`
- **Wrong import syntax:** Use `import Quickshell` not `import "Quickshell"`

## D-Bus Connection Failed

**Problem:** `Qt.dbusCall()` returns null or throws.

**Check:**
1. **Bus type.** Is the service on the session bus or system bus? UPower uses system bus; MPRIS uses session bus.
2. **Service running.** Is the D-Bus service actually running?
   ```bash
   dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep org.mpris
   ```
3. **Spelling.** Service names, object paths, and interface names are case-sensitive.

## Compositor-Specific Issues

### Hyprland

**Popup flickers:** Set `dismissOnClickOutside: false` — Hyprland's focus handling may conflict.

**Window not resizing:** Hyprland caches surface sizes. Call `zwlr_layer_surface_v1_set_size()` explicitly even if the size hasn't changed.

### Sway

**Panel covers full screen:** Sway treats missing anchors as "fill the entire space." Always set at least two opposite anchors.

### KWin

**Layer surface not supported:** KWin (Plasma 6) supports layer-shell but may not handle all properties. Test with `exclusionMode: ExclusionMode.None` first.

## Crash on Startup

**Problem:** Quickshell crashes immediately.

**Debug:**
1. Run with stderr visible: `quickshell 2>&1`
2. Check for missing imports — the QML engine aborts on unknown types.
3. Verify your `shell.qml` has a valid root element (`ShellRoot`).
4. Test with a minimal config:
   ```qml
   import Quickshell
   ShellRoot { Item { } }
   ```

## Still Stuck?

- Search [GitHub Issues](https://github.com/wardvis/Quickshell/issues)
- Ask in the Quickshell community chat
- Check the [Quickshell documentation](https://quickshell.org/docs/) for the latest updates

<Recap :points="['Verify anchors, screen binding, and compositor support for invisible panels', 'Use qmllint to catch syntax errors before runtime', 'Check D-Bus bus type and service availability for integration issues', 'Test with a minimal config to isolate crash causes']" next-chapter="/appendix/qml-cheatsheet" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/guide/install-setup — Quickshell setup
- https://wayland.app/protocols/wlr-layer-shell-unstable-v1 — layer-shell protocol
- https://doc.qt.io/qt-6/qtquick-debugging.html — QML Debugging
-->
