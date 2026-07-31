import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    property var songs: []
    property string title: ""
    property string subtitle: ""

    function formatDuration(seconds) {
        var hours = Math.floor(seconds / 3600)
        var minutes = Math.floor((seconds % 3600) / 60)
        var secs = seconds % 60
        if (hours > 0) {
            return hours + ":" + (minutes < 10 ? "0" : "") + minutes + ":" + (secs < 10 ? "0" : "") + secs
        }
        return minutes + ":" + (secs < 10 ? "0" : "") + secs
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 15
        anchors.margins: 25

        // Header section
        RowLayout {
            Layout.fillWidth: true
            spacing: 20

            // Back button
            Rectangle {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                radius: 8
                color: "#252542"

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: 20
                    color: "#e0e0e0"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contentStack.currentIndex = 2  // Go back to Library
                    }
                }
            }

            ColumnLayout {
                spacing: 5

                Text {
                    text: root.title
                    font.pixelSize: 28
                    font.bold: true
                    color: "#e0e0e0"
                }

                Text {
                    text: root.subtitle
                    font.pixelSize: 14
                    color: "#a0a0a0"
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: songs.length + " songs"
                font.pixelSize: 14
                color: "#a0a0a0"
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#4a4a6a"
        }

        // Songs list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: songs
            spacing: 5
            clip: true

            delegate: Rectangle {
                width: ListView.view.width
                height: 70
                color: modelData.id == player.currentTrackId ? "#2a2a4a" : "transparent"
                radius: 8

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    // Track number
                    Text {
                        text: index + 1
                        font.pixelSize: 16
                        color: "#a0a0a0"
                        Layout.preferredWidth: 40
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Track info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: modelData.title || "Unknown Track"
                            font.pixelSize: 15
                            font.bold: true
                            color: "#e0e0e0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: (modelData.artist || "Unknown Artist") + " • " + (modelData.album || "Unknown Album")
                            font.pixelSize: 13
                            color: "#a0a0a0"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    // Duration
                    Text {
                        text: formatDuration(modelData.duration || 0)
                        font.pixelSize: 14
                        color: "#a0a0a0"
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignRight
                    }

                    // Play button
                    Rectangle {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        radius: 17
                        color: "#7c3aed"

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            font.pixelSize: 14
                            color: "white"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (musicManager) {
                                    musicManager.playSong(modelData.id)
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onDoubleClicked: {
                        if (musicManager) {
                            musicManager.playSong(modelData.id)
                        }
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
        }

        // Empty state
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: songs.length === 0
            color: "transparent"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                Text {
                    text: "🎵"
                    font.pixelSize: 80
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "No songs found"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#e0e0e0"
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
