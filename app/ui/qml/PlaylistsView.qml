import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: theme.background
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 28
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            Text {
                text: "Playlists"
                font.pixelSize: 30
                font.weight: Font.DemiBold
                color: theme.textPrimary
            }

            Text {
                text: "Your music, gathered your way"
                font.pixelSize: 13
                color: theme.textSecondary
                Layout.alignment: Qt.AlignVCenter
            }
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "+ New Playlist"
                Layout.preferredHeight: 42
                Layout.preferredWidth: 150
                background: Rectangle {
                    color: theme.primary
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
                    color: theme.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Subtitle
                Text {
                    text: "Create your first playlist to organize your music"
                    font.pixelSize: 14
                    color: theme.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }

                Button {
                    text: "Create a playlist"
                    Layout.alignment: Qt.AlignHCenter
                    contentItem: Text {
                        text: parent.text
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle { color: theme.primary; radius: 12 }
                    onClicked: newPlaylistDialog.open()
                }
            }
        }
        
        // Playlist grid
        GridView {
            id: playlistGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            cellWidth: 224
            cellHeight: 268
            visible: playlistModel.rowCount() > 0
            clip: true
            
            model: playlistModel
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            
            Connections {
                target: playlistModel
                function onModelChanged() {
                    playlistGrid.model = null
                    playlistGrid.model = playlistModel
                }
            }
            
            delegate: PlaylistCard {
                width: 208
                height: 252
                name: model.name
                description: model.description
                trackCount: model.trackCount
                playlistId: model.id
                
                onClicked: {
                    playlistDetailView.playlistId = model.id
                    playlistDetailView.playlistName = model.name
                    playlistDetailView.playlistDescription = model.description
                    contentStack.currentIndex = 3
                }
                onEditRequested: {
                    editPlaylistDialog.playlistId = model.id
                    editPlaylistNameInput.text = model.name
                    editPlaylistDescInput.text = model.description
                    editPlaylistDialog.open()
                }
                onDeleteRequested: {
                    deleteConfirmDialog.playlistId = model.id
                    deleteConfirmDialog.open()
                }
                onDuplicateRequested: playlistController.duplicatePlaylist(model.id)
            }
        }
    }
    
    // New playlist dialog
    Dialog {
        id: newPlaylistDialog
        property string errorMessage: ""
        title: ""
        modal: true
        width: 420
        height: 260
        
        anchors.centerIn: parent
        background: Rectangle { color: theme.surface; radius: 16; border.color: theme.border }
        onOpened: errorMessage = ""
        
        ColumnLayout {
            spacing: 15
            anchors.fill: parent
            anchors.margins: 22

            Text {
                text: "Create playlist"
                color: theme.textPrimary
                font.pixelSize: 20
                font.weight: Font.DemiBold
            }
            
            TextField {
                id: playlistNameInput
                Layout.fillWidth: true
                placeholderText: "Playlist name"
                color: theme.textPrimary
                placeholderTextColor: theme.textSecondary
                background: Rectangle { color: theme.background; radius: 10; border.color: theme.border }
                selectByMouse: true
            }
            
            TextField {
                id: playlistDescInput
                Layout.fillWidth: true
                placeholderText: "Description (optional)"
                color: theme.textPrimary
                placeholderTextColor: theme.textSecondary
                background: Rectangle { color: theme.background; radius: 10; border.color: theme.border }
                selectByMouse: true
            }

            Text {
                Layout.fillWidth: true
                visible: newPlaylistDialog.errorMessage.length > 0
                text: newPlaylistDialog.errorMessage
                color: "#dc2626"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
            }
            
            RowLayout {
                Layout.fillWidth: true
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Cancel"
                    contentItem: Text { text: parent.text; color: theme.textPrimary; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: theme.surfaceVariant; radius: 8 }
                    onClicked: newPlaylistDialog.close()
                }
                
                Button {
                    text: "Create"
                    background: Rectangle {
                        color: theme.primary
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
                        if (playlistController.createPlaylist(playlistNameInput.text, playlistDescInput.text)) {
                            newPlaylistDialog.close()
                            playlistNameInput.text = ""
                            playlistDescInput.text = ""
                        } else {
                            newPlaylistDialog.errorMessage = playlistNameInput.text.trim().length === 0
                                ? "Enter a playlist name."
                                : "That name is already in use. Choose another name."
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
        property string errorMessage: ""
        title: ""
        modal: true
        width: 350
        height: 300
        
        anchors.centerIn: parent
        background: Rectangle {
            color: theme.surface
            radius: 12
            border.color: theme.primary
            border.width: 1
        }
        onOpened: errorMessage = ""
        
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
                    color: theme.textPrimary
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
                        color: theme.textSecondary
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
                color: theme.textPrimary
                font.pixelSize: 13
                padding: 10
                background: Rectangle {
                    color: theme.surface
                    radius: 8
                    border.color: theme.border
                }
                selectByMouse: true
            }

            TextField {
                id: editPlaylistDescInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: "Description (optional)"
                color: theme.textPrimary
                placeholderTextColor: theme.textSecondary
                padding: 10
                background: Rectangle { color: theme.surface; radius: 8; border.color: theme.border }
                selectByMouse: true
            }

            Text {
                Layout.fillWidth: true
                visible: editPlaylistDialog.errorMessage.length > 0
                text: editPlaylistDialog.errorMessage
                color: "#dc2626"
                font.pixelSize: 12
                wrapMode: Text.WordWrap
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
                        color: theme.primary
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
                        if (playlistController.updatePlaylist(editPlaylistDialog.playlistId, editPlaylistNameInput.text, editPlaylistDescInput.text)) {
                            editPlaylistDialog.close()
                            editPlaylistNameInput.text = ""
                            editPlaylistDescInput.text = ""
                        } else {
                            editPlaylistDialog.errorMessage = editPlaylistNameInput.text.trim().length === 0
                                ? "Enter a playlist name."
                                : "That name is already in use. Choose another name."
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
        height: 220
        
        anchors.centerIn: parent
        background: Rectangle {
            color: theme.background
            radius: 12
            border.color: "#ef4444"
            border.width: 1
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
                    color: theme.textPrimary
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
                        color: theme.textSecondary
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
                color: theme.textSecondary
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
                        color: theme.surfaceVariant
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        color: theme.textPrimary
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
