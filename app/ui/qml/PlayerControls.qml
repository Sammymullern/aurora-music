import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: "#16162b"
    
    // Bind to player properties
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
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16
        
        // Track info (left side - 30-35%)
        TrackInfo {
            Layout.preferredWidth: Math.min(parent.width * 0.35, 280)
            Layout.fillWidth: false
            title: root.currentTrack
            artist: root.currentArtist
            albumArt: "" // TODO: Add album art support
        }
        
        Item { Layout.fillWidth: true }
        
        // Playback controls (center)
        PlaybackControls {
            isPlaying: root.isPlaying
            isShuffle: root.shuffle
            repeatMode: root.repeat
            
            onShuffleClicked: {
                if (player) player.toggleShuffle()
            }
            onPreviousClicked: {
                if (player) player.previous()
            }
            onPlayPauseClicked: {
                if (player) player.playPause()
            }
            onNextClicked: {
                if (player) player.next()
            }
            onRepeatClicked: {
                if (player) player.toggleRepeat()
            }
        }
        
        Item { Layout.fillWidth: true }
        
        // Progress section (expands to fill space)
        ProgressSection {
            Layout.fillWidth: true
            Layout.preferredWidth: 200
            Layout.maximumWidth: 400
            position: root.currentPosition
            duration: root.currentDuration
            
            onSeekRequested: function(position) {
                if (player) player.seekTo(position)
            }
        }
        
        // Volume control (right side)
        VolumeControl {
            volume: root.volume
            
            onVolumeValueChanged: function(vol) {
                if (volumeController) volumeController.setVolume(vol)
            }
        }
    }
}
