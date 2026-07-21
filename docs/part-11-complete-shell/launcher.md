---
title: "Launcher"
description: "A keyboard-driven application launcher for the complete shell"
---

<ChapterMeta reading-time="12 min" :difficulty="2" :prerequisites="['PopupWindow', 'ListView', 'Qt.process']" you-will-build="A fuzzy-search application launcher" />

## The Problem

Users need to launch applications quickly without lifting their hands from the keyboard or navigating through menus. A launcher combines search with application discovery.

## The Naive Approach

Use a `TextInput` and hardcoded app list:

```qml
TextInput {
  onAccepted: Qt.process([text])
}
```

This expects users to type exact executable names. No search, no discovery, no desktop file integration.

<MentalModel>

Think of a launcher as a search engine for your computer. You type what you want to do ("write a document", "browse the web") and it shows matching applications. The best match is pre-selected — just press Enter to launch.

</MentalModel>

## The Idea

Parse `.desktop` files from XDG data directories into a searchable list. Display results in a `ListView` with fuzzy matching. Highlight the best match and launch on Enter.

## Let's Build It

```qml
// Launcher.qml
PopupWindow {
  id: launcher
  width: 500; height: 400
  visible: false
  dismissOnClickOutside: true

  property string searchText: ""
  property var apps: []
  property var filtered: []

  function loadApps() {
    Qt.process(["bash", "-c", "ls /usr/share/applications/*.desktop ~/.local/share/applications/*.desktop 2>/dev/null"])
      .onStdout.connect(function(data) {
        apps = data.trim().split("\n").filter(function(p) { return p }).map(function(path) {
          return path.split("/").pop().replace(".desktop", "")
        }).sort()
      })
  }

  function filterApps() {
    if (!searchText) { filtered = apps.slice(0, 20); return }
    var q = searchText.toLowerCase()
    filtered = apps.filter(function(a) {
      return a.toLowerCase().indexOf(q) >= 0
    }).slice(0, 20)
  }

  Component.onCompleted: loadApps()

  Rectangle {
    anchors.fill: parent; radius: 8; color: "#1e1e2e"

    Column {
      anchors { fill: parent; margins: 12 }; spacing: 8

      Rectangle {
        width: parent.width; height: 40; radius: 6; color: "#313244"
        TextInput {
          id: input
          anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
          font.pixelSize: 15; color: "#cdd6f4"
          placeholderText: "Search applications..."
          focus: true
          onTextChanged: { launcher.searchText = text; launcher.filterApps() }
          Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Down) listView.incrementCurrentIndex()
            else if (event.key === Qt.Key_Up) listView.decrementCurrentIndex()
            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              if (listView.currentIndex >= 0 && listView.currentIndex < filtered.length) {
                Qt.execDetached({ command: filtered[listView.currentIndex] })
                launcher.visible = false
              }
            }
            else if (event.key === Qt.Key_Escape) launcher.visible = false
          }
        }
      }

      ListView {
        id: listView
        width: parent.width; height: parent.height - 60
        model: filtered
        spacing: 2; clip: true

        delegate: Rectangle {
          required property string modelData
          required property int index
          width: parent.width; height: 36; radius: 4
          color: index === listView.currentIndex ? "#45475a" : "transparent"

          Row {
            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }; spacing: 8
            anchors.verticalCenter: parent.verticalCenter
            Text {
              text: modelData.charAt(0).toUpperCase()
              font.pixelSize: 14; color: "#89b4fa"
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: modelData
              font.pixelSize: 13; color: "#cdd6f4"
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              Qt.execDetached({ command: modelData })
              launcher.visible = false
            }
          }
        }

        ScrollBar.vertical: ScrollBar { active: true }
      }
    }
  }
}
```

<BuildIt>

The launcher loads `.desktop` filenames at startup, filters by substring match as the user types, and displays results in a `ListView`. Arrow keys navigate, Enter launches, Escape dismisses.

</BuildIt>

## Let's Improve It

Add fuzzy matching with scoring and result caching:

```qml
function fuzzyScore(query, target) {
  var q = query.toLowerCase(), t = target.toLowerCase()
  if (t.indexOf(q) >= 0) return 100 - (t.indexOf(q) * 5)  // prefix matches score highest
  // Simple character-by-character matching
  var score = 0, qi = 0
  for (var ti = 0; ti < t.length && qi < q.length; ti++) {
    if (t[ti] === q[qi]) { score += 10; qi++ }
  }
  return qi === q.length ? score : 0
}
```

<CommonMistake>

**Parsing full .desktop files.** `Exec=` lines contain field codes (`%f`, `%u`, `%F`, `%U`) that must be stripped. Use a proper `.desktop` parser or rely on the executable name from the filename.

**No debouncing.** Filtering 1000+ apps on every keystroke causes visible lag. Debounce at 100ms, or move filtering to a worker.

**Forgetting `TryExec`.** Some `.desktop` files have `TryExec` — don't show apps whose `TryExec` binary isn't installed.

</CommonMistake>

## Under the Hood

XDG `.desktop` files are INI-format files located in `/usr/share/applications/` and `~/.local/share/applications/`. Each file has a `Name` (human-readable), `Exec` (command to run), `Icon` (themed icon name), and `Categories` (for grouping). The launcher parses these to build its search index.

## Exercises

<ExerciseBlock :difficulty="1">
Parse the full `.desktop` file to extract `Name`, `GenericName`, and `Comment`. Search against all three fields, not just the filename. Show the `Comment` as a subtitle in the results.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a "most-used" section at the top of results. Track launch count in `Quickshell.statePath("launcher-history.json")`. Sort results by frequency when no search query is entered.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Implement a "calculator mode" — when the search text looks like a math expression (`2+2`, `sqrt(144)`), evaluate it using `JavaScript` and show the result as the first entry. Selecting it copies the result to the clipboard.
</ExerciseBlock>

<Recap :points="['Parse XDG .desktop files for app search', 'Use fuzzy matching with scoring for better result ordering', 'Keyboard navigation: arrows, Enter, Escape', 'Debounce search and cache results for performance']" next-chapter="/part-11-complete-shell/top-bar" />

<!--
Sources verified for this chapter:
- https://specifications.freedesktop.org/desktop-entry-spec/latest/ — Desktop Entry Specification
- https://quickshell.org/docs/v0.3.0/types/Quickshell/PopupWindow/ — PopupWindow
- https://doc.qt.io/qt-6/qml-qtquick-controls-listview.html — ListView
-->
