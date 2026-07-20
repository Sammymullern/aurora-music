import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    
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
        
        // Track list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ListView {
                id: trackList
                model: 50  // Placeholder
                
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
