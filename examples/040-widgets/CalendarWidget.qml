/*!
 * \qmltype CalendarWidget
 * \inqmlmodule Widgets
 * \brief Displays a monthly calendar grid.
 *
 * Renders a month/year header and a grid of day cells for the
 * month represented by \c date. Days before the 1st are shown
 * as blank cells so the grid alignment is correct.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    /*! The date used to determine the displayed month and year. */
    property date date: new Date()

    /*! The first day of the displayed month. */
    readonly property date monthStart: new Date(date.getFullYear(), date.getMonth(), 1)

    /*! The last day of the displayed month. */
    readonly property date monthEnd: new Date(date.getFullYear(), date.getMonth() + 1, 0)

    /*! Number of days in the month. */
    readonly property int daysInMonth: monthEnd.getDate()

    /*! Weekday of the first day (0=Sun .. 6=Sat). */
    readonly property int startDayOfWeek: monthStart.getDay()

    /*! Total cells needed to fill the grid (leading blanks + days). */
    readonly property int totalCells: startDayOfWeek + daysInMonth

    implicitWidth: calendarColumn.implicitWidth
    implicitHeight: calendarColumn.implicitHeight

    ColumnLayout {
        id: calendarColumn
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                var months = ["January","February","March","April","May","June",
                              "July","August","September","October","November","December"];
                return months[root.date.getMonth()] + " " + root.date.getFullYear();
            }
            color: "#cdd6f4"
            font.pixelSize: 13
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        GridLayout {
            columns: 7
            rowSpacing: 2
            columnSpacing: 2
            Layout.alignment: Qt.AlignHCenter

            Repeater {
                model: 7

                Text {
                    text: ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"][model.index]
                    color: "#585b70"
                    font.pixelSize: 10
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    width: 28
                    height: 20
                }
            }

            Repeater {
                model: root.totalCells

                Item {
                    width: 28
                    height: 24

                    Text {
                        anchors.centerIn: parent
                        text: {
                            var day = model.index - root.startDayOfWeek + 1;
                            return (day >= 1 && day <= root.daysInMonth) ? day : "";
                        }
                        color: {
                            if (text === "") return "transparent";
                            var today = new Date();
                            var isToday = root.date.getFullYear() === today.getFullYear()
                                       && root.date.getMonth() === today.getMonth()
                                       && parseInt(text) === today.getDate();
                            return isToday ? "#f38ba8" : "#cdd6f4";
                        }
                        font.pixelSize: 11
                        font.bold: {
                            if (text === "") return false;
                            var today = new Date();
                            return root.date.getFullYear() === today.getFullYear()
                                && root.date.getMonth() === today.getMonth()
                                && parseInt(text) === today.getDate();
                        }
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -2
                            radius: 4
                            color: "transparent"
                            border.color: "#89b4fa"
                            border.width: parent.text !== "" && parent.font.bold ? 1 : 0
                            visible: parent.font.bold
                        }
                    }
                }
            }
        }
    }
}
