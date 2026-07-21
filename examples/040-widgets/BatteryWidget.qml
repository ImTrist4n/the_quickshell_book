/*!
 * \qmltype BatteryWidget
 * \inqmlmodule Widgets
 * \brief Displays battery percentage and charging status.
 *
 * Shows a battery icon (Text fallback) and a percentage label.
 * The icon changes based on \c percent and \c charging.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    /*! Battery charge level from 0 to 100. */
    property int percent: 0

    /*! Whether the battery is currently charging. */
    property bool charging: false

    implicitWidth: batteryRow.implicitWidth
    implicitHeight: batteryRow.implicitHeight

    RowLayout {
        id: batteryRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                if (root.charging) return "\u26A1";
                if (root.percent <= 10) return "\u26A1";
                if (root.percent <= 25) return "\u25D4";
                if (root.percent <= 50) return "\u25D3";
                if (root.percent <= 75) return "\u25D2";
                return "\u25D1";
            }
            color: {
                if (root.charging) return "#a6e3a1";
                if (root.percent <= 15) return "#f38ba8";
                return "#cdd6f4";
            }
            font.pixelSize: 14
        }

        Text {
            text: root.percent + "%"
            color: "#cdd6f4"
            font.pixelSize: 12
        }
    }
}
