import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    property string text: ""
    property string iconSource: ""
    property int viewIndex: 0
    property bool isActive: contentStack.currentIndex === viewIndex

    signal clicked()

    color: {
        if (isActive) return "#221845"
        if (ma.containsMouse) return "#1d1d3a"
        return "transparent"
    }
    radius: 8

    // 3D shadow effect
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: root.isActive ? 4 : 0
        radius: 8
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#3d2a5c" }
            GradientStop { position: 1.0; color: "#1a1030" }
        }
        Behavior on width { NumberAnimation { duration: 180 } }
    }

    // Active-state accent bar (left edge)
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
        width: root.isActive ? 3 : 0
        radius: 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#a78bfa" }
            GradientStop { position: 1.0; color: "#7c3aed" }
        }
        Behavior on width { NumberAnimation { duration: 180 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.isActive ? 17 : 20
        anchors.rightMargin: 16
        spacing: 12

        Image {
            source: root.iconSource
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            sourceSize: Qt.size(20, 20)
            opacity: root.isActive ? 1.0 : 0.85
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Text {
            Layout.fillWidth: true
            text: root.text
            font.pixelSize: 13
            font.weight: root.isActive ? Font.DemiBold : Font.Medium
            color: root.isActive ? "#ffffff" : "#b8b8d8"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Behavior on color { ColorAnimation { duration: 140 } }
}
