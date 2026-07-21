---
title: "Session Management"
description: "Handling user session actions: logout, reboot, shutdown, and suspend"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['Power profiles', 'PopupWindow']" you-will-build="A session management dialog with power actions" />

## The Problem

Users need to log out, reboot, shut down, suspend, or hibernate their system. Without shell integration, they fall back to terminal commands or the compositor's built-in exit keybind.

## The Naive Approach

Run `systemctl` commands directly:

```qml
Button {
  text: "Shut Down"
  onClicked: Qt.process(["systemctl", "poweroff"])
}
```

`systemctl poweroff` works, but doesn't support session-specific actions (exit the compositor without shutting down the system) and may not integrate with polkit for password-protected actions.

<MentalModel>

Think of session management like the exit door of a building. You can leave temporarily (suspend — step outside for air), leave for the day (logout — clock out), or close the building entirely (shutdown — lock up and go home). Each action needs a clear label and confirmation.

</MentalModel>

## The Idea

Create a session popup with buttons for each action. Use `systemctl` for system-level actions and `hyprctl` (or compositor-specific) for logout. Integrate with `logind` via `loginctl` for session-level control.

## Let's Build It

```qml
// SessionControl.qml
PopupWindow {
  id: root
  width: 280; height: 240
  anchor.window: panel

  property bool confirmShutdown: false

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 16 }; spacing: 12

      Text { text: "Session"; font.pixelSize: 14; font.bold: true; color: "#cdd6f4" }

      // Log out
      SessionButton {
        text: "Log Out"
        icon: "🚪"
        onClicked: {
          Qt.process(["hyprctl", "dispatch", "exit"])
          // For Sway: Qt.process(["swaymsg", "exit"])
          // For KWin: Qt.process(["qdbus", "org.kde.KWin", "/Session", "logout"])
        }
      }

      // Suspend
      SessionButton {
        text: "Suspend"
        icon: "💤"
        onClicked: Qt.process(["systemctl", "suspend"])
      }

      // Reboot
      SessionButton {
        text: "Reboot"
        icon: "🔄"
        onClicked: Qt.process(["systemctl", "reboot"])
      }

      // Shutdown with confirmation
      SessionButton {
        text: root.confirmShutdown ? "Confirm Shutdown?" : "Shut Down"
        icon: "⏻"
        onClicked: {
          if (root.confirmShutdown) {
            Qt.process(["systemctl", "poweroff"])
          } else {
            root.confirmShutdown = true
            timer.start()
          }
        }
      }
    }
  }

  Timer {
    id: timer
    interval: 3000
    onTriggered: root.confirmShutdown = false
  }
}
```

Helper component:

```qml
// SessionButton.qml
Rectangle {
  id: control
  property string text: ""
  property string icon: ""
  signal clicked()

  width: parent.width; height: 36; radius: 6; color: "#313244"

  Row {
    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
    spacing: 8; anchors.verticalCenter: parent.verticalCenter
    Text { text: control.icon; font.pixelSize: 16; anchors.verticalCenter: parent.verticalCenter }
    Text { text: control.text; font.pixelSize: 13; color: "#cdd6f4"; anchors.verticalCenter: parent.verticalCenter }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onEntered: control.color = "#45475a"
    onExited: control.color = "#313244"
    onClicked: control.clicked()
  }
}
```

<BuildIt>

The session popup provides a clean list of power actions. Shutdown requires confirmation (click once to arm, click again within 3 seconds to execute). Each compositor has a different logout command — detect and use the appropriate one.

</BuildIt>

## Action Reference

| Action | Command | Notes |
|---|---|---|
| Log Out (Hyprland) | `hyprctl dispatch exit` | Exits the compositor |
| Log Out (Sway) | `swaymsg exit` | Exits the compositor |
| Log Out (KWin) | `qdbus org.kde.KWin /Session logout` | D-Bus call |
| Suspend | `systemctl suspend` | Saves state to RAM |
| Hibernate | `systemctl hibernate` | Saves state to disk |
| Hybrid Sleep | `systemctl hybrid-sleep` | RAM + disk suspend |
| Reboot | `systemctl reboot` | Full system restart |
| Shutdown | `systemctl poweroff` | Power off system |
| Lock Screen | `loginctl lock-session` | Locks the current session |

<CommonMistake>

**Not checking for polkit.** `systemctl poweroff` may fail on systems where the user doesn't have passwordless sudo. Use `pkexec systemctl poweroff` or integrate with polkit via `qt-polkit` for proper authentication.

**Forgetting hibernate support.** Hibernate requires sufficient swap space. Check `cat /sys/power/state` for available sleep states. Disable hibernate if `disk` is not listed.

**No confirmation for destructive actions.** Shutdown and reboot should always have a confirmation step. Accidental clicks are too destructive to ignore. A 3-second confirmation timer is standard UX practice.

</CommonMistake>

## Under the Hood

Session management uses `systemd-logind` for session lifecycle. Actions like suspend, hibernate, and hybrid-sleep go through logind's inhibitors — applications can inhibit sleep (e.g., "A movie is playing"). Your session popup can query inhibitors via `loginctl list-inhibitors` and warn the user before forcing a suspend.

## Exercises

<ExerciseBlock :difficulty="1">
Add a "countdown shutdown" option. When shutdown is selected, show a 30-second countdown with a cancel button. This gives users time to save work before the system powers off.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Query logind inhibitors before suspend. If an application is inhibiting sleep (e.g., "Firefox playing audio"), warn the user and list the inhibiting applications.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Add a "schedule shutdown" dialog. Let users set a timer (30 min, 1 hour, custom) after which the system auto-shuts down. Implement the timer in your shell service using `shutdown +30` command.
</ExerciseBlock>

<Recap :points="['Use compositor-specific commands for logout, systemctl for power actions', 'Add confirmation step for destructive actions (shutdown, reboot)', 'Support suspend, hibernate, and hybrid-sleep where available', 'Check for polkit and logind inhibitors to avoid failed or blocked actions']" next-chapter="/part-11-complete-shell/startup" />

<!--
Sources verified for this chapter:
- https://www.freedesktop.org/wiki/Software/systemd/logind/ — systemd-logind
- https://wiki.hyprland.org/Configuring/Uncommon-tips/ — Hyprland tips
- https://quickshell.org/docs/v0.3.0/types/Quickshell/Quickshell/ — Quickshell.process()
-->
