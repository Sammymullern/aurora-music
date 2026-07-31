import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#141428"

    // 3D shadow effect
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: 8
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a1a35" }
            GradientStop { position: 1.0; color: "#0f0f20" }
        }
    }

    // Gradient border
    Rectangle {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
        width: 1
        gradient: Gradient {
            GradientStop { position: 0.00; color: "#7c3aed" }
            GradientStop { position: 0.50; color: "#8b5cf6" }
            GradientStop { position: 1.00; color: "#10b981" }
        }
        opacity: 0.55
    }

    property string assetsPath: Qt.resolvedUrl("../../assets/icons/")

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        spacing: 0

        // ===== Logo / Brand =====
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 78
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 18
                spacing: 12

                // SVG Logo
                Image {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 42
                    source: assetsPath + "logo.svg"
                    sourceSize: Qt.size(42, 42)
                    smooth: true
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: "Aurora"
                        font.pixelSize: 18
                        font.bold: true
                        color: "#ffffff"
                    }
                    Text {
                        text: "MUSIC"
                        font.pixelSize: 11
                        color: "#7c3aed"
                        font.letterSpacing: 3
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.leftMargin: 18
            Layout.rightMargin: 18
            Layout.preferredHeight: 1
            color: "#2a2a4a"
        }

        // ===== NAVIGATE header =====
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.topMargin: 10

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: "NAVIGATE"
                font.pixelSize: 10
                font.letterSpacing: 2
                color: "#5a5a88"
                font.bold: true
            }
        }

        // ===== Nav buttons — placed directly, no wrapping column that collapses =====
        SidebarButton {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.preferredHeight: 46
            text: "Music"
            iconSource: assetsPath + "music.svg"
            viewIndex: 0
            onClicked: contentStack.currentIndex = 0
        }
        SidebarButton {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.preferredHeight: 46
            Layout.topMargin: 2
            text: "Library"
            iconSource: assetsPath + "library.svg"
            viewIndex: 1
            onClicked: contentStack.currentIndex = 1
        }
        SidebarButton {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.preferredHeight: 46
            Layout.topMargin: 2
            text: "Playlists"
            iconSource: assetsPath + "playlist.svg"
            viewIndex: 2
            onClicked: contentStack.currentIndex = 2
        }

        // ===== Spacer pushes Settings to bottom =====
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 10
        }

        // ===== SYSTEM header =====
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 30

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 24
                text: "SYSTEM"
                font.pixelSize: 10
                font.letterSpacing: 2
                color: "#5a5a88"
                font.bold: true
            }
        }

        SidebarButton {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            Layout.preferredHeight: 46
            text: "Settings"
            iconSource: assetsPath + "settings.svg"
            viewIndex: 4
            onClicked: contentStack.currentIndex = 4
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 12
        }
    }
}
