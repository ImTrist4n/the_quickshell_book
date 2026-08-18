import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        implicitHeight: 48
        color: "#1e1e2e"

        anchors {
            top: true
            left: true
            right: true
        }

        Text {
            anchors.centerIn: parent
            color: "#cdd6f4"
            text: "My first shell"
        }

    }

}
