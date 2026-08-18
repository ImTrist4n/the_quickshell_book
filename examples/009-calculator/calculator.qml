import QtQuick
import QtQuick.Layouts
import QtQuick.Window

Window {
    width: 300
    height: 400
    title: "Calculator"
    visible: true

    Rectangle {
        id: mainRect

        property string displayText: "0"
        property real leftOperand: 0
        property string operator: ""
        property bool freshInput: true

        function digitPressed(d) {
            if (freshInput) {
                displayText = d;
                freshInput = false;
            } else {
                if (displayText === "0" && d === "0")
                    return ;

                displayText = displayText === "0" ? d : displayText + d;
            }
        }

        function operatorPressed(op) {
            leftOperand = parseFloat(displayText);
            operator = op;
            freshInput = true;
        }

        function equalsPressed() {
            var right = parseFloat(displayText);
            var result = 0;
            switch (operator) {
            case "+":
                result = leftOperand + right;
                break;
            case "−":
                result = leftOperand - right;
                break;
            case "×":
                result = leftOperand * right;
                break;
            case "÷":
                result = right !== 0 ? leftOperand / right : 0;
                break;
            default:
                result = right;
            }
            displayText = String(result);
            operator = "";
            freshInput = true;
        }

        function clearPressed() {
            displayText = "0";
            leftOperand = 0;
            operator = "";
            freshInput = true;
        }

        anchors.fill: parent
        color: "#1e1e2e"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Display
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                color: "#181825"
                radius: 8

                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: mainRect.displayText
                    color: "#cdd6f4"
                    font.pixelSize: 32
                }

            }

            // Keypad Grid
            GridLayout {
                columns: 4
                rowSpacing: 6
                columnSpacing: 6
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop

                // Row 1
                CalcButton {
                    text: "C"
                    bgColor: "#f38ba8"
                    textColor: "#1e1e2e"
                    onClicked: mainRect.clearPressed()
                }

                CalcButton {
                    text: "÷"
                    bgColor: "#45475a"
                    onClicked: mainRect.operatorPressed("÷")
                }

                CalcButton {
                    text: "×"
                    bgColor: "#45475a"
                    onClicked: mainRect.operatorPressed("×")
                }

                CalcButton {
                    text: "⌫"
                    bgColor: "#45475a"
                    onClicked: {
                        if (mainRect.freshInput)
                            return ;

                        mainRect.displayText = mainRect.displayText.length > 1 ? mainRect.displayText.slice(0, -1) : "0";
                    }
                }

                // Row 2
                CalcButton {
                    text: "7"
                    onClicked: mainRect.digitPressed("7")
                }

                CalcButton {
                    text: "8"
                    onClicked: mainRect.digitPressed("8")
                }

                CalcButton {
                    text: "9"
                    onClicked: mainRect.digitPressed("9")
                }

                CalcButton {
                    text: "−"
                    bgColor: "#45475a"
                    onClicked: mainRect.operatorPressed("−")
                }

                // Row 3
                CalcButton {
                    text: "4"
                    onClicked: mainRect.digitPressed("4")
                }

                CalcButton {
                    text: "5"
                    onClicked: mainRect.digitPressed("5")
                }

                CalcButton {
                    text: "6"
                    onClicked: mainRect.digitPressed("6")
                }

                CalcButton {
                    text: "+"
                    bgColor: "#45475a"
                    onClicked: mainRect.operatorPressed("+")
                }

                // Row 4
                CalcButton {
                    text: "1"
                    onClicked: mainRect.digitPressed("1")
                }

                CalcButton {
                    text: "2"
                    onClicked: mainRect.digitPressed("2")
                }

                CalcButton {
                    text: "3"
                    onClicked: mainRect.digitPressed("3")
                }

                CalcButton {
                    text: "±"
                    bgColor: "#45475a"
                    onClicked: mainRect.displayText = String(-parseFloat(mainRect.displayText))
                }

                // Row 5
                CalcButton {
                    text: "0"
                    onClicked: mainRect.digitPressed("0")
                }

                CalcButton {
                    text: "."
                    onClicked: {
                        if (!mainRect.displayText.includes("."))
                            mainRect.displayText += ".";

                    }
                }

                CalcButton {
                    text: "="
                    bgColor: "#89b4fa"
                    textColor: "#1e1e2e"
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    onClicked: mainRect.equalsPressed()
                }

            }

        }

    }

}
