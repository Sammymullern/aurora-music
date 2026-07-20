import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#16162b"
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 20
        
        // Current track info
        Rectangle {
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            color: "transparent"
            
            RowLayout {
                anchors.fill: parent
                spacing: 10
                
                // Small album art
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    radius: 8
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#7c3aed" }
                        GradientStop { position: 1.0; color: "#3b82f6" }
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    Text {
                        text: "Track Title"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#e0e0e0"
                    }
                    
                    Text {
                        text: "Artist Name"
                        font.pixelSize: 11
                        color: "#a0a0a0"
                    }
                }
            }
        }
        
        // Playback controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15
            
            ControlButton {
                icon: "⏮"
                onClicked: console.log("Previous")
            }
            
            ControlButton {
                icon: "▶"
                size: 50
                onClicked: console.log("Play/Pause")
            }
            
            ControlButton {
                icon: "⏭"
                onClicked: console.log("Next")
            }
        }
        
        // Progress bar and volume
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 300
            spacing: 5
            
            // Progress bar
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "1:23"
                    font.pixelSize: 11
                    color: "#a0a0a0"
                    Layout.preferredWidth: 35
                }
                
                ProgressBar {
                    Layout.fillWidth: true
                    value: 0.3
                    
                    background: Rectangle {
                        color: "#252542"
                        radius: 4
                    }
                    
                    contentItem: Rectangle {
                        width: parent.visualPosition * parent.width
                        height: parent.height
                        radius: 4
                        color: "#7c3aed"
                    }
                }
                
                Text {
                    text: "4:56"
                    font.pixelSize: 11
                    color: "#a0a0a0"
                    Layout.preferredWidth: 35
                }
            }
            
            // Volume
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                
                Text {
                    text: "🔊"
                    font.pixelSize: 14
                }
                
                Slider {
                    Layout.fillWidth: true
                    value: 0.7
                    
                    background: Rectangle {
                        color: "#252542"
                        radius: 4
                    }
                    
                    handle: Rectangle {
                        x: parent.visualPosition * parent.width - width / 2
                        y: parent.height / 2 - height / 2
                        width: 14
                        height: 14
                        radius: 7
                        color: "#7c3aed"
                    }
                }
            }
        }
    }
}
