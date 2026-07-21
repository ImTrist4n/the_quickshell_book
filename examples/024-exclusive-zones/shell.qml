import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
  PanelWindow {
    anchors {
      top: true
      left: true
      right: true
    }
    height: 48
    color: "#1e1e2e"
    // Reserve 48px at the top so maximized windows avoid this area
    exclusiveZone: 48

    Text {
      anchors.centerIn: parent
      color: "#cdd6f4"
      text: "exclusiveZone: 48 — maximized windows avoid me"
    }
  }

  // A panel without exclusiveZone — windows can overlap it
  PanelWindow {
    anchors {
      bottom: true
      left: true
      right: true
    }
    height: 48
    color: "#313244"
    // exclusiveZone omitted — windows may cover this panel

    Text {
      anchors.centerIn: parent
      color: "#cdd6f4"
      text: "No exclusiveZone — windows can overlap"
    }
  }
}
