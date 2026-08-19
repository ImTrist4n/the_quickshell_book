import QtQuick
import Quickshell

PanelWindow {
    id: panel

    implicitHeight: 48
    color: "#1e1e2e"
    exclusiveZone: 48

    anchors {
        top: true
        left: true
        right: true
    }

    Row {
        spacing: 12

        anchors {
            left: parent.left
            leftMargin: 12
            verticalCenter: parent.verticalCenter
        }

        LauncherButton {
            iconText: ""
        }

        WorkspaceDots {
        }

    }

    Row {
        spacing: 12

        anchors {
            right: parent.right
            rightMargin: 12
            verticalCenter: parent.verticalCenter
        }

        ClockWidget {
        }

    }

}
