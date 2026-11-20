import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import "components"

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    minimumWidth: 1050
    minimumHeight: 680
    flags: Qt.Window | Qt.FramelessWindowHint
    color: theme.background
    title: "NelvaMusic"

    property color glassColor: theme.surface
    property color glassBorder: theme.border
    property real glassOpacity: 0.7

    property bool showNowPlaying: false
    property int previousContentIndex: 0
    readonly property int nowPlayingIndex: 6
    readonly property int playerBarHeight: 132

    function openNowPlaying() {
        if (!player || !player.hasCurrentTrack) return
        if (contentStack.currentIndex !== nowPlayingIndex)
            previousContentIndex = contentStack.currentIndex
        showNowPlaying = true
        contentStack.currentIndex = nowPlayingIndex
    }

    function closeNowPlaying() {
        showNowPlaying = false
        contentStack.currentIndex = previousContentIndex
    }

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
                color: theme.background

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    TopBar {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 42
                    }

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
                        LibrarySongsView { id: librarySongsView }
                        NowPlayingView {
                            id: nowPlayingView
                            onBackClicked: root.closeNowPlaying()
                            currentTrack: player ? player.currentDisplayTitle : ""
                            currentArtist: player ? player.currentArtist : ""
                            currentAlbum: player ? player.currentAlbum : ""
                            currentAlbumArt: player ? player.currentAlbumArt : ""
                        }
                    }

                    PlayerControls {
                        id: playerControls
                        visible: !showNowPlaying
                        Layout.fillWidth: true
                        Layout.preferredHeight: root.playerBarHeight
                        Layout.minimumHeight: root.playerBarHeight
                        onShowNowPlayingRequested: {
                            root.openNowPlaying()
                        }
                    }
                }
            }
        }

        WindowResizeHandles {
            anchors.fill: scene
            z: 20
            appWindow: root
        }
    }
}
