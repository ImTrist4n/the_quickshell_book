import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Layouts

// Catppuccin Mocha palette
pragma Singleton
QtObject {
    id: theme
    property color base: "#1e1e2e"
    property color surface: "#313244"
    property color text: "#cdd6f4"
    property color accent: "#89b4fa"
    property color green: "#a6e3a1"
    property color red: "#f38ba8"
    property color yellow: "#f9e2af"
    property color purple: "#cba6f7"
    property int radius: 8
    property int spacing: 6
}

// Hardcoded application database
property var allApps: []
function loadApps() {
    allApps = [
        { name: "Browser", icon: "🌐", exec: "browser" },
        { name: "Terminal", icon: "", exec: "terminal" },
        { name: "Files", icon: "", exec: "files" },
        { name: "Settings", icon: "", exec: "settings" },
        { name: "Code", icon: "", exec: "code" },
        { name: "Calculator", icon: "", exec: "calculator" },
        { name: "Calendar", icon: "", exec: "calendar" },
        { name: "Mail", icon: "", exec: "mail" },
        { name: "Music", icon: "", exec: "music" },
        { name: "Photos", icon: "", exec: "photos" }
    ]
}

// Fuzzy scoring mock — returns 0..1 match score
function fuzzyScore(query, target) {
    if (!query) return 1
    var q = query.toLowerCase()
    var t = target.toLowerCase()
    if (t.indexOf(q) >= 0) return 1
    // Simple character-by-character fuzzy
    var qi = 0
    for (var ti = 0; ti < t.length && qi < q.length; ti++) {
        if (q[qi] === t[ti]) qi++
    }
    return qi === q.length ? 0.5 : 0
}

function filterApps(query) {
    var scored = allApps.map(function(app) {
        return { app: app, score: fuzzyScore(query, app.name) }
    })
    scored.sort(function(a, b) { return b.score - a.score })
    return scored.filter(function(item) { return item.score > 0 }).map(function(item) { return item.app })
}

property var filteredApps: allApps

ShellRoot {
    PopupWindow {
        id: launcher
        width: 500
        height: 400
        color: theme.base
        visible: false
        // Toggle with Meta/Super key via a Quickshell shortcut binding

        Rectangle {
            anchors.fill: parent
            radius: theme.radius
            color: theme.base
            border { color: theme.accent; width: 2 }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: theme.spacing

                // Search input
                Rectangle {
                    Layout.fillWidth: true
                    height: 40
                    radius: theme.radius
                    color: theme.surface

                    TextInput {
                        id: searchInput
                        anchors.fill: parent
                        anchors.margins: 10
                        color: theme.text
                        font.pixelSize: 16
                        placeholderText: "Search applications..."
                        placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)

                        onTextChanged: {
                            filteredApps = filterApps(text)
                        }

                        Keys.onEscapePressed: {
                            launcher.visible = false
                            searchInput.text = ""
                        }

                        Keys.onReturnPressed: {
                            if (resultsListView.currentIndex >= 0 && resultsListView.currentIndex < resultsList.count) {
                                var app = resultsList.get(resultsListView.currentIndex).modelData
                                console.log("Launching: " + app.name + " (" + app.exec + ")")
                                launcher.visible = false
                                searchInput.text = ""
                            }
                        }

                        Keys.onUpPressed: {
                            if (resultsListView.currentIndex > 0)
                                resultsListView.currentIndex--
                        }

                        Keys.onDownPressed: {
                            if (resultsListView.currentIndex < resultsList.count - 1)
                                resultsListView.currentIndex++
                        }
                    }
                }

                // Results list
                ListView {
                    id: resultsListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: ListModel { id: resultsList }

                    delegate: Rectangle {
                        width: resultsListView.width
                        height: 40
                        radius: theme.radius
                        color: ListView.isCurrentItem ? theme.accent : "transparent"
                        Behavior on color { ColorAnimation { duration: 50 } }

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Text {
                                text: modelData.icon
                                font.pixelSize: 18
                            }
                            Text {
                                text: modelData.name
                                color: theme.text
                                font.pixelSize: 14
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: modelData.exec
                                color: Qt.rgba(1, 1, 1, 0.4)
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                console.log("Launching: " + modelData.name + " (" + modelData.exec + ")")
                                launcher.visible = false
                                searchInput.text = ""
                            }
                        }
                    }

                    // Sync filteredApps into the ListModel
                    property var filteredApps: filteredApps
                    onFilteredAppsChanged: {
                        resultsList.clear()
                        for (var i = 0; i < filteredApps.length; i++) {
                            resultsList.append({modelData: filteredApps[i]})
                        }
                    }
                    Component.onCompleted: {
                        resultsList.clear()
                        for (var i = 0; i < filteredApps.length; i++) {
                            resultsList.append({modelData: filteredApps[i]})
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        loadApps()
        filteredApps = allApps
    }
}
