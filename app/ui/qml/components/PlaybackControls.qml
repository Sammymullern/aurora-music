import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 12

    property bool isPlaying: false
    property bool isShuffle: false
    property string repeatMode: "off"

    signal shuffleClicked()
    signal previousClicked()
    signal playPauseClicked()
    signal nextClicked()
    signal repeatClicked()
    signal stopClicked()

    readonly property color slateBg:     "#1f1f3c"
    readonly property color slateBorder: "#32325a"
    readonly property color hoverBg:     "#2a2a52"
    readonly property color purple:      "#7c3aed"
    readonly property color purpleSoft:  "#a78bfa"
    readonly property color green:       "#10b981"
    readonly property color greenHi:     "#34d399"
    readonly property color iconMuted:   "#b8b8d8"

    // ############################################
    // # Shuffle — purple when active, slate otherwise
    // ############################################
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 22
        color: root.isShuffle ? root.purple : root.slateBg
        border.color: root.isShuffle ? root.purple : root.slateBorder
        border.width: 1.4
        scale: shuffleMA.pressed ? 0.93 : (shuffleMA.containsMouse ? 1.04 : 1.0)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 120 } }

        Rectangle { z: -1; anchors.centerIn: parent; width: parent.width-2; height: parent.height-2
            radius: parent.radius; color: "#000000"; opacity: 0.30; y: 2 }

        Image {
            anchors.centerIn: parent
            source: "../../../../assets/icons/shuffle.svg"
            sourceSize.width: 20; sourceSize.height: 20
            width: 20; height: 20
            opacity: root.isShuffle ? 1.0 : 0.88
        }
        MouseArea {
            id: shuffleMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 350
            ToolTip.text: root.isShuffle ? "Shuffle: On" : "Shuffle: Off"
            onEntered: if (!root.isShuffle) { parent.border.color = root.purpleSoft; parent.color = root.hoverBg }
            onExited:  if (!root.isShuffle) { parent.border.color = root.slateBorder; parent.color = root.slateBg }
            onClicked: root.shuffleClicked()
        }
    }

    // ############################################
    // # Stop — slate idle (■ square glyph, no SVG)
    // ############################################
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 22
        color: root.slateBg
        border.color: root.slateBorder
        border.width: 1.4
        scale: stopMA.pressed ? 0.93 : (stopMA.containsMouse ? 1.04 : 1.0)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 120 } }

        Rectangle { z: -1; anchors.centerIn: parent; width: parent.width-2; height: parent.height-2
            radius: parent.radius; color: "#000000"; opacity: 0.30; y: 2 }

        Rectangle {
            anchors.centerIn: parent
            width: 14; height: 14; radius: 2
            color: (stopMA.containsMouse || stopMA.pressed) ? root.green : "#d0d0ff"
        }
        MouseArea {
            id: stopMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 350; ToolTip.text: "Stop Playback"
            onEntered: { parent.border.color = root.purpleSoft; parent.color = root.hoverBg }
            onExited:  { parent.border.color = root.slateBorder; parent.color = root.slateBg }
            onClicked: root.stopClicked()
        }
    }

    // ############################################
    // # Previous — slate idle
    // ############################################
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 22
        color: root.slateBg
        border.color: root.slateBorder
        border.width: 1.4
        scale: prevMA.pressed ? 0.93 : (prevMA.containsMouse ? 1.04 : 1.0)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 120 } }

        Rectangle { z: -1; anchors.centerIn: parent; width: parent.width-2; height: parent.height-2
            radius: parent.radius; color: "#000000"; opacity: 0.30; y: 2 }

        Image {
            anchors.centerIn: parent
            source: "../../../../assets/icons/previous.svg"
            sourceSize.width: 20; sourceSize.height: 20; width: 20; height: 20; opacity: 0.9
        }
        MouseArea {
            id: prevMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 350; ToolTip.text: "Previous Track"
            onEntered: { parent.border.color = root.purpleSoft; parent.color = root.hoverBg }
            onExited:  { parent.border.color = root.slateBorder; parent.color = root.slateBg }
            onClicked: root.previousClicked()
        }
    }

    // ############################################
    // # PLAY / PAUSE — center, large, aurora-green gradient
    // ############################################
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 54
        Layout.preferredHeight: 54
        radius: 27
        gradient: Gradient {
            GradientStop { position: 0.0; color: root.green }
            GradientStop { position: 1.0; color: root.greenHi }
        }
        border.color: "#6ee7b7"
        border.width: 1.4
        scale: playMA.pressed ? 0.93 : (playMA.containsMouse ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: 120 } }

        // Halo: outer purple aura, inner soft green aura, bottom shadow
        Rectangle { z: -2; anchors.centerIn: parent
            width: parent.width+16; height: parent.height+16; radius: width/2
            color: root.purple; opacity: 0.10 }
        Rectangle { z: -1; anchors.centerIn: parent
            width: parent.width+6; height: parent.height+6; radius: width/2
            color: root.greenHi; opacity: 0.20 }
        Rectangle { z: -3; anchors.centerIn: parent
            width: parent.width; height: parent.height; radius: parent.radius
            color: "#000000"; opacity: 0.28; y: 3 }

        Image {
            anchors.centerIn: parent
            source: root.isPlaying
                ? "../../../../assets/icons/pause.svg"
                : "../../../../assets/icons/play.svg"
            sourceSize.width: 26; sourceSize.height: 26; width: 26; height: 26
        }
        MouseArea {
            id: playMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 250
            ToolTip.text: root.isPlaying ? "Pause" : "Play"
            onClicked: root.playPauseClicked()
        }
    }

    // ############################################
    // # Next — slate idle
    // ############################################
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 22
        color: root.slateBg
        border.color: root.slateBorder
        border.width: 1.4
        scale: nextMA.pressed ? 0.93 : (nextMA.containsMouse ? 1.04 : 1.0)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 120 } }

        Rectangle { z: -1; anchors.centerIn: parent; width: parent.width-2; height: parent.height-2
            radius: parent.radius; color: "#000000"; opacity: 0.30; y: 2 }

        Image {
            anchors.centerIn: parent
            source: "../../../../assets/icons/next.svg"
            sourceSize.width: 20; sourceSize.height: 20; width: 20; height: 20; opacity: 0.9
        }
        MouseArea {
            id: nextMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 350; ToolTip.text: "Next Track"
            onEntered: { parent.border.color = root.purpleSoft; parent.color = root.hoverBg }
            onExited:  { parent.border.color = root.slateBorder; parent.color = root.slateBg }
            onClicked: root.nextClicked()
        }
    }

    // ############################################
    // # Repeat — purple when active
    // ############################################
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 22
        color: (root.repeatMode !== "off") ? root.purple : root.slateBg
        border.color: (root.repeatMode !== "off") ? root.purple : root.slateBorder
        border.width: 1.4
        scale: repeatMA.pressed ? 0.93 : (repeatMA.containsMouse ? 1.04 : 1.0)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 120 } }

        Rectangle { z: -1; anchors.centerIn: parent; width: parent.width-2; height: parent.height-2
            radius: parent.radius; color: "#000000"; opacity: 0.30; y: 2 }

        Image {
            anchors.centerIn: parent
            source: (root.repeatMode === "one")
                ? "../../../../assets/icons/repeat-once.svg"
                : "../../../../assets/icons/repeat.svg"
            sourceSize.width: 20; sourceSize.height: 20
            width: 20; height: 20
            opacity: (root.repeatMode !== "off") ? 1.0 : 0.88
        }
        MouseArea {
            id: repeatMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 350
            ToolTip.text: (root.repeatMode === "off") ? "Repeat: Off"
                       : (root.repeatMode === "all") ? "Repeat: All"
                       : "Repeat: One"
            onEntered: if (root.repeatMode === "off") { parent.border.color = root.purpleSoft; parent.color = root.hoverBg }
            onExited:  if (root.repeatMode === "off") { parent.border.color = root.slateBorder; parent.color = root.slateBg }
            onClicked: root.repeatClicked()
        }
    }
}
