import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 40
        
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
                text: "Track Title"
                font.pixelSize: 32
                font.bold: true
                color: "#e0e0e0"
                Layout.alignment: Qt.AlignHCenter
            }
            
            Text {
                text: "Artist Name • Album Name"
                font.pixelSize: 18
                color: "#a0a0a0"
                Layout.alignment: Qt.AlignHCenter
            }
        }
        
        Item { Layout.fillHeight: true }
    }
}
