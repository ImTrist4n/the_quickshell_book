/*!
 * \qmltype ClockWidget
 * \inqmlmodule Widgets
 * \brief Displays the current time and date.
 *
 * Shows a formatted time string updated every second.
 * Clicking the widget reveals the full date below the time.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    //! The current time as a formatted string (HH:mm:ss).
    readonly property string timeString: new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
    //! The current date as a formatted string.
    readonly property string dateString: new Date().toLocaleDateString(Qt.locale(), "ddd MMM d yyyy")
    //! Whether the date label is visible.
    property bool showDate: false

    implicitWidth: clockLayout.implicitWidth
    implicitHeight: clockLayout.implicitHeight

    ColumnLayout {
        id: clockLayout

        anchors.centerIn: parent
        spacing: 2

        Text {
            id: timeText

            text: root.timeString
            color: "#cdd6f4"
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Text {
            id: dateText

            text: root.dateString
            color: "#89b4fa"
            font.pixelSize: 11
            horizontalAlignment: Text.AlignHCenter
            visible: root.showDate
            Layout.fillWidth: true
        }

    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.showDate = !root.showDate
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = root.timeString;
            dateText.text = root.dateString;
        }
    }

}
