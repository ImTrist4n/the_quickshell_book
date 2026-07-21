import QtQuick
import QtQuick.Window

Window {
  width: 400
  height: 350
  title: "Signals"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    property int clickCount: 0

    Rectangle {
      id: button
      anchors.centerIn: parent
      width: 180
      height: 60
      color: "#89b4fa"
      radius: 10
      border.color: "#7a8cd6"
      border.width: 2

      Text {
        id: buttonLabel
        anchors.centerIn: parent
        text: "Click me!"
        color: "#1e1e2e"
        font.pixelSize: 18
        font.bold: true
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          parent.clicked()
        }
      }

      signal clicked()

      onClicked: {
        root.clickCount += 1
        buttonLabel.text = "Clicked " + root.clickCount
        if (clickCount === 1) buttonLabel.text = "Clicked once"
      }
    }

    Rectangle {
      id: indicator
      anchors.top: button.bottom
      anchors.topMargin: 24
      anchors.horizontalCenter: parent.horizontalCenter
      width: 12
      height: 12
      radius: 6
      color: "#a6e3a1"

      PropertyAnimation on color {
        id: flashAnim
        from: "#f38ba8"
        to: "#a6e3a1"
        duration: 300
      }
    }

    Text {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 20
      anchors.horizontalCenter: parent.horizontalCenter
      text: "Signals connect events to behavior"
      color: "#a6adc8"
      font.pixelSize: 13
    }
  }
}
