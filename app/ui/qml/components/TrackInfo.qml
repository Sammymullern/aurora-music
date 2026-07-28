import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 12
    
    property string title: ""
    property string artist: ""
    property string albumArt: ""
    
    // Album artwork
    Rectangle {
        Layout.preferredWidth: 52
        Layout.preferredHeight: 52
        radius: 6
        color: "#252542"
        
        // Gradient placeholder when no album art
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#7c3aed" }
            GradientStop { position: 1.0; color: "#10b981" }
        }
        
        // Album art image
        Image {
            anchors.fill: parent
            source: root.albumArt
            fillMode: Image.PreserveAspectCrop
            visible: root.albumArt !== ""
            
            layer.enabled: true
            layer.effect: null
        }
        
        // Placeholder icon when no album art
        Image {
            anchors.centerIn: parent
            source: "../../../../assets/icons/music.svg"
            sourceSize.width: 32
            sourceSize.height: 32
            width: 32
            height: 32
            visible: root.albumArt === ""
        }
    }
    
    // Track info column
    ColumnLayout {
        Layout.fillWidth: true
        Layout.maximumWidth: 200
        spacing: 2
        
        // Song title with marquee
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 20
            clip: true
            
            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                text: root.title
                font.pixelSize: 13
                font.bold: true
                color: "#e0e0e0"
                
                // Continuous marquee animation (scroll left to right)
                SequentialAnimation on x {
                    id: titleMarquee
                    running: true
                    loops: Animation.Infinite
                    
                    // Scroll from left (off-screen) to right (off-screen)
                    NumberAnimation {
                        from: -titleText.contentWidth
                        to: parent.width
                        duration: 8000
                        easing.type: Easing.Linear
                    }
                    
                    // Pause at end
                    PauseAnimation { duration: 1000 }
                    
                    // Reset to start position
                    NumberAnimation {
                        from: parent.width
                        to: -titleText.contentWidth
                        duration: 0
                    }
                }
            }
        }
        
        // Artist name with marquee
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 16
            clip: true
            
            Text {
                id: artistText
                anchors.verticalCenter: parent.verticalCenter
                text: root.artist
                font.pixelSize: 11
                color: "#a0a0b0"
                
                // Continuous marquee animation (scroll left to right)
                SequentialAnimation on x {
                    id: artistMarquee
                    running: true
                    loops: Animation.Infinite
                    
                    // Scroll from left (off-screen) to right (off-screen)
                    NumberAnimation {
                        from: -artistText.contentWidth
                        to: parent.width
                        duration: 8000
                        easing.type: Easing.Linear
                    }
                    
                    // Pause at end
                    PauseAnimation { duration: 1000 }
                    
                    // Reset to start position
                    NumberAnimation {
                        from: parent.width
                        to: -artistText.contentWidth
                        duration: 0
                    }
                }
            }
        }
    }
}
