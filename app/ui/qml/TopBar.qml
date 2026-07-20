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
        spacing: 15
        
        // Search bar
        Rectangle {
            Layout.preferredWidth: 300
            Layout.preferredHeight: 40
            radius: 20
            color: "#252542"
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                spacing: 10
                
                Text {
                    text: "🔍"
                    font.pixelSize: 16
                }
                
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "Search library..."
                    background: Rectangle { color: "transparent" }
                    color: "#e0e0e0"
                    font.pixelSize: 14
                }
            }
        }
        
        Item { Layout.fillWidth: true }
        
        // Filter buttons
        Repeater {
            model: ["All", "Artists", "Albums", "Genres"]
            
            Button {
                text: modelData
                flat: true
                contentItem: Text {
                    text: parent.text
                    color: "#e0e0e0"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    color: parent.hovered ? "#252542" : "transparent"
                    radius: 15
                }
            }
        }
    }
}
