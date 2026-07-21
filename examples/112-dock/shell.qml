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
    property int spacing: 8
    property int radius: 8
    property int iconSize: 48
}

// Pinned applications
property var pinnedApps: [
    { name: "Browser", icon: "🌐" },
    { name: "Terminal", icon: "" },
    { name: "Files", icon: "" },
    { name: "Settings", icon: "" },
    { name: "Code", icon: "" }
]

// Currently "running" apps (mocked)
property var runningApps: ["Browser", "Terminal"]

// Mock launch or focus function
function launchOrFocus(appName) {
    if (runningApps.indexOf(appName) >= 0) {
        console.log("Focusing " + appName)
    } else {
        console.log("Launching " + appName)
        runningApps.push(appName)
        runningAppsChanged()
    }
}

ShellRoot {
    PanelWindow {
        id: dock
        anchors {
            bottom: true
            left: true
            right: true
        }
        height: theme.iconSize + 16
        color: theme.base
        exclusionMode: ExclusionMode.Exclusive

        RowLayout {
            anchors.centerIn: parent
            spacing: theme.spacing

            Repeater {
                model: pinnedApps

                delegate: Item {
                    width: theme.iconSize + 8
                    height: theme.iconSize + 8

                    // App icon button
                    Rectangle {
                        id: iconBg
                        anchors.centerIn: parent
                        width: theme.iconSize
                        height: theme.iconSize
                        radius: theme.radius
                        color: mouseArea.containsMouse ? theme.accent : Qt.rgba(255, 255, 255, 0.1)
                        Behavior on color { ColorAnimation { duration: 100 } }

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

                            // Fake preview window on hover
                            onEntered: {
                                if (!fakeWindow) {
                                    var comp = Qt.createComponent("FakeWindow.qml")
                                    fakeWindow = comp.createObject(dock, {appName: modelData.name})
                                }
                                fakeWindow.visible = true
                            }
                            onExited: {
                                if (fakeWindow)
                                    fakeWindow.visible = false
                            }
                        }

                        property var fakeWindow: null
                    }

                    // Running indicator dot
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        width: 6; height: 6; radius: 3
                        color: runningApps.indexOf(modelData.name) >= 0 ? theme.green : Qt.rgba(255, 255, 255, 0.2)
                    }
                }
            }
        }
    }

    // Inline FakeWindow component for preview
    component FakeWindow: Rectangle {
        id: fw
        property string appName: ""
        width: 200; height: 120; radius: 10
        color: theme.base
        border { color: theme.accent; width: 2 }
        visible: false
        opacity: 0.95

        x: dock.x + dock.width / 2 - width / 2
        y: dock.y - height - 10

        Text {
            anchors.centerIn: parent
            text: fw.appName
            color: theme.text
            font.pixelSize: 18
        }
    }
}
