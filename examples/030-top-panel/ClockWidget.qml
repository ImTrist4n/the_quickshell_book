import QtQuick

Text {
  id: root
  color: "#cdd6f4"
  font.pixelSize: 14
  font.family: "monospace"
  horizontalAlignment: Text.AlignRight
  verticalAlignment: Text.AlignVCenter

  Timer {
    interval: 1000
    running: true
    repeat: true
    onTriggered: root.text = new Date().toLocaleString(Qt.locale(), "HH:mm")
  }

  Component.onCompleted: root.text = new Date().toLocaleString(Qt.locale(), "HH:mm")
}
