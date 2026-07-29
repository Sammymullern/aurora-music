import QtQuick 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    property string track: ""
    property string artist: ""
    property string album: ""
    property bool miniMode: false

    spacing: miniMode ? 6 : 10

    readonly property real titlePx: miniMode ? 22 : 34
    readonly property real titleMax: miniMode ? 2 : 2
    readonly property real artistPx: miniMode ? 15 : 20
    readonly property real albumPx: miniMode ? 12 : 15

    Text {
        id: titleText
        Layout.fillWidth: true
        text: root.track
        font.pixelSize: root.titlePx
        font.bold: true
        font.letterSpacing: miniMode ? 0 : 0.2
        color: "#ffffff"
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
        maximumLineCount: root.titleMax
        lineHeight: 1.12

        Rectangle {
            z: -1
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: parent.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#fff0ff" }
                GradientStop { position: 0.5; color: "#e0d8ff" }
                GradientStop { position: 1.0; color: "#c0ffd8" }
            }
            opacity: 0.0
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: miniMode ? 6 : 10

        Rectangle {
            Layout.preferredWidth: 3
            Layout.preferredHeight: root.artistPx * 0.72
            radius: 1.5
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#7c3aed" }
                GradientStop { position: 1.0; color: "#10b981" }
            }
            opacity: 0.9
        }

        Text {
            Layout.fillWidth: true
            Layout.maximumWidth: miniMode ? Number.MAX_VALUE : 600
            text: root.artist
            font.pixelSize: root.artistPx
            font.letterSpacing: 0.3
            color: "#c4b5fd"
            elide: Text.ElideRight
            opacity: 0.95
            font.weight: Font.DemiBold
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.maximumWidth: miniMode ? Number.MAX_VALUE : 600
        text: root.album
        font.pixelSize: root.albumPx
        color: "#8a8ab0"
        elide: Text.ElideRight
        opacity: 0.88
        visible: root.album && root.album.length > 0 && root.album !== "Unknown"
    }

    Item { Layout.preferredHeight: miniMode ? 2 : 4 }

    Row {
        Layout.fillWidth: true
        visible: false

        spacing: 8

        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: "#10b981"
            opacity: 0.7
        }

        Text {
            text: "LIVE"
            font.pixelSize: 10
            font.bold: true
            font.letterSpacing: 2
            color: "#34d399"
            opacity: 0.8
        }
    }
}
