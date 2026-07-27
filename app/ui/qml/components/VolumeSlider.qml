import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    property int volume: 100
    signal volumeValueChanged(int volume)
    
    spacing: 8
    
    // Volume icon
    Text {
        text: root.volume > 0 ? "🔊" : "🔇"
        font.pixelSize: 16
        Layout.preferredWidth: 20
    }
    
    // Volume slider
    Rectangle {
        Layout.preferredWidth: 80
        Layout.preferredHeight: 6
        radius: 3
        color: "#1e293b"
        
        Rectangle {
            id: volumeBar
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * (root.volume / 100)
            radius: parent.radius
            color: "#10b981"
            
            Behavior on width {
                NumberAnimation { duration: 100 }
            }
        }
        
        MouseArea {
            anchors.fill: parent
            onClicked: {
                var vol = mouseX / parent.width * 100
                vol = Math.max(0, Math.min(100, vol))
                root.volumeValueChanged(Math.round(vol))
            }
        }
    }
    
    // Volume percentage
    Text {
        text: root.volume + "%"
        font.pixelSize: 12
        color: "#a0a0a0"
        Layout.preferredWidth: 35
    }
}
