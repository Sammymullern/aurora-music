import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Row {
    id: root
    spacing: 8
    
    property int volume: 100
    signal volumeValueChanged(int volume)
    
    // Speaker icon button
    Rectangle {
        width: 36
        height: 36
        radius: 18
        color: "transparent"
        border.color: "#a0a0b0"
        border.width: 1
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }
        
        Image {
            anchors.centerIn: parent
            source: getVolumeIcon(root.volume)
            sourceSize.width: 20
            sourceSize.height: 20
            width: 20
            height: 20
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                parent.color = containsMouse ? "#252542" : "transparent"
                parent.border.color = containsMouse ? "#10b981" : "#a0a0b0"
            }
            onClicked: {
                // Toggle mute
                if (root.volume > 0) {
                    root.volumeValueChanged(0)
                } else {
                    root.volumeValueChanged(50)
                }
            }
        }
    }
    
    // Volume slider (collapsible based on window width)
    Rectangle {
        Layout.preferredWidth: 100
        Layout.preferredHeight: 4
        radius: 2
        color: "#252542"
        visible: parent.width > 600
        
        Rectangle {
            id: volumeProgress
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * (root.volume / 100)
            radius: parent.radius
            color: "#10b981"
            
            Behavior on width {
                NumberAnimation { duration: 100 }
            }
        }
        
        // Hover handle
        Rectangle {
            id: volumeHandle
            anchors.left: volumeProgress.right
            anchors.verticalCenter: parent.verticalCenter
            width: 8
            height: 8
            radius: 4
            color: "#10b981"
            visible: volumeMouseArea.containsMouse || volumeMouseArea.dragging
            
            Behavior on x {
                NumberAnimation { duration: 100 }
            }
        }
        
        MouseArea {
            id: volumeMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            
            property bool dragging: false
            
            onPressed: {
                dragging = true
                updateVolume(mouseX)
            }
            onPositionChanged: {
                if (dragging) {
                    updateVolume(mouseX)
                }
            }
            onReleased: {
                dragging = false
                updateVolume(mouseX)
            }
            onClicked: {
                updateVolume(mouseX)
            }
            
            function updateVolume(mouseX) {
                var vol = (mouseX / parent.width) * 100
                vol = Math.max(0, Math.min(100, vol))
                root.volumeValueChanged(Math.round(vol))
            }
        }
    }
    
    function getVolumeIcon(vol) {
        if (vol === 0) return "../../../../assets/icons/mute.svg"
        if (vol < 30) return "../../../../assets/icons/volume.svg"
        if (vol < 70) return "../../../../assets/icons/volume.svg"
        return "../../../../assets/icons/volume.svg"
    }
}
