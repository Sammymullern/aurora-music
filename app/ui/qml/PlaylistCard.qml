import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    property string name: ""
    property int trackCount: 0
    property int playlistId: 0
    
    signal clicked()
    signal editRequested()
    signal deleteRequested()
    
    implicitWidth: 190
    implicitHeight: 240
    radius: 12
    color: "#252542"
    
    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        
        // Playlist art placeholder
        Rectangle {
            width: parent.width
            height: 150
            radius: 8
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#ec4899" }
                GradientStop { position: 1.0; color: "#8b5cf6" }
            }
            
            Text {
                anchors.centerIn: parent
                text: "🎵"
                font.pixelSize: 50
            }
        }
        
        Text {
            text: root.name
            font.pixelSize: 14
            font.bold: true
            color: "#e0e0e0"
            width: parent.width
            elide: Text.ElideRight
        }
        
        Text {
            text: root.trackCount + " tracks"
            font.pixelSize: 12
            color: "#a0a0a0"
        }
    }
    
    // Settings button (3 dots)
    Button {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        width: 32
        height: 32
        z: 2
        background: Rectangle {
            color: parent.hovered ? "#3a3a6a" : "#2a2a4a"
            radius: 16
        }
        contentItem: Text {
            text: "⋮"
            color: "#e0e0e0"
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: contextMenu.popup()
    }
    
    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: 40
        anchors.bottomMargin: 40
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onEntered: root.color = "#2a2a52"
        onExited: root.color = "#252542"
        
        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                root.clicked()
            } else if (mouse.button === Qt.RightButton) {
                contextMenu.popup()
            }
        }
        
        cursorShape: Qt.PointingHandCursor
    }
    
    Menu {
        id: contextMenu
        width: 150
        background: Rectangle {
            color: "#252542"
            radius: 8
            border.color: "#7c3aed"
            border.width: 1
        }
        
        MenuItem {
            text: "Edit"
            height: 40
            contentItem: Text {
                text: parent.text
                color: "#e0e0e0"
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                leftPadding: 15
            }
            background: Rectangle {
                color: parent.hovered ? "#2a2a4a" : "transparent"
                radius: 4
            }
            onTriggered: root.editRequested()
        }
        
        MenuSeparator {}
        
        MenuItem {
            text: "Delete"
            height: 40
            contentItem: Text {
                text: parent.text
                color: "#ef4444"
                font.pixelSize: 13
                verticalAlignment: Text.AlignVCenter
                leftPadding: 15
            }
            background: Rectangle {
                color: parent.hovered ? "#2a2a4a" : "transparent"
                radius: 4
            }
            onTriggered: root.deleteRequested()
        }
    }
}
