import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        implicitHeight: 48
        color: "#1e1e2e"
        // Reserve 48px at the top so maximized windows avoid this area
        exclusiveZone: 48
        WlrLayershell.layer: WlrLayer.Bottom

        anchors {
            top: true
            left: true
            right: true
        }

        Text {
            anchors.centerIn: parent
            color: "#cdd6f4"
            text: "exclusiveZone: 48 — maximized windows avoid me"
        }

    }

    // A panel without exclusiveZone — windows can overlap it
    PanelWindow {
        // exclusiveZone omitted — windows may cover this panel
        implicitHeight: 48
        color: "#313244"

        anchors {
            bottom: true
            left: true
            right: true
        }

        Text {
            anchors.centerIn: parent
            color: "#cdd6f4"
            text: "No exclusiveZone — windows can overlap"
        }

    }

}
