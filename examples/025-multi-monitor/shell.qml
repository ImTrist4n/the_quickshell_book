import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
  // Iterate over every connected screen
  Instantiator {
    model: Quickshell.screens

    PanelWindow {
      // Assign each window to its corresponding screen variant
      screen: VariantList {
        Variant {
          screen: modelData
          value: modelData
        }
      }

      anchors {
        top: true
        left: true
        right: true
      }
      height: 48
      color: "#1e1e2e"
      exclusiveZone: 48

      Text {
        anchors.centerIn: parent
        color: "#cdd6f4"
        text: "Screen: " + modelData.name + " (" + modelData.width + "x" + modelData.height + ")"
      }
    }
  }
}
