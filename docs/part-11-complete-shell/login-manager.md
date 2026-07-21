---
title: "Login Manager"
description: "A login/display manager screen built with Quickshell"
---

<ChapterMeta reading-time="14 min" :difficulty="3" :prerequisites="['Lock screen', 'Session management']" you-will-build="A full greeter/login manager with user selection" />

## The Problem

A display manager presents a login screen before the user session starts. Users select their account, enter credentials, and choose a desktop environment. Replacing GDM/SDDM/LightDM with a Quickshell greeter gives full control over the login experience.

## The Naive Approach

Use an existing DM and only customize the theme:

```css
/* SDDM theme override */
#clock { font-size: 24px; }
```

Limited to whatever the DM's theming engine supports. No custom QML components, no animations, no multi-factor auth.

<MentalModel>

Think of a login manager as the front desk of a hotel. Guests (users) arrive, identify themselves (select username), prove their reservation (enter password), and get a room key (session). The front desk should be welcoming, secure, and handle multiple guests.

</MentalModel>

## The Idea

Quickshell can act as a greeter for greetd. The greeter runs before any user session starts, fullscreen, with complete QML control. greetd handles authentication and session startup.

## Let's Build It

```qml
// Greeter.qml
PanelWindow {
  id: greeter
  layer: WindowLayer.Overlay
  anchors { left: true; right: true; top: true; bottom: true }
  color: "#1e1e2e"

  property var users: []
  property int selectedUser: 0
  property string password: ""
  property string errorMsg: ""
  property bool authenticating: false

  function loadUsers() {
    Qt.process(["bash", "-c", "cat /etc/passwd | grep '/home/' | cut -d: -f1"])
      .onStdout.connect(function(data) {
        users = data.trim().split("\n").filter(function(u) { return u })
      })
  }

  function login() {
    if (authenticating) return
    authenticating = true
    errorMsg = ""
    var user = users[selectedUser]
    // Send credentials to greetd via IPC
    Qt.process(["/usr/lib/greetd/greet-auth", user, password])
      .onFinished.connect(function(success) {
        authenticating = false
        if (success) {
          Qt.process(["/usr/lib/greetd/start-session", user])
        } else {
          errorMsg = "Incorrect password"
          password = ""
        }
      })
  }

  Component.onCompleted: loadUsers()

  Column {
    anchors.centerIn: parent
    spacing: 16

    // User selection
    Text {
      text: "Welcome"
      font.pixelSize: 36; font.bold: true; color: "white"
      anchors.horizontalCenter: parent.horizontalCenter
    }

    Rectangle {
      width: 320; height: 48; radius: 8; color: "#313244"
      Row {
        anchors.centerIn: parent; spacing: 12
        Text { text: "&lt;"; color: "#6c7086"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
        Text {
          text: users.length > 0 ? users[selectedUser] : "Loading..."
          color: "#cdd6f4"; font.pixelSize: 16
          anchors.verticalCenter: parent.verticalCenter
        }
        Text { text: "&gt;"; color: "#6c7086"; font.pixelSize: 18; anchors.verticalCenter: parent.verticalCenter }
      }
      MouseArea {
        anchors.fill: parent
        onHorizontalWheel: function(wheel) {
          if (wheel.angleDelta.x > 0 || wheel.angleDelta.y > 0)
            selectedUser = (selectedUser + 1) % users.length
          else
            selectedUser = (selectedUser - 1 + users.length) % users.length
        }
      }
    }

    // Password
    Rectangle {
      width: 320; height: 44; radius: 8; color: "#313244"
      TextInput {
        anchors { fill: parent; margins: 12 }
        font.pixelSize: 16; color: "#cdd6f4"
        echoMode: TextInput.Password
        placeholderText: "Password"; focus: true
        onAccepted: greeter.login()
      }
    }

    Text { text: errorMsg; color: "#f38ba8"; font.pixelSize: 13; visible: errorMsg !== "" }

    // Session selector
    Rectangle {
      width: 320; height: 36; radius: 6; color: "#313244"
      Text {
        anchors.centerIn: parent
        text: "Session: Hyprland"
        color: "#a6adc8"; font.pixelSize: 12
      }
    }

    // Login button
    Rectangle {
      width: 320; height: 44; radius: 8; color: "#89b4fa"
      Text {
        anchors.centerIn: parent
        text: authenticating ? "Signing in..." : "Sign In"
        color: "white"; font.pixelSize: 14; font.bold: true
      }
      MouseArea {
        anchors.fill: parent
        onClicked: greeter.login()
      }
    }
  }
}
```

<BuildIt>

The greeter shows a user list (scrollable with mouse wheel), password field, session selector, and login button. It communicates with greetd for authentication. The overlay layer ensures it's the only thing on screen.

</BuildIt>

## Let's Improve It

Add session type selection and auto-login with countdown:

```qml
property var sessions: ["Hyprland", "Sway", "KDE Plasma", "GNOME"]
property int selectedSession: 0
property int autoLoginCountdown: -1

Timer {
  interval: 1000; running: autoLoginCountdown > 0; repeat: true
  onTriggered: {
    autoLoginCountdown--
    if (autoLoginCountdown === 0) login()
  }
}
```

<CommonMistake>

**Running as root.** Display managers run with elevated privileges. Be extremely careful with file paths and process execution. Never trust user input directly — greetd handles credential validation; your QML code only collects input.

**Hardcoding session types.** Desktop sessions are defined in `/usr/share/wayland-sessions/` and `/usr/share/xsessions/`. Parse these `.desktop` files dynamically instead of hardcoding.

**Not handling the `greetd` IPC protocol.** greetd expects a specific JSON-based IPC on a Unix socket. The `greet-auth` helper binary abstracts this. If it's not installed, your greeter won't work.

</CommonMistake>

## Under the Hood

greetd (the Greeter Daemon) manages authentication and session startup. It listens on a Unix socket (`/run/greetd.sock`). The greeter process connects to this socket and sends authentication requests. On success, greetd starts the chosen session. Quickshell's `GreetdSession` type wraps this IPC.

## Exercises

<ExerciseBlock :difficulty="1">
Parse `/usr/share/wayland-sessions/*.desktop` to populate the session selector dynamically. Show the session name and icon from the desktop file.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a virtual keyboard for touch-screen devices. Display a QWERTY keyboard panel at the bottom when the password field has focus. Use `Keys.onPressed` for hardware keyboard passthrough.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement auto-login with configurable timeout. Read auto-login settings from `/etc/greetd/config.toml`. Show a countdown on the login button. Clicking anywhere cancels the auto-login.
</ExerciseBlock>

<Recap :points="['Quickshell greeter replaces GDM/SDDM with full QML control', 'Communicate with greetd via IPC for authentication', 'Parse /etc/passwd for user list, .desktop files for sessions', 'Handle auto-login and session selection for complete DM functionality']" next-chapter="/part-11-complete-shell/notification-center" />

<!--
Sources verified for this chapter:
- https://git.sr.ht/~kennylevinsen/greetd — greetd
- https://man.archlinux.org/man/greetd.8 — greetd man page
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow/ — PanelWindow overlay
-->
