---
title: "Lock Screen"
description: "A lock screen for the complete desktop shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'Keys & Focus']" you-will-build="A full-screen lock screen with time display and authentication" />

## The Problem

A lock screen secures your session. It must prevent all input from reaching other windows, display useful information (time, date, media), and provide authentication. On Wayland, this requires the `overlay` layer or the `ext-session-lock` protocol.

## The Naive Approach

A simple overlay window:

```qml
PanelWindow {
  layer: WindowLayer.Overlay
  anchors { left: true; right: true; top: true; bottom: true }
  color: "black"
}
```

Without keyboard grab, users can press Super+Tab to bypass it.

<MentalModel>

Think of a lock screen as a security checkpoint. All input must pass through the guard (lock screen). If the guard is active, everything is intercepted until the user provides valid ID (password).

</MentalModel>

## The Idea

Create a fullscreen overlay `PanelWindow` that grabs keyboard input. Display the time, date, and a password field. Use PAM authentication via a helper binary.

## Let's Build It

```qml
// LockScreen.qml
PanelWindow {
  id: lock
  layer: WindowLayer.Overlay
  anchors { left: true; right: true; top: true; bottom: true }
  color: "#1e1e2e"
  visible: false

  property string password: ""
  property string errorMsg: ""

  function show() { visible = true; passInput.forceActiveFocus() }
  function hide() { visible = false }

  function authenticate() {
    Qt.process(["/usr/lib/quickshell/lock-auth", password, Quickshell.env("USER")])
      .onFinished.connect(function(success) {
        if (success) { hide() }
        else { errorMsg = "Incorrect password"; password = ""; passInput.text = "" }
      })
  }

  Column {
    anchors.centerIn: parent
    spacing: 24

    // Time
    Text {
      id: timeLabel
      text: new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
      font.pixelSize: 64; font.bold: true; color: "white"
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Timer {
      interval: 1000; running: lock.visible; repeat: true
      onTriggered: timeLabel.text = new Date().toLocaleTimeString(Qt.locale(), Locale.ShortFormat)
    }

    // Date
    Text {
      text: new Date().toLocaleDateString(Qt.locale(), Locale.LongFormat)
      font.pixelSize: 18; color: "#a6adc8"
      anchors.horizontalCenter: parent.horizontalCenter
    }

    // User avatar placeholder
    Rectangle {
      width: 80; height: 80; radius: 40; color: "#313244"
      anchors.horizontalCenter: parent.horizontalCenter
      Text {
        text: Quickshell.env("USER").charAt(0).toUpperCase()
        anchors.centerIn: parent; color: "white"; font.pixelSize: 32
      }
    }

    // Password input
    Rectangle {
      width: 280; height: 44; radius: 8; color: "#313244"
      TextInput {
        id: passInput
        anchors { fill: parent; margins: 12 }
        font.pixelSize: 16; color: "#cdd6f4"
        echoMode: TextInput.Password
        placeholderText: "Password"
        onAccepted: lock.authenticate()
      }
    }

    // Error message
    Text {
      text: errorMsg
      color: "#f38ba8"; font.pixelSize: 13
      visible: errorMsg !== ""
      anchors.horizontalCenter: parent.horizontalCenter
    }
  }
}
```

<BuildIt>

The lock screen covers all outputs in the overlay layer. It captures all input via `forceActiveFocus()`. Time updates every second. The password field uses echo mode. Authentication delegates to `lock-auth` which checks via PAM.

</BuildIt>

## Let's Improve It

Add media player controls and wallpaper background:

```qml
Image {
  source: "/path/to/wallpaper.jpg"
  anchors.fill: parent
  fillMode: Image.PreserveAspectCrop
}
Rectangle {
  anchors.fill: parent; color: "#1e1e2e"; opacity: 0.5
}
```

<CommonMistake>

**Not forcing keyboard focus.** A lock screen that doesn't call `forceActiveFocus()` on its password field can be bypassed. Connect to `visibleChanged` and grab focus whenever shown.

**Hardcoding the authentication binary.** `lock-auth` path differs across distros. Check multiple locations or make it configurable. Fall back to `chsh` or `passwd` verification if the binary isn't found.

**Forgetting ext-session-lock.** Without Wayland's session lock protocol, a determined user can switch to another VT (Ctrl+Alt+F2). On compositors that support `ext-session-lock`, use it for proper security.

</CommonMistake>

## Under the Hood

The `ext-session-lock` protocol (version 1) creates a locked surface that the compositor guarantees exclusive keyboard focus. When locked, the compositor hides all other surfaces. Input goes only to the lock surface. If the lock client crashes, the compositor may either unlock or remain locked depending on policy.

## Exercises

<ExerciseBlock :difficulty="1">
Add idle detection — automatically show the lock screen after N minutes of inactivity. Use a Timer that resets on any keyboard or mouse activity (detected via `Keys.onPressed` on the root window).
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement unlock animation — on successful authentication, fade the lock screen out over 300ms before hiding. Use a `PropertyAnimation` on `opacity`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a multi-factor lock screen that supports password AND a YubiKey. Detect YubiKey insertion via `udevadm monitor`, require both physical presence and password to unlock.
</ExerciseBlock>

<Recap :points="['Lock screen uses overlay layer + keyboard grab for security', 'Display time, date, user avatar, and password field', 'Authenticate via PAM helper binary', 'Consider ext-session-lock protocol for compositor-enforced locking']" next-chapter="/part-11-complete-shell/login-manager" />

<!--
Sources verified for this chapter:
- https://wayland.app/protocols/ext-session-lock-v1 — ext-session-lock protocol
- https://wiki.archlinux.org/title/PAM — PAM
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/ — PanelWindow overlay
-->
