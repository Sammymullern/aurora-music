import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property bool isPlaying: false  // Will be connected to player
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 40
        
        // Empty state when not playing
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !isPlaying
            color: "transparent"
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                // Empty state icon
                Text {
                    text: "🎧"
                    font.pixelSize: 100
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Empty state message
                Text {
                    text: "Nothing playing"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Subtitle
                Text {
                    text: "Select a track from your library to start listening"
                    font.pixelSize: 16
                    color: "#a0a0a0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Go to library button
                Button {
                    text: "Go to Library"
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 40
                    
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.hovered ? "#7c3aed" : "#6366f1"
                        radius: 20
                    }
                    
                    onClicked: {
                        // Navigate to library
                        contentStack.currentIndex = 0
                    }
                }
            }
        }
        
        // Now playing content
        ColumnLayout {
            visible: isPlaying
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20
            
            // Album art
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 400
                Layout.preferredHeight: 400
                radius: 20
                color: "#252542"
                
                // Placeholder gradient
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#7c3aed" }
                    GradientStop { position: 1.0; color: "#3b82f6" }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "🎵"
                    font.pixelSize: 100
                }
            }
            
            // Track info
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                
                Text {
                    text: "Track Title"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: "Artist Name • Album Name"
                    font.pixelSize: 18
                    color: "#a0a0a0"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
