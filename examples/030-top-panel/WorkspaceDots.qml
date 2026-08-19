import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    property int workspaceCount: 5
    property int currentWorkspace: 0
    property color activeColor: "#89b4fa"
    property color inactiveColor: "#585b70"
    property int dotSize: 10
    property int spacing: 8

    implicitWidth: row.implicitWidth
    implicitHeight: 36

    Row {
        id: row
        anchors.centerIn: parent
        spacing: root.spacing

        Repeater {

            model: root.workspaceCount

            Rectangle {
                 readonly property int workspaceId: index + 1
                readonly property bool isFocused: Hyprland.focusedWorkspace?.id === workspaceId

                width: root.dotSize
                height: root.dotSize
                radius: root.dotSize / 2
                color: isFocused ? root.activeColor : root.inactiveColor

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspaceId + " })")
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

    }

}
