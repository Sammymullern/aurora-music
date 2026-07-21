import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property int trackCount: 0  // Will be connected to database
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 20
        
        // Section header
        Text {
            text: "Library"
            font.pixelSize: 28
            font.bold: true
            color: "#e0e0e0"
        }
        
        // Empty state
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: trackCount === 0
            color: "transparent"
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                // Empty state icon
                Text {
                    text: "🎵"
                    font.pixelSize: 80
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Empty state message
                Text {
                    text: "No music in library"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Subtitle
                Text {
                    text: "Add your music folders in Settings to get started"
                    font.pixelSize: 14
                    color: "#a0a0a0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Add music button
                Button {
                    text: "Add Music"
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
                        // Navigate to settings
                        contentStack.currentIndex = 3
                    }
                }
            }
        }
        
        // Track list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            visible: trackCount > 0
            
            ListView {
                id: trackList
                model: trackCount
                
                delegate: TrackDelegate {
                    width: trackList.width
                    title: "Track " + (index + 1)
                    artist: "Artist Name"
                    album: "Album Name"
                    duration: "3:45"
                    onPlayClicked: console.log("Play track", index)
                }
                
                spacing: 5
            }
        }
    }
}
