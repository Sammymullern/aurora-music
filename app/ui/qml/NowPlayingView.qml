import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: "#0d0d1f"

    property bool isPlaying: player ? player.isPlaying : false
    property bool isPaused: player ? player.isPaused : true
    property real currentPosition: player ? player.currentPosition : 0.0
    property real currentDuration: player ? player.currentDuration : 0.0
    property int volume: volumeController ? volumeController.volume : 100
    property bool shuffle: player ? player.isShuffle : false
    property string repeat: player ? player.repeatMode : "off"
    property string currentTrack: player ? player.currentTitle : ""
    property string currentArtist: player ? player.currentArtist : ""
    property string currentAlbum: player ? player.currentAlbum : ""
    property string currentAlbumArt: player ? player.currentAlbumArt : ""

    property bool hasTrack: currentTrack.length > 0

    readonly property real viewW: root.width
    readonly property real viewH: root.height

    readonly property bool isMiniMode: viewW < 850 || viewH < 560
    readonly property real layoutT: Math.min(1, Math.max(0, (viewW - 850) / 900))

    readonly property int outerPad: Math.round(20 + layoutT * 36)
    readonly property int contentMaxW: Math.round(1200 + layoutT * 200)

    signal backClicked()

    Image {
        id: bgImage
        anchors.fill: parent
        source: root.currentAlbumArt
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: root.currentAlbumArt !== "" && root.hasTrack
        opacity: 0.18

        layer.enabled: true
        layer.effect: ShaderEffect {
            property variant source: bgImage
            property real radius: 64
            property real step: 1.0 / 128.0
            fragmentShader: "
                varying highp vec2 qt_TexCoord0;
                uniform sampler2D source;
                uniform lowp float qt_Opacity;
                uniform highp float radius;
                uniform highp float step;
                void main() {
                    lowp vec4 sum = vec4(0.0);
                    highp vec2 tc = qt_TexCoord0;
                    highp float blur = radius * step;
                    for (int x = -4; x <= 4; x++) {
                        for (int y = -4; y <= 4; y++) {
                            highp vec2 off = vec2(float(x), float(y)) * blur;
                            sum += texture2D(source, tc + off);
                        }
                    }
                    sum /= 81.0;
                    gl_FragColor = sum * qt_Opacity;
                }
            "
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#a0141433" }
            GradientStop { position: 0.35; color: "#b80f0f28" }
            GradientStop { position: 0.75; color: "#c810102a" }
            GradientStop { position: 1.00; color: "#d00a0a1e" }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#300d0d1f" }
            GradientStop { position: 0.50; color: "#00000000" }
            GradientStop { position: 1.00; color: "#500a0a1e" }
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
                color: "#2a2a42"
                border.color: "#3f3f68"
                border.width: 1
                opacity: 0.92

                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#f0f0ff"
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: { backBtn.color = "#38385c"; backBtn.border.color = "#7c3aed" }
                    onExited: { backBtn.color = "#2a2a42"; backBtn.border.color = "#3f3f68" }
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
                color: "#d0d0ee"
                font.letterSpacing: 0.4
                opacity: 0.92
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                id: modeBadge
                Layout.preferredWidth: badgeText.contentWidth + 22
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignVCenter
                radius: 16
                color: root.isMiniMode ? "#222244" : "#1d1d3a"
                border.color: root.isMiniMode ? "#7c3aed" : "#38385c"
                border.width: 1
                visible: false

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: root.isMiniMode ? "MINI" : "MAX"
                    font.pixelSize: 10
                    font.bold: true
                    color: root.isMiniMode ? "#c4b5fd" : "#9090b4"
                    font.letterSpacing: 1.2
                }
            }
        }

        Loader {
            id: layoutLoader
            anchors { top: topRow.bottom; topMargin: 16; left: parent.left; right: parent.right; bottom: parent.bottom }
            sourceComponent: root.isMiniMode ? miniLayout : wideLayout
            asynchronous: true
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
            color: "#7c3aed"
            opacity: 0.55
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Nothing playing right now"
            font.pixelSize: 24
            font.bold: true
            color: "#e0e0f5"
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Pick a song from your Music library to start listening"
            font.pixelSize: 15
            color: "#8a8ab0"
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
                        Layout.preferredHeight: 140
                        Layout.minimumHeight: 100
                        radius: 22
                        color: "#1a1a34"
                        border.color: "#2e2e50"
                        border.width: 1
                        opacity: 0.90

                        Rectangle {
                            z: -1
                            anchors.fill: parent
                            radius: parent.radius
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#307c3aed" }
                                GradientStop { position: 1.0; color: "#1510b981" }
                            }
                            opacity: 0.08
                        }

                        WaveformProgress {
                            id: wideWaveform
                            anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 10; bottomMargin: 10 }
                            position: root.currentPosition
                            duration: root.currentDuration
                            isPlaying: root.isPlaying
                            trackSeed: root.currentTrack + "|" + root.currentArtist
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
                        color: "#16162e"
                        border.color: "#2b2b4e"
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
            spacing: 18

            AlbumArtStage {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Math.max(220, Math.min(viewW * 0.52, 340))
                Layout.preferredHeight: Layout.preferredWidth
                Layout.maximumHeight: Math.min(viewH * 0.38, 340)
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
                Layout.preferredHeight: 96
                Layout.minimumHeight: 78
                radius: 18
                color: "#1a1a34"
                border.color: "#2e2e50"
                border.width: 1
                opacity: 0.90

                WaveformProgress {
                    id: miniWaveform
                    anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: 8; bottomMargin: 8 }
                    position: root.currentPosition
                    duration: root.currentDuration
                    isPlaying: root.isPlaying
                    trackSeed: root.currentTrack + "|" + root.currentArtist
                    onSeekRequested: function(p) { if (player) player.seekTo(p) }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 82
                radius: 20
                color: "#16162e"
                border.color: "#2b2b4e"
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
