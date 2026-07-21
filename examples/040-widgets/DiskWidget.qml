/*!
 * \qmltype DiskWidget
 * \inqmlmodule Widgets
 * \brief Displays disk usage with a label and progress bar.
 *
 * The progress bar width animates as \c usage changes.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    /*! Disk usage as a float from 0.0 to 1.0. */
    property real usage: 0.0

    implicitWidth: diskRow.implicitWidth
    implicitHeight: diskRow.implicitHeight

    RowLayout {
        id: diskRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "\U0001F4BE DISK"
            color: "#f38ba8"
            font.pixelSize: 11
            font.bold: true
        }

        Rectangle {
            id: barBg
            width: 60
            height: 8
            radius: 4
            color: "#1e1e2e"
            border.color: "#585b70"
            border.width: 1

            Rectangle {
                id: barFill
                width: barBg.width * Math.min(Math.max(root.usage, 0.0), 1.0)
                height: parent.height
                radius: 4
                color: root.usage > 0.8 ? "#f38ba8" : "#89b4fa"

                Behavior on width { SmoothedAnimation { velocity: 200 } }
            }
        }

        Text {
            text: Math.round(root.usage * 100) + "%"
            color: "#cdd6f4"
            font.pixelSize: 11
        }
    }
}
