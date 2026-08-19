import QtQuick
import QtQuick.Layouts
import Quickshell

ShellRoot {
    // Pinned applications
    property var pinnedApps: [{
        "name": "Browser",
        "icon": "🌐"
    }, {
        "name": "Terminal",
        "icon": ""
    }, {
        "name": "Files",
        "icon": ""
    }, {
        "name": "Settings",
        "icon": ""
    }, {
        "name": "Code",
        "icon": ""
    }]
    // Currently running apps (mocked state)
    property var runningApps: ["Browser", "Terminal"]

    // Launch or focus target application
    function launchOrFocus(appName) {
        if (runningApps.indexOf(appName) >= 0) {
            console.log("Focusing " + appName);
        } else {
            console.log("Launching " + appName);
            runningApps.push(appName);
            runningAppsChanged();
        }
    }

    QtObject {
        id: theme

        // Catppuccin Mocha color palette
        property color base: "#1e1e2e"
        property color text: "#cdd6f4"
        property color accent: "#89b4fa"
        property color green: "#a6e3a1"
        property color red: "#f38ba8"
        property color yellow: "#f9e2af"
        property color purple: "#cba6f7"
        property int spacing: 8
        property int radius: 8
        property int iconSize: 48
    }

    PanelWindow {
        id: dock

        implicitHeight: theme.iconSize + 16
        color: theme.base
        exclusionMode: ExclusionMode.Normal

        anchors {
            bottom: true
            left: true
            right: true
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: theme.spacing

            Repeater {
                model: pinnedApps

                delegate: Item {
                    id: delegateItem

                    width: theme.iconSize + 8
                    height: theme.iconSize + 8

                    // App icon item container
                    Rectangle {
                        id: iconBg

                        anchors.centerIn: parent
                        width: theme.iconSize
                        height: theme.iconSize
                        radius: theme.radius
                        color: mouseArea.containsMouse ? theme.accent : Qt.rgba(1, 1, 1, 0.1)

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 22
                            color: theme.text
                        }

                        MouseArea {
                            id: mouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: launchOrFocus(modelData.name)
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }

                        }

                    }

                    // Native Quickshell popup window for hover preview
                    PopupWindow {
                        id: previewPopup

                        visible: mouseArea.containsMouse
                        width: 200
                        height: 120
                        color: "transparent"

                        // Anchor popup to the top of the icon item
                        anchor {
                            window: dock
                            rect.x: delegateItem.x + (delegateItem.width / 2) - 100
                            rect.y: dock.y - 130
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: theme.base
                            opacity: 0.95

                            border {
                                color: theme.accent
                                width: 2
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.name
                                color: theme.text
                                font.pixelSize: 18
                            }

                        }

                    }

                    // Active window indicator dot
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: 6
                        height: 6
                        radius: 3
                        color: runningApps.indexOf(modelData.name) >= 0 ? theme.green : Qt.rgba(1, 1, 1, 0.2)
                    }

                }

            }

        }

    }

}
