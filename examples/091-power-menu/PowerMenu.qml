import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property string shutdownIcon: "⏻"
    property real shutdownHoldProgress: 0
    property bool shutdownConfirming: false

    function execute(command) {
        cmdProcess.command = ["bash", "-c", command];
        cmdProcess.running = true;
        root.visible = false;
    }

    function startShutdownTimer() {
        if (root.shutdownConfirming)
            return ;

        root.shutdownConfirming = true;
        root.shutdownHoldProgress = 0;
        shutdownTimer.start();
    }

    function cancelShutdown() {
        root.shutdownConfirming = false;
        root.shutdownHoldProgress = 0;
        shutdownTimer.stop();
    }

    implicitWidth: 380
    implicitHeight: 260
    color: "transparent"
    visible: true
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: false
        bottom: false
        left: false
        right: false
    }

    Process {
        id: cmdProcess
    }

    Timer {
        id: shutdownTimer

        interval: 50
        repeat: true
        onTriggered: {
            root.shutdownHoldProgress += 0.025;
            if (root.shutdownHoldProgress >= 1) {
                root.shutdownHoldProgress = 0;
                root.shutdownConfirming = false;
                shutdownTimer.stop();
                root.execute("systemctl poweroff");
            }
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            root.cancelShutdown();
            root.visible = false;
        }
    }

    // Main window container
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        border.color: "#313244"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            Text {
                text: "Power Menu"
                font.pixelSize: 18
                font.bold: true
                color: "#cdd6f4"
                Layout.alignment: Qt.AlignHCenter
            }

            GridLayout {
                columns: 3
                columnSpacing: 10
                rowSpacing: 10
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                Repeater {

                    model: ListModel {
                        ListElement {
                            label: "Lock"
                            icon: ""
                            cmd: "loginctl lock-session"
                        }

                        ListElement {
                            label: "Log Out"
                            icon: ""
                            cmd: "loginctl terminate-user $USER"
                        }

                        ListElement {
                            label: "Sleep"
                            icon: ""
                            cmd: "systemctl suspend"
                        }

                        ListElement {
                            label: "Restart"
                            icon: ""
                            cmd: "systemctl reboot"
                        }

                        ListElement {
                            label: "Shutdown"
                            icon: "⏻"
                            cmd: "systemctl poweroff"
                        }

                    }

                    delegate: Rectangle {
                        required property string label
                        required property string icon
                        required property string cmd

                        width: 100
                        height: 75
                        radius: 10
                        color: {
                            if (label === "Shutdown" && root.shutdownConfirming)
                                return Qt.rgba(0.95, 0.54, 0.66, root.shutdownHoldProgress * 0.4);

                            return "#313244";
                        }
                        border.color: (label === "Shutdown" && root.shutdownConfirming) ? "#f38ba8" : "transparent"
                        border.width: (label === "Shutdown" && root.shutdownConfirming) ? 2 : 0

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 4

                            Text {
                                text: parent.parent.icon
                                font.pixelSize: 20
                                color: (parent.parent.label === "Shutdown" && root.shutdownConfirming) ? "#f38ba8" : "#89b4fa"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: parent.parent.label
                                font.pixelSize: 12
                                color: "#cdd6f4"
                                Layout.alignment: Qt.AlignHCenter
                            }

                            // Hold progress bar for shutdown confirmation
                            Rectangle {
                                Layout.fillWidth: true
                                height: 3
                                radius: 2
                                color: "#45475a"
                                visible: parent.parent.label === "Shutdown" && root.shutdownConfirming

                                Rectangle {
                                    width: parent.width * root.shutdownHoldProgress
                                    height: parent.height
                                    radius: 2
                                    color: "#f38ba8"
                                }

                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                if (label === "Shutdown") {
                                    if (!root.shutdownConfirming)
                                        root.startShutdownTimer();
                                    else
                                        root.cancelShutdown();
                                } else {
                                    root.execute(cmd);
                                }
                            }
                        }

                    }

                }

            }

            Item {
                Layout.fillHeight: true
            }

            Text {
                text: "Esc to close"
                font.pixelSize: 11
                color: "#585b70"
                Layout.alignment: Qt.AlignHCenter
            }

        }

    }

}
