import QtQuick
import Quickshell

PanelWindow {
    implicitHeight: Theme.panelHeight
    color: Theme.bgColor

    anchors {
        top: true
        left: true
        right: true
    }

    Row {
        spacing: 16

        anchors {
            left: parent.left
            leftMargin: 12
            verticalCenter: parent.verticalCenter
        }

        Text {
            color: Theme.accent
            text: " Launcher"
        }

        Text {
            color: Theme.fgColor
            text: " Terminal"
        }

        Item {
            width: 1
            height: 1
        }

        Text {
            color: Theme.fgColor
            text: " 12:00"
        }

    }

}
