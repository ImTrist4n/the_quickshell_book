import QtQuick

Rectangle {
  id: root

  property alias text: label.text
  property color bgColor: "#313244"
  property color textColor: "#cdd6f4"

  signal clicked()

  width: 64
  height: 56
  color: bgColor
  radius: 8
  border.color: "#45475a"
  border.width: 1

  Text {
    id: label
    anchors.centerIn: parent
    color: root.textColor
    font.pixelSize: 20
    font.bold: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
    onPressed: root.color = Qt.darker(root.bgColor, 1.3)
    onReleased: root.color = root.bgColor
  }
}
