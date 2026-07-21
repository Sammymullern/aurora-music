import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property string text: ""
    property string icon: ""
    property int viewIndex: 0
    property bool isActive: contentStack.currentIndex === viewIndex
    
    signal clicked()
    
    color: isActive ? "#7c3aed" : "transparent"
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        spacing: 15
        
        Text {
            text: icon
            font.pixelSize: 20
            Layout.preferredWidth: 30
        }
        
        Text {
            text: root.text
            font.pixelSize: 14
            color: "#e0e0e0"
            font.bold: root.isActive
        }
        
        Item { Layout.fillWidth: true }
    }
    
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        hoverEnabled: true
        
        onEntered: {
            if (!root.isActive) {
                root.color = "#252542"
            }
        }
        
        onExited: {
            if (!root.isActive) {
                root.color = "transparent"
            }
        }
    }
}
