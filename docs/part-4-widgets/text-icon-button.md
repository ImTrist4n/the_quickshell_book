---
title: "Text, Icon, Button"
description: "The three foundational visual elements in Quickshell — displaying text, rendering icons, and handling clicks"
---

<ChapterMeta reading-time="12 min" :difficulty="1" :prerequisites="['QML Objects', 'Properties', 'MouseArea']" you-will-build="A clickable launcher button with icon and label" />

## The Problem

Every desktop shell needs basic building blocks: text labels, icons, and clickable buttons. Without these, you can't display a clock, a battery indicator, or a workspace switcher. The question is how to render them efficiently in a Wayland-native QML shell.

## The Naive Approach

In raw Qt Quick, you could slap a `Text` item for labels, an `Image` for icons, and a `Rectangle` with a `MouseArea` for buttons. This works, but you end up rewriting hover states, press feedback, and accessibility each time. There's no standardized "button" component in basic QML.

```qml
Text {
  text: "Click me"
  font.pixelSize: 14
}

Image {
  source: "icon.svg"
  width: 24; height: 24
}

Rectangle {
  width: 100; height: 36
  color: "#3b82f6"
  MouseArea {
    anchors.fill: parent
    onClicked: print("clicked")
  }
}
```

<MentalModel>

Think of `Text` like a printed label on a physical button — it says what the button does. An icon is a symbol that conveys meaning faster than words (a gear for settings, a bell for notifications). A button is the physical actuator that makes something happen when you press it.

</MentalModel>

## The Idea

Quickshell doesn't reinvent these primitives — it leverages Qt Quick's `Text`, `Image` (or better, icon fonts), and the composability of QML to create reusable widget patterns. The key insight: you build your own button component once, then reuse it everywhere.

## Let's Build It

Let's create a reusable `ShellButton` component that combines an icon (using Nerd Font glyphs) with a text label:

<BuildIt>

```qml
// ShellButton.qml
import QtQuick
import QtQuick.Controls

Rectangle {
  id: root

  property string icon: ""
  property string label: ""
  property color baseColor: "#1e1e2e"
  property color hoverColor: "#313244"
  property color textColor: "#cdd6f4"
  property color accentColor: "#89b4fa"
  signal clicked()

  radius: 6
  color: mouseArea.containsMouse ? hoverColor : baseColor
  width: labelItem.visible ? labelItem.width + iconItem.width + 24 : iconItem.width + 16
  height: 32

  Row {
    anchors.centerIn: parent
    spacing: 6

    Text {
      id: iconItem
      text: root.icon
      font.pixelSize: 16
      color: root.accentColor
      visible: root.icon !== ""
    }

    Text {
      id: labelItem
      text: root.label
      font.pixelSize: 13
      color: root.textColor
      visible: root.label !== ""
    }
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
```

</BuildIt>

Now use it in a panel:

```qml
ShellButton {
  icon: ""
  label: "Power"
  onClicked: print("power menu")
}
```

## Let's Improve It

Add keyboard focus indication, press animation, and configurable sizing:

```qml
Rectangle {
  id: root
  property string icon: ""
  property string label: ""
  property color baseColor: "#1e1e2e"
  property color hoverColor: "#313244"
  property color textColor: "#cdd6f4"
  property color accentColor: "#89b4fa"
  signal clicked()

  radius: 6
  color: mouseArea.containsMouse
    ? (mouseArea.pressed ? Qt.lighter(hoverColor, 1.2) : hoverColor)
    : baseColor
  width: labelItem.visible ? labelItem.width + iconItem.width + 24 : iconItem.width + 16
  height: 32

  Behavior on color { ColorAnimation { duration: 100 } }

  Row {
    anchors.centerIn: parent
    spacing: 6

    Text {
      id: iconItem
      text: root.icon
      font.pixelSize: 16
      color: mouseArea.containsMouse ? root.textColor : root.accentColor
      visible: root.icon !== ""
    }

    Text {
      id: labelItem
      text: root.label
      font.pixelSize: 13
      color: root.textColor
      visible: root.label !== ""
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: 6
    color: "transparent"
    border.width: focusItem.activeFocus ? 2 : 0
    border.color: root.accentColor
  }

  Item { id: focusItem; focus: true; Keys.onReturnPressed: root.clicked() }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
```

<CommonMistake>

**Using bitmap images for icons.** SVG or icon fonts (Nerd Fonts) scale cleanly on HiDPI displays. Bitmap PNG icons look blurry at 2x or 3x scaling. Use Nerd Font glyphs as `Text` items — they're crisp at any size.

**Forgetting `hoverEnabled`.** Without `hoverEnabled: true` on your `MouseArea`, the `containsMouse` property never updates. Your hover effects will silently not work.

**Hardcoding colors everywhere.** Define color palettes as globals or theme properties. When you decide to switch from Catppuccin to Gruvbox, you'll thank yourself for not searching and replacing 200 hex codes.

</CommonMistake>

## Under the Hood

`Text` in QML renders using Qt's text layout engine, which supports rich text (HTML subset), eliding, and wrapping. For icons, using Nerd Font glyphs means the "icon" is just a character in a specially patched font — no image loading, no texture uploads. `MouseArea` is a transparent input region that captures mouse events and updates `containsMouse` and `pressed` properties reactively.

<UnderTheHood>

When you set `hoverEnabled: true`, `MouseArea` installs a hover event filter on the window. On Wayland, the compositor sends `wl_pointer.enter/leave` events, which Qt translates into QML hover signals. This round-trip is fast, but for very frequent updates (e.g., tracking mouse position every frame), consider using `QtQuick.Controls`' `HoverHandler` instead.

</UnderTheHood>

## Exercises

<ExerciseBlock :difficulty="1">
Create a `ShellButton` that shows only an icon (no label). Set its icon to the power symbol "⏻" and wire it to print "shutting down" to the console.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Extend `ShellButton` with a `tooltip` property. Use a `MouseArea.onEntered`/`onExited` to show/hide a floating `Rectangle` with the tooltip text positioned above the button.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Build a button group component that ensures only one button in a set is "active" at a time. Expose an `activeIndex` property and emit `activated(index)` when a button is clicked. Think radio buttons.
</ExerciseBlock>

<Recap :points="['Text renders labels and icon glyphs using Nerd Font characters', 'MouseArea handles click, hover, and press interactions', 'Reusable button components prevent repeating layout code', 'Hover effects require hoverEnabled: true', 'Icon fonts scale better than bitmap images on HiDPI']" next-chapter="/part-4-widgets/clock" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtquick-index.html -- Qt Quick documentation
- https://quickshell.org/docs/guide/introduction/ -- Quickshell widget patterns
-->

