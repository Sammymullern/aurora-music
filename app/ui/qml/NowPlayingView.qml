import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: "#1a1a2e"
    
    // Bind to player properties
    property bool isPlaying: player ? player.isPlaying : false
    property bool isPaused: player ? player.isPaused : true
    property real currentPosition: player ? player.currentPosition : 0.0
    property real currentDuration: player ? player.currentDuration : 0.0
    property int volume: player ? player.currentVolume : 100
    property bool shuffle: player ? player.isShuffle : false
    property string repeat: player ? player.repeatMode : "off"
    
    // Track info from player
    property string currentTrack: player ? player.currentTitle : ""
    property string currentArtist: player ? player.currentArtist : ""
    property string currentAlbum: player ? player.currentAlbum : ""
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 40
        
        // Empty state when not playing
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: !isPlaying
            color: "transparent"
            
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20
                
                // Empty state icon
                Text {
                    text: "🎧"
                    font.pixelSize: 100
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Empty state message
                Text {
                    text: "Nothing playing"
                    font.pixelSize: 28
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Subtitle
                Text {
                    text: "Select a track from your library to start listening"
                    font.pixelSize: 16
                    color: "#a0a0a0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                // Go to library button
                Button {
                    text: "Go to Library"
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
                        // Navigate to library
                        contentStack.currentIndex = 0
                    }
                }
            }
        }
        
        // Now playing content
        ColumnLayout {
            visible: isPlaying
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20
            
            // Album art
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 400
                Layout.preferredHeight: 400
                radius: 20
                color: "#252542"
                
                // Placeholder gradient
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#7c3aed" }
                    GradientStop { position: 1.0; color: "#3b82f6" }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "🎵"
                    font.pixelSize: 100
                }
            }
            
            // Track info
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10
                
                Text {
                    text: root.currentTrack || "Track Title"
                    font.pixelSize: 32
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignHCenter
                }
                
                Text {
                    text: (root.currentArtist || "Artist Name") + (root.currentAlbum ? " • " + root.currentAlbum : "")
                    font.pixelSize: 18
                    color: "#a0a0a0"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            Item { Layout.fillHeight: true }
            
            // Progress bar and time
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                ProgressBar {
                    Layout.fillWidth: true
                    value: root.currentDuration > 0 ? root.currentPosition / root.currentDuration : 0
                    onSeekRequested: function(position) {
                        if (player) player.seekTo(position)
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    Text {
                        text: formatTime(root.currentPosition)
                        font.pixelSize: 12
                        color: "#a0a0a0"
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: formatTime(root.currentDuration)
                        font.pixelSize: 12
                        color: "#a0a0a0"
                    }
                }
            }
            
            // Player controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 16
                
                // Shuffle button
                PlayerButton {
                    icon: "🔀"
                    isActive: root.shuffle
                    onClicked: {
                        if (player) player.toggleShuffle()
                    }
                }
                
                // Previous button
                PlayerButton {
                    icon: "⏮"
                    onClicked: {
                        if (player) player.previous()
                    }
                }
                
                // Play/Pause button (larger)
                PlayerButton {
                    width: 64
                    height: 64
                    radius: 32
                    icon: root.isPaused ? "▶" : "⏸"
                    onClicked: {
                        if (player) player.playPause()
                    }
                }
                
                // Stop button
                PlayerButton {
                    icon: "⏹"
                    onClicked: {
                        if (player) player.stop()
                    }
                }
                
                // Next button
                PlayerButton {
                    icon: "⏭"
                    onClicked: {
                        if (player) player.next()
                    }
                }
                
                // Repeat button
                PlayerButton {
                    icon: root.repeat === "one" ? "🔂" : "🔁"
                    isActive: root.repeat !== "off"
                    onClicked: {
                        if (player) player.toggleRepeat()
                    }
                }
                
                // Volume slider
                VolumeSlider {
                    volume: root.volume
                    onVolumeValueChanged: function(vol) {
                        if (player) player.setVolume(vol)
                    }
                }
            }
        }
    }
    
    function formatTime(seconds) {
        if (!seconds || seconds < 0) return "0:00"
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
