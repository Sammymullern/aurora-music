import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 12
    
    property real position: 0.0
    property real duration: 0.0
    signal seekRequested(real position)
    
    // Elapsed time
    Text {
        Layout.preferredWidth: 45
        text: formatTime(root.position)
        font.pixelSize: 11
        color: "#a0a0b0"
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
    }
    
    // Progress bar
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 4
        radius: 2
        color: "#252542"
        
        Rectangle {
            id: progress
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * (root.duration > 0 ? root.position / root.duration : 0)
            radius: parent.radius
            color: "#10b981"
            
            Behavior on width {
                NumberAnimation { duration: 100 }
            }
        }
        
        // Hover handle
        Rectangle {
            id: handle
            anchors.left: progress.right
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: "#10b981"
            visible: progressMouseArea.containsMouse || progressMouseArea.dragging
            
            Behavior on x {
                NumberAnimation { duration: 100 }
            }
        }
        
        MouseArea {
            id: progressMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            property bool dragging: false
            
            onPressed: {
                dragging = true
                updatePosition(mouseX)
            }
            onPositionChanged: {
                if (dragging) {
                    updatePosition(mouseX)
                }
            }
            onReleased: {
                dragging = false
                updatePosition(mouseX)
            }
            onClicked: {
                updatePosition(mouseX)
            }
            
            function updatePosition(mouseX) {
                var position = mouseX / parent.width
                position = Math.max(0, Math.min(1, position))
                root.seekRequested(position)
            }
        }
    }
    
    // Total duration
    Text {
        Layout.preferredWidth: 45
        text: formatTime(root.duration)
        font.pixelSize: 11
        color: "#a0a0b0"
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }
    
    function formatTime(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
