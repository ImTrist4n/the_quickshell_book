import QtQuick
import Quickshell

ShellRoot {
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
                text: "Apps"
            }

            Text {
                color: Theme.fgColor
                text: "Terminal"
            }

            Text {
                color: Theme.fgColor
                text: "Settings"
            }

        }

    }

}
