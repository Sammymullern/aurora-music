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
    color: theme.surface
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
            color: theme.primary
            
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
                color: theme.textPrimary
            }
            
            Text {
                text: root.artist + " • " + root.album
                font.pixelSize: 12
                color: theme.textSecondary
            }
        }
        
        // Duration
        Text {
            text: root.duration
            font.pixelSize: 13
            color: theme.textSecondary
            Layout.preferredWidth: 50
        }
        
        // More options
        Text {
            text: "⋮"
            font.pixelSize: 20
            color: theme.textSecondary
            Layout.preferredWidth: 30
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        
        onEntered: root.color = theme.surfaceVariant
        onExited: root.color = theme.surface
    }
}
