import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property int trackCount: libraryManager ? libraryManager.trackCount : 0
    property int albumCount: libraryManager ? libraryManager.albumCount : 0
    property int artistCount: libraryManager ? libraryManager.artistCount : 0
    property string totalDuration: libraryManager ? libraryManager.totalDuration : "0:00:00"
    property var libraryTracks: libraryManager ? libraryManager.libraryTracks : []
    property var libraryGroups: libraryManager ? libraryManager.libraryGroups : []
    property var uncategorizedTracks: libraryManager ? libraryManager.uncategorizedTracks : []
    property string currentFilter: "All"
    property string currentSort: "Name"
    property string currentView: "Cards"  // Cards or List

    Component.onCompleted: {
        if (libraryManager) {
            libraryTracks = libraryManager.libraryTracks
            libraryGroups = libraryManager.libraryGroups
            uncategorizedTracks = libraryManager.uncategorizedTracks
        }
    }

    Connections {
        target: libraryManager
        function onLibraryStatsChanged() {
            if (libraryManager) {
                libraryTracks = libraryManager.libraryTracks
                libraryGroups = libraryManager.libraryGroups
                uncategorizedTracks = libraryManager.uncategorizedTracks
                libraryGroupsList.model = filterGroups()
            }
        }
    }

    function formatDuration(seconds) {
        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        var secs = seconds % 60
        if (hours > 0) {
            return hours + ":" + (minutes < 10 ? "0" : "") + minutes + ":" + (secs < 10 ? "0" : "") + secs
        }
        return minutes + ":" + (secs < 10 ? "0" : "") + secs
    }

    function filterGroups() {
        var filtered = []
        var searchText = librarySearchInput.text.toLowerCase()

        for (var i = 0; i < libraryGroups.length; i++) {
            var group = libraryGroups[i]
            var matchesSearch = true

            if (searchText !== "") {
                var name = (group.name || "").toLowerCase()
                var artist = (group.artist || "").toLowerCase()
                matchesSearch = name.indexOf(searchText) >= 0 ||
                               (artist && artist.indexOf(searchText) >= 0)
            }

            var matchesFilter = true
            if (currentFilter === "Lossless") {
                matchesFilter = group.lossless === true
            } else if (currentFilter === "High Bitrate") {
                // For groups, this doesn't apply much, but we can filter by lossless
                matchesFilter = group.lossless === true
            }

            if (matchesSearch && matchesFilter) {
                filtered.push(group)
            }
        }

        // Sort the filtered groups
        if (currentSort === "Name") {
            filtered.sort(function(a, b) {
                var nameA = (a.name || "").toLowerCase()
                var nameB = (b.name || "").toLowerCase()
                return nameA.localeCompare(nameB)
            })
        } else if (currentSort === "Artist") {
            filtered.sort(function(a, b) {
                var artistA = (a.artist || a.name || "").toLowerCase()
                var artistB = (b.artist || b.name || "").toLowerCase()
                return artistA.localeCompare(artistB)
            })
        } else if (currentSort === "Duration") {
            filtered.sort(function(a, b) {
                return (a.total_duration || 0) - (b.total_duration || 0)
            })
        }

        return filtered
    }

    function filterTracks() {
        var filtered = []
        var searchText = librarySearchInput.text.toLowerCase()

        for (var i = 0; i < libraryTracks.length; i++) {
            var track = libraryTracks[i]
            var matchesSearch = true

            if (searchText !== "") {
                var title = (track.title || "").toLowerCase()
                var artist = (track.artist || "").toLowerCase()
                var album = (track.album || "").toLowerCase()
                matchesSearch = title.indexOf(searchText) >= 0 ||
                               artist.indexOf(searchText) >= 0 ||
                               album.indexOf(searchText) >= 0
            }

            var matchesFilter = true
            if (currentFilter === "Recently Added") {
                // Filter by recently added (last 30 days)
                var addedDate = new Date(track.dateAdded || 0)
                var thirtyDaysAgo = new Date()
                thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30)
                matchesFilter = addedDate >= thirtyDaysAgo
            } else if (currentFilter === "Lossless") {
                matchesFilter = track.lossless === true
            } else if (currentFilter === "High Bitrate") {
                matchesFilter = track.bitrate >= 320
            }

            if (matchesSearch && matchesFilter) {
                filtered.push(track)
            }
        }

        // Sort the filtered tracks
        if (currentSort === "Name") {
            filtered.sort(function(a, b) {
                var nameA = (a.title || "").toLowerCase()
                var nameB = (b.title || "").toLowerCase()
                return nameA.localeCompare(nameB)
            })
        } else if (currentSort === "Artist") {
            filtered.sort(function(a, b) {
                var artistA = (a.artist || "").toLowerCase()
                var artistB = (b.artist || "").toLowerCase()
                return artistA.localeCompare(artistB)
            })
        } else if (currentSort === "Album") {
            filtered.sort(function(a, b) {
                var albumA = (a.album || "").toLowerCase()
                var albumB = (b.album || "").toLowerCase()
                return albumA.localeCompare(albumB)
            })
        } else if (currentSort === "Duration") {
            filtered.sort(function(a, b) {
                return (a.duration || 0) - (b.duration || 0)
            })
        } else if (currentSort === "Date Added") {
            filtered.sort(function(a, b) {
                return new Date(b.dateAdded || 0) - new Date(a.dateAdded || 0)
            })
        }

        return filtered
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15
        anchors.margins: 25

        // Header section
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            Text {
                text: "Library"
                font.pixelSize: 32
                font.bold: true
                color: "#e0e0e0"
            }

            Item { Layout.fillWidth: true }

            // Statistics
            RowLayout {
                spacing: 15

                Text {
                    text: trackCount + " Tracks"
                    font.pixelSize: 13
                    color: "#a0a0a0"
                }

                Text {
                    text: "•"
                    font.pixelSize: 13
                    color: "#4a4a6a"
                }

                Text {
                    text: albumCount + " Albums"
                    font.pixelSize: 13
                    color: "#a0a0a0"
                }

                Text {
                    text: "•"
                    font.pixelSize: 13
                    color: "#4a4a6a"
                }

                Text {
                    text: artistCount + " Artists"
                    font.pixelSize: 13
                    color: "#a0a0a0"
                }

                Text {
                    text: "•"
                    font.pixelSize: 13
                    color: "#4a4a6a"
                }

                Text {
                    text: totalDuration
                    font.pixelSize: 13
                    color: "#a0a0a0"
                }
            }
        }

        // Search and controls bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 15

            // Search bar
            TextField {
                id: librarySearchInput
                Layout.fillWidth: true
                Layout.preferredHeight: 45
                placeholderText: "🔍 Search tracks, artists, albums..."
                color: "#e0e0e0"
                font.pixelSize: 14
                padding: 12
                background: Rectangle {
                    color: "#252542"
                    radius: 10
                }
                selectByMouse: true
                onTextChanged: {
                    if (currentView === "Cards") {
                        libraryGroupsList.model = filterGroups()
                    } else {
                        libraryTrackList.model = filterTracks()
                    }
                }
            }

            // View toggle
            RowLayout {
                spacing: 5
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 8
                    color: currentView === "Cards" ? "#7c3aed" : "#252542"
                    Text {
                        anchors.centerIn: parent
                        text: "⊞"
                        font.pixelSize: 18
                        color: "white"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            currentView = "Cards"
                            libraryGroupsList.model = filterGroups()
                        }
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 8
                    color: currentView === "List" ? "#7c3aed" : "#252542"
                    Text {
                        anchors.centerIn: parent
                        text: "☰"
                        font.pixelSize: 18
                        color: "white"
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            currentView = "List"
                            libraryTrackList.model = filterTracks()
                        }
                    }
                }
            }

            // Sort dropdown
            Rectangle {
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                radius: 8
                color: "#252542"

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text {
                        text: "Sort: " + currentSort
                        font.pixelSize: 13
                        color: "#e0e0e0"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "▼"
                        font.pixelSize: 10
                        color: "#a0a0a0"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            sortMenu.popup()
                        }
                    }
                }

                Menu {
                    id: sortMenu
                    MenuItem {
                        text: "Name"
                        onTriggered: {
                            currentSort = "Name"
                            if (currentView === "Cards") {
                                libraryGroupsList.model = filterGroups()
                            } else {
                                libraryTrackList.model = filterTracks()
                            }
                        }
                    }
                    MenuItem {
                        text: "Artist"
                        onTriggered: {
                            currentSort = "Artist"
                            if (currentView === "Cards") {
                                libraryGroupsList.model = filterGroups()
                            } else {
                                libraryTrackList.model = filterTracks()
                            }
                        }
                    }
                    MenuItem {
                        text: "Album"
                        onTriggered: {
                            currentSort = "Album"
                            if (currentView === "Cards") {
                                libraryGroupsList.model = filterGroups()
                            } else {
                                libraryTrackList.model = filterTracks()
                            }
                        }
                    }
                    MenuItem {
                        text: "Duration"
                        onTriggered: {
                            currentSort = "Duration"
                            if (currentView === "Cards") {
                                libraryGroupsList.model = filterGroups()
                            } else {
                                libraryTrackList.model = filterTracks()
                            }
                        }
                    }
                    MenuItem {
                        text: "Date Added"
                        onTriggered: {
                            currentSort = "Date Added"
                            if (currentView === "Cards") {
                                libraryGroupsList.model = filterGroups()
                            } else {
                                libraryTrackList.model = filterTracks()
                            }
                        }
                    }
                }
            }
        }

        // Filter chips bar
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Repeater {
                model: ["All", "Recently Added", "Lossless", "High Bitrate"]

                Rectangle {
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: label.contentWidth + 20
                    radius: 16
                    color: currentFilter === modelData ? "#7c3aed" : "#252542"

                    Text {
                        id: label
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 12
                        color: currentFilter === modelData ? "white" : "#a0a0a0"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onEntered: {
                            if (currentFilter !== modelData) {
                                parent.color = "#2a2a4a"
                            }
                        }
                        onExited: {
                            if (currentFilter !== modelData) {
                                parent.color = "#252542"
                            }
                        }
                        onClicked: {
                            currentFilter = modelData
                            if (currentView === "Cards") {
                                libraryGroupsList.model = filterGroups()
                            } else {
                                libraryTrackList.model = filterTracks()
                            }
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#4a4a6a"
        }

        // Uncategorized tracks section (error handling)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            visible: uncategorizedTracks.length > 0 && currentView === "Cards"
            color: "#2a2a4a"
            radius: 8

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 10

                RowLayout {
                    spacing: 10

                    Text {
                        text: "⚠️"
                        font.pixelSize: 20
                    }

                    Text {
                        text: uncategorizedTracks.length + " uncategorized tracks"
                        font.pixelSize: 14
                        font.bold: true
                        color: "#e0e0e0"
                    }
                }

                Text {
                    text: "These tracks couldn't be automatically categorized. Switch to List view to see them."
                    font.pixelSize: 12
                    color: "#a0a0a0"
                    Layout.fillWidth: true
                }

                Button {
                    text: "Switch to List View"
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 30
                    background: Rectangle {
                        color: "#7c3aed"
                        radius: 15
                    }
                    contentItem: Text {
                        text: parent.text
                        color: "white"
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        currentView = "List"
                    }
                }
            }
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
                        contentStack.currentIndex = 4
                    }
                }
            }
        }

        // Groups list (Cards view)
        GridView {
            id: libraryGroupsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: trackCount > 0 && currentView === "Cards"
            model: filterGroups()
            cellWidth: 220
            cellHeight: 180
            clip: true

            delegate: Rectangle {
                width: GridView.view.cellWidth - 10
                height: GridView.view.cellHeight - 10
                color: "#252542"
                radius: 12

                // 3D shadow effect
                Rectangle {
                    anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                    width: 4
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#3d2a5c" }
                        GradientStop { position: 1.0; color: "#1a1030" }
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    // Icon/Art
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                        radius: 8
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: modelData.type === "artist" ? "#ec4899" : "#8b5cf6" }
                            GradientStop { position: 1.0; color: modelData.type === "artist" ? "#be185d" : "#7c3aed" }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.type === "artist" ? "🎤" : "💿"
                            font.pixelSize: 40
                        }

                        // Lossless indicator
                        Rectangle {
                            anchors { top: parent.top; right: parent.right }
                            width: 20
                            height: 20
                            radius: 10
                            color: "#10b981"
                            visible: modelData.lossless === true
                            Text {
                                anchors.centerIn: parent
                                text: "∞"
                                font.pixelSize: 12
                                color: "white"
                            }
                        }
                    }

                    // Info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: modelData.name || "Unknown"
                            font.pixelSize: 14
                            font.bold: true
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.type === "artist" ? 
                                   (modelData.album_count + " Albums") : 
                                   modelData.artist
                            font.pixelSize: 12
                            color: "#a0a0a0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.track_count + " tracks • " + formatDuration(modelData.total_duration || 0)
                            font.pixelSize: 11
                            color: "#7c3aed"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onDoubleClicked: {
                        if (modelData.type === "album" && modelData.tracks && modelData.tracks.length > 0) {
                            // Play first track from album
                            if (musicManager) {
                                musicManager.playSong(modelData.tracks[0].id)
                            }
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        // Track list (List view)
        ListView {
            id: libraryTrackList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: trackCount > 0 && currentView === "List"
            model: filterTracks()
            spacing: 5
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 76
                color: modelData.id == player.currentTrackId ? "#2a2a4a" : "transparent"
                radius: 8

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    // Album art thumbnail
                    Rectangle {
                        Layout.preferredWidth: 56
                        Layout.preferredHeight: 56
                        radius: 8
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#ec4899" }
                            GradientStop { position: 1.0; color: "#8b5cf6" }
                        }

                        // 3D shadow for album art
                        Rectangle {
                            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                            width: 4
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#be185d" }
                                GradientStop { position: 1.0; color: "#7c3aed" }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (modelData.title || "U").charAt(0).toUpperCase()
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Track info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: modelData.title || "Unknown Track"
                            font.pixelSize: 15
                            font.bold: true
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: (modelData.artist || "Unknown Artist") + " • " + (modelData.album || "Unknown Album")
                            font.pixelSize: 13
                            color: "#a0a0a0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            spacing: 10

                            Text {
                                text: formatDuration(modelData.duration || 0)
                                font.pixelSize: 12
                                color: "#7c3aed"
                            }

                            Text {
                                text: (modelData.bitrate || 0) + " kbps"
                                font.pixelSize: 12
                                color: "#a0a0a0"
                                visible: modelData.bitrate > 0
                            }

                            Rectangle {
                                Layout.preferredWidth: 4
                                Layout.preferredHeight: 4
                                radius: 2
                                color: modelData.lossless ? "#10b981" : "#4a4a6a"
                                visible: modelData.lossless !== undefined
                            }
                        }
                    }

                    // Duration
                    Text {
                        text: formatDuration(modelData.duration || 0)
                        font.pixelSize: 13
                        color: "#a0a0a0"
                        Layout.preferredWidth: 50
                        horizontalAlignment: Text.AlignRight
                    }

                    // Action buttons
                    RowLayout {
                        id: trackActions
                        spacing: 10
                        visible: false
                        Layout.preferredWidth: 80

                        Button {
                            text: "⋮"
                            background: Rectangle { color: "transparent" }
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 16
                                color: "#a0a0a0"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: trackContextMenu.popup()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: trackActions.visible = true
                    onExited: trackActions.visible = false
                    onDoubleClicked: {
                        if (musicManager) {
                            musicManager.playSong(modelData.id)
                        }
                    }
                }

                Menu {
                    id: trackContextMenu

                    MenuItem {
                        text: "Play"
                        onTriggered: {
                            if (musicManager) {
                                musicManager.playSong(modelData.id)
                            }
                        }
                    }

                    MenuItem {
                        text: "Add to Queue"
                        onTriggered: {
                            if (player) {
                                player.addToQueue(modelData.id)
                            }
                        }
                    }

                    MenuSeparator {}

                    MenuItem {
                        text: "Add to Playlist"
                        onTriggered: {
                            // Open add to playlist dialog
                        }
                    }

                    MenuItem {
                        text: "View Album"
                        onTriggered: {
                            // Navigate to album view
                        }
                    }

                    MenuItem {
                        text: "View Artist"
                        onTriggered: {
                            // Navigate to artist view
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        // Grid view (Album art grid)
        GridView {
            id: libraryGridView
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: trackCount > 0 && currentView === "Grid"
            model: filterTracks()
            cellWidth: 180
            cellHeight: 220
            clip: true

            delegate: Rectangle {
                width: GridView.view.cellWidth - 10
                height: GridView.view.cellHeight - 10
                color: "transparent"
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Album art
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 140
                        radius: 10
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#ec4899" }
                            GradientStop { position: 1.0; color: "#8b5cf6" }
                        }

                        // 3D shadow for album art
                        Rectangle {
                            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
                            width: 5
                            radius: 10
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#be185d" }
                                GradientStop { position: 1.0; color: "#7c3aed" }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: (modelData.title || "U").charAt(0).toUpperCase()
                            font.pixelSize: 40
                            font.bold: true
                            color: "white"
                        }
                    }

                    // Track info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: modelData.title || "Unknown Track"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.artist || "Unknown Artist"
                            font.pixelSize: 11
                            color: "#a0a0a0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                        if (musicManager) {
                            musicManager.playSong(modelData.id)
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }
    }
}
