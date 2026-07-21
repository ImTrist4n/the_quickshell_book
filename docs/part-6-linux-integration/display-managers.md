---
title: "Display Managers"
description: "Building a display manager / login screen with Quickshell"
---

# Display Managers

## The Problem

A display manager (like SDDM, GDM, LightDM) is the first thing a user sees after boot — it lists user accounts, accepts credentials, and starts a desktop session. Building one from scratch requires handling seat management, session starting, and graceful error recovery.

## The Naive Approach

Wrapping SDDM's theme system. SDDM themes are QML-based but restricted to SDDM's API — you can't use Quickshell features like `PanelWindow`, hot reload, or Quickshell services. You're also locked into SDDM's configuration model.

<MentalModel>

A display manager has three layers: seat management (greetd/Logind), authentication (PAM), and session launching (execing the chosen DE/WM). Your Quickshell greeter connects to greetd, authenticates, and execs the session. greetd handles the PAM conversation and seat lifecycle. The greeter is just a beautiful UI on top.

</MentalModel>

## The Idea

Write a Quickshell config that runs as the greetd greeter. It shows a user list, password field, and session picker. On successful auth, greetd starts the session. Use `FloatingWindow` for the full-screen login UI.

## Let's Build It

```qml
// shell.qml for the display manager
import Quickshell
import Quickshell.Services.Greetd
import Quickshell.Widgets

ShellRoot {
  width: 1920; height: 1080

  FloatingWindow {
    id: loginWindow
    width: root.width
    height: root.height
    color: "#1a1a2e"

    Rectangle {
      anchors.centerIn: parent
      width: 400; height: 500
      radius: 16; color: "#16213e"

      Column {
        spacing: 16
        anchors { centerIn: parent; margins: 32 }

        Image {
          source: "file:///etc/greetd/logo.png"
          width: 80; height: 80
          anchors.horizontalCenter: parent.horizontalCenter
        }

        Label { text: "Welcome"; font.pixelSize: 28; anchors.horizontalCenter: parent.horizontalCenter }

        ComboBox {
          id: userCombo
          model: greetd.users
          textRole: "name"
          width: parent.width
        }

        TextField {
          id: passwordField
          echoMode: TextInput.Password
          placeholderText: "Password"
          width: parent.width
          onAccepted: login()
        }

        Button {
          text: "Sign In"
          width: parent.width
          onClicked: login()
        }

        Label {
          id: errorLabel
          color: "#e25252"
          visible: text !== ""
        }
      }

      function login() {
        greetd.login(userCombo.currentText, passwordField.text)
      }

      GreetdSession {
        onAuthenticated: {
          // greetd will exec the session; shell replaces itself
        }
        onAuthenticationFailed: (reason) => {
          errorLabel.text = reason
          passwordField.text = ""
        }
      }
    }
  }
}
```

<BuildIt>

The greeter runs as a full-screen `FloatingWindow`. When `GreetdSession.login()` succeeds, greetd terminates the greeter process and starts the user's session. The session command is configured in greetd's config (`/etc/greetd/config.toml`), but you can override it via greetd's `session` request field.

</BuildIt>

## Let's Improve It

Add a session picker (read available `.desktop` files from `/usr/share/wayland-sessions`), user avatar display, accessibility options (screen reader, font scaling), and a "Restart" / "Shutdown" button row.

```qml
RestartButton {
  onClicked: Process.exec("systemctl reboot")
}

ShutdownButton {
  onClicked: Process.exec("systemctl poweroff")
}
```

<CommonMistake>

Running the display manager shell without `greetd` configured. Your Quickshell greeter must be registered as greetd's greeter in `/etc/greetd/config.toml`: `command = "quickshell /path/to/shell.qml"`. Without this, greetd won't launch your DM.

</CommonMistake>

## Under the Hood

greetd spawns the greeter process (your Quickshell instance) as a child. The greeter connects to greetd's Unix socket. When authentication succeeds, greetd performs the PAM session open, sets up environment variables (`XDG_SESSION_TYPE=wayland`, `DESKTOP_SESSION=hyprland`), and execs the session command. Your Quickshell process is replaced — no cleanup needed.

## Exercises

**Beginner:** Style the login screen with your favorite color scheme and add a background wallpaper.

**Intermediate:** Add a power menu (suspend, hibernate, restart, shutdown) with confirmation dialogs using `systemctl`.

**Advanced:** Implement auto-login after timeout (for single-user systems) with visual countdown and a grace-period cancellation.

<Recap :points="['A Quickshell display manager is a greeter for greetd', 'Full-screen QML UI with greetd for auth and session management', 'Part 6 complete — integrating with major Linux subsystems']" next-chapter="/part-7-hyprland/workspaces" />

<!--
Sources verified for this chapter:
- https://github.com/kennylevinsen/greetd — greetd project
- https://wiki.archlinux.org/title/greetd — greetd setup guide
- https://quickshell.org/docs/v0.3.0/types/Greetd/GreetdSession/ — Quickshell GreetdSession type
-->
