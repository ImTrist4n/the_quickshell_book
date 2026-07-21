import Quickshell
import Quickshell.Window
import QtQuick

ShellRoot {
  // Spawn a MainPanel on every connected screen
  Instantiator {
    model: Quickshell.screens

    MainPanel {
      screen: VariantList {
        Variant {
          screen: modelData
          value: modelData
        }
      }
    }
  }
}
