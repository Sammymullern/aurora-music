import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property string name: ""
    property string description: ""
    property int trackCount: 0
    property int playlistId: 0

    signal clicked()
    signal editRequested()
    signal deleteRequested()
    signal duplicateRequested()

    radius: 16
    color: theme.surface
    border.width: 1
    border.color: cardMouse.containsMouse ? theme.primary : theme.border
    clip: true

    Behavior on border.color { ColorAnimation { duration: 140 } }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 96
            radius: 12
            gradient: Gradient {
                GradientStop { position: 0.0; color: theme.primary }
                GradientStop { position: 1.0; color: theme.primaryDark }
            }

            Text {
                anchors.centerIn: parent
                text: "♫"
                font.pixelSize: 54
                color: "#ffffff"
                opacity: 0.95
            }

            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                radius: 12
                color: "#33000000"
                width: 58
                height: 24
                Text {
                    anchors.centerIn: parent
                    text: root.trackCount + (root.trackCount === 1 ? " track" : " tracks")
                    color: "#ffffff"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.name
            font.pixelSize: 15
            font.weight: Font.DemiBold
            color: theme.textPrimary
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: root.description || "Your collection"
            font.pixelSize: 12
            color: theme.textSecondary
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        anchors.rightMargin: 44
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Button {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        width: 34
        height: 34
        z: 2
        text: "⋯"
        background: Rectangle {
            radius: 17
            color: parent.hovered ? theme.surfaceVariant : theme.surface
            border.color: theme.border
            border.width: 1
        }
        contentItem: Text {
            text: parent.text
            color: theme.textPrimary
            font.pixelSize: 18
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: contextMenu.popup()
    }

    Menu {
        id: contextMenu
        width: 160
        background: Rectangle { color: theme.surface; radius: 10; border.color: theme.border }
        MenuItem {
            text: "Edit"
            contentItem: Text { text: parent.text; color: theme.textPrimary; verticalAlignment: Text.AlignVCenter; leftPadding: 12 }
            background: Rectangle { color: parent.hovered ? theme.surfaceVariant : "transparent"; radius: 6 }
            onTriggered: root.editRequested()
        }
        MenuItem {
            text: "Duplicate"
            contentItem: Text { text: parent.text; color: theme.textPrimary; verticalAlignment: Text.AlignVCenter; leftPadding: 12 }
            background: Rectangle { color: parent.hovered ? theme.surfaceVariant : "transparent"; radius: 6 }
            onTriggered: root.duplicateRequested()
        }
        MenuSeparator {}
        MenuItem {
            text: "Delete"
            contentItem: Text { text: parent.text; color: "#dc2626"; verticalAlignment: Text.AlignVCenter; leftPadding: 12 }
            background: Rectangle { color: parent.hovered ? theme.surfaceVariant : "transparent"; radius: 6 }
            onTriggered: root.deleteRequested()
        }
    }
}
