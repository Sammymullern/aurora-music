import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: theme.background
    property int trackCount: libraryManager ? libraryManager.trackCount : 0
    property int albumCount: libraryManager ? libraryManager.albumCount : 0
    property int artistCount: libraryManager ? libraryManager.artistCount : 0
    property string totalDuration: libraryManager ? libraryManager.totalDuration : "0 min"
    property var libraryTracks: libraryManager ? libraryManager.libraryTracks : []
    property var libraryGroups: libraryManager ? libraryManager.libraryGroups : []
    property var uncategorizedTracks: libraryManager ? libraryManager.uncategorizedTracks : []
    readonly property var visibleGroups: {
        if (!libraryTabBar || libraryTabBar.currentIndex === 2) return []
        var groupType = libraryTabBar.currentIndex === 0 ? "artist" : "album"
        return libraryGroups.filter(function(group) { return group.type === groupType })
    }

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
            }
        }
    }

    function formatDuration(seconds) {
        return libraryManager ? libraryManager.formatDuration(Number(seconds)) : "0:00"
    }

    function openGroup(group) {
        librarySongsView.songs = group.tracks || []
        librarySongsView.title = group.name || "Unknown"
        librarySongsView.subtitle = group.type === "artist"
            ? group.album_count + " albums"
            : (group.artist || "Unknown artist")
        contentStack.currentIndex = 5
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
                color: theme.textPrimary
            }

            Item { Layout.fillWidth: true }

            // Statistics
            RowLayout {
                spacing: 15

                Text {
                    text: trackCount + " Tracks"
                    font.pixelSize: 13
                    color: theme.textSecondary
                }

                Text {
                    text: "•"
                    font.pixelSize: 13
                    color: theme.surfaceVariant
                }

                Text {
                    text: albumCount + " Albums"
                    font.pixelSize: 13
                    color: theme.textSecondary
                }

                Text {
                    text: "•"
                    font.pixelSize: 13
                    color: theme.surfaceVariant
                }

                Text {
                    text: artistCount + " Artists"
                    font.pixelSize: 13
                    color: theme.textSecondary
                }

                Text {
                    text: "•"
                    font.pixelSize: 13
                    color: theme.surfaceVariant
                }

                Text {
                    text: totalDuration
                    font.pixelSize: 13
                    color: theme.textSecondary
                }
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: theme.surfaceVariant
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            ActionButton {
                text: "Add Folder"
                primaryAction: true
                enabled: settings && !settings.libraryBusy
                onClicked: {
                    var folder = settings ? settings.browseMusicFolder() : ""
                    if (folder && settings) settings.scanLibrary()
                }
            }
            ActionButton { text: "Scan Library"; enabled: settings && !settings.libraryBusy; onClicked: if (settings) settings.scanLibrary() }
            ActionButton { text: "Clean Missing"; enabled: settings && !settings.libraryBusy; onClicked: cleanMissingConfirmation.open() }
            ActionButton { text: "Rebuild Index"; enabled: settings && !settings.libraryBusy; onClicked: rebuildConfirmation.open() }
            Item { Layout.fillWidth: true }
        }

        Text {
            Layout.fillWidth: true
            visible: settings && settings.libraryOperationStatus.length > 0
            text: settings ? settings.libraryOperationStatus : ""
            color: theme.textSecondary
            font.pixelSize: 12
        }

        TabBar {
            id: libraryTabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            currentIndex: 0
            visible: trackCount > 0
            background: Rectangle { color: "transparent" }

            TabButton {
                text: "Artists  " + root.artistCount
                contentItem: Text { text: parent.text; color: parent.checked ? "#ffffff" : theme.textSecondary; font.pixelSize: 13; font.weight: parent.checked ? Font.DemiBold : Font.Medium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: parent.checked ? theme.primary : theme.surface; radius: 10; border.color: parent.checked ? theme.primary : theme.border }
            }
            TabButton {
                text: "Albums  " + root.albumCount
                contentItem: Text { text: parent.text; color: parent.checked ? "#ffffff" : theme.textSecondary; font.pixelSize: 13; font.weight: parent.checked ? Font.DemiBold : Font.Medium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: parent.checked ? theme.primary : theme.surface; radius: 10; border.color: parent.checked ? theme.primary : theme.border }
            }
            TabButton {
                text: "Songs  " + root.trackCount
                contentItem: Text { text: parent.text; color: parent.checked ? "#ffffff" : theme.textSecondary; font.pixelSize: 13; font.weight: parent.checked ? Font.DemiBold : Font.Medium; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: parent.checked ? theme.primary : theme.surface; radius: 10; border.color: parent.checked ? theme.primary : theme.border }
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
                    color: theme.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Subtitle
                Text {
                    text: "Add a music folder to start building your library"
                    font.pixelSize: 14
                    color: theme.textSecondary
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Add music button
                Button {
                    text: "Add Music"
                    enabled: settings && !settings.libraryBusy
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
                        color: parent.hovered ? theme.primary : "#6366f1"
                        radius: 20
                    }
                    
                    onClicked: {
                        var folder = settings ? settings.browseMusicFolder() : ""
                        if (folder && settings) settings.scanLibrary()
                    }
                }
            }
        }

        // Groups list (Expandable cards)
        ListView {
            id: libraryGroupsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: trackCount > 0 && libraryTabBar.currentIndex < 2
            model: root.visibleGroups
            spacing: 10
            clip: true

            delegate: Rectangle {
                id: card
                width: ListView.view.width
                height: 86
                color: theme.surface
                radius: 12
                border.color: theme.border
                border.width: 1

                ColumnLayout {
                    z: 1
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 0

                    // Card header (always visible)
                    RowLayout {
                        z: 1
                        Layout.fillWidth: true
                        spacing: 15

                        // Icon/Art
                        Rectangle {
                            Layout.preferredWidth: 56
                            Layout.preferredHeight: 56
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: modelData.type === "artist" ? "#ec4899" : theme.primaryLight }
                                GradientStop { position: 1.0; color: modelData.type === "artist" ? "#be185d" : theme.primary }
                            }

                            Image {
                                anchors.fill: parent
                                source: modelData.album_art || ""
                                visible: source.toString().length > 0
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.type === "artist" ? "🎤" : "💿"
                                font.pixelSize: 26
                                visible: !modelData.album_art
                            }

                            // Lossless indicator
                            Rectangle {
                                anchors { top: parent.top; right: parent.right }
                                width: 18
                                height: 18
                                radius: 9
                                color: "#10b981"
                                visible: modelData.lossless === true
                                Text {
                                    anchors.centerIn: parent
                                    text: "∞"
                                    font.pixelSize: 10
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
                                font.pixelSize: 16
                                font.bold: true
                                color: theme.textPrimary
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.type === "artist" ?
                                       (modelData.album_count + " Albums") :
                                       modelData.artist
                                font.pixelSize: 13
                                color: theme.textSecondary
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.track_count + " tracks • " + formatDuration(modelData.total_duration || 0)
                                font.pixelSize: 12
                                color: theme.primary
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        // Open button
                        Rectangle {
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 42
                            radius: 21
                            color: theme.primary
                            z: 2

                            Text {
                                anchors.centerIn: parent
                                text: "▶"
                                font.pixelSize: 14
                                color: "white"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.openGroup(modelData)
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: 0
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.openGroup(modelData)
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        ListView {
            id: libraryTrackList
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: trackCount > 0 && libraryTabBar.currentIndex === 2
            model: libraryTracks
            spacing: 8
            clip: true

            delegate: Rectangle {
                id: songRow
                width: ListView.view.width
                height: 68
                radius: 12
                color: songRow.isCurrent ? theme.surfaceVariant : theme.surface
                border.color: songRow.isCurrent ? theme.primary : theme.border
                border.width: songRow.isCurrent ? 1 : 0
                readonly property bool isCurrent: player && String(modelData.id) === String(player.currentTrackId)

                RowLayout {
                    z: 1
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 12
                    spacing: 12

                    Image {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        visible: !!modelData.album_art
                        source: modelData.album_art || ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Item {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 22
                        PlayingIndicator { anchors.centerIn: parent; active: songRow.isCurrent; playing: active && player.isPlaying }
                        Text { anchors.centerIn: parent; visible: !songRow.isCurrent; text: index + 1; color: theme.textSecondary; font.pixelSize: 12 }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3
                        Text { text: modelData.title || "Unknown track"; color: theme.textPrimary; font.pixelSize: 14; font.weight: Font.DemiBold; Layout.fillWidth: true; elide: Text.ElideRight }
                        Text { text: (modelData.artist || "Unknown artist") + "  ·  " + (modelData.album || "Unknown album"); color: theme.textSecondary; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                    }

                    Text { text: formatDuration(modelData.duration); color: theme.textSecondary; font.pixelSize: 12; Layout.preferredWidth: 72; horizontalAlignment: Text.AlignRight }

                    Button {
                        z: 2
                        Layout.preferredWidth: 38
                        Layout.preferredHeight: 38
                        text: modelData.favorite ? "♥" : "♡"
                        contentItem: Text { text: parent.text; color: modelData.favorite ? "#ef4444" : theme.textSecondary; font.pixelSize: 19; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: parent.hovered ? theme.surfaceVariant : "transparent"; radius: 19 }
                        onClicked: if (libraryManager) libraryManager.toggleFavorite(String(modelData.id))
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: 0
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (libraryManager) libraryManager.playSong(String(modelData.id))
                }
            }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }
    }

    Dialog {
        id: cleanMissingConfirmation
        title: "Remove missing tracks?"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Cancel | Dialog.Ok
        Label {
            text: "Tracks whose files are no longer available will be removed from your library and playlists."
            wrapMode: Text.WordWrap
            color: theme.textPrimary
        }
        onAccepted: if (settings) settings.cleanMissingSongs()
    }

    Dialog {
        id: rebuildConfirmation
        title: "Rebuild library index?"
        modal: true
        anchors.centerIn: parent
        standardButtons: Dialog.Cancel | Dialog.Ok
        Label {
            text: "This clears the current index and scans your configured music folders again."
            wrapMode: Text.WordWrap
            color: theme.textPrimary
        }
        onAccepted: if (settings) settings.rebuildDatabase()
    }
}
