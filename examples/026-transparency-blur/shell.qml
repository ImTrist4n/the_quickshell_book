import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        implicitHeight: 48
        // Apply a blur for a glass-like effect
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }

        Rectangle {
            id: background

            anchors.fill: parent
            color: "#1e1e2e"
            opacity: 0.85
            layer.enabled: true

            Text {
                anchors.centerIn: parent
                color: "#cdd6f4"
                text: "Transparent panel with blur effect"
            }

            layer.effect: GaussianBlur {
                radius: 8
                samples: 17
            }

        }

    }

}
