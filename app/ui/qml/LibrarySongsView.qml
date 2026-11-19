import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: theme.background
    property var songs: []
    property string title: ""
    property string subtitle: ""
    property var selectedTrack: ({})
    readonly property var metadataRows: {
        if (!selectedTrack || !selectedTrack.metadata) return []
        var fields = selectedTrack.metadata
        var labels = {
            track_number: "Track", disc_number: "Disc", year: "Year", genre: "Genre",
            composer: "Composer", performer: "Performer", lyricist: "Lyricist",
            comment: "Comment", format: "Format", bitrate: "Bitrate",
            sample_rate: "Sample rate", channels: "Channels", bit_depth: "Bit depth",
            track_gain: "Track gain", album_gain: "Album gain"
        }
        return Object.keys(labels).filter(function(key) {
            return fields[key] !== null && fields[key] !== undefined && String(fields[key]).length > 0
        }).map(function(key) { return { label: labels[key], value: String(fields[key]) + (key === "bitrate" ? " kbps" : key === "sample_rate" ? " Hz" : "") } })
    }

    function formatDuration(seconds) {
        return libraryManager ? libraryManager.formatDuration(Number(seconds)) : "0:00"
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
                color: theme.surface

                Text {
                    anchors.centerIn: parent
                    text: "←"
                    font.pixelSize: 20
                    color: theme.textPrimary
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        contentStack.currentIndex = 1
                    }
                }
            }

            ColumnLayout {
                spacing: 5

                Text {
                    text: root.title
                    font.pixelSize: 28
                    font.bold: true
                    color: theme.textPrimary
                }

                Text {
                    text: root.subtitle
                    font.pixelSize: 14
                    color: theme.textSecondary
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: songs.length + " songs"
                font.pixelSize: 14
                color: theme.textSecondary
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: theme.surfaceVariant
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
                color: modelData.id == player.currentTrackId ? theme.surfaceVariant : "transparent"
                radius: 8

                Behavior on color { ColorAnimation { duration: 150 } }

                RowLayout {
                    z: 1
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 15

                    // Track number
                    Image {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        visible: !!modelData.album_art
                        source: modelData.album_art || ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                    }

                    Item {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 22
                        PlayingIndicator {
                            anchors.centerIn: parent
                            active: String(modelData.id) === String(player.currentTrackId)
                            playing: active && player.isPlaying
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: String(modelData.id) !== String(player.currentTrackId)
                        text: index + 1
                        font.pixelSize: 16
                        color: theme.textSecondary
                        }
                    }

                    // Track info
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: modelData.title || "Unknown Track"
                            font.pixelSize: 15
                            font.bold: true
                            color: theme.textPrimary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: (modelData.artist || "Unknown Artist") + " • " + (modelData.album || "Unknown Album")
                            font.pixelSize: 13
                            color: theme.textSecondary
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    // Duration
                    Text {
                        text: formatDuration(modelData.duration || 0)
                        font.pixelSize: 14
                        color: theme.textSecondary
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignRight
                    }

                    Button {
                        text: "i"
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        onClicked: { root.selectedTrack = modelData; trackMetadataDialog.open() }
                        contentItem: Text { text: parent.text; color: theme.textSecondary; font.pixelSize: 16; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        background: Rectangle { color: theme.surface; radius: 17 }
                        ToolTip.visible: hovered
                        ToolTip.text: "Song details"
                    }

                    // Play button
                    Rectangle {
                        Layout.preferredWidth: 35
                        Layout.preferredHeight: 35
                        radius: 17
                        color: theme.primary

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
                    z: 0
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
                    color: theme.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }

    Dialog {
        id: trackMetadataDialog
        title: root.selectedTrack.title || "Song details"
        modal: true
        anchors.centerIn: parent
        width: Math.min(root.width - 40, 480)
        height: Math.min(root.height - 40, 560)
        standardButtons: Dialog.Close
        background: Rectangle { color: theme.surface; radius: 18; border.color: theme.border }

        contentItem: ColumnLayout {
            spacing: 12
            Text {
                Layout.fillWidth: true
                text: (root.selectedTrack.artist || "Unknown artist") + " · " + (root.selectedTrack.album || "Unknown album")
                color: theme.textSecondary
                wrapMode: Text.Wrap
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: root.metadataRows
                delegate: RowLayout {
                    width: ListView.view.width
                    height: Math.max(40, detailValue.implicitHeight + 12)
                    Text { Layout.preferredWidth: 120; text: modelData.label; color: theme.textSecondary; font.pixelSize: 13 }
                    Text { id: detailValue; Layout.fillWidth: true; text: modelData.value; color: theme.textPrimary; font.pixelSize: 13; wrapMode: Text.Wrap }
                }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
        }
    }
}
