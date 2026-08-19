import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property var appsList: [{
        "name": "Firefox",
        "exec": "firefox",
        "icon": "󰈹"
    }, {
        "name": "Terminal",
        "exec": "kitty",
        "icon": "󰞷"
    }, {
        "name": "Code",
        "exec": "vscodium",
        "icon": "󰨞"
    }, {
        "name": "Files",
        "exec": "nautilus",
        "icon": "󰉋"
    }, {
        "name": "Settings",
        "exec": "gnome-control-center",
        "icon": "󰒓"
    }, {
        "name": "Calculator",
        "exec": "qalculate-gtk",
        "icon": "󰪚"
    }]
    property string filterQuery: searchInput.text.toLowerCase()
    property var filteredApps: appsList.filter((app) => {
        return app.name.toLowerCase().includes(filterQuery);
    })

    function launchCurrent() {
        if (filteredApps.length > 0 && appListView.currentIndex >= 0) {
            let app = filteredApps[appListView.currentIndex];
            appProcess.command = ["bash", "-c", app.exec];
            appProcess.running = true;
            root.visible = false;
        }
    }

    implicitWidth: 500
    implicitHeight: 400
    color: "transparent"
    visible: true
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    Component.onCompleted: searchInput.forceActiveFocus()

    anchors {
        top: false
        bottom: false
        left: false
        right: false
    }

    Process {
        id: appProcess
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    Shortcut {
        sequence: "Return"
        onActivated: root.launchCurrent()
    }

    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 12
        border.color: "#313244"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            // Barre de recherche
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                color: "#313244"
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "󰍉"
                        color: "#89b4fa"
                        font.pixelSize: 16
                    }

                    TextInput {
                        id: searchInput

                        Layout.fillWidth: true
                        color: "#cdd6f4"
                        font.pixelSize: 15
                        clip: true
                        focus: true
                        onTextChanged: appListView.currentIndex = 0
                        Keys.onDownPressed: appListView.incrementCurrentIndex()
                        Keys.onUpPressed: appListView.decrementCurrentIndex()

                        Text {
                            text: "Search applications..."
                            color: "#6c7086"
                            font.pixelSize: 15
                            visible: searchInput.text === ""
                        }

                    }

                }

            }

            ListView {
                id: appListView

                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.filteredApps
                currentIndex: 0

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: appListView.width
                    height: 42
                    radius: 6
                    color: index === appListView.currentIndex ? "#45475a" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: modelData.icon
                            font.pixelSize: 18
                            color: "#89b4fa"
                        }

                        Text {
                            text: modelData.name
                            font.pixelSize: 14
                            color: "#cdd6f4"
                            Layout.fillWidth: true
                        }

                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            appListView.currentIndex = index;
                            root.launchCurrent();
                        }
                    }

                }

            }

        }

    }

}
