import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    minimumWidth: 1050
    minimumHeight: 680
    color: "#1a1a2e"
    title: "Aurora Music"

    property color glassColor: "#252542"
    property color glassBorder: "#3a3a5c"
    property real glassOpacity: 0.7

    property bool showNowPlaying: false
    readonly property int playerBarHeight: 132

    Item {
        id: scene
        anchors.fill: parent

        RowLayout {
            id: rootLayout
            anchors.fill: parent
            spacing: 0

            Sidebar {
                id: sidebar
                Layout.preferredWidth: 250
                Layout.minimumWidth: 220
                Layout.maximumWidth: 300
                Layout.fillHeight: true
                visible: !showNowPlaying
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#1a1a2e"

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    StackLayout {
                        id: contentStack
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.minimumHeight: 200

                        MusicView { id: musicView }
                        LibraryView { id: libraryView }
                        PlaylistsView { id: playlistsView }
                        PlaylistDetailView { id: playlistDetailView }
                        SettingsView { id: settingsView }
                    }

                    PlayerControls {
                        id: playerControls
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.playerBarHeight
                        Layout.minimumHeight: root.playerBarHeight
                        onShowNowPlayingRequested: {
                            if (player && player.currentTitle && player.currentTitle.length > 0) {
                                showNowPlaying = true
                            }
                        }
                    }
                }
            }
        }

        NowPlayingView {
            id: nowPlayingView
            anchors {
                fill: scene
                bottomMargin: playerControls.height
            }
            z: 10
            visible: showNowPlaying
            onBackClicked: { showNowPlaying = false }
            currentTrack: player ? player.currentTitle : ""
            currentArtist: player ? player.currentArtist : ""
            currentAlbum: player ? player.currentAlbum : ""
            currentAlbumArt: player ? player.currentAlbumArt : ""
        }
    }
}
