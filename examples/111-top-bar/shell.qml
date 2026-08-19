import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: root

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

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: panel

            required property var modelData

            screen: modelData
            WlrLayershell.layer: WlrLayer.Top
            implicitHeight: theme.slimHeight
            color: theme.base

            anchors {
                top: true
                left: true
                right: true
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: panel.implicitHeight = theme.expandedHeight
                onExited: panel.implicitHeight = theme.slimHeight

                Behavior on height {
                    NumberAnimation {
                        duration: 150
                    }

                }

            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: theme.spacing

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: theme.spacing

                    // Workspace Indicator
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: theme.radius
                        color: theme.accent

                        Text {
                            anchors.centerIn: parent
                            text: "1"
                            color: theme.base
                            font.bold: true
                        }

                    }

                    // Launcher Button
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: theme.radius
                        color: theme.purple

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: theme.base
                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    id: clockText

                    Layout.alignment: Qt.AlignCenter
                    text: new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
                    color: theme.text
                    font.pixelSize: 14

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = new Date().toLocaleTimeString(Qt.locale(), "hh:mm")
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignVCenter
                    spacing: theme.spacing

                    // Volume Icon
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: theme.radius
                        color: theme.green

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: theme.base
                        }

                    }

                    // Battery Icon
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: theme.radius
                        color: theme.yellow

                        Text {
                            anchors.centerIn: parent
                            text: ""
                            color: theme.base
                        }

                    }

                    // System Tray Placeholder
                    Rectangle {
                        implicitWidth: 60
                        implicitHeight: 24
                        radius: theme.radius
                        color: theme.text
                        opacity: 0.2
                    }

                }

            }

        }

    }

}
