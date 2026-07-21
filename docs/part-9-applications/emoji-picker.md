---
title: "Emoji Picker"
description: "Building a searchable emoji picker popup for your shell"
---

<ChapterMeta reading-time="10 min" :difficulty="2" :prerequisites="['PopupWindow', 'ListView']" you-will-build="A searchable emoji picker that copies emoji to the clipboard" />

## The Problem

Emoji are everywhere in modern communication. Users need a quick way to insert them into text fields, chat apps, and documents. System-level emoji pickers (like GNOME's or KDE's) exist, but they're tied to specific desktop environments. A shell-integrated emoji picker works on any compositor.

## The Naive Approach

Simulate key combinations to open the OS emoji picker:

```qml
function openEmojiPicker() {
  Qt.process(["wtype", "-k", "ctrl", "-k", "shift", "-k", "e"])
}
```

This only works on GNOME/KDE with specific shortcuts configured. On Wayland, it requires `wtype` or similar tools for keyboard simulation.

<MentalModel>

Think of an emoji picker as a specialized search engine for smileys. You type what you feel ("happy", "food", "travel"), and it returns matching emoji. Click one, and it's on your clipboard ready to paste.

</MentalModel>

## The Idea

An emoji picker is a `PopupWindow` containing a search field, a `ListView` of filtered results, and category tabs. The emoji data is a JSON file bundled with your shell or fetched from a standard source like the Unicode Consortium's emoji list.

## Let's Build It

```qml
import Quickshell
import Quickshell.Services
import QtQml.Models

PopupWindow {
  id: root
  width: 360
  height: 420
  visible: false

  property string searchText: ""
  property var emojiData: loadEmojiData()

  function loadEmojiData() {
    // Simplified emoji set — in production, load from a JSON file
    return [
      { emoji: "😀", name: "grinning face", category: "smileys" },
      { emoji: "😂", name: "joy", category: "smileys" },
      { emoji: "🥰", name: "smiling face with hearts", category: "smileys" },
      { emoji: "😎", name: "smiling face with sunglasses", category: "smileys" },
      { emoji: "👍", name: "thumbs up", category: "gestures" },
      { emoji: "👎", name: "thumbs down", category: "gestures" },
      { emoji: "👋", name: "waving hand", category: "gestures" },
      { emoji: "🔥", name: "fire", category: "objects" },
      { emoji: "❤️", name: "red heart", category: "symbols" },
      { emoji: "⭐", name: "star", category: "symbols" },
      { emoji: "🍕", name: "pizza", category: "food" },
      { emoji: "☕", name: "coffee", category: "food" },
      { emoji: "🚀", name: "rocket", category: "travel" },
      { emoji: "💻", name: "laptop", category: "objects" }
    ]
  }

  function copyEmoji(emoji) {
    Clipboard.text = emoji
    root.visible = false
  }

  Rectangle {
    anchors.fill: parent; color: "#1e1e2e"; radius: 8

    Column {
      anchors.fill: parent; anchors.margins: 12; spacing: 8

      Rectangle {
        width: parent.width; height: 36; radius: 6; color: "#313244"
        TextInput {
          id: searchField
          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          font.pixelSize: 14; color: "#cdd6f4"
          placeholderText: "Search emoji..."; placeholderTextColor: "#6c7086"
          onTextChanged: root.searchText = text
        }
      }

      ListView {
        width: parent.width; height: parent.height - 60
        model: emojiData.filter(item =>
          item.name.toLowerCase().includes(root.searchText.toLowerCase()) ||
          item.emoji.includes(root.searchText)
        )
        spacing: 2; clip: true

        delegate: Rectangle {
          required property var modelData
          width: parent.width; height: 40; radius: 4; color: "#313244"

          Row {
            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
            spacing: 12; anchors.verticalCenter: parent.verticalCenter

            Text { text: modelData.emoji; font.pixelSize: 24; anchors.verticalCenter: parent.verticalCenter }
            Text { text: modelData.name; font.pixelSize: 13; color: "#cdd6f4"; anchors.verticalCenter: parent.verticalCenter }
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: copyEmoji(modelData.emoji)
          }
        }

        ScrollBar.vertical: ScrollBar { active: true }
      }
    }
  }
}
```

<BuildIt>

The emoji picker uses a flat JSON array as its data source. Each emoji has an `emoji` (the actual Unicode character), `name` (searchable description), and `category` (for future tab filtering). The `TextInput` filters the list in real-time as the user types.

</BuildIt>

## Let's Improve It

Add category tabs and recently-used tracking:

```qml
property var recentEmoji: loadRecent()
property string activeCategory: "recent"

Row {
  spacing: 4
  Repeater {
    model: ["recent", "smileys", "gestures", "objects", "food", "travel", "symbols"]
    delegate: Rectangle {
      required property string modelData
      width: 36; height: 28; radius: 4
      color: modelData === activeCategory ? "#89b4fa" : "#45475a"
      Text {
        text: modelData[0].toUpperCase()
        anchors.centerIn: parent; color: "white"; font.pixelSize: 12
      }
      MouseArea { anchors.fill: parent; onClicked: activeCategory = modelData }
    }
  }
}
```

<CommonMistake>

**Hardcoding the emoji list.** The Unicode standard adds new emoji yearly. Bundle a `emoji.json` file from a maintained source like `github.com/muan/emojilib` and load it at startup. Check for updates periodically.

**Not supporting skin tones.** Many emoji support Fitzpatrick skin tone modifiers (🏽, 🏾, 🏿). Show skin tone selectors when a relevant emoji is selected, or use zero-width joiner sequences for the full range.

**Ignoring search relevance.** Simple substring search returns poor results for abbreviations. Use a scoring function that prioritizes emoji where the search term appears at the start of the name, and boosts commonly-used emoji.

</CommonMistake>

## Under the Hood

Emoji are Unicode characters in specific ranges (U+1F300–U+1F9FF for most pictographic emoji). The emoji picker doesn't "insert" an emoji — it copies the Unicode character to the clipboard via `Clipboard.text = "🚀"`. The user then pastes it into their target application. This approach works universally because every modern application accepts Unicode paste.

For keyboard-driven interaction, the picker should support Tab to move through results, Enter to select, and Escape to close — implemented via `Keys.onPressed` on the `PopupWindow`.

## Exercises

<ExerciseBlock :difficulty="1">
Add skin tone support. When an emoji that supports skin tones is selected, show a row of 5 skin tone variant buttons. Append the appropriate Fitzpatrick modifier to the emoji character.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Implement the recent emoji list. Store selected emoji in a `ListModel` (max 20), display them in a separate "Recent" tab. Persist to `Quickshell.statePath("recent-emoji.json")`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Load the full emoji dataset from `emojilib` or `unicode-emoji-json`. Implement category tabs that filter the list. Add a "frequently used" section that sorts by usage count. Bundle the JSON as a Qt resource file.
</ExerciseBlock>

<Recap :points="['Emoji picker copies Unicode emoji characters to the clipboard', 'Search filtering with real-time ListView updates provides quick access', 'Bundle emoji data from a maintained source for up-to-date coverage', 'Keyboard navigation (Tab/Enter/Escape) improves power-user workflow']" next-chapter="/part-9-applications/clipboard-manager" />

<!--
Sources verified for this chapter:
- https://unicode.org/emoji/charts/ — Unicode Emoji charts
- https://github.com/muan/emojilib — emoji keyword library
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/ — PopupWindow type
-->
