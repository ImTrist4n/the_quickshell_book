---
title: "Models & Delegates"
description: "Separating data from presentation using models and delegates in QML"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['Components']" you-will-build="A list of workspace items using models and delegates" />

## The Problem

A desktop shell constantly displays lists of items: workspaces, notifications, open windows, system tray icons. Each item has data (name, state, icon) and a visual representation (how it looks on screen). Mixing data and presentation code is messy — if you change the data source, you have to rewrite the visual layout, and vice versa.

## The Naive Approach

You could hardcode each item:

```qml
Column {
  Text { text: "Workspace 1"; color: active ? "blue" : "gray" }
  Text { text: "Workspace 2"; color: active ? "blue" : "gray" }
  Text { text: "Workspace 3"; color: active ? "blue" : "gray" }
}
```

This works for three static items. But what if workspaces are dynamic (Hyprland can have any number)? What if the workspace data comes from an external source? Hardcoding doesn't adapt.

<MentalModel>

A model is a phone book — it holds the data (names, numbers). A delegate is the phone book's design — the font, the layout, the spacing. The phone company can change the design without touching the subscriber data, and subscribers can change without redesigning the book.

</MentalModel>

## The Idea

QML separates data from presentation using two concepts:

- **Model** — provides the data. Can be a static list, a JavaScript array, an integer (auto-generates indices), or a custom type.
- **Delegate** — a component that renders each item. The delegate is instantiated once per item in the model.

Views like `ListView`, `GridView`, and `Repeater` combine models with delegates to produce the visual output.

## Let's Build It

```qml
import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 350
  visible: true
  title: "Models & Delegates"

  // A JavaScript array as a model
  property var workspaces: [
    { name: "Main", active: true, windows: 3 },
    { name: "Code", active: false, windows: 5 },
    { name: "Web", active: false, windows: 2 },
    { name: "Chat", active: false, windows: 1 },
    { name: "Media", active: false, windows: 2 }
  ]

  Column {
    anchors.fill: parent
    anchors.margins: 16
    spacing: 8

    Text {
      text: "Workspaces"
      font.pixelSize: 18
      font.bold: true
      color: "#333"
    }

    // ColumnView using Repeater
    Column {
      width: parent.width
      spacing: 4

      Repeater {
        model: workspaces

        delegate: Rectangle {
          required property var modelData
          required property int index

          width: parent.width
          height: 44
          radius: 6
          color: modelData.active ? "#e8f4f8" : "#fafafa"
          border.color: modelData.active ? "#4ecdc4" : "#eee"
          border.width: modelData.active ? 2 : 1

          Row {
            anchors {
              left: parent.left; right: parent.right
              verticalCenter: parent.verticalCenter
              leftMargin: 12; rightMargin: 12
            }
            spacing: 10

            // Active indicator
            Rectangle {
              width: 8; height: 8; radius: 4
              anchors.verticalCenter: parent.verticalCenter
              color: modelData.active ? "#4ecdc4" : "#ccc"
            }

            // Workspace name
            Text {
              text: modelData.name
              font.pixelSize: 15
              font.bold: modelData.active
              color: modelData.active ? "#1a1a2e" : "#888"
              anchors.verticalCenter: parent.verticalCenter
            }

            // Spacer
            Item { width: 1; height: 1 }

            // Window count
            Text {
              text: modelData.windows + " windows"
              font.pixelSize: 12
              color: "#aaa"
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              workspaces = workspaces.map((ws, i) => ({
                ...ws,
                active: i === index
              }))
            }
          }
        }
      }
    }
  }
}
```

<BuildIt>

Key concepts:

- **`model: workspaces`** — the data source. A JavaScript array of objects, each with `name`, `active`, and `windows` properties.
- **`delegate:`** — defines the visual appearance of each item. It's a component that's instantiated once per model entry.
- **`required property var modelData`** — exposes the current item's data. This is automatically injected by the view.
- **`required property int index`** — the 0-based index of the current item.
- **`modelData.name`**, **`modelData.active`** — accessing properties of the current list item.

</BuildIt>

## Model Roles

When using JavaScript objects as models, each property of the object becomes a **role** that the delegate can access directly:

```qml
Repeater {
  model: [
    { name: "Main", active: true, windows: 3 },
    { name: "Code", active: false, windows: 5 }
  ]

  delegate: Rectangle {
    // Automatically available roles (shorter access):
    // name, active, windows, index, modelData
    color: active ? "blue" : "gray"
    Text { text: name + ": " + windows + " windows" }
  }
}
```

Roles are accessed by their property name directly — `name`, `active`, `windows` — without `modelData.` prefix, when the model item is a flat object with primitive-valued properties.

## ListModel

For more complex cases, QML provides `ListModel`:

```qml
ListModel {
  id: workspaceModel
  ListElement { name: "Main"; active: true; windows: 3 }
  ListElement { name: "Code"; active: false; windows: 5 }
}

// Use it:
Repeater {
  model: workspaceModel
  delegate: Text { text: name }
}

// Modify dynamically:
workspaceModel.append({ name: "New", active: false, windows: 0 })
workspaceModel.setProperty(0, "active", true)
workspaceModel.remove(2)
```

`ListModel` emits change signals when modified, so views update automatically — unlike plain JavaScript arrays where you must reassign the property.

<CommonMistake>

**Forgetting `required property` in the delegate.** Without it, the delegate won't receive model data. In older QML, you'd use `property var modelData` without `required`, but the modern pattern requires explicit declaration.

**Mutating array items in place.** `workspaces[0].active = true` changes the object but doesn't notify the view. Reassign the array: `workspaces = workspaces.map(...)` or use `ListModel`.

**Using `index` when the view reorders items.** If a view supports sorting or filtering, `index` reflects the visual position, not the model position. Use `modelIndex` for the model position if needed.

</CommonMistake>

## Under the Hood

`Repeater` instantiates all delegates immediately. For small lists (workspaces, system tray items), this is fine. For large lists, use `ListView` which virtualizes — it creates only visible delegates and reuses them as the user scrolls.

The `modelData` role is provided by the QML engine through the `QQmlDelegateModel` class. Each delegate is a separate QML context with `modelData` and role names injected as context properties. This is why you can access `name`, `active`, etc. without declaring them — they're injected into the delegate's scope.

## Exercises

<ExerciseBlock :difficulty="1">
Create a model with 5 `Person` objects (name, age, city). Use a `Repeater` and `Column` to display them. Each person should show their name in bold and age in lighter text.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Add a `ListModel` that supports dynamic operations. Include a text field and "Add" button that appends a new item to the model. The view should update automatically.
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Create a custom model using `QML`'s `ObjectModel` (from `QtQml.Models`). Use it to mix different delegate types — some items rendered as rectangles, others as images — in a single view.
</ExerciseBlock>

<Recap :points="['Models hold data, delegates define appearance — separation of concerns', 'JavaScript arrays, ListModel, and integers can all serve as models', 'Delegates access model data through roles like modelData, index, and named properties', 'ListModel provides mutation methods that automatically notify views']" next-chapter="/part-1-qml/repeaters" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-models-data-abstractmodels.html — Model documentation
- https://doc.qt.io/qt-6/qml-qtqml-models-listmodel.html — ListModel type
- https://doc.qt.io/qt-6/qml-qtquick-repeater.html — Repeater type
-->
