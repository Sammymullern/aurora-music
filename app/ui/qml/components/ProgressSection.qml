import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 14

    property real position: 0.0
    property real duration: 0.0
    signal seekRequested(real position)

    readonly property real fraction: (root.duration > 0) ? Math.max(0, Math.min(1, root.position / root.duration)) : 0
    readonly property bool hoverOrDrag: barMA.containsMouse || barMA.dragging

    // ###########################################
    // # Elapsed time (left) — bold white, 13px
    // ###########################################
    Text {
        Layout.preferredWidth: 60
        text: formatTime(root.position)
        font.pixelSize: 13
        font.bold: true
        color: "#ffffff"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }

    // ###########################################
    // # Progress bar container (enlarges on hover/drag)
    // ###########################################
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 28
        Layout.alignment: Qt.AlignVCenter

        // Track — 8px thick, grows to 10px when hovered/dragging.
        Rectangle {
            id: barTrack
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.hoverOrDrag ? 10 : 8
            radius: height / 2
            color: "#202040"
            border { color: "#2c2c52"; width: 1 }

            // Filled portion — Aurora purple→green gradient.
            // Disable tween animation during drag to feel responsive.
            Rectangle {
                id: barFilled
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: parent.width * root.fraction
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#7c3aed" }   // aurora purple
                    GradientStop { position: 1.0; color: "#10b981" }   // aurora green
                }
                Behavior on width {
                    enabled: !barMA.dragging
                    NumberAnimation { duration: 80 }
                }

                // Tiny subtle highlight along the top of the fill (3D feel).
                Rectangle {
                    anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 1 }
                    height: 1
                    radius: 0.5
                    color: "#ffffff"
                    opacity: 0.18
                }
            }

            // Handle — 12–16px with double halo (purple outer + white inner)
            Rectangle {
                id: handle
                anchors { left: barFilled.right; leftMargin: root.hoverOrDrag ? -8 : -6; verticalCenter: parent.verticalCenter }
                width: root.hoverOrDrag ? 16 : 12
                height: width
                radius: width / 2
                color: "#ffffff"
                border { color: "#10b981"; width: 2 }
                visible: root.hoverOrDrag || root.fraction > 0
                Behavior on width { NumberAnimation { duration: 80 } }
                Behavior on height { NumberAnimation { duration: 80 } }
                Behavior on anchors.leftMargin { NumberAnimation { duration: 80 } }

                // Purple halo (outer)
                Rectangle {
                    z: -1
                    anchors.centerIn: parent
                    width: parent.width + 8
                    height: parent.height + 8
                    radius: width / 2
                    color: "#7c3aed"
                    opacity: 0.22
                }
                // Green halo (inner)
                Rectangle {
                    z: -1
                    anchors.centerIn: parent
                    width: parent.width + 4
                    height: parent.height + 4
                    radius: width / 2
                    color: "#34d399"
                    opacity: 0.30
                }
            }
        }

        // Hit area — full container height so easy to grab.
        MouseArea {
            id: barMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse && root.duration > 0
            ToolTip.delay: 250
            ToolTip.text: formatTime(root.position) + "  /  " + formatTime(root.duration)

            property bool dragging: false

            onPressed:  { dragging = true;  updateSeek(mouseX) }
            onPositionChanged: if (dragging) updateSeek(mouseX)
            onReleased: { dragging = false; updateSeek(mouseX) }
            onClicked: updateSeek(mouseX)

            function updateSeek(mouseX) {
                var w = barTrack.width
                if (w <= 0) return
                var pos = (mouseX - barTrack.x) / w
                pos = Math.max(0, Math.min(1, pos))
                root.seekRequested(pos)
            }
        }
    }

    // ###########################################
    // # Duration (right) — muted purple, 13px
    // ###########################################
    Text {
        Layout.preferredWidth: 60
        text: formatTime(root.duration)
        font.pixelSize: 13
        color: "#a8a8c8"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
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
