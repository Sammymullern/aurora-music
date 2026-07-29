import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 16

    property real position: 0.0
    property real duration: 0.0
    property bool isPlaying: false
    property string trackSeed: ""
    signal seekRequested(real position)

    readonly property real fraction: (root.duration > 0) ? Math.max(0, Math.min(1, root.position / root.duration)) : 0
    readonly property bool hoverOrDrag: waveformMA.containsMouse || waveformMA.dragging

    readonly property int barCount: 96
    readonly property real minBarHeightRatio: 0.12
    readonly property real maxBarHeightRatio: 1.0

    property var barHeights: []
    property var liveHeights: []

    Component.onCompleted: regenerateBars()
    onTrackSeedChanged: regenerateBars()

    function regenerateBars() {
        var seed = 0
        var s = root.trackSeed || "default"
        for (var i = 0; i < s.length; i++) {
            seed = ((seed << 5) - seed) + s.charCodeAt(i)
            seed = seed & 0xffffffff
        }
        barHeights = []
        liveHeights = []
        var s2 = seed
        for (var b = 0; b < root.barCount; b++) {
            s2 = (s2 * 1664525 + 1013904223) & 0xffffffff
            var r = (s2 & 0x7fffffff) / 0x7fffffff
            var waveShape = Math.sin(b * 0.32) * 0.18 + Math.sin(b * 0.08) * 0.22 + 0.5
            var h = root.minBarHeightRatio + Math.max(0, Math.min(1, waveShape * 0.55 + r * 0.45)) * (root.maxBarHeightRatio - root.minBarHeightRatio)
            barHeights.push(h)
            liveHeights.push(0)
        }
    }

    Text {
        Layout.preferredWidth: 64
        text: formatTime(root.position)
        font.pixelSize: 13
        font.bold: true
        color: "#ffffff"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        Layout.minimumHeight: 60

        property int activeBars: Math.floor(root.fraction * root.barCount)
        property real fractionalBar: (root.fraction * root.barCount) - activeBars

        Item {
            id: waveformContainer
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            clip: true

            Repeater {
                id: barRepeater
                model: root.barCount

                delegate: Rectangle {
                    property int idx: model.index
                    property bool isPlayed: idx < waveformContainer.activeBars
                    property bool isPartial: idx === waveformContainer.activeBars
                    property real baseH: (barHeights && barHeights[idx]) ? barHeights[idx] : 0.3
                    property real liveOffset: (liveHeights && liveHeights[idx]) ? liveHeights[idx] : 0
                    property real barH: Math.max(root.minBarHeightRatio, Math.min(1.0, baseH + liveOffset))

                    readonly property real totalPad: root.barCount - 1
                    readonly property real gap: 2
                    readonly property real usableWidth: parent.width
                    readonly property real barWidth: Math.max(2, (usableWidth - gap * totalPad) / root.barCount)

                    x: idx * (barWidth + gap)
                    y: parent.height * (1 - barH) / 2
                    width: barWidth
                    height: parent.height * barH
                    radius: Math.min(width / 2, 2)

                    gradient: Gradient {
                        GradientStop {
                            position: 0.0
                            color: isPlayed || isPartial ? "#7c3aed" : "#2a2a48"
                        }
                        GradientStop {
                            position: 1.0
                            color: isPlayed || isPartial ? "#10b981" : "#35355a"
                        }
                    }

                    opacity: isPlayed ? 1.0 : (isPartial ? (0.4 + 0.6 * waveformContainer.fractionalBar) : 0.55)

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#0affffff" }
                            GradientStop { position: 1.0; color: "#00ffffff" }
                        }
                        opacity: (isPlayed || isPartial) ? 0.10 : 0
                    }

                    Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
                    Behavior on opacity { NumberAnimation { duration: 140 } }
                }
            }

            Rectangle {
                id: playhead
                x: {
                    var bars = root.barCount
                    var bw = barRepeater.itemAt(0) ? barRepeater.itemAt(0).width : 4
                    var g = 2
                    return waveformContainer.activeBars * (bw + g) + (bw * waveformContainer.fractionalBar) - width / 2
                }
                y: (parent.height - height) / 2
                width: 3
                height: parent.height * 1.02
                radius: 2
                color: "#ffffff"
                visible: root.fraction > 0

                Rectangle {
                    z: -1
                    anchors.centerIn: parent
                    width: parent.width + 10
                    height: parent.height + 10
                    radius: parent.radius + 5
                    color: "#10b981"
                    opacity: 0.28
                }

                Rectangle {
                    id: playheadDot
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom
                    anchors.topMargin: 4
                    width: 10
                    height: 10
                    radius: 5
                    color: "#ffffff"
                    border.color: "#7c3aed"
                    border.width: 2

                    Rectangle {
                        z: -1
                        anchors.centerIn: parent
                        width: parent.width + 10
                        height: parent.height + 10
                        radius: width / 2
                        color: "#7c3aed"
                        opacity: 0.22
                    }
                }
            }
        }

        MouseArea {
            id: waveformMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse && root.duration > 0
            ToolTip.delay: 200
            ToolTip.text: formatTime(root.position) + "  /  " + formatTime(root.duration)

            property bool dragging: false

            onPressed:  { dragging = true;  updateSeek(mouseX) }
            onPositionChanged: if (dragging) updateSeek(mouseX)
            onReleased: { dragging = false; updateSeek(mouseX) }
            onClicked: updateSeek(mouseX)

            function updateSeek(mouseX) {
                var w = waveformContainer.width
                if (w <= 0) return
                var pos = (mouseX - waveformContainer.x) / w
                pos = Math.max(0, Math.min(1, pos))
                root.seekRequested(pos)
            }
        }
    }

    Text {
        Layout.preferredWidth: 64
        text: formatTime(root.duration)
        font.pixelSize: 13
        color: "#a8a8c8"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    Timer {
        id: liveAnimationTimer
        interval: 85
        running: root.isPlaying && root.barCount > 0
        repeat: true
        onTriggered: {
            if (!liveHeights || liveHeights.length !== root.barCount) return
            var t = Date.now() / 1000
            for (var i = 0; i < root.barCount; i++) {
                var noise = (Math.sin(t * 4.2 + i * 0.51) * 0.09)
                          + (Math.sin(t * 6.7 + i * 0.27) * 0.06)
                          + (Math.sin(t * 9.3 + i * 0.13) * 0.04)
                var envelope = 0.6 + 0.4 * Math.sin(t * 1.2 + i * 0.05)
                liveHeights[i] = noise * envelope
            }
            var r = barRepeater
            for (var j = 0; j < r.count; j++) {
                var item = r.itemAt(j)
                if (item) {
                    var bh = barHeights[j] || 0.3
                    var lh = liveHeights[j] || 0
                    item.barH = Math.max(root.minBarHeightRatio, Math.min(1.0, bh + lh))
                }
            }
        }
    }

    Timer {
        id: settleTimer
        interval: 90
        running: !root.isPlaying && root.barCount > 0
        repeat: true
        onTriggered: {
            var any = false
            for (var i = 0; i < root.barCount; i++) {
                if (liveHeights[i] !== 0) {
                    liveHeights[i] *= 0.78
                    if (Math.abs(liveHeights[i]) < 0.003) liveHeights[i] = 0
                    any = true
                    var item = barRepeater.itemAt(i)
                    if (item) {
                        var bh = barHeights[i] || 0.3
                        item.barH = Math.max(root.minBarHeightRatio, Math.min(1.0, bh + liveHeights[i]))
                    }
                }
            }
            if (!any) settleTimer.stop()
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        var h = Math.floor(seconds / 3600)
        var m = Math.floor((seconds % 3600) / 60)
        var s = Math.floor(seconds % 60)
        function pad(n) { return n < 10 ? "0" + n : "" + n }
        if (h > 0) return h + ":" + pad(m) + ":" + pad(s)
        return m + ":" + pad(s)
    }
}
