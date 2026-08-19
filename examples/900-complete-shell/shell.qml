import QtQuick
import QtQuick.Layouts
import Quickshell

// ──────────────────────────────────────────────
// Shell root — top-level container for the shell
// ──────────────────────────────────────────────
ShellRoot {
    id: shell

    // Instantiate Theme directly inside the root component
    Theme {
        id: theme
    }

    // ── Top Bar ────────────────────────────────
    PanelWindow {
        id: topBar

        implicitHeight: theme.topBarHeight
        color: theme.base

        anchors {
            top: true
            left: true
            right: true
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: theme.spacingMedium
            spacing: theme.spacingMedium

            // Left: workspace + launcher toggle
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: theme.spacingMedium

                Rectangle {
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    color: theme.accent

                    Text {
                        anchors.centerIn: parent
                        text: "1"
                        color: theme.base
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: console.log("Workspace switched")
                    }

                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    color: theme.purple

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: theme.base
                        font.pixelSize: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: launcher.visible = !launcher.visible
                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            // Center: clock
            Text {
                Layout.alignment: Qt.AlignCenter
                text: new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
                color: theme.text
                font.pixelSize: theme.fontSizeLarge

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm")
                }

            }

            Item {
                Layout.fillWidth: true
            }

            // Right: system indicators
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: theme.spacingMedium

                Rectangle {
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    color: theme.green

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: theme.base
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: controlCenter.visible = !controlCenter.visible
                    }

                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    color: theme.yellow

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: theme.base
                    }

                }

                Rectangle {
                    width: 32
                    height: 32
                    radius: theme.radiusSmall
                    color: theme.red

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        color: theme.base
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: notificationCenter.visible = !notificationCenter.visible
                    }

                }

                Rectangle {
                    width: 60
                    height: 28
                    radius: theme.radiusSmall
                    color: theme.surface0
                }

            }

        }

    }

    // ── Dock ───────────────────────────────────
    PanelWindow {
        id: dock

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
        property var runningApps: ["Browser", "Terminal"]

        function launchOrFocus(appName) {
            if (runningApps.indexOf(appName) >= 0) {
                console.log("Focusing " + appName);
            } else {
                console.log("Launching " + appName);
                runningApps.push(appName);
                runningAppsChanged();
            }
        }

        implicitHeight: theme.dockHeight
        color: theme.mantle

        anchors {
            bottom: true
            left: true
            right: true
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: theme.spacingMedium

            Repeater {
                model: dock.pinnedApps

                delegate: Column {
                    spacing: 2

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: theme.iconSize
                        height: theme.iconSize
                        radius: theme.radiusMedium
                        color: mouseArea.containsMouse ? theme.accent : Qt.rgba(1, 1, 1, 0.08)

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
                            onClicked: dock.launchOrFocus(modelData.name)
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }

                        }

                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 6
                        height: 6
                        radius: 3
                        color: dock.runningApps.indexOf(modelData.name) >= 0 ? theme.green : Qt.rgba(1, 1, 1, 0.15)
                    }

                }

            }

        }

    }

    // ── Launcher ────────────────────────────────
    PopupWindow {
        id: launcher

        implicitWidth: 520
        implicitHeight: 440
        color: "transparent"
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: theme.radiusLarge
            color: theme.base

            border {
                color: theme.accent
                width: 2
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: theme.spacingLarge
                spacing: theme.spacingMedium

                Rectangle {
                    Layout.fillWidth: true
                    height: 42
                    radius: theme.radiusMedium
                    color: theme.surface0

                    TextInput {
                        id: searchInput

                        anchors.fill: parent
                        anchors.margins: 12
                        color: theme.text
                        font.pixelSize: theme.fontSizeLarge
                        Keys.onEscapePressed: {
                            launcher.visible = false;
                            searchInput.text = "";
                        }
                        Keys.onReturnPressed: {
                            console.log("Launch selected");
                            launcher.visible = false;
                            searchInput.text = "";
                        }

                        // Custom placeholder overlay for standard TextInput
                        Text {
                            anchors.fill: parent
                            text: "Search applications..."
                            color: theme.overlay0
                            font.pixelSize: parent.font.pixelSize
                            visible: !searchInput.text && !searchInput.activeFocus
                        }

                    }

                }

                ListView {
                    id: launcherList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    Keys.onUpPressed: {
                        if (currentIndex > 0)
                            currentIndex--;

                    }
                    Keys.onDownPressed: {
                        if (currentIndex < count - 1)
                            currentIndex++;

                    }

                    model: ListModel {
                        ListElement {
                            name: "Browser"
                            icon: "🌐"
                            exec: "browser"
                        }

                        ListElement {
                            name: "Terminal"
                            icon: ""
                            exec: "terminal"
                        }

                        ListElement {
                            name: "Files"
                            icon: ""
                            exec: "files"
                        }

                        ListElement {
                            name: "Settings"
                            icon: ""
                            exec: "settings"
                        }

                        ListElement {
                            name: "Code"
                            icon: ""
                            exec: "code"
                        }

                        ListElement {
                            name: "Calculator"
                            icon: ""
                            exec: "calculator"
                        }

                        ListElement {
                            name: "Calendar"
                            icon: ""
                            exec: "calendar"
                        }

                        ListElement {
                            name: "Mail"
                            icon: ""
                            exec: "mail"
                        }

                        ListElement {
                            name: "Music"
                            icon: ""
                            exec: "music"
                        }

                        ListElement {
                            name: "Photos"
                            icon: ""
                            exec: "photos"
                        }

                    }

                    delegate: Rectangle {
                        width: launcherList.width
                        height: 40
                        radius: theme.radiusSmall
                        color: launcherList.currentIndex === index ? theme.accent : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: theme.spacingMedium
                            spacing: theme.spacingLarge

                            Text {
                                text: icon
                                font.pixelSize: 18
                            }

                            Text {
                                text: name
                                color: theme.text
                                font.pixelSize: theme.fontSizeMedium
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: exec
                                color: theme.overlay0
                                font.pixelSize: theme.fontSizeSmall
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Launch: " + name);
                                launcher.visible = false;
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 50
                            }

                        }

                    }

                }

            }

        }

    }

    // ── Notification Center ─────────────────────
    PopupWindow {
        id: notificationCenter

        implicitWidth: 360
        implicitHeight: 480
        color: "transparent"
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: theme.radiusLarge
            color: theme.mantle

            border {
                color: theme.surface1
                width: 1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: theme.spacingLarge
                spacing: theme.spacingMedium

                Text {
                    text: "Notifications"
                    color: theme.text
                    font.pixelSize: theme.fontSizeLarge
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: theme.radiusMedium
                    color: theme.surface0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: theme.spacingMedium
                        spacing: theme.spacingMedium

                        Repeater {
                            model: [{
                                "app": "Mail",
                                "summary": "New email",
                                "body": "You have 3 unread messages"
                            }, {
                                "app": "Calendar",
                                "summary": "Meeting at 3pm",
                                "body": "Standup in 15 minutes"
                            }, {
                                "app": "Music",
                                "summary": "Now Playing",
                                "body": "Song Title — Artist"
                            }]

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                height: 60
                                radius: theme.radiusSmall
                                color: theme.surface1

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: theme.spacingMedium
                                    spacing: 2

                                    Text {
                                        text: modelData.app + " — " + modelData.summary
                                        color: theme.text
                                        font.pixelSize: theme.fontSizeSmall
                                        font.bold: true
                                    }

                                    Text {
                                        text: modelData.body
                                        color: theme.subtext0
                                        font.pixelSize: theme.fontSizeSmall
                                        elide: Text.ElideRight
                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

    }

    // ── Control Center ──────────────────────────
    PopupWindow {
        id: controlCenter

        implicitWidth: 320
        implicitHeight: 320
        color: "transparent"
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: theme.radiusLarge
            color: theme.mantle

            border {
                color: theme.surface1
                width: 1
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: theme.spacingLarge
                spacing: theme.spacingLarge

                Text {
                    text: "Control Center"
                    color: theme.text
                    font.pixelSize: theme.fontSizeLarge
                    font.bold: true
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: theme.spacingMedium
                    columnSpacing: theme.spacingMedium

                    Repeater {
                        model: [{
                            "label": "Wi-Fi",
                            "icon": "",
                            "active": true
                        }, {
                            "label": "Bluetooth",
                            "icon": "",
                            "active": false
                        }, {
                            "label": "DND",
                            "icon": "",
                            "active": false
                        }, {
                            "label": "VPN",
                            "icon": "",
                            "active": true
                        }]

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 60
                            radius: theme.radiusMedium
                            color: modelData.active ? theme.surface1 : theme.surface0

                            border {
                                color: modelData.active ? theme.accent : "transparent"
                                width: 1
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.icon
                                    color: modelData.active ? theme.accent : theme.overlay0
                                    font.pixelSize: 20
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.label
                                    color: modelData.active ? theme.text : theme.overlay0
                                    font.pixelSize: theme.fontSizeSmall
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    modelData.active = !modelData.active;
                                    console.log("Toggle " + modelData.label + ": " + modelData.active);
                                }
                            }

                        }

                    }

                }

                Item {
                    Layout.fillHeight: true
                }

                // Volume slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: theme.spacingSmall

                    Text {
                        text: "Volume"
                        color: theme.subtext0
                        font.pixelSize: theme.fontSizeSmall
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: theme.surface1

                        Rectangle {
                            width: parent.width * 0.7
                            height: parent.height
                            radius: 3
                            color: theme.accent
                        }

                    }

                }

                // Brightness slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: theme.spacingSmall

                    Text {
                        text: "Brightness"
                        color: theme.subtext0
                        font.pixelSize: theme.fontSizeSmall
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: theme.yellow

                        Rectangle {
                            width: parent.width * 0.85
                            height: parent.height
                            radius: 3
                            color: theme.yellow
                        }

                    }

                }

            }

        }

    }

    // ── Keyboard shortcut: Meta/Super to toggle launcher ──
    Shortcut {
        sequence: "Meta+Space"
        onActivated: launcher.visible = !launcher.visible
    }

}
