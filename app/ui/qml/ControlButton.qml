import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    property string icon: ""
    property int size: 40
    
    signal clicked()
    
    implicitWidth: size
    implicitHeight: size
    radius: size / 2
    color: theme.surface
    
    Text {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: root.size * 0.4
        color: theme.textPrimary
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        hoverEnabled: true
        
        onEntered: root.color = theme.surfaceVariant
        onExited: root.color = theme.surface
        cursorShape: Qt.PointingHandCursor
    }
}
