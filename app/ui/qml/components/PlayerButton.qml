import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    property string icon: ""
    property bool isActive: false
    property bool isHovered: false
    signal clicked()
    
    width: 48
    height: 48
    radius: 24
    color: isHovered ? theme.primary : (isActive ? theme.primary : theme.primaryDark)
    border.color: isActive ? theme.primary : theme.border
    border.width: isActive ? 2 : 1
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    
    Text {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: 20
        color: "#ffffff"
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.isHovered = true
        onExited: root.isHovered = false
        onClicked: root.clicked()
    }
}
