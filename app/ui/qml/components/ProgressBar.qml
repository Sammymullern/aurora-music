import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    property real value: 0.0  // 0.0 to 1.0
    property real duration: 0.0
    signal seekRequested(real position)
    
    height: 6
    radius: 3
    color: "#1e293b"
    
    Rectangle {
        id: progress
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * root.value
        radius: parent.radius
        color: "#10b981"
        
        Behavior on width {
            NumberAnimation { duration: 100 }
        }
    }
    
    Rectangle {
        id: handle
        anchors.left: progress.right
        anchors.verticalCenter: parent.verticalCenter
        width: 12
        height: 12
        radius: 6
        color: "#10b981"
        visible: root.isHovered || root.isDragging
        
        Behavior on x {
            NumberAnimation { duration: 100 }
        }
    }
    
    property bool isHovered: false
    property bool isDragging: false
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onPressed: {
            root.isDragging = true
            updatePosition(mouseX)
        }
        onPositionChanged: {
            if (root.isDragging) {
                updatePosition(mouseX)
            }
        }
        onReleased: {
            root.isDragging = false
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
