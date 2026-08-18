import QtQuick
import Quickshell

ShellRoot {
    Instantiator {
        model: Quickshell.screens

        PanelWindow {
            screen: modelData
            implicitHeight: 48
            color: "#1e1e2e"
            exclusiveZone: 48

            anchors {
                top: true
                left: true
                right: true
            }

            // Assign each window to its corresponding screen variant
            Text {
                anchors.centerIn: parent
                color: "#cdd6f4"
                text: "Screen: " + modelData.name + " (" + modelData.width + "x" + modelData.height + ")"
            }

        }

    }

}
