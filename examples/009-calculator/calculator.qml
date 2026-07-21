import QtQuick
import QtQuick.Window

Window {
  width: 300
  height: 400
  title: "Calculator"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    property string displayText: "0"
    property real leftOperand: 0
    property string operator: ""
    property bool freshInput: true

    function digitPressed(d) {
      if (freshInput) {
        displayText = d
        freshInput = false
      } else {
        displayText = displayText === "0" ? d : displayText + d
      }
    }

    function operatorPressed(op) {
      leftOperand = parseFloat(displayText)
      operator = op
      freshInput = true
    }

    function equalsPressed() {
      var right = parseFloat(displayText)
      var result = 0
      switch (operator) {
        case "+": result = leftOperand + right; break
        case "−": result = leftOperand - right; break
        case "×": result = leftOperand * right; break
        case "÷": result = right !== 0 ? leftOperand / right : 0; break
        default: result = right
      }
      displayText = String(result)
      operator = ""
      freshInput = true
    }

    function clearPressed() {
      displayText = "0"
      leftOperand = 0
      operator = ""
      freshInput = true
    }

    Column {
      anchors.fill: parent
      anchors.margins: 16
      spacing: 8

      Rectangle {
        width: parent.width
        height: 64
        color: "#181825"
        radius: 8

        Text {
          anchors.right: parent.right
          anchors.rightMargin: 12
          anchors.verticalCenter: parent.verticalCenter
          text: displayText
          color: "#cdd6f4"
          font.pixelSize: 32
        }
      }

      Grid {
        columns: 4
        spacing: 6
        width: parent.width

        CalcButton { text: "C"; bgColor: "#f38ba8"; textColor: "#1e1e2e"; onClicked: clearPressed() }
        CalcButton { text: "÷"; bgColor: "#45475a"; onClicked: operatorPressed("÷") }
        CalcButton { text: "×"; bgColor: "#45475a"; onClicked: operatorPressed("×") }
        CalcButton { text: "⌫"; bgColor: "#45475a"; onClicked: { displayText = displayText.slice(0, -1) || "0" } }

        CalcButton { text: "7"; onClicked: digitPressed("7") }
        CalcButton { text: "8"; onClicked: digitPressed("8") }
        CalcButton { text: "9"; onClicked: digitPressed("9") }
        CalcButton { text: "−"; bgColor: "#45475a"; onClicked: operatorPressed("−") }

        CalcButton { text: "4"; onClicked: digitPressed("4") }
        CalcButton { text: "5"; onClicked: digitPressed("5") }
        CalcButton { text: "6"; onClicked: digitPressed("6") }
        CalcButton { text: "+"; bgColor: "#45475a"; onClicked: operatorPressed("+") }

        CalcButton { text: "1"; onClicked: digitPressed("1") }
        CalcButton { text: "2"; onClicked: digitPressed("2") }
        CalcButton { text: "3"; onClicked: digitPressed("3") }
        CalcButton { text: "="; bgColor: "#89b4fa"; textColor: "#1e1e2e"; onClicked: equalsPressed() }

        CalcButton { text: "0"; width: 134; onClicked: digitPressed("0") }
        CalcButton { text: "."; onClicked: { if (!displayText.includes(".")) displayText += "." } }
        CalcButton { text: "±"; onClicked: { displayText = String(-parseFloat(displayText)) } }
      }
    }
  }
}
