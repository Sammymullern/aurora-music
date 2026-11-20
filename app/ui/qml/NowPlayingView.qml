import QtQuick 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: theme.background

    property bool isPlaying: player ? player.isPlaying : false
    property bool isPaused: player ? player.isPaused : true
    property real currentPosition: player ? player.currentPosition : 0.0
    property real currentDuration: player ? player.currentDuration : 0.0
    property int volume: volumeController ? volumeController.volume : 100
    property bool shuffle: player ? player.isShuffle : false
    property string repeat: player ? player.repeatMode : "off"
    property string currentTrack: player ? player.currentDisplayTitle : ""
    property string currentArtist: player ? player.currentArtist : ""
    property string currentAlbum: player ? player.currentAlbum : ""
    property string currentAlbumArt: player ? player.currentAlbumArt : ""

    property bool hasTrack: player ? player.hasCurrentTrack : currentTrack.length > 0

    readonly property real viewW: root.width
    readonly property real viewH: root.height

    readonly property bool isMiniMode: viewW < 1250 || viewH < 760
    readonly property real layoutT: Math.min(1, Math.max(0, (viewW - 850) / 900))
    readonly property real miniArtSize: Math.min(240, Math.max(150, viewH * 0.30))

    readonly property int outerPad: Math.round(20 + layoutT * 36)

    signal backClicked()

    Image {
        id: bgImage
        anchors.fill: parent
        source: root.currentAlbumArt
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: root.currentAlbumArt !== "" && root.hasTrack
        opacity: 0.12
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#0c000000" }
            GradientStop { position: 0.35; color: "#08000000" }
            GradientStop { position: 0.75; color: "#08000000" }
            GradientStop { position: 1.00; color: "#14000000" }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#08000000" }
            GradientStop { position: 0.50; color: "#00000000" }
            GradientStop { position: 1.00; color: "#10000000" }
        }
    }

    Item {
        id: contentArea
        anchors.fill: parent
        anchors.margins: root.outerPad

        RowLayout {
            id: topRow
            anchors { top: parent.top; left: parent.left; right: parent.right }
            Layout.preferredHeight: 56
            spacing: 14

            Rectangle {
                id: backBtn
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                Layout.alignment: Qt.AlignVCenter
                radius: 23
                color: theme.surfaceVariant
                border.color: theme.surfaceVariant
                border.width: 1
                opacity: 0.92

                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    font.pixelSize: 28
                    font.bold: true
                    color: theme.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: { backBtn.color = theme.surfaceVariant; backBtn.border.color = theme.primary }
                    onExited: { backBtn.color = theme.surfaceVariant; backBtn.border.color = theme.surfaceVariant }
                    onClicked: root.backClicked()
                }

                Behavior on color { ColorAnimation { duration: 140 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }
            }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: "Now Playing"
                font.pixelSize: 18
                font.bold: true
                color: theme.textPrimary
                font.letterSpacing: 0.4
                opacity: 0.92
            }

            Item { Layout.fillWidth: true }

        }

        Loader {
            id: layoutLoader
            anchors { top: topRow.bottom; topMargin: 16; left: parent.left; right: parent.right; bottom: parent.bottom }
            sourceComponent: root.isMiniMode ? miniLayout : wideLayout
            asynchronous: true
            active: root.hasTrack
            visible: root.hasTrack
        }
    }

    ColumnLayout {
        id: emptyLayout
        anchors.centerIn: parent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        spacing: 24
        visible: !root.hasTrack

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "♪"
            font.pixelSize: 120
            color: theme.primary
            opacity: 0.55
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Nothing playing right now"
            font.pixelSize: 24
            font.bold: true
            color: theme.textPrimary
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Go back to your library and choose a song"
            font.pixelSize: 15
            color: theme.textSecondary
        }
    }

    Component {
        id: wideLayout
        RowLayout {
            spacing: Math.round(40 + layoutT * 30)

            Item {
                Layout.preferredWidth: Math.max(320, Math.round(viewW * 0.40))
                Layout.maximumWidth: 520
                Layout.fillHeight: true

                AlbumArtStage {
                    anchors.centerIn: parent
                    width: Math.min(parent.width * 0.95, 480)
                    height: width
                    albumArt: root.currentAlbumArt
                    isPlaying: root.isPlaying
                    hasTrack: root.hasTrack
                    isPaused: root.isPaused
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.topMargin: 20
                    spacing: 0

                    TrackHeader {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 720
                        Layout.alignment: Qt.AlignLeft
                        track: root.currentTrack
                        artist: root.currentArtist
                        album: root.currentAlbum
                        miniMode: false
                    }

                    Item { Layout.preferredHeight: 28 }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.maximumWidth: 720
                        Layout.preferredHeight: 100
                        Layout.minimumHeight: 82
                        radius: 18
                        color: theme.background
                        border.color: theme.surfaceVariant
                        border.width: 1
                        opacity: 0.90

                        WaveformProgress {
                            anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 8; bottomMargin: 8 }
                            position: root.currentPosition
                            duration: root.currentDuration
                            onSeekRequested: function(p) { if (player) player.seekTo(p) }
                        }
                    }

                    Item { Layout.preferredHeight: 32 }

                    Rectangle {
                        Layout.alignment: Qt.AlignLeft
                        Layout.preferredHeight: 96
                        Layout.maximumWidth: 720
                        Layout.fillWidth: true
                        radius: 24
                        color: theme.backgroundDark
                        border.color: theme.surfaceVariant
                        border.width: 1
                        opacity: 0.92

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 22
                            anchors.rightMargin: 22
                            spacing: 20

                            PlaybackControls {
                                Layout.preferredHeight: 58
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 12
                                isPlaying: root.isPlaying
                                isShuffle: root.shuffle
                                repeatMode: root.repeat
                                onShuffleClicked: { if (player) player.toggleShuffle() }
                                onStopClicked: { if (player) player.stop() }
                                onPreviousClicked: { if (player) player.previous() }
                                onPlayPauseClicked: { if (player) player.playPause() }
                                onNextClicked: { if (player) player.next() }
                                onRepeatClicked: { if (player) player.toggleRepeat() }
                            }

                            Item { Layout.fillWidth: true }

                            VolumeControl {
                                Layout.preferredHeight: 58
                                Layout.alignment: Qt.AlignVCenter
                                showSlider: true
                                volumeSliderWidth: 170
                                volume: root.volume
                                onVolumeValueChanged: function(v) { if (volumeController) volumeController.setVolume(v) }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }

    Component {
        id: miniLayout
        ColumnLayout {
            spacing: 12

            AlbumArtStage {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: root.miniArtSize
                Layout.preferredHeight: root.miniArtSize
                Layout.maximumWidth: root.miniArtSize
                Layout.maximumHeight: root.miniArtSize
                albumArt: root.currentAlbumArt
                isPlaying: root.isPlaying
                hasTrack: root.hasTrack
                isPaused: root.isPaused
            }

            TrackHeader {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                track: root.currentTrack
                artist: root.currentArtist
                album: root.currentAlbum
                miniMode: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 78
                Layout.minimumHeight: 68
                radius: 16
                color: theme.background
                border.color: theme.surfaceVariant
                border.width: 1
                opacity: 0.90

                WaveformProgress {
                    anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: 4; bottomMargin: 4 }
                    position: root.currentPosition
                    duration: root.currentDuration
                    onSeekRequested: function(p) { if (player) player.seekTo(p) }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 82
                radius: 20
                color: theme.backgroundDark
                border.color: theme.surfaceVariant
                border.width: 1
                opacity: 0.92

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 8

                    PlaybackControls {
                        Layout.preferredHeight: 58
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 6
                        isPlaying: root.isPlaying
                        isShuffle: root.shuffle
                        repeatMode: root.repeat
                        onShuffleClicked: { if (player) player.toggleShuffle() }
                        onStopClicked: { if (player) player.stop() }
                        onPreviousClicked: { if (player) player.previous() }
                        onPlayPauseClicked: { if (player) player.playPause() }
                        onNextClicked: { if (player) player.next() }
                        onRepeatClicked: { if (player) player.toggleRepeat() }
                    }

                    Item { Layout.fillWidth: true }

                    VolumeControl {
                        Layout.preferredHeight: 58
                        Layout.alignment: Qt.AlignVCenter
                        showSlider: viewW > 620
                        volumeSliderWidth: 110
                        volume: root.volume
                        onVolumeValueChanged: function(v) { if (volumeController) volumeController.setVolume(v) }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
