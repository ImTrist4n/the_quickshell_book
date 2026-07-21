---
title: "Project: Build a Calculator"
description: "Apply everything from Part I to build a working calculator in QML"
---

<ChapterMeta reading-time="12 min" :difficulty="3" :prerequisites="['Timers', 'Animations', 'States', 'Components', 'Signals', 'JavaScript in QML']" you-will-build="A fully functional calculator with animated buttons and keyboard input" />

## The Problem

You've learned QML's building blocks. Now you'll combine them into a real application. A calculator exercises everything: UI layout, state management, event handling, component design, and keyboard integration — without needing external dependencies.

## The Idea

We'll build a calculator with:

- Display showing current input and result
- Basic operations: +, −, ×, ÷
- Animated button presses with color feedback
- Full keyboard support
- Error handling (division by zero)

## Let's Build It

First, create the button component `CalcButton.qml`:

```qml
// CalcButton.qml
import QtQuick

Rectangle {
  id: root

  property string text: ""
  property color baseColor: "#2a2a3e"
  signal clicked()

  width: 64; height: 56; radius: 8
  color: mouseArea.pressed ? Qt.lighter(baseColor, 1.3) :
         mouseArea.containsMouse ? Qt.lighter(baseColor, 1.1) : baseColor

  Behavior on color { ColorAnimation { duration: 80 } }

  Text {
    text: root.text
    anchors.centerIn: parent
    color: "#e0e0e0"
    font.pixelSize: 20
    font.bold: true
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: root.clicked()

    // Scale animation on press
    onPressed: root.scale = 0.92
    onReleased: root.scale = 1.0
  }

  NumberAnimation on scale {
    duration: 80
    easing.type: Easing.OutQuad
  }
}
```

Now the main calculator:

```qml
// calculator.qml
import QtQuick
import QtQuick.Window
import QtQuick.Layouts

Window {
  id: root
  width: 280; height: 440
  visible: true
  title: "Calculator"
  minimumWidth: 260; minimumHeight: 400

  // State
  property string currentInput: "0"
  property string previousInput: ""
  property string operator: ""
  property bool waitingForOperand: false
  property bool hasError: false

  // Logic
  function inputDigit(digit) {
    if (hasError) { clear(); return }
    if (waitingForOperand) {
      currentInput = String(digit)
      waitingForOperand = false
    } else {
      currentInput = currentInput === "0" ? String(digit) : currentInput + digit
    }
  }

  function inputDecimal() {
    if (hasError) { clear(); return }
    if (waitingForOperand) { currentInput = "0."; waitingForOperand = false; return }
    if (currentInput.indexOf(".") === -1) currentInput += "."
  }

  function handleOperator(op) {
    if (hasError) { clear(); return }
    if (operator !== "" && !waitingForOperand) calculate()
    previousInput = currentInput
    operator = op
    waitingForOperand = true
  }

  function calculate() {
    if (operator === "" || hasError) return
    var a = parseFloat(previousInput)
    var b = parseFloat(currentInput)
    var result = 0
    switch (operator) {
      case "+": result = a + b; break
      case "−": result = a - b; break
      case "×": result = a * b; break
      case "÷":
        if (b === 0) { showError(); return }
        result = a / b; break
    }
    currentInput = String(result)
    operator = ""
    waitingForOperand = true
  }

  function clear() {
    currentInput = "0"; previousInput = ""
    operator = ""; waitingForOperand = false; hasError = false
  }

  function showError() {
    currentInput = "Error"; hasError = true
    operator = ""; waitingForOperand = false
  }

  function backspace() {
    if (hasError) { clear(); return }
    if (waitingForOperand) return
    currentInput = currentInput.length > 1 ? currentInput.slice(0, -1) : "0"
  }

  // Keyboard
  Keys.onPressed: (event) => {
    if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9)
      inputDigit(event.key - Qt.Key_0)
    else if (event.key === Qt.Key_Period || event.key === Qt.Key_Comma)
      inputDecimal()
    else if (event.key === Qt.Key_Backspace)
      backspace()
    else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
      calculate()
    else if (event.key === Qt.Key_Plus) handleOperator("+")
    else if (event.key === Qt.Key_Minus) handleOperator("−")
    else if (event.key === Qt.Key_Asterisk) handleOperator("×")
    else if (event.key === Qt.Key_Slash) handleOperator("÷")
    else if (event.key === Qt.Key_Escape) clear()
    event.accepted = true
  }

  // UI
  Rectangle {
    anchors.fill: parent; color: "#1a1a2e"

    ColumnLayout {
      anchors.fill: parent; anchors.margins: 12; spacing: 8

      // Display
      Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 100
        radius: 8; color: "#16213e"

        Column {
          anchors { right: parent.right; bottom: parent.bottom; margins: 16 }
          spacing: 4
          Text {
            text: operator ? previousInput + " " + operator : ""
            font.pixelSize: 14; color: "#888"; anchors.right: parent.right
          }
          Text {
            text: currentInput
            font.pixelSize: hasError ? 20 : 36; font.bold: true
            color: hasError ? "#ff6b6b" : "white"; anchors.right: parent.right
          }
        }
      }

      // Buttons
      GridLayout {
        Layout.fillWidth: true; Layout.fillHeight: true
        columns: 4; rowSpacing: 6; columnSpacing: 6

        // Row 1
        CalcButton { text: "C"; baseColor: "#ff6b6b"; onClicked: clear() }
        CalcButton { text: "+/−"; baseColor: "#ff9f43"; onClicked: { currentInput = String(-parseFloat(currentInput)) } }
        CalcButton { text: "%"; baseColor: "#ff9f43"; onClicked: { currentInput = String(parseFloat(currentInput) / 100) } }
        CalcButton { text: "÷"; baseColor: "#45b7d1"; onClicked: handleOperator("÷") }

        // Row 2
        CalcButton { text: "7"; onClicked: inputDigit(7) }
        CalcButton { text: "8"; onClicked: inputDigit(8) }
        CalcButton { text: "9"; onClicked: inputDigit(9) }
        CalcButton { text: "×"; baseColor: "#45b7d1"; onClicked: handleOperator("×") }

        // Row 3
        CalcButton { text: "4"; onClicked: inputDigit(4) }
        CalcButton { text: "5"; onClicked: inputDigit(5) }
        CalcButton { text: "6"; onClicked: inputDigit(6) }
        CalcButton { text: "−"; baseColor: "#45b7d1"; onClicked: handleOperator("−") }

        // Row 4
        CalcButton { text: "1"; onClicked: inputDigit(1) }
        CalcButton { text: "2"; onClicked: inputDigit(2) }
        CalcButton { text: "3"; onClicked: inputDigit(3) }
        CalcButton { text: "+"; baseColor: "#45b7d1"; onClicked: handleOperator("+") }

        // Row 5
        CalcButton { text: "0"; onClicked: inputDigit(0); Layout.columnSpan: 2; Layout.preferredWidth: 134 }
        CalcButton { text: "."; onClicked: inputDecimal() }
        CalcButton { text: "="; baseColor: "#4ecdc4"; onClicked: calculate() }
      }
    }
  }
}
```

<BuildIt>

What this project demonstrates:

- **Component abstraction** — `CalcButton` encapsulates button appearance, hover, press, and animation. Used 19 times with different properties.
- **State management** — six properties track calculator state. All UI derives from them.
- **JavaScript logic** — `inputDigit`, `calculate`, `handleOperator`, etc. are pure JS functions called from signal handlers.
- **Signal-based architecture** — `CalcButton` emits `clicked()`, main file connects it to logic functions. No tight coupling.
- **Keyboard integration** — `Keys.onPressed` maps physical keys to the same functions as button clicks.
- **Animations** — `ColorAnimation` on button hover, `NumberAnimation` on scale for press feedback.
- **Layout** — `GridLayout` arranges buttons in a 5×4 grid with `columnSpan` for the zero button.

</BuildIt>

<CommonMistake>

**Not handling floating-point precision.** JavaScript's `parseFloat` and arithmetic produce results like `0.1 + 0.2 = 0.30000000000000004`. For a calculator project this is acceptable, but for a financial app you'd use fixed-point arithmetic or rounding.

**Button not releasing focus after click.** If a button "steals" focus from the window, keyboard shortcuts stop working. Ensure the window has `focus: true` and buttons don't call `forceActiveFocus()`.

</CommonMistake>

## Exercises

<ExerciseBlock :difficulty="1">Add keyboard shortcut indicators to buttons. For example, display "Esc" on the C button, "Enter" on the = button. Use a smaller secondary text on each button.</ExerciseBlock>

<ExerciseBlock :difficulty="2">Add a history panel that records previous calculations. Use a `ListModel` to store each completed calculation as a string (e.g., "5 + 3 = 8") and display it in a `ListView` that slides in from the right.</ExerciseBlock>

<ExerciseBlock :difficulty="3">Implement square root (√) and power (x²) operations. Add a "mode" toggle between basic and scientific modes, with additional buttons appearing when scientific mode is active. Use `Repeater` with a model that switches between button sets.</ExerciseBlock>

<Recap :points="['Components encapsulate reusable UI with customizable properties and signals', 'State management keeps all UI derived from a small set of source properties', 'Keyboard input is handled declaratively via Keys.onPressed', 'Animation adds polish — subtle scale and color changes on interaction', 'GridLayout with columnSpan creates complex button grids']" next-chapter="/part-2-quickshell/what-quickshell-adds" />

<!--
Sources verified for this chapter:
- https://doc.qt.io/qt-6/qml-qtquick-controls2-gridlayout.html — GridLayout
- https://doc.qt.io/qt-6/qml-qtquick-keys.html — Keys attached property
- https://doc.qt.io/qt-6/qml-qtquick-rectangle.html — Rectangle type
-->
