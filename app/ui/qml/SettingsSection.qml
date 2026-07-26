import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property string title: ""
    default property alias content: contentLayout.children
    
    implicitWidth: parent.width
    implicitHeight: sectionColumn.height + 40
    radius: 12
    color: "#252542"
    
    ColumnLayout {
        id: sectionColumn
        anchors.fill: parent
        anchors.margins: 30
        spacing: 25
        
        Text {
            text: root.title
            font.pixelSize: 20
            font.bold: true
            color: "#e0e0e0"
        }
        
        Item { Layout.preferredHeight: 10 }
        
        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            spacing: 20
        }
    }
}
