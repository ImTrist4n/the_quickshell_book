import QtQuick
import Quickshell

ShellRoot {
    // Full-width top panel
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
            text: "Top panel (anchors top + left + right)"
        }

    }

    // Bottom panel with margins on each side
    PanelWindow {
        implicitHeight: 48
        color: "#313244"
        exclusiveZone: 48

        anchors {
            bottom: true
            left: true
            right: true
        }

        margins {
            bottom: 8
            left: 64
            right: 64
        }

        Text {
            anchors.centerIn: parent
            color: "#cdd6f4"
            text: "Bottom panel with margins"
        }

    }

}
