---
title: "IDs"
description: "Using IDs to reference QML objects — the glue that connects your UI"
---

<ChapterMeta reading-time="5 min" :difficulty="1" :prerequisites="['Properties']" you-will-build="An interactive counter that shows how IDs connect objects" />

## The Problem

In the previous chapter, we accessed the `count` property through `parent.parent.count`. This works for two levels of nesting, but it's fragile. If you restructure the object tree — add a new wrapper, change the nesting order — `parent.parent` breaks. You need a way to reference any object in the tree directly, regardless of nesting.

## The Naive Approach

You could store references in JavaScript variables:

```javascript
property var boxRef: null
// ... later in some init code:
boxRef = box
```

But this misses the point of QML's declarative nature. You shouldn't need imperative initialization code just to reference an object.

## The Idea

QML provides **IDs** — a lightweight way to name any object so other objects can reference it directly. An ID is declared with `id: someName` on any object, and then you can use `someName.property` anywhere in the same file. No `parent.parent`, no lookup chains.

<MentalModel>

Think of IDs as a phone book for your QML file. Each object can have an entry in the book (its `id`), and any other object can look it up by name. You don't need to navigate the object tree — you just call the name.

</MentalModel>

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 500
  height: 300
  visible: true
  title: "IDs"

  Rectangle {
    id: leftBox
    x: 20; y: 30
    width: 200; height: 200
    color: "#4ecdc4"
    radius: 8

    Text {
      id: leftLabel
      text: "I am leftBox"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 16
    }
  }

  Rectangle {
    id: rightBox
    x: 260; y: 30
    width: 200; height: 200
    color: "#ff6b6b"
    radius: 8

    Text {
      id: rightLabel
      text: "I reference leftBox"
      anchors.centerIn: parent
      color: "white"
      font.pixelSize: 14
      wrapMode: Text.WordWrap
      width: parent.width - 20
      horizontalAlignment: Text.AlignHCenter
    }
  }

  Rectangle {
    id: bottomBox
    x: 20; y: 250
    width: 460; height: 30
    color: leftBox.color  // Direct ID reference
    radius: 4
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      // Access objects by ID from JavaScript
      leftBox.color = "#ffe66d"
      leftLabel.text = "Clicked!"
      rightLabel.text = "leftBox is now yellow"
      bottomBox.color = rightBox.color
    }
  }
}
```

The bottom box sets its color directly to `leftBox.color` — a binding across siblings, using the ID `leftBox`. When you click, JavaScript code changes properties on `leftBox`, `leftLabel`, `rightLabel`, and `bottomBox` using their IDs.

<BuildIt>

Key points about IDs:

- **IDs are file-scoped.** Any object in the `.qml` file can reference any other object by ID. They're not global across files.
- **IDs start with a lowercase letter** by convention, though this is not enforced.
- **IDs are not properties.** You can't access `id` at runtime — `object.id` returns `undefined`. IDs are compile-time references, not runtime strings.
- **You can use IDs in both bindings and JavaScript.** `color: leftBox.color` is a declarative binding. `leftBox.color = "#ffe66d"` in JavaScript is an imperative assignment.

</BuildIt>

## Let's Improve It

IDs really shine when you have deeply nested objects. Compare:

```qml
// Without IDs — fragile parent chains
Text {
  text: parent.parent.parent.parent.someProperty
}

// With IDs — direct and robust
Text {
  text: someObject.someProperty
}
```

There's a practical difference: the first version breaks if you wrap the `Text` in an extra container. The second version works regardless of nesting.

<CommonMistake>

**Using the same ID twice.** IDs must be unique within a file. The QML engine will emit an error if you declare two objects with the same `id`.

**Trying to set id dynamically.** `id` is a compile-time attribute and cannot be changed at runtime. It must be declared inline in the object definition.

**Using `parent` when you mean an ID.** `parent` is a property that follows the object tree. If you restructure the tree, `parent` changes. An ID follows the object, not the tree.

</CommonMistake>

## Under the Hood

When the QML engine compiles a file, it builds a symbol table of IDs. Each ID maps to the C++ object pointer of the instantiated type. The mapping is established once at creation time — there's no lookup overhead at runtime. This is why `color: leftBox.color` is as efficient as `color: parent.color`.

The engine also tracks reverse dependencies: if `bottomBox.color` is bound to `leftBox.color`, the engine registers a dependency from `bottomBox`'s binding on `leftBox`'s `colorChanged` signal. When `leftBox.color` changes, it triggers re-evaluation of `bottomBox.color`'s binding.

## Exercises

<ExerciseBlock :difficulty="1">
Add a third rectangle between `leftBox` and `rightBox` with an ID. Connect it to the click handler so all three rectangles change color together.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Make `bottomBox`'s width bind to `leftBox.width + rightBox.width + 20` (the 20 is for the gap). Verify that resizing either side box updates `bottomBox`.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a circle (`Rectangle` with `radius: width / 2`) that always stays centered between `leftBox` and `rightBox`, regardless of their positions. Use IDs and mathematical bindings.
</ExerciseBlock>

<Recap :points="['IDs provide direct, stable references to any object in a QML file', 'IDs are file-scoped, unique, and created at compile time', 'Use IDs instead of parent chains for robust object references', 'IDs work in both declarative bindings and imperative JavaScript']" next-chapter="/part-1-qml/anchors" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html — ID attributes
-->
