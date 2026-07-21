---
title: "JavaScript in QML"
description: "Using JavaScript expressions and functions inside QML"
---

<ChapterMeta reading-time="6 min" :difficulty="2" :prerequisites="['Property Bindings']" you-will-build="A QML file with JavaScript functions for data processing" />

## The Problem

Property bindings handle simple expressions — arithmetic, conditionals, string concatenation. But real shells need more: formatting dates, processing JSON responses from APIs, implementing search filters, computing complex layouts. You need real programming logic.

## The Naive Approach

You could try to cram everything into binding expressions:

```qml
text: "Today is " + ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][new Date().getDay()]
```

This works for one line. But try adding a multi-step calculation, error handling, or string manipulation, and binding expressions become unreadable.

## The Idea

QML embeds JavaScript as a first-class language. You can:

- Write functions in `function` blocks
- Call built-in Qt JavaScript helpers (`Qt.formatDate`, `Qt.md5`, etc.)
- Use standard JavaScript: arrays, objects, loops, `map`, `filter`, `reduce`
- Import external JavaScript files

<MentalModel>

Think of QML as the UI layer and JavaScript as the logic layer. QML declares *what* the UI looks like. JavaScript implements *how* the data flows. They're two languages in one file, each doing what it does best.

</MentalModel>

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 450
  height: 350
  visible: true
  title: "JavaScript in QML"

  // Property to hold raw data
  property string rawNames: "alice,bob,charlie,diana,evan"

  // JavaScript functions
  function capitalize(str) {
    if (!str) return ""
    return str.charAt(0).toUpperCase() + str.slice(1)
  }

  function parseNames(csv) {
    return csv.split(",").map(capitalize)
  }

  function formatList(names) {
    if (names.length === 0) return "(empty)"
    if (names.length === 1) return names[0]
    if (names.length === 2) return names[0] + " and " + names[1]
    return names.slice(0, -1).join(", ") + ", and " + names[names.length - 1]
  }

  // Computed property using a function
  readonly property var names: parseNames(rawNames)
  readonly property string displayText: formatList(names)

  Column {
    anchors {
      centerIn: parent
      margins: 20
    }
    spacing: 12

    Text {
      text: "Names: " + displayText
      font.pixelSize: 20
      font.bold: true
      color: "#1a56db"
      wrapMode: Text.WordWrap
      width: 400
    }

    Row {
      spacing: 8
      Repeater {
        model: names
        Rectangle {
          width: 60; height: 60; radius: 30
          color: Qt.hsla(Math.random() * 0.3 + 0.5, 0.6, 0.6, 1)

          Text {
            text: modelData[0]  // First initial
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 24
            font.bold: true
          }
        }
      }
    }

    Text {
      text: "Total: " + names.length + " names"
      font.pixelSize: 14
      color: "#888"
    }

    // Button to add a name
    Rectangle {
      width: 120; height: 36; radius: 6
      color: "#4ecdc4"

      Text {
        text: "Add Name"
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 14
        font.bold: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          var newName = "frank"
          rawNames = rawNames + "," + newName
          // names and displayText update automatically via bindings
        }
      }
    }
  }
}
```

<BuildIt>

Key JavaScript integration points:

- **`function capitalize(str) { ... }`** — a plain JavaScript function, callable from bindings and other JavaScript.
- **`parseNames(csv)`** — uses `split()`, `map()`, and the custom `capitalize` function. Standard JavaScript array methods work.
- **`names: parseNames(rawNames)`** — calling a function in a property declaration. The function runs once at creation *and* whenever `rawNames` changes.
- **`displayText: formatList(names)`** — another function call in a binding. When `names` updates (because `rawNames` changed), `displayText` re-evaluates.
- **`modelData[0]`** — JavaScript string indexing inside a `Repeater` delegate.

</BuildIt>

## Let's Improve It

You can also import standalone JavaScript libraries. Create a file `utils.js`:

```javascript
function formatBytes(bytes) {
  if (bytes === 0) return "0 B"
  const k = 1024
  const sizes = ["B", "KB", "MB", "GB", "TB"]
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + " " + sizes[i]
}
```

Then import and use it in a QML file using `as` to create a namespace:

<pre><code>import 'utils.js' as Utils

Text {
  text: Utils.formatBytes(2048000)
}
</code></pre>

The `as Utils` namespace prefix keeps imports organized and prevents naming collisions. Note that QML requires double quotes for import paths, but single quotes also work in modern QML.

Qt also provides built-in JavaScript helpers:

```qml
Text {
  text: Qt.formatDate(new Date(), "yyyy-MM-dd")
  // More helpers: Qt.formatTime, Qt.formatDateTime, Qt.md5, Qt.btoa, Qt.atob
}
```

<CommonMistake>

**Overusing JavaScript when QML bindings would suffice.** If you find yourself writing `function updateColor() { ... }` and calling it from `onPropertyChanged` handlers, consider whether a binding expression would be simpler.

**Modifying array/object properties imperatively.** QML's binding engine doesn't detect mutations to JavaScript arrays or objects. If you do `namesArray.push("frank")`, bindings that depend on `namesArray` may not update. Instead, reassign the property: `namesArray = namesArray.concat(["frank"])`.

**Forgetting that functions in bindings run on every dependency change.** A function called in a `text:` binding runs each time any of its inputs change. If the function is expensive (HTTP requests, file I/O), defer it to a timer or signal handler.

</CommonMistake>

## Under the Hood

QML's JavaScript engine is a full ECMAScript engine provided by Qt QML. It supports ES6+ features including arrow functions, `let`/`const`, template literals, promises, and `Map`/`Set`. However, the JavaScript context is *not* a browser — there's no `document`, `window`, or DOM API. You're in a Qt runtime with access to Qt types and the QML object tree.

Functions defined in QML files are compiled to `QQmlScriptBlob` objects and can access QML IDs and properties as if they were JavaScript variables. This is why `rawNames` is visible inside `parseNames` — it's captured from the enclosing QML scope.

## Exercises

<ExerciseBlock :difficulty="1">
Write a JavaScript function `randomColor()` that returns a random hex color string. Use it in a `Rectangle`'s `color` property.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a simple search filter: a `TextField` (from `QtQuick.Controls`) and a list of names. Use JavaScript's `filter()` method to show only names that contain the search text. (Use `property string searchText` and bind the filter result.)
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Write a JavaScript module file (`formatting.js`) with functions `formatDate`, `formatTime`, and `formatTemperature`. Import it into a QML file and use all three functions on a dashboard-style display.
</ExerciseBlock>

<Recap :points="['JavaScript functions in QML handle logic that bindings alone cannot express cleanly', 'Functions access QML properties and IDs from the enclosing scope', 'Import js files with import + as Namespace syntax', 'Use Qt.formatDate and other built-in helpers for common formatting', 'Array and object mutations require reassignment to trigger binding updates']" next-chapter="/part-1-qml/signals" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-javascript-functionlist.html — JavaScript functions in QML
- https://doc.qt.io/qt-6/qtqml-javascript-imports.html — Importing JavaScript
- https://doc.qt.io/qt-6/qtqml-javascript-qmlglobalobject.html — Qt JavaScript helpers
-->
