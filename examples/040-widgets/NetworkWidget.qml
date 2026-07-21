/*!
 * \qmltype NetworkWidget
 * \inqmlmodule Widgets
 * \brief Displays Wi-Fi signal strength and SSID.
 *
 * Shows a signal strength icon with four levels derived from \c strength.
 * The SSID is displayed as a label beside the icon.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    /*! Signal strength from 0 to 100. */
    property int strength: 0

    /*! The SSID of the connected network. */
    property string ssid: ""

    implicitWidth: netRow.implicitWidth
    implicitHeight: netRow.implicitHeight

    RowLayout {
        id: netRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                if (root.ssid === "") return "\u2262";
                if (root.strength <= 0) return "\uD83D\uDDA4";
                if (root.strength <= 25) return "\uD83D\uDD36";
                if (root.strength <= 50) return "\uD83D\uDFE8";
                if (root.strength <= 75) return "\uD83D\uDFE0";
                return "\uD83D\uDFE2";
            }
            color: {
                if (root.ssid === "") return "#585b70";
                if (root.strength <= 25) return "#f38ba8";
                if (root.strength <= 50) return "#fab387";
                if (root.strength <= 75) return "#f9e2af";
                return "#a6e3a1";
            }
            font.pixelSize: 14
        }

        Text {
            text: root.ssid === "" ? "Disconnected" : root.ssid
            color: root.ssid === "" ? "#585b70" : "#cdd6f4"
            font.pixelSize: 11
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}
