import QtQuick
import QtQuick.Window

Window {
  width: 480
  height: 400
  title: "Layouts"
  visible: true

  Rectangle {
    anchors.fill: parent
    color: "#1e1e2e"

    Column {
      anchors.centerIn: parent
      spacing: 24

      Column {
        spacing: 8
        Text {
          text: "Row layout:"
          color: "#a6adc8"
          font.pixelSize: 14
        }
        Row {
          spacing: 8
          Repeater {
            model: 4
            Rectangle {
              width: 50
              height: 50
              color: "#89b4fa"
              radius: 6
              Text {
                anchors.centerIn: parent
                text: index + 1
                color: "#1e1e2e"
                font.bold: true
              }
            }
          }
        }
      }

      Column {
        spacing: 8
        Text {
          text: "Column layout:"
          color: "#a6adc8"
          font.pixelSize: 14
        }
        Column {
          spacing: 4
          Repeater {
            model: 3
            Rectangle {
              width: 200
              height: 30
              color: "#a6e3a1"
              radius: 4
              Text {
                anchors.centerIn: parent
                text: "Item " + (index + 1)
                color: "#1e1e2e"
                font.bold: true
              }
            }
          }
        }
      }

      Column {
        spacing: 8
        Text {
          text: "Grid layout:"
          color: "#a6adc8"
          font.pixelSize: 14
        }
        Grid {
          columns: 3
          rows: 3
          spacing: 4
          Repeater {
            model: 9
            Rectangle {
              width: 40
              height: 40
              color: "#f38ba8"
              radius: 4
              Text {
                anchors.centerIn: parent
                text: index + 1
                color: "#1e1e2e"
                font.bold: true
              }
            }
          }
        }
      }
    }
  }
}
