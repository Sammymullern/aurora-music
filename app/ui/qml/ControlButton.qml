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
    color: "#252542"
    
    Text {
        anchors.centerIn: parent
        text: root.icon
        font.pixelSize: root.size * 0.4
        color: "#e0e0e0"
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        hoverEnabled: true
        
        onEntered: root.color = "#2a2a52"
        onExited: root.color = "#252542"
        cursorShape: Qt.PointingHandCursor
    }
}
