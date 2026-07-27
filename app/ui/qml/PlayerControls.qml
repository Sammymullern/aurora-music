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
    
    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 6
        
        // Track info section (top)
        RowLayout {
            Layout.fillWidth: true
            spacing: 15
            
            // Album art
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 8
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#10b981" }
                    GradientStop { position: 1.0; color: "#059669" }
                }
            }
            
            // Track info
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: root.currentTrack || "No track playing"
                    font.pixelSize: 14
                    font.bold: true
                    color: "#e0e0e0"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                
                Text {
                    text: root.currentArtist || "Artist"
                    font.pixelSize: 12
                    color: "#a0a0a0"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            
            // Volume slider (right side)
            VolumeSlider {
                Layout.preferredWidth: 150
                volume: root.volume
                onVolumeValueChanged: function(vol) {
                    if (volumeController) volumeController.setVolume(vol)
                }
            }
        }
        
        // Progress bar section (middle)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            Layout.topMargin: 8
            
            // Progress bar
            ProgressBar {
                Layout.fillWidth: true
                value: root.currentDuration > 0 ? root.currentPosition / root.currentDuration : 0
                onSeekRequested: function(position) {
                    if (player) player.seekTo(position)
                }
            }
            
            // Time labels
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: formatTime(root.currentPosition)
                    font.pixelSize: 11
                    color: "#a0a0a0"
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: formatTime(root.currentDuration)
                    font.pixelSize: 11
                    color: "#a0a0a0"
                }
            }
        }
        
        // Playback controls frame (bottom)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            radius: 8
            color: "#1e1e3a"
            border.color: "#2a2a4a"
            border.width: 1
            
            Row {
                anchors.centerIn: parent
                spacing: 25
                
                // Shuffle button
                Rectangle {
                    width: 46
                    height: 46
                    radius: 23
                    color: root.shuffle ? "#059669" : "#1e293b"
                    border.color: root.shuffle ? "#10b981" : "#334155"
                    border.width: root.shuffle ? 2 : 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "🔀"
                        font.pixelSize: 18
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (!root.shuffle) {
                                parent.color = containsMouse ? "#10b981" : "#1e293b"
                            }
                        }
                        onClicked: {
                            if (player) player.toggleShuffle()
                        }
                    }
                }
                
                // Previous button
                Rectangle {
                    width: 46
                    height: 46
                    radius: 23
                    color: "#1e293b"
                    border.color: "#334155"
                    border.width: 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⏮"
                        font.pixelSize: 18
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            parent.color = containsMouse ? "#10b981" : "#1e293b"
                        }
                        onClicked: {
                            if (player) player.previous()
                        }
                    }
                }
                
                // Play/Pause button (larger)
                Rectangle {
                    width: 56
                    height: 56
                    radius: 28
                    color: "#10b981"
                    border.color: "#10b981"
                    border.width: 2
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                    
                    scale: playPauseMouse.pressed ? 0.95 : 1.0
                    
                    Text {
                        anchors.centerIn: parent
                        text: root.isPaused ? "▶" : "⏸"
                        font.pixelSize: 24
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        id: playPauseMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (player) player.playPause()
                        }
                    }
                }
                
                // Next button
                Rectangle {
                    width: 46
                    height: 46
                    radius: 23
                    color: "#1e293b"
                    border.color: "#334155"
                    border.width: 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: "⏭"
                        font.pixelSize: 18
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            parent.color = containsMouse ? "#10b981" : "#1e293b"
                        }
                        onClicked: {
                            if (player) player.next()
                        }
                    }
                }
                
                // Repeat button
                Rectangle {
                    width: 46
                    height: 46
                    radius: 23
                    color: root.repeat !== "off" ? "#059669" : "#1e293b"
                    border.color: root.repeat !== "off" ? "#10b981" : "#334155"
                    border.width: root.repeat !== "off" ? 2 : 1
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: root.repeat === "one" ? "🔂" : "🔁"
                        font.pixelSize: 18
                        color: "#ffffff"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onHoveredChanged: {
                            if (root.repeat === "off") {
                                parent.color = containsMouse ? "#10b981" : "#1e293b"
                            }
                        }
                        onClicked: {
                            if (player) player.toggleRepeat()
                        }
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
