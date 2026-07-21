import QtQuick

Rectangle {
  id: root

  property alias text: label.text
  signal clicked()

  width: 140
  height: 44
  color: "#89b4fa"
  radius: 8
  border.color: "#7a8cd6"
  border.width: 1

  Text {
    id: label
    anchors.centerIn: parent
    color: "#1e1e2e"
    font.pixelSize: 15
    font.bold: true
  }

  MouseArea {
    anchors.fill: parent
    onClicked: root.clicked()
    onPressed: root.color = "#7a8cd6"
    onReleased: root.color = "#89b4fa"
  }
}
