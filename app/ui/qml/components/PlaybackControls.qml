import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Row {
    id: root
    spacing: 8
    
    property bool isPlaying: false
    property bool isShuffle: false
    property string repeatMode: "off" // "off", "all", "one"
    
    signal shuffleClicked()
    signal previousClicked()
    signal playPauseClicked()
    signal nextClicked()
    signal repeatClicked()
    
    // Shuffle button
    Rectangle {
        width: 40
        height: 40
        radius: 20
        color: root.isShuffle ? "#059669" : "transparent"
        border.color: root.isShuffle ? "#10b981" : "#a0a0b0"
        border.width: root.isShuffle ? 2 : 1
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }
        
        Image {
            anchors.centerIn: parent
source: "../../../../assets/icons/shuffle.svg"
            sourceSize.width: 22
            sourceSize.height: 22
            width: 22
            height: 22
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (!root.isShuffle) {
                    parent.color = containsMouse ? "#252542" : "transparent"
                    parent.border.color = containsMouse ? "#10b981" : "#a0a0b0"
                }
            }
            onClicked: root.shuffleClicked()
        }
    }
    
    // Previous button
    Rectangle {
        width: 40
        height: 40
        radius: 20
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
source: "../../../../assets/icons/previous.svg"
            sourceSize.width: 22
            sourceSize.height: 22
            width: 22
            height: 22
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                parent.color = containsMouse ? "#252542" : "transparent"
                parent.border.color = containsMouse ? "#10b981" : "#a0a0b0"
            }
            onClicked: root.previousClicked()
        }
    }
    
    // Play/Pause button (larger)
    Rectangle {
        width: 48
        height: 48
        radius: 24
        color: "#10b981"
        border.color: "#10b981"
        border.width: 2
        
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
        
        scale: playPauseMouse.pressed ? 0.92 : 1.0
        
        Image {
            anchors.centerIn: parent
source: root.isPlaying ? "../../../../assets/icons/pause.svg" : "../../../../assets/icons/play.svg"
            sourceSize.width: 26
            sourceSize.height: 26
            width: 26
            height: 26
        }
        
        MouseArea {
            id: playPauseMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.playPauseClicked()
        }
    }
    
    // Next button
    Rectangle {
        width: 40
        height: 40
        radius: 20
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
source: "../../../../assets/icons/next.svg"
            sourceSize.width: 22
            sourceSize.height: 22
            width: 22
            height: 22
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                parent.color = containsMouse ? "#252542" : "transparent"
                parent.border.color = containsMouse ? "#10b981" : "#a0a0b0"
            }
            onClicked: root.nextClicked()
        }
    }
    
    // Repeat button
    Rectangle {
        width: 40
        height: 40
        radius: 20
        color: root.repeatMode !== "off" ? "#059669" : "transparent"
        border.color: root.repeatMode !== "off" ? "#10b981" : "#a0a0b0"
        border.width: root.repeatMode !== "off" ? 2 : 1
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        
        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }
        
        Image {
            anchors.centerIn: parent
source: root.repeatMode === "one" ? "../../../../assets/icons/repeat-once.svg" : "../../../../assets/icons/repeat.svg"
            sourceSize.width: 22
            sourceSize.height: 22
            width: 22
            height: 22
        }
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (root.repeatMode === "off") {
                    parent.color = containsMouse ? "#252542" : "transparent"
                    parent.border.color = containsMouse ? "#10b981" : "#a0a0b0"
                }
            }
            onClicked: root.repeatClicked()
        }
    }
}
