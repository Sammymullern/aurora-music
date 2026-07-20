import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#16162b"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        
        // Logo area
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: "#16162b"
            
            RowLayout {
                anchors.centerIn: parent
                spacing: 10
                
                // Logo placeholder
                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 8
                    color: "#7c3aed"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "A"
                        font.pixelSize: 24
                        font.bold: true
                        color: "white"
                    }
                }
                
                Text {
                    text: "Aurora"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#e0e0e0"
                }
            }
        }
        
        // Navigation items
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            
            ColumnLayout {
                width: parent.width
                spacing: 2
                
                Repeater {
                    model: [
                        { name: "Library", icon: "📚", view: 0 },
                        { name: "Now Playing", icon: "🎵", view: 1 },
                        { name: "Playlists", icon: "📝", view: 2 },
                        { name: "Settings", icon: "⚙️", view: 3 }
                    ]
                    
                    SidebarButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        text: modelData.name
                        icon: modelData.icon
                        viewIndex: modelData.view
                        onClicked: contentStack.currentIndex = viewIndex
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
        }
    }
}
