import Quickshell
import Quickshell.Window
import QtQuick
import Qt5Compat.GraphicalEffects

ShellRoot {
  PanelWindow {
    anchors {
      top: true
      left: true
      right: true
    }
    height: 48
    transparent: true

    // Enable the layer and apply a blur for a glass-like effect
    layer.enabled: true
    layer.effect: GaussianBlur {
      radius: 8
      samples: 17
    }

    Rectangle {
      anchors.fill: parent
      color: "#1e1e2e"
      opacity: 0.85

      Text {
        anchors.centerIn: parent
        color: "#cdd6f4"
        text: "Transparent panel with blur effect"
      }
    }
  }
}
