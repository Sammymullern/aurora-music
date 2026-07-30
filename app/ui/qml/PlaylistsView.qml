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
                onClicked: newPlaylistDialog.open()
            }
        }
        
        // Empty state
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: playlistModel.rowCount() === 0
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
            id: playlistGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 200
            cellHeight: 250
            visible: playlistModel.rowCount() > 0
            
            model: playlistModel
            
            Connections {
                target: playlistModel
                function onModelChanged() {
                    playlistGrid.model = null
                    playlistGrid.model = playlistModel
                }
            }
            
            delegate: PlaylistCard {
                width: 190
                height: 240
                name: model.name
                trackCount: model.trackCount
                playlistId: model.id
                
                onClicked: {
                    playlistDetailView.playlistId = model.id
                    playlistDetailView.playlistName = model.name
                    contentStack.currentIndex = 3
                }
                onEditRequested: {
                    editPlaylistDialog.playlistId = model.id
                    editPlaylistNameInput.text = model.name
                    editPlaylistDialog.open()
                }
                onDeleteRequested: {
                    deleteConfirmDialog.playlistId = model.id
                    deleteConfirmDialog.open()
                }
            }
        }
    }
    
    // New playlist dialog
    Dialog {
        id: newPlaylistDialog
        title: "Create New Playlist"
        modal: true
        
        anchors.centerIn: parent
        
        ColumnLayout {
            spacing: 15
            
            TextField {
                id: playlistNameInput
                Layout.fillWidth: true
                placeholderText: "Playlist name"
                selectByMouse: true
            }
            
            TextField {
                id: playlistDescInput
                Layout.fillWidth: true
                placeholderText: "Description (optional)"
                selectByMouse: true
            }
            
            RowLayout {
                Layout.fillWidth: true
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Cancel"
                    onClicked: newPlaylistDialog.close()
                }
                
                Button {
                    text: "Create"
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
                    onClicked: {
                        if (playlistNameInput.text.length > 0) {
                            playlistController.createPlaylist(playlistNameInput.text, playlistDescInput.text)
                            newPlaylistDialog.close()
                            playlistNameInput.text = ""
                            playlistDescInput.text = ""
                        }
                    }
                }
            }
        }
    }
    
    // Edit playlist dialog
    Dialog {
        id: editPlaylistDialog
        property int playlistId: 0
        title: ""
        modal: true
        width: 350
        height: 200
        
        anchors.centerIn: parent
        background: Rectangle {
            color: "#1a1a2e"
            radius: 12
            border.color: "#7c3aed"
            border.width: 2
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            anchors.margins: 20
            
            // Header with close button
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Edit Playlist"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#e0e0e0"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "×"
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#a0a0a0"
                        font.pixelSize: 20
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: editPlaylistDialog.close()
                }
            }
            
            // Playlist name input
            TextField {
                id: editPlaylistNameInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: "Playlist name..."
                color: "#e0e0e0"
                font.pixelSize: 13
                padding: 10
                background: Rectangle {
                    color: "#252542"
                    radius: 8
                }
                selectByMouse: true
            }
            
            Item { Layout.fillHeight: true }
            
            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Save"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle {
                        color: "#7c3aed"
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        if (editPlaylistNameInput.text.length > 0) {
                            playlistController.updatePlaylist(editPlaylistDialog.playlistId, editPlaylistNameInput.text, "")
                            editPlaylistDialog.close()
                            editPlaylistNameInput.text = ""
                        }
                    }
                }
            }
        }
    }
    
    // Delete confirmation dialog
    Dialog {
        id: deleteConfirmDialog
        property int playlistId: 0
        title: ""
        modal: true
        width: 350
        height: 180
        
        anchors.centerIn: parent
        background: Rectangle {
            color: "#1a1a2e"
            radius: 12
            border.color: "#ef4444"
            border.width: 2
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 15
            anchors.margins: 20
            
            // Header with close button
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Delete Playlist"
                    font.pixelSize: 18
                    font.bold: true
                    color: "#e0e0e0"
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "×"
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "#a0a0a0"
                        font.pixelSize: 20
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: deleteConfirmDialog.close()
                }
            }
            
            // Warning message
            Text {
                text: "Are you sure you want to delete this playlist? This action cannot be undone."
                font.pixelSize: 13
                color: "#a0a0a0"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }
            
            Item { Layout.fillHeight: true }
            
            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Button {
                    text: "Cancel"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle {
                        color: "#4a4a6a"
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: deleteConfirmDialog.close()
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Delete"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 100
                    background: Rectangle {
                        color: "#ef4444"
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 13
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        playlistController.deletePlaylist(deleteConfirmDialog.playlistId)
                        deleteConfirmDialog.close()
                    }
                }
            }
        }
    }
}
