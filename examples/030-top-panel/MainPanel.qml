import Quickshell.Window
import QtQuick

PanelWindow {
  id: panel
  anchors {
    top: true
    left: true
    right: true
  }
  height: 48
  color: "#1e1e2e"
  exclusiveZone: 48

  Row {
    anchors {
      left: parent.left
      leftMargin: 12
      verticalCenter: parent.verticalCenter
    }
    spacing: 12

    LauncherButton { iconText: "" }

    WorkspaceDots {
      currentWorkspace: 0
      workspaceCount: 5
    }
  }

  Row {
    anchors {
      right: parent.right
      rightMargin: 12
      verticalCenter: parent.verticalCenter
    }
    spacing: 12

    ClockWidget { }
  }
}
