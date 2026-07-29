import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root
    implicitWidth: 320
    implicitHeight: 72
    clip: false

    property string title: "Track Title"
    property string artist: "Artist"
    property string albumArt: ""
    property bool isFavorite: false

    signal clicked()
    signal favoriteToggled(bool newFav)

    // Hover highlight (subtle) — covers entire item, z-ordered below content.
    Rectangle {
        z: -1
        anchors { left: parent.left; right: parent.right; top: parent.top; bottom: parent.bottom }
        color: "#2a2a52"
        radius: 10
        opacity: hoverMA.containsMouse ? 0.7 : 0.0
        Behavior on opacity { NumberAnimation { duration: 160 } }
    }

    // Click / hover capture (covers the entire item — fav button MA handles its own area via later stacking order)
    MouseArea {
        id: hoverMA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: 0
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 2
        spacing: 14

        // ================ 64×64 album art card ================
        Item {
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            Layout.alignment: Qt.AlignVCenter

            // Layer 3 — drop shadow (behind everything, offset +2 down)
            Rectangle {
                z: -2
                anchors { left: parent.left; top: parent.top }
                width: parent.width - 2
                height: parent.height - 2
                x: 1
                y: 3
                radius: 12
                color: "#000000"
                opacity: 0.45
            }
            // Layer 2 — soft purple shadow halo behind
            Rectangle {
                z: -1
                anchors.centerIn: parent
                width: parent.width + 2
                height: parent.height + 2
                radius: 14
                color: "#7c3aed"
                opacity: 0.12
            }

            // Layer 1 — actual album art surface (rounded 12, border)
            Rectangle {
                anchors.fill: parent
                radius: 12
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#8b5cf6" }  // aurora purple
                    GradientStop { position: 1.0; color: "#10b981" }  // aurora teal-green
                }
                border { color: "#3a3a5c"; width: 1 }
                clip: true

                // User album art, if set (on top of gradient placeholder)
                Image {
                    anchors.fill: parent
                    source: root.albumArt
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    visible: root.albumArt !== "" && status !== Image.Error
                    sourceSize { width: 256; height: 256 }
                }
                // Placeholder music note (white, single clean icon — no hearts!)
                Image {
                    anchors.centerIn: parent
                    source: "../../../../assets/icons/music.svg"
                    sourceSize.width: 28; sourceSize.height: 28
                    width: 28; height: 28
                    opacity: root.albumArt === "" ? 0.92 : 0.0
                }
            }
        }

        // ================ Title + Artist column ================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            property int layoutMaxWidth: Math.max(100, parent.width - 10)

            // --------- Title (bold white, 14px, marquee if overflow) ---------
            Item {
                id: titleWrap
                Layout.fillWidth: true
                Layout.preferredHeight: 22
                Layout.maximumWidth: parent.layoutMaxWidth
                clip: true

                property bool overflow: titleText.contentWidth > width
                property int scrollDur: Math.max(4000, Math.round((titleText.contentWidth + width) * 18))

                Text {
                    id: titleText
                    x: 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.title
                    font.pixelSize: 14
                    font.bold: true
                    color: "#ffffff"
                    elide: titleWrap.overflow ? Text.ElideNone : Text.ElideRight
                    width: titleWrap.overflow ? undefined : parent.width
                    clip: false

                    SequentialAnimation on x {
                        id: titleAnim
                        loops: titleWrap.overflow ? Animation.Infinite : 0
                        running: Boolean(titleWrap.overflow)

                        PauseAnimation { duration: 1800 }
                        NumberAnimation {
                            from: 0
                            to: -(titleText.contentWidth + 80)
                            duration: titleWrap.overflow ? titleWrap.scrollDur : 0
                            alwaysRunToEnd: true
                        }
                        PauseAnimation { duration: 1800 }
                        ScriptAction { script: titleText.x = 0 }
                    }
                }
            }

            // --------- Artist (aurora purple, 12px medium, marquee if overflow) ---------
            Item {
                id: artistWrap
                Layout.fillWidth: true
                Layout.preferredHeight: 18
                Layout.maximumWidth: parent.layoutMaxWidth
                clip: true

                property bool overflow: artistText.contentWidth > width
                property int scrollDur: Math.max(5000, Math.round((artistText.contentWidth + width) * 22))

                Text {
                    id: artistText
                    x: 0
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.artist
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: "#a78bfa"   // aurora purple-400 — matches brand accent
                    elide: artistWrap.overflow ? Text.ElideNone : Text.ElideRight
                    width: artistWrap.overflow ? undefined : parent.width
                    clip: false

                    SequentialAnimation on x {
                        id: artistAnim
                        loops: artistWrap.overflow ? Animation.Infinite : 0
                        running: Boolean(artistWrap.overflow)

                        PauseAnimation { duration: 2000 }
                        NumberAnimation {
                            from: 0
                            to: -(artistText.contentWidth + 80)
                            duration: artistWrap.overflow ? artistWrap.scrollDur : 0
                            alwaysRunToEnd: true
                        }
                        PauseAnimation { duration: 2000 }
                        ScriptAction { script: artistText.x = 0 }
                    }
                }
            }
        }

        // ================ Favorite (heart) toggle button ================
        Rectangle {
            id: favButton
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: 17
            color: root.isFavorite ? "#ef4444" : "transparent"
            border {
                color: root.isFavorite ? "#ef4444"
                     : (favMA.containsMouse ? "#a78bfa"   // hover → purple
                                             : "#3a3a5c")  // idle → muted
                width: 1.4
            }
            scale: favMA.pressed ? 0.9 : (favMA.containsMouse ? 1.05 : 1.0)

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "♥"
                font.pixelSize: 16
                color: root.isFavorite ? "#ffffff"
                     : (favMA.containsMouse ? "#ef4444" : "#a8a8c8")
            }

            MouseArea {
                id: favMA
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                ToolTip.visible: containsMouse; ToolTip.delay: 350
                ToolTip.text: root.isFavorite ? "Remove from Favorites" : "Add to Favorites"
                onClicked: {
                    var next = !root.isFavorite
                    root.favoriteToggled(next)
                }
            }
        }
    }
}
