import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property string title: ""
    property string artist: ""
    property string album: ""
    property string duration: ""
    
    signal playClicked()
    
    implicitHeight: 60
    color: "#252542"
    radius: 8
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        spacing: 15
        
        // Play button
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 20
            color: "#7c3aed"
            
            Text {
                anchors.centerIn: parent
                text: "▶"
                font.pixelSize: 16
                color: "white"
            }
            
            MouseArea {
                anchors.fill: parent
                onClicked: root.playClicked()
                cursorShape: Qt.PointingHandCursor
            }
        }
        
        // Track info
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: root.title
                font.pixelSize: 14
                font.bold: true
                color: "#e0e0e0"
            }
            
            Text {
                text: root.artist + " • " + root.album
                font.pixelSize: 12
                color: "#a0a0a0"
            }
        }
        
        // Duration
        Text {
            text: root.duration
            font.pixelSize: 13
            color: "#a0a0a0"
            Layout.preferredWidth: 50
        }
        
        // More options
        Text {
            text: "⋮"
            font.pixelSize: 20
            color: "#a0a0a0"
            Layout.preferredWidth: 30
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: root.color = "#2a2a52"
        onExited: root.color = "#252542"
    }
}
