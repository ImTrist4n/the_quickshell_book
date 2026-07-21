---
title: "First Launch"
description: "Your first Quickshell launch — running a minimal shell configuration"
---

<ChapterMeta reading-time="5 min" :difficulty="1" :prerequisites="['Installing Qt & Quickshell']" you-will-build="A minimal running Quickshell config" />

## The Problem

You've installed Quickshell. Now you want to see it work. Even a minimal shell that does nothing but display a colored rectangle proves that your installation is correct and gives you the confidence that you can build from here.

## The Naive Approach

Create a file, type random QML, run `quickshell`, hope it works. If it doesn't — and you don't know the correct QML structure — you'll get confusing errors and no idea what to fix.

## The Idea

Quickshell looks for a file called `shell.qml` inside a config directory. This is the entry point — the first file loaded when Quickshell starts. A minimal `shell.qml` needs three things:

1. Import the Quickshell types
2. Create a window of some kind (`PanelWindow` or `FloatingWindow`)
3. Put something visible inside it

## Let's Build It

Create a directory and a `shell.qml` file:

```bash
mkdir -p ~/quickshell-playground/first-launch
cd ~/quickshell-playground/first-launch
```

Now create `shell.qml`:

```qml
import Quickshell

PanelWindow {
  width: 400
  height: 48
  color: "#1a1a2e"

  Text {
    text: "Quickshell is running!"
    anchors.centerIn: parent
    color: "#e0e0e0"
    font.pixelSize: 16
  }
}
```

Run it:

```bash
quickshell ./
```

A small dark panel should appear at the top of your screen with the text "Quickshell is running!" centered inside it.

<BuildIt>

Let's break down what each line does:

- `import Quickshell` — makes Quickshell's types available. Without this, `PanelWindow` wouldn't be recognized.
- `PanelWindow { ... }` — creates a window using the Layer Shell protocol, positioned at the top layer. `PanelWindow` is the primary window type for bars and panels.
- `width: 400; height: 48` — the window is 400 by 48 pixels.
- `color: "#1a1a2e"` — the background is a dark navy.
- `Text { ... }` — a QML element that displays text. `anchors.centerIn: parent` centers it in the panel. `color` sets the text color. `font.pixelSize` sets the font size.

</BuildIt>

## Let's Improve It

Let's add a few more elements to see how the panel responds:

```qml
import Quickshell

PanelWindow {
  width: 600
  height: 36
  color: "#1a1a2e"

  Row {
    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      leftMargin: 12
    }
    spacing: 8

    Rectangle { width: 8; height: 8; radius: 4; color: "#00ff88" }
    Text { text: "Workspace 1"; color: "#e0e0e0"; font.pixelSize: 13 }
  }

  Text {
    text: "Hello, shell!"
    anchors.centerIn: parent
    color: "#8888aa"
    font.pixelSize: 14
  }

  Text {
    text: "✕"
    anchors {
      right: parent.right
      verticalCenter: parent.verticalCenter
      rightMargin: 12
    }
    color: "#e0e0e0"
    font.pixelSize: 14
  }
}
```

Save and see the hot reload in action. The panel now has a workspace indicator on the left, a centered greeting, and a close button on the right — all inside a `Row` for horizontal layout.

<CommonMistake>

**Forgetting the `import` statement.** QML doesn't have a global namespace. You must explicitly import every module you use. Omitting `import Quickshell` will produce an error like "PanelWindow is not a type."

**Running Quickshell from the wrong directory.** Quickshell expects to find `shell.qml` in the directory you pass it. Running `quickshell` without arguments searches the XDG config paths. If you run it from your playground directory, pass `./` as the argument.

</CommonMistake>

## What Just Happened

When you ran `quickshell ./`, the following occurred:

1. Quickshell scanned the directory for `shell.qml`
2. It loaded the QML file and resolved the `import Quickshell` statement
3. It created a `PanelWindow` — this involved:
   - Opening a Wayland connection
   - Creating a `wlr-layer-shell` surface
   - Setting the layer to `Top` (the default for panels)
   - Anchoring to the top edge
   - Setting the window dimensions
4. The QML engine evaluated the nested types and created the object tree
5. The compositor displayed the surface on screen

Hot reload is active by default. Edit `shell.qml`, save, and the window updates without restarting.

## Exercises

<ExerciseBlock :difficulty="1">
Change the panel color to something you like. Update the text to include your name or a custom message.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a second `Text` element below the first one (hint: use `Column` instead of a single `Text`). Display a second line that shows the current year.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Try changing `PanelWindow` to `FloatingWindow` and observe the difference. What changes about the window's position and behavior? (You'll learn the details in Part III.)
</ExerciseBlock>

<Recap :points="['A Quickshell config is a directory containing shell.qml', 'PanelWindow creates a Layer Shell panel window', 'Text and Rectangle are basic QML elements for content', 'Hot reload updates the UI automatically on file save']" next-chapter="/part-1-qml/hello-world" />

<!--
Sources verified for this chapter:
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PanelWindow — PanelWindow type
- https://quickshell.org/docs/v0.3.0/guide/introduction — Quickshell introduction guide
-->
