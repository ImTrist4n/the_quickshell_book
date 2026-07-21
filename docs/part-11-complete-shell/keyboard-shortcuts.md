---
title: "Keyboard Shortcuts"
description: "Implementing a global keyboard shortcut system for your shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['Keys attached property', 'Signal handling']" you-will-build="A global keyboard shortcut manager" />

## The Problem

Your shell needs to respond to keyboard shortcuts: Super+D to show the desktop, Super+Space to open the app launcher, Super+Q to quit an application. Without a centralized system, you'll have key handlers scattered across every component, conflicting with each other.

## The Naive Approach

Put `Keys.onPressed` on every component:

```qml
Item {
  Keys.onPressed: function(event) {
    if (event.key === Qt.Key_D && event.modifiers & Qt.MetaModifier) {
      showDesktop()
    }
  }
}
```

Now the app launcher also has a `Keys.onPressed` for Super+Space. And the notification center has one for Super+N. And the control center has one for Super+S. They all fight for keyboard focus.

<MentalModel>

Think of a keyboard shortcut system like a switchboard operator. Every shortcut is a call that comes in. The operator (your shortcut manager) looks at who's calling (the key combination) and routes the call to the right person (the component action). No one picks up the phone directly — they wait for the operator to connect them.

</MentalModel>

## The Idea

Create a `ShortcutManager` singleton that registers all global shortcuts in one place. Components register their actions with the manager. The manager handles key dispatch, conflict resolution, and user customization.

## Let's Build It

```qml
// ShortcutManager.qml
pragma Singleton
import Quickshell
import QtQml

QtObject {
  property var shortcuts: ({})

  function register(id, key, modifiers, callback) {
    shortcuts[id] = {
      key: key,
      modifiers: modifiers,
      callback: callback
    }
  }

  function unregister(id) {
    delete shortcuts[id]
  }

  function handleEvent(event) {
    for (var id in shortcuts) {
      var s = shortcuts[id]
      if (event.key === s.key && event.modifiers === s.modifiers) {
        s.callback()
        event.accepted = true
        return true
      }
    }
    return false
  }
}
```

In your main shell file, add a global key handler:

```qml
// shell.qml
ShellRoot {
  Item {
    anchors.fill: parent
    focus: true
    Keys.onPressed: function(event) {
      ShortcutManager.handleEvent(event)
    }

    Component.onCompleted: {
      ShortcutManager.register("launcher", Qt.Key_Space,
        Qt.MetaModifier, function() { appLauncher.toggle() })

      ShortcutManager.register("notifications", Qt.Key_N,
        Qt.MetaModifier, function() { notificationCenter.toggle() })

      ShortcutManager.register("control-center", Qt.Key_S,
        Qt.MetaModifier | Qt.ShiftModifier, function() { controlCenter.toggle() })

      ShortcutManager.register("quit", Qt.Key_Q,
        Qt.MetaModifier | Qt.ControlModifier, function() { quitApp() })
    }
  }
}
```

<BuildIt>

The `ShortcutManager` is a singleton that maps shortcut IDs to key/modifier combinations. Components call `register()` at startup. The main `Keys.onPressed` delegates to `handleEvent()`. This centralizes shortcut logic and makes it easy to expose for user customization.

</BuildIt>

## Let's Improve It

Add user-configurable shortcuts from a config file:

```qml
// ShortcutManager.qml
function loadUserShortcuts() {
  var configPath = Quickshell.configPath("shortcuts.json")
  var file = Qt.open(configPath, "r")
  if (file.valid) {
    var data = JSON.parse(file.readAll())
    for (var id in data) {
      if (shortcuts[id]) {
        shortcuts[id].key = data[id].key
        shortcuts[id].modifiers = data[id].modifiers
      }
    }
  }
}
```

Support multi-key chords (e.g., Super+K, then R for "record screen"):

```qml
property bool chordMode: false
property var chordBuffer: []

function handleEvent(event) {
  if (chordMode) {
    chordBuffer.push(event.key)
    checkChord()
    return true
  }
  // ... normal handling
}
```

<CommonMistake>

**Not releasing grab when popup closes.** If a `PopupWindow` grabs keyboard input and doesn't release it on close, your global shortcuts stop working. Always call `releaseKeyboard()` or ensure `visible: false` properly releases the grab.

**Conflicting shortcuts between shell and compositor.** Super+d is a common "show desktop" shortcut in both the compositor and the shell. Either coordinate with the compositor (let it handle it) or use different key combinations. Check your compositor's config (Hyprland, Sway, etc.) for overlaps.

**Hardcoding keycodes.** `Qt.Key_Space` works cross-platform; `16777217` (raw keycode from `xev`) does not. Always use the `Qt.Key_*` constants for portability.

</CommonMistake>

## Under the Hood

Wayland keyboard handling differs from X11. In Wayland, the compositor controls keyboard focus — a client can't listen for keys it doesn't have focus. Shell components (layer surfaces) can request keyboard interactivity at different levels: `none`, `exclusive`, or `on-demand`. Your shell must be in the overlay layer with `exclusive` keyboard interactivity to reliably capture global shortcuts.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "shortcut conflict detector" to `ShortcutManager`. When `register()` is called, check if any existing shortcut uses the same key+modifier combination. If so, emit a warning with both IDs.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a shortcut settings UI (as a `PopupWindow`). List all registered shortcuts with their key bindings. Allow the user to click a binding and press a new key combination to rebind it. Save to `shortcuts.json`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement "modal" shortcuts — shortcuts that only work when a specific mode is active. For example, "resize mode" (Super+R) temporarily rebinds arrow keys to resize the focused window. Exit the mode with Escape.
</ExerciseBlock>

<Recap :points="['Centralize all global shortcuts in a ShortcutManager singleton', 'Use Keys.onPressed on a single focused item, not scattered across components', 'Support user-customizable shortcuts from a config file', 'Be aware of Wayland keyboard focus model and compositor conflicts']" next-chapter="/part-11-complete-shell/notification-daemon" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/guide/qml-language/#signals — Signal handlers
- https://doc.qt.io/qt-6/qml-qtquick-keys.html — Keys attached property
- https://wayland.app/protocols/wlr-layer-shell-unstable-v1#zwlr_layer_surface_v1:set_keyboard_interactivity — Keyboard interactivity
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.environment access
-->
