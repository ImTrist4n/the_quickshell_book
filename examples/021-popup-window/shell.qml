import QtQuick
import Quickshell

ShellRoot {
    PanelWindow {
        id: panel

        implicitHeight: 48
        color: "#1e1e2e"

        anchors {
            top: true
            left: true
            right: true
        }

        Rectangle {
            id: button

            anchors.centerIn: parent
            width: 120
            height: 32
            radius: 6
            color: "#313244"

            Text {
                anchors.centerIn: parent
                color: "#cdd6f4"
                text: "Click for popup"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: popup.visible = !popup.visible
            }

        }

        PopupWindow {
            id: popup

            implicitWidth: 200
            implicitHeight: 150
            color: "#1e1e2e"
            visible: false

            anchor {
                window: panel
                rect.x: button.x
                rect.y: button.y
                rect.width: button.width
                rect.height: button.height
                edges: Edges.Bottom
                gravity: Edges.Bottom
            }

            Column {
                spacing: 8

                anchors {
                    top: parent.top
                    topMargin: 8
                    horizontalCenter: parent.horizontalCenter
                }

                Text {
                    color: "#cdd6f4"
                    text: "Item 1"
                }

                Text {
                    color: "#cdd6f4"
                    text: "Item 2"
                }

                Text {
                    color: "#cdd6f4"
                    text: "Item 3"
                }

            }

        }

    }

}
