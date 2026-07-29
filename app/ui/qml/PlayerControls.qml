import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    implicitWidth: 1000
    implicitHeight: 132
    clip: true

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#15152e" }
        GradientStop { position: 0.4; color: "#0f0f24" }
        GradientStop { position: 1.0; color: "#0b0b1e" }
    }

    Rectangle {
        z: 3
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: 2
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#7c3aed" }
            GradientStop { position: 0.50; color: "#8b5cf6" }
            GradientStop { position: 1.00; color: "#10b981" }
        }
    }

    Rectangle {
        z: 2
        anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 2 }
        height: 10
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0affffff" }
            GradientStop { position: 1.0; color: "#00ffffff" }
        }
    }

    // ===================================================================
    // Player property bindings (unchanged)
    // ===================================================================
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
    property string currentTrackId: player ? player.currentTrackId : ""
    // Favorite state is sourced from player.currentTrackFavorite (synced with DB via MusicManager).
    // Local override during the short instant between click and DB round-trip (prevents flicker).
    property bool _pendingFavoriteValid: false
    property bool _pendingFavoriteValue: false
    property bool isFavorite: root._pendingFavoriteValid
        ? root._pendingFavoriteValue
        : (player ? Boolean(player.currentTrackFavorite) : false)

    readonly property real windowWidth: {
        if (root.Window && root.Window.window) return root.Window.window.width
        return root.width
    }

    // ===================================================================
    // Responsive clampers — tuned so spacing stops growing on huge
    // monitors (no awkward "spread across the whole screen" look).
    //
    //   t ∈ [0,1]: 0 at 900px, 1 at 2200px+
    // ===================================================================
    readonly property real t: Math.min(1, Math.max(0, (root.windowWidth - 900) / 1300))

    readonly property int outerPad:        Math.round(20 + t * 24)   // 20 → 44
    readonly property int rowSpacing:      Math.round(6 + t * 8)     // 6 → 14
    readonly property int itemSpacing:     Math.round(12 + t * 14)   // 12 → 26
    readonly property int trackInfoMaxW:   Math.round(320 + t * 160) // 320 → 480
    readonly property int volSliderMin:    70
    readonly property int volSliderMax:    Math.round(120 + t * 80)  // 120 → 200
    readonly property bool showVolumeSlider: root.windowWidth >= 1050
    readonly property int volumeSliderWidth: Math.max(root.volSliderMin,
        Math.min(root.volSliderMax,
                 Math.round((root.windowWidth - 900) * 0.12 + 120)))

    signal showNowPlayingRequested()

    // ===================================================================
    // 2-ROW LAYOUT:
    //   Row 1:  progress bar + times
    //   Row 2:  [TrackInfo + Fav] [⟷spacer⟶] [Buttons centered] [⟵spacer⟷] [Volume]
    //
    // Inner layout fits inside 132px bar:
    //   • 12px top visuals   (2px separator + 10px glow) — sits above topMargin
    //   • 14px topMargin     (start of ColumnLayout below glow)
    //   • 14px bottomMargin
    //   • Row 1 Progress: 28px
    //   • rowSpacing: 6
    //   • Row 2 Content: 58px  (tallest = 54px play button)
    //   = 12 + 14 + 14 + 28 + 6 + 58 = 132px ✓
    // ===================================================================
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin:   root.outerPad
        anchors.rightMargin:  root.outerPad
        anchors.topMargin:    14
        anchors.bottomMargin: 14
        spacing: Math.min(8, root.rowSpacing)

        // ============ Row 1: Progress bar (full width) ============
        ProgressSection {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            position: root.currentPosition
            duration: root.currentDuration
            onSeekRequested: function(position) {
                if (player) player.seekTo(position)
            }
        }

        // ============ Row 2: 3 zones (tracks / buttons / volume) ============
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            Layout.minimumHeight: 58
            spacing: root.itemSpacing

            TrackInfo {
                Layout.preferredWidth: Math.min(root.width * 0.35, root.trackInfoMaxW)
                Layout.minimumWidth: 220
                Layout.preferredHeight: 58
                Layout.alignment: Qt.AlignVCenter
                title: root.currentTrack
                artist: root.currentArtist
                albumArt: root.currentAlbumArt
                isFavorite: root.isFavorite
                onClicked: root.showNowPlayingRequested()
                onFavoriteToggled: function(newFav) {
                    // Optimistically set the UI to prevent flicker while DB save happens.
                    // MusicManager.toggleFavorite will push an authoritative update via player.currentTrackFavorite.
                    var sid = root.currentTrackId
                    if (sid !== "" && musicManager) {
                        root._pendingFavoriteValue = Boolean(newFav)
                        root._pendingFavoriteValid = true
                        musicManager.toggleFavorite(sid)
                        // Clear the optimistic override after the manager's push-down arrives
                        // (player.currentTrackFavorite changes → isFavorite re-evaluates).
                        pendingResetTimer.restart()
                    }
                }

                Timer {
                    id: pendingResetTimer
                    interval: 400
                    running: false
                    repeat: false
                    onTriggered: {
                        root._pendingFavoriteValid = false
                    }
                }
            }

            Item { Layout.fillWidth: true }

            PlaybackControls {
                Layout.preferredHeight: 58
                Layout.alignment: Qt.AlignVCenter
                spacing: 12
                isPlaying: root.isPlaying
                isShuffle: root.shuffle
                repeatMode: root.repeat
                onShuffleClicked:    { if (player) player.toggleShuffle() }
                onStopClicked:       { if (player) player.stop() }
                onPreviousClicked:   { if (player) player.previous() }
                onPlayPauseClicked:  { if (player) player.playPause() }
                onNextClicked:       { if (player) player.next() }
                onRepeatClicked:     { if (player) player.toggleRepeat() }
            }

            Item { Layout.fillWidth: true }

            VolumeControl {
                Layout.preferredHeight: 58
                Layout.alignment: Qt.AlignVCenter
                showSlider: root.showVolumeSlider
                volumeSliderWidth: root.volumeSliderWidth
                volume: root.volume
                onVolumeValueChanged: function(vol) {
                    if (volumeController) volumeController.setVolume(vol)
                }
            }
        }
    }
}
