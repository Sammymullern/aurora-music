import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 14

    property real position: 0
    property real duration: 0
    property var waveformData: waveformController ? waveformController.waveformData : []
    property bool waveformLoading: waveformController ? waveformController.isLoading : false
    property string waveformError: waveformController ? waveformController.error : ""

    readonly property real fraction: duration > 0 ? Math.max(0, Math.min(1, position / duration)) : 0
    readonly property int barCount: waveformData ? waveformData.length : 0
    signal seekRequested(real fraction)

    Text {
        Layout.preferredWidth: 58
        text: root.formatTime(root.position)
        font.pixelSize: 12
        font.bold: true
        color: theme.textPrimary
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }

    Item {
        id: waveformTrack
        Layout.fillWidth: true
        Layout.preferredHeight: 76
        Layout.minimumHeight: 48
        clip: true

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: 3
            radius: 2
            color: theme.border
            visible: root.barCount === 0

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * root.fraction
                radius: parent.radius
                color: theme.primary
            }
        }

        Repeater {
            model: root.waveformData
            delegate: Rectangle {
                required property int index
                readonly property real gap: 1
                readonly property real amplitude: Number(root.waveformData[index] || 0.035)
                readonly property real barWidth: Math.max(1, (waveformTrack.width - gap * (root.barCount - 1)) / root.barCount)
                readonly property bool played: index < root.fraction * root.barCount

                x: index * (barWidth + gap)
                width: barWidth
                height: Math.max(2, waveformTrack.height * amplitude)
                y: (waveformTrack.height - height) / 2
                radius: Math.min(2, width / 2)
                opacity: played ? 1.0 : 0.62
                gradient: Gradient {
                    GradientStop { position: 0; color: played ? "#34d399" : theme.borderLight }
                    GradientStop { position: 1; color: played ? theme.primary : theme.border }
                }
            }
        }

        Rectangle {
            x: Math.max(0, Math.min(waveformTrack.width - width, waveformTrack.width * root.fraction - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: 3
            height: parent.height * 0.92
            radius: 2
            color: "#ffffff"
            visible: root.duration > 0
            z: 2

            Rectangle {
                z: -1
                anchors.centerIn: parent
                width: parent.width + 9
                height: parent.height + 8
                radius: 5
                color: theme.primary
                opacity: 0.22
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.waveformLoading ? "Preparing waveform…" : "Waveform unavailable"
            color: theme.textSecondary
            font.pixelSize: 11
            visible: root.barCount === 0 && root.duration > 0
            opacity: 0.9
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.duration > 0
            hoverEnabled: true
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            property bool dragging: false
            ToolTip.visible: containsMouse && root.duration > 0
            ToolTip.delay: 180
            ToolTip.text: root.formatTime(root.position) + " / " + root.formatTime(root.duration)

            onPressed: dragging = true
            onPositionChanged: if (dragging) updateSeek(mouseX)
            onReleased: {
                dragging = false
                updateSeek(mouseX)
            }

            function updateSeek(mouseX) {
                if (waveformTrack.width <= 0) return
                root.seekRequested(Math.max(0, Math.min(1, mouseX / waveformTrack.width)))
            }
        }
    }

    Text {
        Layout.preferredWidth: 58
        text: root.formatTime(root.duration)
        font.pixelSize: 12
        color: theme.textSecondary
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        var secs = Math.floor(seconds % 60)
        function pad(value) { return value < 10 ? "0" + value : "" + value }
        if (hours > 0) return hours + ":" + pad(minutes) + ":" + pad(secs)
        return minutes + ":" + pad(secs)
    }
}
