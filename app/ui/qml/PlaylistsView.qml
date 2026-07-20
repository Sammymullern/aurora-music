import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 20
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: "Playlists"
                font.pixelSize: 28
                font.bold: true
                color: "#e0e0e0"
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "+ New Playlist"
                background: Rectangle {
                    color: "#7c3aed"
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        
        // Playlist grid
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 200
            cellHeight: 250
            
            model: 10  // Placeholder
            
            delegate: PlaylistCard {
                width: 190
                height: 240
                name: "Playlist " + (index + 1)
                trackCount: (index + 1) * 5
            }
        }
    }
}
