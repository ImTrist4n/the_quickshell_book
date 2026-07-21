/*!
 * \qmltype WeatherWidget
 * \inqmlmodule Widgets
 * \brief Displays current weather for a city.
 *
 * Shows city name, temperature, and a textual condition description
 * stacked vertically.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    /*! City name. */
    property string city: ""

    /*! Temperature string (e.g. "24°C"). */
    property string temperature: ""

    /*! Weather condition description (e.g. "Partly Cloudy"). */
    property string condition: ""

    implicitWidth: weatherColumn.implicitWidth
    implicitHeight: weatherColumn.implicitHeight

    ColumnLayout {
        id: weatherColumn
        anchors.centerIn: parent
        spacing: 1

        Text {
            text: root.city
            color: "#f38ba8"
            font.pixelSize: 11
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Text {
            text: root.temperature
            color: "#cdd6f4"
            font.pixelSize: 14
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }

        Text {
            text: root.condition
            color: "#89b4fa"
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
        }
    }
}
