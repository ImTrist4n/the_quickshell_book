---
title: "Property Bindings"
description: "Automatic property updates through QML's binding engine"
---

<ChapterMeta reading-time="7 min" :difficulty="2" :prerequisites="['Properties', 'IDs']" you-will-build="A temperature converter with live-updating bindings" />

## The Problem

You've already seen property bindings in action: `color: count % 2 === 0 ? "#4ecdc4" : "#ff6b6b"` updates whenever `count` changes. But property bindings are a deep concept — they're the mechanism that makes QML reactive, and understanding them thoroughly is essential for building shells that respond correctly to system events.

## The Naive Approach

Without bindings, you'd manually sync every property that depends on other properties:

```javascript
function updateUI() {
  celsiusDisplay.text = String(celsius)
  fahrenheitDisplay.text = String(celsius * 9/5 + 32)
  barIndicator.height = celsius * 2
  colorIndicator.color = celsius > 30 ? "red" : "blue"
}

// Call whenever celsius changes
onCelsiusChanged(updateUI)
onFahrenheitChanged(updateUI)
```

This works but has problems: you can forget to update something, you update things unnecessarily, and the code scatters the relationships across multiple functions.

<MentalModel>

Property bindings are like formulas in a spreadsheet. If cell C1 contains `=A1 + B1`, changing A1 or B1 automatically recalculates C1. In QML, every property can be a formula — an expression that re-evaluates whenever any of its inputs change.

</MentalModel>

## The Idea

A **property binding** is an expression assigned to a property that the QML engine automatically re-evaluates when its dependencies change. The key insight: **the assignment operator `:` creates bindings by default in QML**. When you write:

```qml
Text {
  text: celsius * 9/5 + 32 + "°F"
}
```

The `text` property is forever bound to `celsius`. Whenever `celsius` changes, `text` updates. You didn't connect a signal, register a listener, or call a function.

## Let's Build It

```qml
import QtQuick
import QtQuick.Window
import QtQuick.Controls

Window {
  width: 400
  height: 300
  visible: true
  title: "Property Bindings"

  // Source of truth
  property real celsius: 20

  Column {
    anchors {
      centerIn: parent
      topMargin: -30
    }
    spacing: 16

    // Slider controls celsius
    Slider {
      id: slider
      from: -20
      to: 45
      value: celsius  // Binding: slider follows celsius
      stepSize: 1
      anchors.horizontalCenter: parent.horizontalCenter

      onValueChanged: {
        celsius = value  // Imperative: slider changes celsius
      }
    }

    // Display bindings
    Text {
      text: celsius + "°C"
      anchors.horizontalCenter: parent.horizontalCenter
      font.pixelSize: 28
      font.bold: true
      color: celsius > 30 ? "#ff6b6b" : celsius < 0 ? "#4ecdc4" : "#333"
    }

    Text {
      // Expression with multiple dependent values
      text: celsius * 9/5 + 32 + "°F"
      anchors.horizontalCenter: parent.horizontalCenter
      font.pixelSize: 18
      color: "#888"
    }

    // Rectangle whose size and color bind to celsius
    Rectangle {
      id: bar
      anchors.horizontalCenter: parent.horizontalCenter
      width: 200
      height: 20
      radius: 4

      // Color transitions based on temperature
      color: {
        if (celsius < 0) return "#4ecdc4"
        if (celsius < 25) return "#45b7d1"
        if (celsius < 35) return "#ffe66d"
        return "#ff6b6b"
      }

      Rectangle {
        // Width fills proportionally
        anchors {
          left: parent.left
          top: parent.top
          bottom: parent.bottom
          leftMargin: 1
        }
        width: Math.max(2, (parent.width - 2) * Math.max(0, Math.min(1,
          (celsius + 20) / 65)))

        radius: 3
        color: Qt.lighter(parent.color, 1.3)
      }
    }

    Text {
      // Binding using conditional logic
      text: {
        if (celsius > 35) return "🔥 Hot!"
        if (celsius > 25) return "☀️ Warm"
        if (celsius > 10) return "🌤️ Mild"
        if (celsius > 0) return "❄️ Cool"
        return "🥶 Freezing!"
      }
      anchors.horizontalCenter: parent.horizontalCenter
      font.pixelSize: 14
      color: "#888"
    }
  }
}
```

<BuildIt>

Key binding patterns shown here:

1. **`color: celsius > 30 ? "#ff6b6b" : celsius < 0 ? "#4ecdc4" : "#333"`** — a conditional binding that re-evaluates when `celsius` changes.

2. **`text: celsius * 9/5 + 32 + "°F"`** — an arithmetic binding. The expression is recalculated as a single unit.

3. **`color: { ... }`** — a block expression binding. The last value in the block is the binding's result. Blocks can contain multiple statements for complex logic.

4. **`width: Math.max(2, (parent.width - 2) * ...)`** — a binding using JavaScript math functions.

</BuildIt>

## Binding vs. Assignment

There's a critical distinction you must understand:

```qml
// THIS creates a binding:
text: celsius * 9/5 + 32 + "°F"

// THIS destroys the binding and assigns a one-time value:
text = celsius * 9/5 + 32 + "°F"
```

The difference is `:` vs `=`. In QML declarations, `:` sets up a binding. In JavaScript blocks, `=` performs a one-time assignment. If you accidentally use `=` in a property declaration, you'll get an error. If you use `=` inside a JavaScript function on a property that was previously bound, you break the binding permanently.

```qml
Text {
  id: display
  text: celsius + "°C"  // Binding
}

// Later in a JavaScript block:
display.text = "25°C"  // Assigns once, binding is destroyed!
// Now display.text will NOT update when celsius changes
```

## Let's Improve It

To update a property without breaking its binding, modify the *source* property instead:

```qml
// Instead of:
// display.text = String(celsius + 1)  // Breaks binding

// Do:
celsius = celsius + 1  // Update source; bindings re-evaluate automatically
```

If you must assign from JavaScript and keep the binding, use `Qt.binding()`:

```qml
display.text = Qt.binding(function() { return celsius + "°C" })
```

But this is rarely necessary. The declarative approach — defining the relationship once in the property declaration — is almost always cleaner.

<CommonMistake>

**Breaking a binding unintentionally.** This is the #1 pitfall. Any `=` assignment to a property inside a JavaScript block destroys that property's binding. If you find a property that stopped updating, check that some JavaScript didn't assign to it directly.

**Circular bindings.** If A binds to B and B binds to A, you create a circular dependency. The QML engine detects this and emits a warning. Avoid designing interdependent bindings.

**Using too-complex expressions in bindings.** If a binding expression does heavy computation (parsing data, building strings), it runs on every dependency change. Keep binding expressions fast. For heavy work, compute in a JavaScript function and update periodically.

</CommonMistake>

## Under the Hood

When the QML engine encounters a property assignment with `:`, it doesn't evaluate the expression immediately. Instead, it:

1. Parses the expression into a `QQmlBinding` object
2. Scans the expression for dependencies (property reads like `celsius`, `parent.width`)
3. Connects to each dependency's `NOTIFY` signal (Qt's change notification mechanism)
4. Evaluates the expression and stores the result
5. When any dependency signals a change, re-evaluates and updates the property

This is called **automatic dependency tracking**. The engine doesn't know in advance what a binding depends on — it discovers dependencies by observing which property getters are called during the first evaluation.

## Exercises

<ExerciseBlock :difficulty="1">
Add a humidity property (`real humidity: 50`) and a `Text` that displays "Humidity: X%" that updates when you change humidity. Use `onValueChanged` on a second `Slider`.
</ExerciseBlock>

<ExerciseBlock :difficulty="2">
Create a heat index display (`text`) that combines `celsius` and `humidity` using the formula: heatIndex = celsius + 0.555 * (6.11 * 10^(7.5 * celsius / (237.7 + celsius)) - 10) * humidity / 100. (Approximate is fine.)
</ExerciseBlock>

<ExerciseBlock :difficulty="3">
Add a `readonly property string temperatureCategory` that uses a binding (not imperative code) to return one of "freezing", "cold", "mild", "warm", "hot" based on `celsius`. Use this property in multiple binding expressions across the UI.
</ExerciseBlock>

<Recap :points="['Property bindings are expressions that re-evaluate when dependencies change', 'The : operator creates bindings; the = operator performs one-time assignment and destroys bindings', 'Modify source properties to trigger binding updates, not the bound property itself', 'Binding expressions should be fast — heavy computation belongs in separate functions']" next-chapter="/part-1-qml/javascript-in-qml" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qtqml-syntax-propertybinding.html — Property binding documentation
- https://doc.qt.io/qt-6/qtqml-syntax-objectattributes.html#binding-to-a-property — Binding syntax
-->
