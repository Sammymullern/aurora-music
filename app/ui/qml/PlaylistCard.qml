import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    property string name: ""
    property int trackCount: 0
    
    implicitWidth: 190
    implicitHeight: 240
    radius: 12
    color: "#252542"
    
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // Playlist art placeholder
        Rectangle {
            width: parent.width
            height: 150
            radius: 8
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ec4899" }
                GradientStop { position: 1.0; color: "#8b5cf6" }
            }
            
            Text {
                anchors.centerIn: parent
                text: "🎵"
                font.pixelSize: 50
            }
        }
        
        Text {
            text: root.name
            font.pixelSize: 14
            font.bold: true
            color: "#e0e0e0"
            width: parent.width
            elide: Text.ElideRight
        }
        
        Text {
            text: root.trackCount + " tracks"
            font.pixelSize: 12
            color: "#a0a0a0"
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: root.color = "#2a2a52"
        onExited: root.color = "#252542"
        cursorShape: Qt.PointingHandCursor
    }
}
