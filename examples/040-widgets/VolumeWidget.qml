/*!
 * \qmltype VolumeWidget
 * \inqmlmodule Widgets
 * \brief Displays audio volume level and mute status.
 *
 * Shows a speaker icon that reflects mute state and volume icon,
 * along with a percentage label.
 */

import QtQuick
import QtQuick.Layouts

Item {
    id: root

    /*! Volume level from 0 to 100. */
    property int volume: 0

    /*! Whether the audio output is muted. */
    property bool muted: false

    implicitWidth: volumeRow.implicitWidth
    implicitHeight: volumeRow.implicitHeight

    RowLayout {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: {
                if (root.muted) return "\uD83D\uDD07";
                if (root.volume <= 0) return "\uD83D\uDD07";
                if (root.volume <= 33) return "\uD83D\uDD08";
                if (root.volume <= 66) return "\uD83D\uDD09";
                return "\uD83D\uDD0A";
            }
            color: root.muted ? "#f38ba8" : "#cdd6f4"
            font.pixelSize: 14
        }

        Text {
            text: root.volume + "%"
            color: root.muted ? "#585b70" : "#cdd6f4"
            font.pixelSize: 12
        }
    }
}
