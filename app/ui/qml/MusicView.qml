import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import "./components"

Rectangle {
    id: root
    color: theme.background

    function formatDuration(seconds) {
        if (seconds === null || seconds === undefined) return "0:00"
        var sec = Number(seconds)
        if (isNaN(sec) || sec < 0) return "0:00"
        var h = Math.floor(sec / 3600)
        var m = Math.floor((sec % 3600) / 60)
        var s = Math.floor(sec % 60)
        function pad(n) { return n < 10 ? "0" + n : "" + n }
        if (h > 0) return h + ":" + pad(m) + ":" + pad(s)
        return m + ":" + pad(s)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 28
        anchors.rightMargin: 28
        anchors.topMargin: 20
        anchors.bottomMargin: 20
        spacing: 14

        // ===== HEADER: Title + Search/Sort row (compact) =====
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Text {
                text: "Music"
                font.pixelSize: 28
                font.bold: true
                color: theme.textPrimary
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 440
                Layout.minimumWidth: 280
                Layout.preferredHeight: 38
                color: theme.surface
                radius: 10
                border.color: theme.border
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: "🔍"
                        font.pixelSize: 14
                        color: "#8a8ab0"
                    }

                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Search songs, artists, albums..."
                        font.pixelSize: 13
                        color: theme.textPrimary
                        selectionColor: theme.primary
                        placeholderTextColor: "#606088"
                        background: Item { }
                        onTextChanged: {
                            if (musicManager) musicManager.setSearchQuery(text)
                        }
                    }
                }
            }

            ComboBox {
                Layout.preferredWidth: 130
                Layout.preferredHeight: 38
                model: ["A-Z", "Z-A", "Recently Added", "Most Played"]
                currentIndex: 0
                font.pixelSize: 13

                background: Rectangle {
                    color: theme.surface
                    radius: 10
                    border.color: theme.border
                    border.width: 1
                }

                contentItem: Text {
                    text: parent.displayText
                    color: theme.textPrimary
                    font.pixelSize: 13
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 14
                    rightPadding: 30
                }

                indicator: Canvas {
                    x: parent.width - width - 14
                    y: parent.height / 2 - height / 2
                    width: 10
                    height: 6
                    contextType: "2d"
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.fillStyle = theme.textSecondary
                        ctx.beginPath()
                        ctx.moveTo(0, 0)
                        ctx.lineTo(10, 0)
                        ctx.lineTo(5, 6)
                        ctx.closePath()
                        ctx.fill()
                    }
                }
            }

            Row {
                spacing: 8
                Rectangle {
                    width: 36; height: 36; radius: 8
                    color: theme.primary
                    Text {
                        anchors.centerIn: parent
                        text: "▢"; font.pixelSize: 15; color: "white"
                    }
                }
                Rectangle {
                    width: 36; height: 36; radius: 8
                    color: theme.surface
                    border.color: theme.border; border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "☰"; font.pixelSize: 15; color: theme.textSecondary
                    }
                }
            }
        }

        // ===== FILTER CHIPS — unified size, icons, hover + active aurora glow =====
        RowLayout {
            id: filterRow
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            spacing: 10

            property string currentFilter: "all"

            Repeater {
                model: [
                    { key: "all",              label: "All",            icon: "🎧" },
                    { key: "favorites",        label: "Favorites",      icon: "♥"  },
                    { key: "recently_added",   label: "Recently Added", icon: "⏱"  },
                    { key: "high_rating",      label: "High Rating",    icon: "★"  }
                ]

                delegate: Rectangle {
                    id: chip
                    Layout.preferredHeight: 36
                    Layout.minimumHeight: 36
                    Layout.preferredWidth: contentWrap.implicitWidth + 44
                    Layout.minimumWidth: 110
                    radius: 18
                    clip: false

                    readonly property bool active: filterRow.currentFilter === chipKey
                    readonly property string chipKey: modelData.key
                    readonly property string chipLabel: modelData.label
                    readonly property string chipIcon: modelData.icon
                    readonly property bool isHovered: chipMA.containsMouse

                    // ===== Layered visuals: base bg + outer halo on active =====
                    color: {
                        if (active) return theme.primary
                        if (isHovered) return theme.surfaceVariant
                        return theme.surface
                    }

                    border {
                        width: active ? 0 : 1
                        color: {
                            if (active) return theme.primary
                            if (isHovered) return theme.primaryLight
                            return theme.surfaceVariant
                        }
                    }

                    // Active-state aurora gradient fill overlays the base
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: theme.primary }
                            GradientStop { position: 1.0; color: theme.primaryDark }
                        }
                        opacity: chip.active ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }

                    // Active-state outer purple halo (double-layer — matches PlayerControls buttons)
                    Rectangle {
                        z: -2
                        anchors.centerIn: parent
                        width: parent.width + 10
                        height: parent.height + 10
                        radius: width / 2
                        color: theme.primary
                        opacity: chip.active ? 0.18 : (chip.isHovered ? 0.08 : 0.0)
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }
                    Rectangle {
                        z: -1
                        anchors.centerIn: parent
                        width: parent.width + 5
                        height: parent.height + 5
                        radius: width / 2
                        color: "#10b981"
                        opacity: chip.active ? 0.10 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }

                    // ===== Icon + Label content row =====
                    Row {
                        id: contentWrap
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            id: iconT
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.chipIcon
                            font.pixelSize: chip.active ? 14 : 13
                            color: chip.active ? "#ffffff" : (chip.isHovered ? theme.primary : theme.textSecondary)
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        Text {
                            id: labelT
                            anchors.verticalCenter: parent.verticalCenter
                            text: chip.chipLabel
                            font.pixelSize: 12
                            font.weight: chip.active ? Font.DemiBold : Font.Medium
                            font.letterSpacing: chip.active ? 0.4 : 0
                            color: chip.active ? "#ffffff" : (chip.isHovered ? theme.primary : theme.textSecondary)
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    // ===== Click / hover capture =====
                    MouseArea {
                        id: chipMA
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        ToolTip.visible: containsMouse
                        ToolTip.delay: 400
                        ToolTip.text: "Filter by " + chip.chipLabel
                        onClicked: {
                            filterRow.currentFilter = chip.chipKey
                            if (musicManager) musicManager.setFilter(chip.chipKey)
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 160 } }
                    Behavior on border.color { ColorAnimation { duration: 160 } }
                }
            }

            Item { Layout.fillWidth: true }
        }

        // ===== SONGS HEADER + COUNT =====
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            spacing: 12

            Text {
                text: musicManager ? "Songs (" + musicManager.songCount + ")" : "Songs (0)"
                font.pixelSize: 14
                font.bold: true
                color: theme.textPrimary
            }

            Item { Layout.fillWidth: true }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: "transparent"
            }
        }

        // ===== SONGS TABLE (fills ALL remaining height, internal ScrollView clips/scrolling) =====
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 180
            color: theme.backgroundLight
            radius: 12
            border.color: theme.surfaceVariant
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Table header (fixed)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: theme.backgroundLight

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 18
                        anchors.rightMargin: 18
                        spacing: 16

                        Text {
                            Layout.preferredWidth: 40
                            text: "#"
                            font.pixelSize: 11
                            font.letterSpacing: 1
                            font.bold: true
                            color: theme.textSecondary
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 200
                            text: "TITLE"
                            font.pixelSize: 11
                            font.letterSpacing: 1
                            font.bold: true
                            color: theme.textSecondary
                        }

                        Text {
                            Layout.preferredWidth: 220
                            text: "ARTIST"
                            font.pixelSize: 11
                            font.letterSpacing: 1
                            font.bold: true
                            color: theme.textSecondary
                        }

                        Text {
                            Layout.preferredWidth: 220
                            text: "ALBUM"
                            font.pixelSize: 11
                            font.letterSpacing: 1
                            font.bold: true
                            color: theme.textSecondary
                        }

                        Text {
                            Layout.preferredWidth: 84
                            text: "⏱"
                            font.pixelSize: 12
                            color: theme.textSecondary
                            horizontalAlignment: Text.AlignRight
                        }

                        Item { Layout.preferredWidth: 52 }
                    }
                }

                // Separator line
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: theme.surfaceVariant
                }

                // Scrollable rows (takes the rest — CRITICAL: must have Layout.fillHeight: true to clip+scroll)
                ScrollView {
                    id: rowsScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                    ScrollBar.vertical.width: 6
                    ScrollBar.vertical.background: Rectangle { color: theme.background }
                    ScrollBar.vertical.contentItem: Rectangle {
                        color: theme.border
                        radius: 3
                        implicitWidth: 6
                    }

                    ColumnLayout {
                        width: rowsScroll.availableWidth
                        spacing: 0

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.minimumHeight: rowsScroll.availableHeight
                            color: "transparent"
                            visible: musicManager && musicManager.songs.length === 0

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 14

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "🎵"
                                    font.pixelSize: 56
                                    color: theme.border
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "No songs found"
                                    font.pixelSize: 17
                                    color: theme.textSecondary
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Try a different search or add music to your library"
                                    font.pixelSize: 13
                                    color: "#606080"
                                }
                            }
                        }

                        Repeater {
                            model: musicManager ? musicManager.songs : []

                            delegate: Rectangle {
                                id: delegateRoot
                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                color: isActive ? theme.surfaceVariant : ((index % 2 === 0) ? theme.surface : theme.backgroundLight)
                                property bool isHovered: false
                                readonly property bool isActive: Boolean(player) && String(player.currentTrackId || "") === String(modelData.id)
                                readonly property bool isFav: Boolean(modelData.favorite)

                                RowLayout {
                                    z: 1
                                    anchors.fill: parent
                                    anchors.leftMargin: 18
                                    anchors.rightMargin: 18
                                    spacing: 16

                                    PlayingIndicator {
                                        Layout.preferredWidth: 40
                                        Layout.preferredHeight: 22
                                        active: delegateRoot.isActive
                                        playing: active && player && player.isPlaying
                                        color: theme.primary
                                        Text {
                                            anchors.centerIn: parent
                                            visible: !delegateRoot.isActive
                                            text: index + 1
                                            font.pixelSize: 13
                                            color: theme.textSecondary
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 200
                                        text: modelData.title || "Unknown"
                                        font.pixelSize: 13
                                        color: delegateRoot.isActive ? theme.primary : theme.textPrimary
                                        font.bold: delegateRoot.isActive
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.preferredWidth: 220
                                        text: modelData.artist || "Unknown"
                                        font.pixelSize: 13
                                        color: theme.textSecondary
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.preferredWidth: 220
                                        text: modelData.album || "Unknown"
                                        font.pixelSize: 13
                                        color: theme.textSecondary
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        Layout.preferredWidth: 84
                                        text: root.formatDuration(modelData.duration)
                                        font.pixelSize: 13
                                        color: theme.textSecondary
                                        horizontalAlignment: Text.AlignRight
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 36
                                        Layout.preferredHeight: 36
                                        radius: 18
                                        z: 2
                                        color: delegateRoot.isFav ? "#ef4444" : "transparent"
                                        visible: delegateRoot.isHovered || delegateRoot.isFav
                                        opacity: delegateRoot.isFav ? 1.0 : (delegateRoot.isHovered ? 0.85 : 0)
                                        Behavior on opacity { NumberAnimation { duration: 120 } }

                                        Text {
                                            anchors.centerIn: parent
                                            text: delegateRoot.isFav ? "♥" : "♡"
                                            font.pixelSize: 16
                                            color: delegateRoot.isFav ? "#ffffff" : "#ef4444"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            ToolTip.visible: containsMouse
                                            ToolTip.text: delegateRoot.isFav ? "Remove from favorites" : "Add to favorites"
                                            onClicked: {
                                                if (musicManager) musicManager.toggleFavorite(String(modelData.id))
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: {
                                        parent.isHovered = true
                                        parent.color = theme.surfaceVariant
                                    }
                                    onExited: {
                                        parent.isHovered = false
                                        parent.color = parent.isActive ? theme.surfaceVariant : ((index % 2 === 0) ? theme.surface : theme.backgroundLight)
                                    }
                                    onClicked: {
                                        if (musicManager) musicManager.playSong(modelData.id)
                                    }
                                }
                            }
                        }

                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }
}
