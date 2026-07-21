import QtQuick
import QtQuick.Layouts

Rectangle {
  id: root

  property string icon: ""
  property string label: ""
  property bool toggled: false

  signal clicked()

  width: 100
  height: 100
  radius: 12
  color: root.toggled ? "#cba6f7" : "#313244"

  Behavior on color {
    ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
  }

  ColumnLayout {
    anchors.centerIn: parent
    spacing: 6

    Text {
      text: root.icon
      font.pixelSize: 28
      color: root.toggled ? "#1e1e2e" : "#cdd6f4"
      Layout.alignment: Qt.AlignHCenter

      Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
      }
    }

    Text {
      text: root.label
      font.pixelSize: 12
      color: root.toggled ? "#1e1e2e" : "#a6adc8"
      Layout.alignment: Qt.AlignHCenter

      Behavior on color {
        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    onClicked: {
      root.toggled = !root.toggled;
      root.clicked();
    }
  }
}
