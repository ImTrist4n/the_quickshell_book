---
title: "Lock Screen"
description: "Building a Wayland-compatible lock screen with Quickshell"
---

<ChapterMeta reading-time="16 min" :difficulty="3" :prerequisites="['PopupWindow', 'Keys & Focus', 'Authentication']" you-will-build="A full-screen lock screen with password authentication and media controls" />

## The Problem

A lock screen secures your session when you step away from the computer. On Wayland, creating a lock screen is uniquely challenging — you must create an overlay surface that captures all input, preventing any other application from receiving events until the user authenticates.

## The Naive Approach

Use `xdg-shell` to create a fullscreen window:

```qml
FloatingWindow {
  width: screen.width
  height: screen.height
  visible: true
}
```

This creates a regular window that doesn't actually block input — users can alt-tab away from it, and it doesn't prevent the compositor from routing input to other windows.

<MentalModel>

Think of a lock screen as a security checkpoint. Every input event (keyboard, mouse, touch) must pass through the checkpoint. If the checkpoint is active, it intercepts everything until the user proves their identity. On Wayland, this requires compositor support via the ext-session-lock protocol.

</MentalModel>

## The Idea

Quickshell's `PanelWindow` with `layer: "overlay"` creates a surface in the `overlay` layer, which sits above all other windows. Combined with keyboard grab and fullscreen sizing, this simulates a lock screen. For production use, Quickshell supports the `ext-session-lock` protocol when available.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services

PanelWindow {
  id: root
  anchors { left: true; right: true; top: true; bottom: true }
  layer: WindowLayer.Overlay
  color: "#1e1e2e"

  property string password: ""
  property string errorMessage: ""
  property bool authenticating: false

  function authenticate() {
    authenticating = true
    // In production, use PAM authentication via a helper process
    Qt.process(["/usr/lib/quickshell/lock-auth", password])
      .onFinished.connect(function(success) {
        if (success) {
          root.visible = false
        } else {
          errorMessage = "Incorrect password"
          password = ""
          authenticating = false
        }
      })
  }

  Item {
    anchors.fill: parent

    // Clock display
    Column {
      anchors.centerIn: parent
      spacing: 8

      Text {
        id: clockDisplay
        text: new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
        font.pixelSize: 72; font.bold: true; color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        text: new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat)
        font.pixelSize: 18; color: "#a6adc8"
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }

    // Password input
    Column {
      anchors {
        bottom: parent.bottom; bottomMargin: 120
        horizontalCenter: parent.horizontalCenter
      }
      spacing: 12

      Rectangle {
        width: 280; height: 44; radius: 8; color: "#313244"
        TextInput {
          id: passwordInput
          anchors { fill: parent; margins: 12 }
          font.pixelSize: 16; color: "#cdd6f4"
          echoMode: TextInput.Password
          focus: true

          onAccepted: root.authenticate()
          onTextChanged: {
            password = text
            errorMessage = ""
          }
        }
      }

      Text {
        text: errorMessage
        color: "#f38ba8"; font.pixelSize: 13
        visible: errorMessage !== ""
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Text {
        text: "Press Enter to unlock"
        color: "#6c7086"; font.pixelSize: 12
        visible: !authenticating
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }

    // Media player on lock screen
    Rectangle {
      anchors { bottom: passwordInput.bottom; bottomMargin: 80; horizontalCenter: parent.horizontalCenter }
      width: 300; height: 40; radius: 6; color: "#313244"

      Text {
        anchors.centerIn: parent
        text: MprisService.players.length > 0
          ? MprisService.players[0].title + " - " + MprisService.players[0].artist
          : "No media playing"
        color: "#a6adc8"; font.pixelSize: 12; elide: Text.ElideRight
        width: parent.width - 20
      }
    }
  }

  Timer {
    id: clockTimer
    interval: 1000; running: true; repeat: true
    onTriggered: {
      clockDisplay.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
    }
  }
}
```

<BuildIt>

The lock screen uses an overlay `PanelWindow` that covers all outputs. It displays the current time (updated every second), a password input field, and currently-playing media info. Authentication delegates to an external helper (`lock-auth`) for PAM verification.

</BuildIt>

## Let's Improve It

Add a wallpaper background, blur effect, and media playback controls:

```qml
// Background image
Image {
  source: "/path/to/wallpaper.jpg"
  anchors.fill: parent
  fillMode: Image.PreserveAspectCrop
}

// Blur overlay
Rectangle {
  anchors.fill: parent
  color: "#1e1e2e"
  opacity: 0.6
}
```

For `ext-session-lock` protocol support, Quickshell provides `LockScreen` type (if available in your version). This creates a proper locked surface that the compositor enforces.

<CommonMistake>

**Not grabbing keyboard input.** A lock screen must prevent users from interacting with other windows. Use `forceActiveFocus()` on the password field and accept all key events without propagating them. Test that Alt+Tab, Super, and Ctrl+Alt+F* are also captured.

**Assuming fullscreen blocks everything.** On Wayland without `ext-session-lock`, a fullscreen overlay can still be bypassed if the compositor allows switching virtual terminals (Ctrl+Alt+F1-F7). Consider disabling VT switching or monitoring for it.

**Hardcoding the authentication method.** PAM authentication path differs across distributions. Use `pam_unix.so` configuration or a helper binary like `swaylock`'s approach. On systems without PAM (embedded, FreeBSD), use `/etc/shadow` verification.

</CommonMistake>

## Under the Hood

Wayland's `ext-session-lock` protocol (version 1) allows a privileged client to lock the session. When locked, the compositor hides all other surfaces and displays only the lock surface. Input events go only to the lock surface. When the lock client unlocks (or crashes), the compositor restores normal operation. This is the same protocol used by `swaylock` and `hyprlock`.

Without this protocol, a lock screen is a best-effort overlay — effective against casual access but not against a determined attacker who can switch VTs or SSH in.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "Forgot Password?" option that shows a hint message configured in the shell settings.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement idle detection: automatically show the lock screen after N minutes of inactivity. Use the `IdleDetection` service if available, or track input via a global `MouseArea` and `Keys.onPressed`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a multi-factor lock screen: require both password AND a USB key (check for a specific USB device by vendor/product ID via `lsusb` output parsing). Unlock only when both factors are present.
</ExerciseBlock>

<Recap :points="['Lock screens on Wayland require overlay surfaces or ext-session-lock protocol', 'Full keyboard grab prevents input leaking to other windows', 'Use external PAM helper for authentication', 'Display clock, date, and media info for visual appeal']" next-chapter="/part-9-applications/media-player" />

<!--
Sources verified for this chapter:
- https://wayland.app/protocols/ext-session-lock-v1 — ext-session-lock protocol
- https://wiki.archlinux.org/title/PAM — PAM authentication
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/ — PanelWindow with overlay layer
-->
