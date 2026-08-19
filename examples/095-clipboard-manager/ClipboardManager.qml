import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property int maxHistory: 20
    property bool ignoreNextChange: false

    function addEntry(text) {
        if (!text || text.trim() === "")
            return ;

        for (let i = 0; i < clipboardModel.count; i++) {
            if (clipboardModel.get(i).text === text) {
                clipboardModel.move(i, 0, 1);
                return ;
            }
        }
        clipboardModel.insert(0, {
            "text": text
        });
        while (clipboardModel.count > root.maxHistory)
            clipboardModel.remove(clipboardModel.count - 1);

    }

    function copyToClipboard(text) {
        root.ignoreNextChange = true;
        clipboardDebounceTimer.restart();
        copyProcess.command = ["bash", "-c", `printf '%s' "${text.replace(/"/g, '\\"')}" | wl-copy`];
        copyProcess.running = true;
        root.visible = false;
    }

    // Window dimensions
    implicitWidth: 420
    implicitHeight: 500
    color: "transparent"
    visible: true
    // Enable Wayland LayerShell focus
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    Component.onCompleted: {
        if (Quickshell.clipboard && Quickshell.clipboard.text)
            root.addEntry(Quickshell.clipboard.text);

    }

    anchors {
        top: false
        bottom: false
        left: false
        right: false
    }

    // Process instance for wl-copy execution
    Process {
        id: copyProcess
    }

    ListModel {
        id: clipboardModel

        ListElement {
            text: "https://github.com/Quickshell/quickshell"
        }

        ListElement {
            text: "qml: warning: unknown property"
        }

        ListElement {
            text: "systemctl --user status"
        }

        ListElement {
            text: "Hello, World!"
        }

        ListElement {
            text: "#include <stdio.h>"
        }

        ListElement {
            text: "catppuccin/mocha"
        }

        ListElement {
            text: "192.168.1.1"
        }

        ListElement {
            text: "Lorem ipsum dolor sit amet"
        }

    }

    Timer {
        id: clipboardDebounceTimer

        interval: 300
        onTriggered: root.ignoreNextChange = false
    }

    // Native Quickshell Clipboard observer
    Connections {
        function onTextChanged() {
            if (root.ignoreNextChange)
                return ;

            root.addEntry(Quickshell.clipboard.text);
        }

        target: Quickshell.clipboard
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    // Main window frame
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        border.color: "#313244"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Clipboard History"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#cdd6f4"
                    Layout.fillWidth: true
                }

                Text {
                    text: clipboardModel.count + " items"
                    font.pixelSize: 11
                    color: "#585b70"
                }

            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#313244"
            }

            ListView {
                id: listView

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: clipboardModel

                delegate: Rectangle {
                    required property string text
                    required property int index

                    width: listView.width
                    height: 44
                    radius: 6
                    color: mouseArea.containsMouse ? "#45475a" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            text: ""
                            font.pixelSize: 14
                            color: "#89b4fa"
                        }

                        Text {
                            text: parent.parent.text
                            font.pixelSize: 13
                            color: "#cdd6f4"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                    }

                    MouseArea {
                        id: mouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.copyToClipboard(parent.text)
                    }

                }

            }

        }

    }

}
