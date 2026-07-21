import QtQuick

Rectangle {
  id: root
  width: 36
  height: 36
  radius: 8
  color: "#313244"

  property alias iconText: label.text

  Text {
    id: label
    anchors.centerIn: parent
    color: "#89b4fa"
    font.pixelSize: 18
    text: ""
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: root.color = "#45475a"
    onExited: root.color = "#313244"
    onClicked: console.log("Launcher clicked")
  }
}
