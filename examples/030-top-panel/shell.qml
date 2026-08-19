import QtQuick
import Quickshell

ShellRoot {
    // Spawn a MainPanel on every connected screen
    Instantiator {
        model: Quickshell.screens

        MainPanel {
        }

    }

}
