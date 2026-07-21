---
title: "Authentication (PAM/Greetd)"
description: "Integrating PAM authentication and greetd for login/lock screens"
---

# Authentication (PAM/Greetd)

## The Problem

A lock screen or login manager must authenticate users against the system's PAM stack. This requires running as root (or with appropriate capabilities) and talking to PAM libraries. Direct PAM calls from QML are impossible without a native bridge.

## The Naive Approach

Calling `loginctl lock-session` and relying on the existing display manager for authentication. This gives your shell zero control over the lock screen UI — you can't customize the look, add a fingerprint reader, or show a custom message.

<MentalModel>

PAM (Pluggable Authentication Modules) is the Linux authentication framework. `greetd` is a minimal greeter daemon that manages PAM sessions and communicates with greeters via a JSON-based IPC protocol over a Unix socket. Your shell acts as a greeter: it sends credentials to greetd, greetd validates them via PAM, and returns success/failure.

</MentalModel>

## The Idea

Run a separate Quickshell instance as the greeter for greetd. Build a lock screen QML component that connects to greetd's IPC socket, sends a password/pin, and handles auth responses. Alternatively, use `pamtester` or `authselect` via `Process` for simpler setups.

## Let's Build It

```qml
// GreeterClient.qml
import Quickshell
import Quickshell.Services.Greetd

Item {
  id: root

  property bool authenticated: false
  property string errorMessage: ""
  signal authSucceeded()
  signal authFailed(string reason)

  GreetdSession {
    id: greetd
    onConnected: {
      // Ready for authentication
    }
    onAuthenticated: {
      root.authenticated = true
      root.authSucceeded()
    }
    onAuthenticationFailed: (reason) => {
      root.authenticated = false
      root.errorMessage = reason
      root.authFailed(reason)
    }
  }

  function authenticate(username, password) {
    greetd.login(username, password)
  }
}
```

<BuildIt>

`GreetdSession` (from `Quickshell.Services.Greetd`) connects to greetd's socket (`/run/greetd/greeter.sock`). It sends JSON requests `{ "type": "login", "username": "...", "password": "..." }` and handles responses. The `authenticated` property reflects the session state.

</BuildIt>

## Let's Improve It

Add support for multiple users (list available users from `/etc/passwd` or greetd's user list), session selection (Hyprland, Sway, etc.), and failed-attempt rate limiting.

```qml
ComboBox {
  model: greetd.users
  textRole: "name"
}

ComboBox {
  model: ["hyprland", "sway", "fish"]
}
```

<CommonMistake>

Storing passwords in QML properties. Never keep the password string alive longer than necessary. Clear the password field after each auth attempt. If using `Process` for PAM (e.g., `pamtester`), avoid passing passwords as command-line arguments (visible in `/proc`).

</CommonMistake>

## Under the Hood

greetd starts as a systemd service (or init script) with root privileges. It opens a Unix socket, creates a PAM session for the authenticated user, and starts the chosen session (e.g., `Hyprland`). Quickshell's `GreetdSession` connects to this socket as a greeter, sending JSON messages. The protocol is simple — `login` requests, `success`/`failure` responses, and `cancel` messages. PAM conversation (password prompts, 2FA) is handled by greetd internally.

## Exercises

**Beginner:** Build a lock screen that takes a password, sends it to greetd, and unlocks on success.

**Intermediate:** Add a user avatar from `~/.face` icon, password field with show/hide toggle, and a "Restart" / "Shutdown" button row.

**Advanced:** Implement fingerprint authentication via `fprintd` D-Bus integration alongside password fallback, with a visual fingerprint animation.

<Recap :points="['Authentication on Linux is handled by PAM via greetd', 'Quickshell GreetdSession bridges your shell to greetd IPC', 'Full control over lock/login UI from QML']" next-chapter="/part-6-linux-integration/display-managers" />

<!--
Sources verified for this chapter:
- https://github.com/kennylevinsen/greetd — greetd project and IPC protocol
- https://linux.die.net/man/8/pam — PAM documentation
- https://quickshell.org/docs/v0.3.0/types/Greetd/GreetdSession/ — Quickshell GreetdSession type
-->
