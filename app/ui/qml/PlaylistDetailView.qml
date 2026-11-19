import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: theme.background
    property int playlistId: 0
    property string playlistName: ""
    property string playlistDescription: ""
    property var playlistStats: playlistController.getPlaylistStats(root.playlistId)
    
    signal backRequested()
    
    Connections {
        target: musicManager
        function onFavoriteToggled(trackId, isFavorite) {
            root.refreshPlaylist(true)
        }
        function onLibraryStatsChanged() {
            if (addTracksDialog.visible)
                filterAvailableTracks()
        }
    }

    onPlaylistIdChanged: root.refreshPlaylist(false)

    function refreshPlaylist(preserveVisibleOrder) {
        if (!playlistController) return
        var freshTracks = playlistController.getPlaylistTracks(root.playlistId)
        if (preserveVisibleOrder && playlistTracksList.model) {
            var byId = {}
            for (var i = 0; i < freshTracks.length; i++)
                byId[String(freshTracks[i].id)] = freshTracks[i]
            var ordered = []
            var used = {}
            var currentTracks = playlistTracksList.model
            for (var j = 0; j < currentTracks.length; j++) {
                var currentId = String(currentTracks[j].id)
                if (byId[currentId]) {
                    ordered.push(byId[currentId])
                    used[currentId] = true
                }
            }
            for (var k = 0; k < freshTracks.length; k++) {
                var freshId = String(freshTracks[k].id)
                if (!used[freshId]) ordered.push(freshTracks[k])
            }
            freshTracks = ordered
        }
        playlistTracksList.model = freshTracks
        playlistStats = playlistController.getPlaylistStats(root.playlistId)
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Hero Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 260
            color: theme.background
            
            // Top navigation row
            RowLayout {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                spacing: 20
                height: 50
                
                // Back button
                Button {
                    text: "←"
                    font.pixelSize: 24
                    background: Rectangle {
                        color: "transparent"
                    }
                    contentItem: Text {
                        text: parent.text
                        color: theme.textPrimary
                        font.pixelSize: 24
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        contentStack.currentIndex = 2
                    }
                }
                
                Item { Layout.fillWidth: true }

                Button {
                    text: "Edit playlist"
                    Layout.preferredHeight: 38
                    Layout.preferredWidth: 120
                    contentItem: Text { text: parent.text; color: theme.textPrimary; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: theme.surface; radius: 10; border.color: theme.border }
                    onClicked: {
                        playlistNameInput.text = root.playlistName
                        playlistDescriptionInput.text = root.playlistDescription
                        playlistSettingsDialog.open()
                    }
                }
            }
            
            // Main content row
            RowLayout {
                anchors.fill: parent
                anchors.margins: 26
                anchors.topMargin: 64
                spacing: 30
                
                // Album Art / Gradient
                Rectangle {
                    Layout.preferredWidth: 164
                    Layout.preferredHeight: 164
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#ec4899" }
                        GradientStop { position: 1.0; color: theme.primaryLight }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: root.playlistName.charAt(0).toUpperCase()
                        font.pixelSize: 72
                        font.bold: true
                        color: "white"
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Text {
                        text: root.playlistName
                        font.pixelSize: 32
                        font.bold: true
                        color: theme.textPrimary
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        text: playlistStats.songCount + " songs • " + playlistStats.totalDuration
                        font.pixelSize: 15
                        color: theme.textSecondary
                    }
                    
                    Text {
                        text: root.playlistDescription
                        visible: root.playlistDescription.length > 0
                        font.pixelSize: 13
                        color: theme.textSecondary
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    RowLayout {
                        spacing: 12
                        
                        Button {
                            text: "▶ Play"
                            font.pixelSize: 14
                            font.bold: true
                            background: Rectangle {
                                color: theme.primary
                                radius: 25
                                implicitHeight: 52
                                implicitWidth: 130
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "#ffffff"
                                font.pixelSize: 14
                                font.bold: true
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                var tracks = playlistController.getPlaylistTracks(root.playlistId)
                                if (tracks.length > 0) {
                                    player.playPlaylist(tracks, 0)
                                    playlistTracksList.model = tracks
                                }
                            }
                        }
                        
                        Button {
                            text: "Shuffle"
                            font.pixelSize: 14
                            background: Rectangle {
                                color: theme.surfaceVariant
                                radius: 25
                                implicitHeight: 52
                                implicitWidth: 110
                            }
                            contentItem: Text {
                                text: parent.text
                                color: theme.textPrimary
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: {
                                var tracks = playlistController.getPlaylistTracks(root.playlistId)
                                if (tracks.length > 0) {
                                    // Shuffle the entire playlist
                                    var shuffled = tracks.slice()
                                    for (var i = shuffled.length - 1; i > 0; i--) {
                                        var j = Math.floor(Math.random() * (i + 1))
                                        var temp = shuffled[i]
                                        shuffled[i] = shuffled[j]
                                        shuffled[j] = temp
                                    }
                                    // Play first shuffled track and update model to shuffled order
                                    player.playPlaylist(shuffled, 0)
                                    playlistTracksList.model = shuffled
                                }
                            }
                        }
                        
                        Button {
                            text: "+ Add Tracks"
                            font.pixelSize: 14
                            background: Rectangle {
                                color: theme.surfaceVariant
                                radius: 25
                                implicitHeight: 52
                                implicitWidth: 130
                            }
                            contentItem: Text {
                                text: parent.text
                                color: theme.textPrimary
                                font.pixelSize: 14
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: addTracksDialog.open()
                        }
                    }
                }
            }
        }
        
        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            Layout.preferredHeight: 1
            color: theme.surfaceVariant
        }
        
        // Track List Area
        ListView {
            id: playlistTracksList
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            Layout.topMargin: 20
            Layout.bottomMargin: 10
            model: playlistController.getPlaylistTracks(root.playlistId)
            spacing: 5
            
            // Empty state
            Rectangle {
                anchors.fill: parent
                visible: playlistTracksList.count === 0
                color: "transparent"
                z: 1
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    
                    Text {
                        text: "🎵"
                        font.pixelSize: 80
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "This playlist is empty"
                        font.pixelSize: 24
                        font.bold: true
                        color: theme.textPrimary
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "Start building it by adding songs"
                        font.pixelSize: 14
                        color: theme.textSecondary
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Button {
                        text: "+ Add Songs"
                        background: Rectangle {
                            color: theme.primary
                            radius: 25
                            implicitHeight: 50
                            implicitWidth: 150
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.pixelSize: 14
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: addTracksDialog.open()
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            delegate: Rectangle {
                id: playlistTrackRow
                width: ListView.view.width
                height: 76
                readonly property bool isCurrent: player && String(modelData.id) === String(player.currentTrackId)
                color: isCurrent ? theme.surfaceVariant : theme.surface
                radius: 12
                border.width: isCurrent ? 1 : 0
                border.color: theme.primary
                
                RowLayout {
                    z: 1
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 14
                    
                    // Track number or play icon for currently playing
                    Item {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 26
                        PlayingIndicator {
                            anchors.centerIn: parent
                            active: playlistTrackRow.isCurrent
                            playing: active && player.isPlaying
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: !playlistTrackRow.isCurrent
                            text: index + 1
                            font.pixelSize: 14
                            color: theme.textSecondary
                        }
                    }
                    
                    // Track info
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4
                        
                        Text {
                            text: modelData.title || "Unknown Track"
                            font.pixelSize: 15
                            font.bold: true
                            color: theme.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: (modelData.artist || "Unknown Artist") + " • " + (modelData.album || "Unknown Album")
                            font.pixelSize: 13
                            color: theme.textSecondary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                    
                    // Duration
                    Text {
                        text: formatDuration(modelData.duration || 0)
                        font.pixelSize: 13
                        color: theme.textSecondary
                        Layout.preferredWidth: 50
                        horizontalAlignment: Text.AlignRight
                    }

                    Button {
                        z: 2
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        text: modelData.favorite ? "♥" : "♡"
                        contentItem: Text {
                            text: parent.text
                            color: modelData.favorite ? "#ef4444" : theme.textSecondary
                            font.pixelSize: 19
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        ToolTip.text: modelData.favorite ? "Remove from favorites" : "Add to favorites"
                        ToolTip.visible: hovered
                        background: Rectangle {
                            radius: 19
                            color: parent.hovered ? theme.surfaceVariant : "transparent"
                        }
                        onClicked: {
                            if (musicManager) musicManager.toggleFavorite(String(modelData.id))
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton) {
                            var tracks = playlistController.getPlaylistTracks(root.playlistId)
                            player.playPlaylist(tracks, index)
                            playlistTracksList.model = tracks
                        } else if (mouse.button === Qt.RightButton) {
                            trackContextMenu.popup()
                        }
                    }
                    cursorShape: Qt.PointingHandCursor
                }
                
                Menu {
                    id: trackContextMenu
                    width: 200
                    background: Rectangle {
                        color: theme.surface
                        radius: 12
                        border.color: theme.primary
                        border.width: 2
                    }
                    
                    MenuItem {
                        text: "▶ Play"
                        height: 45
                        contentItem: Text {
                            text: parent.text
                            color: theme.textPrimary
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 15
                        }
                        background: Rectangle {
                            color: parent.hovered ? theme.surfaceVariant : "transparent"
                            radius: 8
                        }
                        onTriggered: {
                            var tracks = playlistController.getPlaylistTracks(root.playlistId)
                            player.playPlaylist(tracks, index)
                            playlistTracksList.model = tracks
                        }
                    }

                    MenuItem {
                        text: "Move up"
                        enabled: index > 0
                        contentItem: Text { text: parent.text; color: parent.enabled ? theme.textPrimary : theme.textDisabled; font.pixelSize: 14; verticalAlignment: Text.AlignVCenter; leftPadding: 15 }
                        background: Rectangle { color: parent.hovered ? theme.surfaceVariant : "transparent"; radius: 8 }
                        onTriggered: {
                            if (playlistController.moveTrackInPlaylist(root.playlistId, modelData.id, index))
                                root.refreshPlaylist(false)
                        }
                    }

                    MenuItem {
                        text: "Move down"
                        enabled: index < playlistTracksList.count - 1
                        contentItem: Text { text: parent.text; color: parent.enabled ? theme.textPrimary : theme.textDisabled; font.pixelSize: 14; verticalAlignment: Text.AlignVCenter; leftPadding: 15 }
                        background: Rectangle { color: parent.hovered ? theme.surfaceVariant : "transparent"; radius: 8 }
                        onTriggered: {
                            if (playlistController.moveTrackInPlaylist(root.playlistId, modelData.id, index + 2))
                                root.refreshPlaylist(false)
                        }
                    }
                    
                    MenuItem {
                        text: "🗑 Remove from Playlist"
                        height: 45
                        contentItem: Text {
                            text: parent.text
                            color: "#ef4444"
                            font.pixelSize: 14
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 15
                        }
                        background: Rectangle {
                            color: parent.hovered ? theme.surfaceVariant : "transparent"
                            radius: 8
                        }
                        onTriggered: {
                            playlistController.removeTrackFromPlaylist(root.playlistId, modelData.id)
                            root.refreshPlaylist(true)
                        }
                    }
                }
            }
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
        
        // Bottom stats bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            Layout.leftMargin: 30
            Layout.rightMargin: 30
            Layout.bottomMargin: 20
            color: theme.surface
            radius: 8
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 20
                
                Text {
                    text: playlistStats.songCount + " songs"
                    font.pixelSize: 13
                    color: theme.textSecondary
                }
                
                Text {
                    text: playlistStats.totalDuration
                    font.pixelSize: 13
                    color: theme.textSecondary
                }
                
                Item { Layout.fillWidth: true }
            }
        }
    }
    
    function formatDuration(seconds) {
        if (!seconds || seconds <= 0) return "0:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
    
    function filterAvailableTracks() {
        var searchText = trackSearchInput.text.toLowerCase()
        var allTracks = musicManager ? musicManager.libraryTracks : []
        var playlistTracks = playlistController.getPlaylistTracks(root.playlistId)
        var playlistIds = {}
        for (var p = 0; p < playlistTracks.length; p++)
            playlistIds[String(playlistTracks[p].id)] = true
        var filtered = []
        for (var i = 0; i < allTracks.length; i++) {
            var track = allTracks[i]
            if (playlistIds[String(track.id)]) continue
            var title = (track.title || "").toLowerCase()
            var artist = (track.artist || "").toLowerCase()
            var album = (track.album || "").toLowerCase()

            if (searchText === "" || title.indexOf(searchText) >= 0 || artist.indexOf(searchText) >= 0 || album.indexOf(searchText) >= 0) {
                filtered.push(track)
            }
        }
        availableTracksList.model = filtered
    }
    
    // Playlist Settings Dialog
    Dialog {
        id: playlistSettingsDialog
        title: ""
        modal: true
        width: 350
        height: 280
        
        anchors.centerIn: parent
        background: Rectangle {
            color: theme.background
            radius: 12
            border.color: theme.primary
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
                    onClicked: playlistSettingsDialog.close()
                }
            }
            
            // Playlist name input
            TextField {
                id: playlistNameInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: "Playlist name..."
                text: root.playlistName
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
                id: playlistDescriptionInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: "Description (optional)"
                text: root.playlistDescription
                color: theme.textPrimary
                placeholderTextColor: theme.textSecondary
                font.pixelSize: 13
                padding: 10
                background: Rectangle { color: theme.surface; radius: 8; border.color: theme.border }
                selectByMouse: true
            }
            
            Item { Layout.fillHeight: true }
            
            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Button {
                    text: "Delete"
                    Layout.preferredHeight: 40
                    Layout.preferredWidth: 92
                    background: Rectangle {
                        color: "#ef4444"
                        radius: 20
                    }
                    contentItem: Text {
                        text: parent.text
                        color: theme.textPrimary
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        deletePlaylistDialog.open()
                    }
                }
                
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
                        if (playlistController.updatePlaylist(root.playlistId, playlistNameInput.text, playlistDescriptionInput.text)) {
                            root.playlistName = playlistNameInput.text.trim()
                            root.playlistDescription = playlistDescriptionInput.text.trim()
                            playlistSettingsDialog.close()
                        }
                    }
                }
            }
        }
    }
    
    // Add tracks dialog
    Dialog {
        id: addTracksDialog
        title: ""
        modal: true
        width: Math.max(360, Math.min(920, root.width - 48))
        height: Math.max(400, Math.min(640, root.height - 64))
        
        property var selectedTracks: []
        property string errorMessage: ""
        
        anchors.centerIn: parent
        background: Rectangle {
            color: theme.background
            radius: 12
            border.color: theme.primary
            border.width: 2
        }
        onOpened: {
            selectedTracks = []
            selectedTracksList.model = []
            errorMessage = ""
            trackSearchInput.clear()
            filterAvailableTracks()
        }
        
        ColumnLayout {
            anchors.fill: parent
            spacing: 20
            anchors.margins: 20
            
            // Header
            Text {
                text: "Add Tracks to " + root.playlistName
                font.pixelSize: 24
                font.bold: true
                color: theme.textPrimary
                Layout.fillWidth: true
            }
            
            // Search bar
            TextField {
                id: trackSearchInput
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                placeholderText: "🔍 Search tracks..."
                color: theme.textPrimary
                font.pixelSize: 14
                padding: 12
                background: Rectangle {
                    color: theme.surface
                    radius: 10
                }
                selectByMouse: true
                onTextChanged: {
                    filterAvailableTracks()
                }
            }
            
            // Two-panel layout
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20
                
                // Available tracks panel
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: theme.surface
                    radius: 12
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        
                        // Panel header
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: theme.background
                            radius: 12
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Available Songs"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                            }
                        }
                        
                        ListView {
                            id: availableTracksList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10
                            model: musicManager ? musicManager.libraryTracks : []
                            spacing: 8
                            clip: true
                            
                            // Search empty state
                            Rectangle {
                                anchors.fill: parent
                                visible: trackSearchInput.text !== "" && availableTracksList.count === 0
                                color: "transparent"
                                z: 1
                                
                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 20
                                    
                                    Text {
                                        text: "🔍"
                                        font.pixelSize: 60
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: "No tracks found"
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: theme.textPrimary
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                    
                                    Text {
                                        text: "Try a different search term"
                                        font.pixelSize: 12
                                        color: theme.textSecondary
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                            
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 70
                                color: "transparent"
                                radius: 8
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: theme.surfaceVariant
                                    radius: 8
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4
                                            
                                            Text {
                                                text: modelData.title || "Unknown Track"
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: theme.textPrimary
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                            
                                            Text {
                                                text: (modelData.artist || "Unknown Artist") + " • " + (modelData.album || "Unknown Album")
                                                font.pixelSize: 12
                                                color: theme.textSecondary
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                        }
                                        
                                        Button {
                                            text: "+"
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            background: Rectangle {
                                                color: theme.primary
                                                radius: 20
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "white"
                                                font.pixelSize: 18
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            onClicked: {
                                                // Check if track already exists in selected tracks
                                                var alreadyExists = false
                                                for (var i = 0; i < addTracksDialog.selectedTracks.length; i++) {
                                                    if (addTracksDialog.selectedTracks[i].id === modelData.id) {
                                                        alreadyExists = true
                                                        break
                                                    }
                                                }
                                                
                                                if (!alreadyExists) {
                                                    var newSelected = addTracksDialog.selectedTracks.slice()
                                                    newSelected.push(modelData)
                                                    addTracksDialog.selectedTracks = newSelected
                                                    selectedTracksList.model = newSelected
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Selected tracks panel
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: theme.surface
                    radius: 12
                    
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10
                        
                        // Panel header
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: theme.background
                            radius: 12

                            Text {
                                anchors.centerIn: parent
                                text: "Selected (" + addTracksDialog.selectedTracks.length + ")"
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.primary
                            }
                        }
                        
                        ListView {
                            id: selectedTracksList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 10
                            model: addTracksDialog.selectedTracks
                            spacing: 8
                            clip: true
                            
                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 70
                                color: "transparent"
                                radius: 8
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: theme.surfaceVariant
                                    radius: 8
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12
                                        
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 4
                                            
                                            Text {
                                                text: modelData.title || "Unknown Track"
                                                font.pixelSize: 14
                                                font.bold: true
                                                color: theme.textPrimary
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                            
                                            Text {
                                                text: (modelData.artist || "Unknown Artist") + " • " + (modelData.album || "Unknown Album")
                                                font.pixelSize: 12
                                                color: theme.textSecondary
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                            }
                                        }
                                        
                                        Button {
                                            text: "×"
                                            Layout.preferredWidth: 40
                                            Layout.preferredHeight: 40
                                            background: Rectangle {
                                                color: "#ef4444"
                                                radius: 20
                                            }
                                            contentItem: Text {
                                                text: parent.text
                                                color: "white"
                                                font.pixelSize: 20
                                                font.bold: true
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            onClicked: {
                                                // Find index by track ID instead of object reference
                                                var index = -1
                                                for (var i = 0; i < addTracksDialog.selectedTracks.length; i++) {
                                                    if (addTracksDialog.selectedTracks[i].id === modelData.id) {
                                                        index = i
                                                        break
                                                    }
                                                }
                                                
                                                if (index >= 0) {
                                                    var newSelected = addTracksDialog.selectedTracks.slice()
                                                    newSelected.splice(index, 1)
                                                    addTracksDialog.selectedTracks = newSelected
                                                    selectedTracksList.model = newSelected
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            Text {
                Layout.fillWidth: true
                visible: addTracksDialog.errorMessage.length > 0
                text: addTracksDialog.errorMessage
                color: "#dc2626"
                font.pixelSize: 12
            }

            // Bottom buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 15
                
                Button {
                    text: "Cancel"
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 120
                    background: Rectangle {
                        color: theme.surfaceVariant
                        radius: 25
                    }
                    contentItem: Text {
                        text: parent.text
                        color: theme.textPrimary
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        addTracksDialog.selectedTracks = []
                        selectedTracksList.model = []
                        addTracksDialog.close()
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "Add " + addTracksDialog.selectedTracks.length + " Tracks"
                    enabled: addTracksDialog.selectedTracks.length > 0
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 180
                    background: Rectangle {
                        color: enabled ? theme.primary : theme.surfaceVariant
                        radius: 25
                    }
                    contentItem: Text {
                        text: parent.text
                        color: parent.enabled ? "#ffffff" : theme.textDisabled
                        font.pixelSize: 14
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        var ids = addTracksDialog.selectedTracks.map(function(track) { return track.id })
                        var added = playlistController.addTracksToPlaylist(root.playlistId, ids)
                        if (added > 0) {
                            root.refreshPlaylist(true)
                            addTracksDialog.close()
                        } else {
                            addTracksDialog.errorMessage = "Those songs are already in this playlist."
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: deletePlaylistDialog
        anchors.centerIn: parent
        modal: true
        title: ""
        width: 400
        background: Rectangle { color: theme.surface; radius: 16; border.color: theme.border }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16
            Text { text: "Delete playlist?"; color: theme.textPrimary; font.pixelSize: 20; font.weight: Font.DemiBold }
            Text {
                Layout.fillWidth: true
                text: "This removes the playlist and its saved order. Your music files are not affected."
                color: theme.textSecondary
                wrapMode: Text.WordWrap
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                Button { text: "Cancel"; onClicked: deletePlaylistDialog.close() }
                Button {
                    text: "Delete playlist"
                    contentItem: Text { text: parent.text; color: "#ffffff"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    background: Rectangle { color: "#dc2626"; radius: 9 }
                    onClicked: {
                        if (playlistController.deletePlaylist(root.playlistId)) {
                            contentStack.currentIndex = 2
                            deletePlaylistDialog.close()
                            playlistSettingsDialog.close()
                        }
                    }
                }
            }
        }
    }
}
