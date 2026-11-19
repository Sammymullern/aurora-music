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
    property string totalDuration: libraryManager ? libraryManager.totalDuration : "0:00:00"
    property var libraryTracks: libraryManager ? libraryManager.libraryTracks : []
    property var libraryGroups: libraryManager ? libraryManager.libraryGroups : []
    property var uncategorizedTracks: libraryManager ? libraryManager.uncategorizedTracks : []

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
                libraryGroupsList.model = libraryGroups
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
            visible: trackCount > 0
            model: libraryGroups
            spacing: 30
            clip: true

            delegate: Rectangle {
                id: card
                width: ListView.view.width
                height: 100
                color: theme.surface
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

                    // Card header (always visible)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 15

                        // Icon/Art
                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: modelData.type === "artist" ? "#ec4899" : theme.primaryLight }
                                GradientStop { position: 1.0; color: modelData.type === "artist" ? "#be185d" : theme.primary }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.type === "artist" ? "🎤" : "💿"
                                font.pixelSize: 30
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
                            Layout.preferredWidth: 35
                            Layout.preferredHeight: 35
                            radius: 17
                            color: theme.primary

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
                                    // Navigate to songs view
                                    librarySongsView.songs = modelData.tracks || []
                                    librarySongsView.title = modelData.name
                                    librarySongsView.subtitle = modelData.type === "artist" ?
                                        (modelData.album_count + " Albums") :
                                        modelData.artist
                                    contentStack.currentIndex = 5  // LibrarySongsView index
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onDoubleClicked: {
                        // Navigate to songs view
                        librarySongsView.songs = modelData.tracks || []
                        librarySongsView.title = modelData.name
                        librarySongsView.subtitle = modelData.type === "artist" ?
                            (modelData.album_count + " Albums") :
                            modelData.artist
                        contentStack.currentIndex = 5  // LibrarySongsView index
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
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
