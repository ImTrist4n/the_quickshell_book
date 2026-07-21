import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Layouts

// Catppuccin Mocha palette
pragma Singleton
QtObject {
    id: theme
    property color base: "#1e1e2e"
    property color text: "#cdd6f4"
    property color accent: "#89b4fa"
    property color green: "#a6e3a1"
    property color red: "#f38ba8"
    property color yellow: "#f9e2af"
    property color purple: "#cba6f7"
    property int slimHeight: 36
    property int expandedHeight: 48
    property int spacing: 8
    property int radius: 6
}

// Multi-monitor support: one top bar per screen
ShellRoot {
    Variants {
        Quickshell.screens {
            onScreensChanged: {
                for (const screen of screens) {
                    if (!screenComponents[screen.name]) {
                        var component = Qt.createComponent("shell.qml")
                        screenComponents[screen.name] = component.createObject(null, {screen: screen})
                    }
                }
            }
        }
    }

    property var screenComponents: ({})

    Component {
        id: panelDelegate

        PanelWindow {
            id: panel
            screen: screen
            anchors {
                top: true
                left: true
                right: true
            }
            height: theme.slimHeight
            color: theme.base
            exclusionMode: ExclusionMode.Exclusive

            // Hover-to-expand
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: panel.height = theme.expandedHeight
                onExited: panel.height = theme.slimHeight
                Behavior on height { NumberAnimation { duration: 150 } }
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: theme.spacing

                // Left section
                Row {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: theme.spacing

                    WorkspaceIndicator {}
                    LauncherButton {}
                }

                // Center section
                Item { Layout.fillWidth: true }

                ClockWidget {
                    Layout.alignment: Qt.AlignCenter
                }

                // Right section
                Item { Layout.fillWidth: true }

                Row {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: theme.spacing

                    VolumeIcon {}
                    BatteryIcon {}
                    SystemTray {}
                }
            }
        }
    }

    // --- Widget stubs ---

    component WorkspaceIndicator: Rectangle {
        width: 24; height: 24; radius: theme.radius
        color: theme.accent
        Text {
            anchors.centerIn: parent
            text: "1"
            color: theme.base
            font.bold: true
        }
    }

    component LauncherButton: Rectangle {
        width: 24; height: 24; radius: theme.radius
        color: theme.purple
        Text {
            anchors.centerIn: parent
            text: ""
            color: theme.base
        }
    }

    component ClockWidget: Text {
        text: new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
        color: theme.text
        font.pixelSize: 14
        Timer {
            interval: 1000; running: true; repeat: true
            onTriggered: parent.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
        }
    }

    component VolumeIcon: Rectangle {
        width: 24; height: 24; radius: theme.radius
        color: theme.green
        Text {
            anchors.centerIn: parent
            text: ""
            color: theme.base
        }
    }

    component BatteryIcon: Rectangle {
        width: 24; height: 24; radius: theme.radius
        color: theme.yellow
        Text {
            anchors.centerIn: parent
            text: ""
            color: theme.base
        }
    }

    component SystemTray: Rectangle {
        width: 60; height: 24; radius: theme.radius
        color: theme.text
        opacity: 0.2
    }
}
