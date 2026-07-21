---
title: "Power Menu"
description: "Building a power management menu for logout, sleep, restart, and shutdown"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['PopupWindow', 'Processes & Shell Commands']" you-will-build="A power menu popup with session management actions" />

## The Problem

Users need to lock their screen, log out, suspend, restart, or shut down. Without a power menu, they must open a terminal or use DE-specific tools. A shell-integrated power menu provides quick access to these actions.

## The Naive Approach

Use `systemctl` commands directly:

```qml
function shutdown() {
  Qt.process(["systemctl", "poweroff"])
}
function reboot() {
  Qt.process(["systemctl", "reboot"])
}
function suspend() {
  Qt.process(["systemctl", "suspend"])
}
```

This works but requires polkit/root privileges for system-wide actions. It also doesn't handle session-level actions like logout or lock.

<MentalModel>

Think of the power menu as a remote control for your computer's power state. Each button sends a specific command: sleep suspends to RAM, restart reboots the kernel, shutdown powers off. The session manager (logind/elogind) mediates these requests.

</MentalModel>

## The Idea

A power menu combines `systemctl` for system power actions with `loginctl` for session actions. For locking, use `hyprlock`, `swaylock`, or `loginctl lock-session` depending on your compositor.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services

PopupWindow {
  id: root
  width: 320
  height: 300
  visible: false

  property string compositor: "hyprland" // or "sway", "kwin"

  function lockScreen() {
    switch (compositor) {
      case "hyprland": Qt.process(["hyprlock"]); break
      case "sway": Qt.process(["swaylock"]); break
      default: Qt.process(["loginctl", "lock-session"])
    }
  }

  function logout() {
    switch (compositor) {
      case "hyprland": Qt.process(["hyprctl", "dispatch", "exit"]); break
      case "sway": Qt.process(["swaymsg", "exit"]); break
      default: Qt.process(["loginctl", "terminate-user", Quickshell.env("USER")])
    }
  }

  function suspend() {
    Qt.process(["systemctl", "suspend"])
  }

  function reboot() {
    Qt.process(["systemctl", "reboot"])
  }

  function shutdown() {
    Qt.process(["systemctl", "poweroff"])
  }

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"
    radius: 8

    Column {
      anchors.fill: parent; anchors.margins: 16; spacing: 8

      Text { text: "Power"; font.pixelSize: 16; font.bold: true; color: "#cdd6f4" }

      Grid {
        columns: 3; spacing: 8; width: parent.width

        Repeater {
          model: [
            { icon: "🔒", label: "Lock", action: "lockScreen" },
            { icon: "🚪", label: "Log Out", action: "logout" },
            { icon: "💤", label: "Sleep", action: "suspend" },
            { icon: "🔄", label: "Restart", action: "reboot" },
            { icon: "⏻", label: "Shut Down", action: "shutdown" }
          ]

          delegate: Rectangle {
            required property var modelData
            width: 88; height: 72; radius: 6; color: "#313244"

            Column {
              anchors.centerIn: parent; spacing: 4
              Text { text: modelData.icon; font.pixelSize: 24; anchors.horizontalCenter: parent.horizontalCenter }
              Text { text: modelData.label; font.pixelSize: 12; color: "#a6adc8"; anchors.horizontalCenter: parent.horizontalCenter }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: root[modelData.action]()
            }
          }
        }
      }

      // Confirmation state
      Text {
        id: confirmText
        text: ""; color: "#f38ba8"; font.pixelSize: 12
        anchors.horizontalCenter: parent.horizontalCenter
      }
    }
  }
}
```

<BuildIt>

The power menu maps actions to specific commands per compositor. `Quickshell.env("USER")` gets the current username for logout. For safety-critical actions (reboot, shutdown), add a confirmation step before executing.

</BuildIt>

## Let's Improve It

Add a confirmation dialog for destructive actions:

```qml
property string pendingAction: ""
property int confirmTimer: 0

function confirmShutdown() {
  pendingAction = "shutdown"
  confirmTimer = 5
  confirmText.text = "Shutdown in " + confirmTimer + "s (click again)"
  confirmTimerId.start()
}

Timer {
  id: confirmTimerId
  interval: 1000
  repeat: true
  onTriggered: {
    confirmTimer--
    if (confirmTimer <= 0) {
      stop()
      if (pendingAction === "shutdown") shutdown()
      pendingAction = ""
      confirmText.text = ""
    } else {
      confirmText.text = "Shutdown in " + confirmTimer + "s (click again)"
    }
  }
}
```

<CommonMistake>

**Hardcoding compositor-specific commands.** Hyprland uses `hyprctl dispatch exit`, Sway uses `swaymsg exit`. Detect the compositor from `$XDG_CURRENT_DESKTOP` or make it configurable. Hardcoding only works for your setup.

**Not handling polkit prompts.** Some systems require polkit authentication for `systemctl poweroff`. If the command fails silently, users will think the menu is broken. Capture stderr and show feedback.

**Forgetting to lock before suspend.** On many compositors, suspending without locking leaves your session accessible when it resumes. Chain `lockScreen()` before `suspend()` for security.

</CommonMistake>

## Under the Hood

`systemctl suspend/reboot/poweroff` communicates with `systemd-logind` via D-Bus. `loginctl lock-session` sends a `Lock` signal to the session's D-Bs interface, which the compositor intercepts to activate its locker. On Hyprland, `hyprctl dispatch exit` sends an IPC command to the compositor's Unix socket at `$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock`.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "Hibernate" option that runs `systemctl hibernate`. Show a warning that hibernate requires sufficient swap space.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Build a "Schedule Shutdown" feature: let the user input a delay in minutes, then show a countdown with cancel option before executing.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement UPower integration for more granular power info: show battery level, estimated time to empty, and suggest power actions based on low battery (auto-suspend at 5%).
</ExerciseBlock>

<Recap :points="['Power menu sends systemctl/loginctl commands for power actions', 'Use compositor-specific commands for logout and lock', 'Add confirmation before irreversible actions like shutdown', 'Chain lock before suspend for session security']" next-chapter="/part-9-applications/lock-screen" />

<!--
Sources verified for this chapter:
- https://www.freedesktop.org/wiki/Software/systemd/logind/ — logind documentation
- https://wiki.hyprland.org/Configuring/Using-hyprctl/ — hyprctl command reference
- https://www.freedesktop.org/wiki/Software/polkit/ — polkit authorization
-->
