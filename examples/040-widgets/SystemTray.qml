/*!
 * \qmltype SystemTray
 * \inqmlmodule Widgets
 * \brief Placeholder for StatusNotifier system tray items.
 *
 * Uses a Repeater to render colored dots as stand-in items
 * until a real StatusNotifier integration is wired up.
 * The \c model count can be set externally.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    /*! Number of placeholder tray items to display. */
    property int trayItemCount: 4

    implicitWidth: trayRow.implicitWidth
    implicitHeight: trayRow.implicitHeight

    Row {
        id: trayRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: root.trayItemCount

            Rectangle {
                width: 12
                height: 12
                radius: 6
                color: {
                    var colors = ["#89b4fa", "#a6e3a1", "#f9e2af", "#f38ba8",
                                  "#cba6f7", "#94e2d5", "#fab387", "#74c7ec"];
                    return colors[index % colors.length];
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.opacity = 0.6
                    onExited: parent.opacity = 1.0
                }
            }
        }
    }
}
