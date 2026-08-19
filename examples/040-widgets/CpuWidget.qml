/*!
 * \qmltype CpuWidget
 * \inqmlmodule Widgets
 * \brief Displays CPU usage with a label and progress bar.
 *
 * The progress bar width animates as \c usage changes.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    //! CPU usage as a float from 0.0 to 1.0.
    property real usage: 0

    implicitWidth: cpuRow.implicitWidth
    implicitHeight: cpuRow.implicitHeight

    RowLayout {
        id: cpuRow

        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "\u2699 CPU"
            color: "#89b4fa"
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

                width: barBg.width * Math.min(Math.max(root.usage, 0), 1)
                height: parent.height
                radius: 4
                color: root.usage > 0.8 ? "#f38ba8" : "#a6e3a1"

                Behavior on width {
                    SmoothedAnimation {
                        velocity: 200
                    }

                }

            }

        }

        Text {
            text: Math.round(root.usage * 100) + "%"
            color: "#cdd6f4"
            font.pixelSize: 11
        }

    }

}
