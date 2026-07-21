import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property int playlistCount: 0  // Will be connected to database
    
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
        
        // Empty state
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: playlistCount === 0
            color: "transparent"
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                // Empty state icon
                Text {
                    text: "📝"
                    font.pixelSize: 80
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Empty state message
                Text {
                    text: "No playlists yet"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Subtitle
                Text {
                    text: "Create your first playlist to organize your music"
                    font.pixelSize: 14
                    color: "#a0a0a0"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
        
        // Playlist grid
        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 200
            cellHeight: 250
            visible: playlistCount > 0
            
            model: playlistCount
            
            delegate: PlaylistCard {
                width: 190
                height: 240
                name: "Playlist " + (index + 1)
                trackCount: (index + 1) * 5
            }
        }
    }
}
