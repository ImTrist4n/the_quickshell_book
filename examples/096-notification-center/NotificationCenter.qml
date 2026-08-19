import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: root

    function dismiss(index) {
        notifModel.remove(index, 1);
    }

    function clearAll() {
        notifModel.clear();
    }

    implicitWidth: 380
    implicitHeight: 520
    color: "#1e1e2e"

    ListModel {
        id: notifModel

        ListElement {
            appName: "Firefox"
            summary: "Download complete"
            body: "quickshell-book.pdf has finished downloading."
            timestamp: "2m ago"
        }

        ListElement {
            appName: "Spotify"
            summary: "Now Playing"
            body: "Bohemian Rhapsody - Queen"
            timestamp: "5m ago"
        }

        ListElement {
            appName: "System"
            summary: "Updates available"
            body: "3 package updates are available."
            timestamp: "15m ago"
        }

        ListElement {
            appName: "Discord"
            summary: "Message from @user"
            body: "Hey, are you coming to the meeting?"
            timestamp: "1h ago"
        }

        ListElement {
            appName: "Thunderbird"
            summary: "New email"
            body: "Re: Project update - Please review the attached files."
            timestamp: "2h ago"
        }

        ListElement {
            appName: "Slack"
            summary: "Channel notification"
            body: "New message in #general"
            timestamp: "3h ago"
        }

    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Notifications"
                font.pixelSize: 16
                font.bold: true
                color: "#cdd6f4"
                Layout.fillWidth: true
            }

            Rectangle {
                height: 28
                width: 80
                radius: 6
                color: "#f38ba8"

                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    font.pixelSize: 11
                    color: "#1e1e2e"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.clearAll()
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#313244"
        }

        ListView {
            id: notifList

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: notifModel
            spacing: 6

            delegate: Rectangle {
                width: parent.width
                height: 80
                radius: 8
                color: "#313244"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 10

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 8
                        color: "#45475a"

                        Text {
                            anchors.centerIn: parent
                            text: model.appName.charAt(0).toUpperCase()
                            font.bold: true
                            color: "#89b4fa"
                            font.pixelSize: 14
                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true

                            Text {
                                text: model.appName
                                font.pixelSize: 12
                                font.bold: true
                                color: "#cdd6f4"
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: model.timestamp
                                font.pixelSize: 10
                                color: "#585b70"
                            }

                        }

                        Text {
                            text: model.summary
                            font.pixelSize: 12
                            color: "#a6adc8"
                            elide: Text.ElideRight
                        }

                        Text {
                            text: model.body
                            font.pixelSize: 11
                            color: "#6c7086"
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.dismiss(index)
                }

            }

        }

        Text {
            text: "Click a notification to dismiss"
            font.pixelSize: 10
            color: "#585b70"
            Layout.alignment: Qt.AlignHCenter
        }

    }

}
