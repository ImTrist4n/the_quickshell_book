import Quickshell
import Quickshell.Window
import QtQuick
import QtQuick.Layouts

PopupWindow {
  id: root

  width: 420
  height: 500
  backgroundColor: "#1e1e2e"
  color: "#1e1e2e"

  property int maxHistory: 20
  property bool ignoreNextChange: false

  ListModel {
    id: clipboardModel

    ListElement { text: "https://github.com/Quickshell/quickshell" }
    ListElement { text: "qml: warning: unknown property" }
    ListElement { text: "systemctl --user status" }
    ListElement { text: "Hello, World!" }
    ListElement { text: "#include <stdio.h>" }
    ListElement { text: "catppuccin/mocha" }
    ListElement { text: "192.168.1.1" }
    ListElement { text: "Lorem ipsum dolor sit amet" }
  }

  function addEntry(text) {
    if (text.trim() === "") return;

    for (let i = 0; i < clipboardModel.count; i++) {
      if (clipboardModel.get(i).text === text) {
        clipboardModel.move(i, 0, 1);
        return;
      }
    }

    clipboardModel.insert(0, { text: text });
    while (clipboardModel.count > root.maxHistory)
      clipboardModel.remove(clipboardModel.count - 1);
  }

  function copyToClipboard(text) {
    root.ignoreNextChange = true;
    clipboardDebounceTimer.restart();
    Process.exec("bash", ["-c", `printf '%s' "${text}" | wl-copy`]);
    root.visible = false;
  }

  Timer {
    id: clipboardDebounceTimer
    interval: 300
    onTriggered: root.ignoreNextChange = false
  }

  ClipboardsWatcher {
    id: watcher
    onClipboardChanged: {
      if (root.ignoreNextChange) return;
      root.addEntry(watcher.clipboard);
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
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      model: clipboardModel

      delegate: Rectangle {
        width: parent.width
        height: 44
        radius: 6
        color: mouse.containsMouse ? "#45475a" : "transparent"

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
            text: model.text
            font.pixelSize: 13
            color: "#cdd6f4"
            elide: Text.ElideRight
            Layout.fillWidth: true
          }
        }

        property alias mouse: mouseArea

        MouseArea {
          id: mouseArea
          anchors.fill: parent
          hoverEnabled: true
          onClicked: root.copyToClipboard(model.text)
        }
      }
    }
  }

  Component.onCompleted: {
    root.addEntry(watcher.clipboard);
  }
}
