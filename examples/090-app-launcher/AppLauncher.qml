import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

PopupWindow {
  id: root

  width: 500
  height: 400
  backgroundColor: "#1e1e2e"
  color: "#1e1e2e"

  property ListModel allApps: ListModel {
    ListElement { name: "Firefox"; exec: "firefox"; icon: "firefox" }
    ListElement { name: "Terminal"; exec: "kitty"; icon: "terminal" }
    ListElement { name: "Code"; exec: "code"; icon: "code" }
    ListElement { name: "Files"; exec: "nautilus"; icon: "folder" }
    ListElement { name: "Settings"; exec: "gnome-control-center"; icon: "settings" }
    ListElement { name: "Calculator"; exec: "qalculate-gtk"; icon: "calculator" }
    ListElement { name: "Calendar"; exec: "gnome-calendar"; icon: "calendar" }
    ListElement { name: "Music"; exec: "spotify"; icon: "spotify" }
    ListElement { name: "Clock"; exec: "gnome-clocks"; icon: "clock" }
    ListElement { name: "System Monitor"; exec: "gnome-system-monitor"; icon: "system-monitor" }
  }

  property string searchText: ""
  property var filteredApps: []

  function filterApps() {
    if (root.searchText === "") {
      root.filteredApps = [];
      for (let i = 0; i < root.allApps.count; i++)
        root.filteredApps.push(root.allApps.get(i));
    } else {
      root.filteredApps = [];
      for (let i = 0; i < root.allApps.count; i++) {
        let app = root.allApps.get(i);
        if (app.name.toLowerCase().includes(root.searchText.toLowerCase()))
          root.filteredApps.push(app);
      }
    }
    appListView.currentIndex = 0;
  }

  function launchSelected() {
    if (root.filteredApps.length === 0) return;
    let app = root.filteredApps[appListView.currentIndex];
    Process.exec("bash", ["-c", app.exec]);
    root.visible = false;
  }

  Shortcut {
    sequence: "Escape"
    onActivated: root.visible = false
  }

  Shortcut {
    sequence: "Return"
    onActivated: root.launchSelected()
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 8

    Rectangle {
      Layout.fillWidth: true
      height: 40
      radius: 8
      color: "#313244"

      TextField {
        id: searchField
        anchors.fill: parent
        anchors.margins: 4
        placeholderText: "Search applications..."
        placeholderTextColor: "#6c7086"
        color: "#cdd6f4"
        font.pixelSize: 14
        background: null

        Keys.onDownPressed: appListView.incrementCurrentIndex()
        Keys.onUpPressed: appListView.decrementCurrentIndex()

        onTextChanged: {
          root.searchText = text;
          root.filterApps();
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
        width: appListView.width
        height: 40
        radius: 6
        color: ListView.isCurrentItem ? "#45475a" : "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.margins: 8
          spacing: 10

          Text {
            text: modelData.icon || ""
            font.pixelSize: 16
            color: "#89b4fa"
          }

          Text {
            text: modelData.name
            font.pixelSize: 14
            color: "#cdd6f4"
            Layout.fillWidth: true
          }

          Text {
            text: "↵"
            font.pixelSize: 12
            color: "#585b70"
            visible: ListView.isCurrentItem
          }
        }

        MouseArea {
          anchors.fill: parent
          onClicked: {
            appListView.currentIndex = index;
            root.launchSelected();
          }
        }
      }
    }
  }

  Component.onCompleted: {
    root.filterApps();
    searchField.forceActiveFocus();
  }
}
