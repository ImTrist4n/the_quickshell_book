import QtQuick

Item {
  id: root
  height: 36

  property int workspaceCount: 5
  property int currentWorkspace: 0
  property color activeColor: "#89b4fa"
  property color inactiveColor: "#585b70"
  property int dotSize: 10
  property int spacing: 8

  Row {
    anchors.centerIn: parent
    spacing: root.spacing

    Repeater {
      model: root.workspaceCount

      Rectangle {
        width: root.dotSize
        height: root.dotSize
        radius: root.dotSize / 2
        color: index === root.currentWorkspace ? root.activeColor : root.inactiveColor
        Behavior on color { ColorAnimation { duration: 150 } }
      }
    }
  }
}
