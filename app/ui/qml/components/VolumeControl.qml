import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RowLayout {
    id: root
    spacing: 10

    property int volume: 100
    property bool showSlider: true
    property int volumeSliderWidth: 120

    signal volumeValueChanged(int volume)

    readonly property color slateBg:     "#1f1f3c"
    readonly property color slateBorder: "#32325a"
    readonly property color hoverBg:     "#2a2a52"
    readonly property color purple:      "#7c3aed"
    readonly property color purpleSoft:  "#a78bfa"
    readonly property color green:       "#10b981"
    readonly property color greenHi:     "#34d399"
    readonly property color iconMuted:   "#b8b8d8"

    readonly property real fraction: Math.max(0, Math.min(1, root.volume / 100))
    readonly property bool hoverOrDrag: volMA.containsMouse || volMA.dragging

    // ###########################################
    // # Speaker / mute toggle button (44px, slate filled)
    // ###########################################
    Rectangle {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 44
        Layout.preferredHeight: 44
        radius: 22
        color: root.volume === 0 ? root.purple : root.slateBg
        border.color: root.volume === 0 ? root.purple : root.slateBorder
        border.width: 1.4
        scale: speakerMA.pressed ? 0.93 : (speakerMA.containsMouse ? 1.04 : 1.0)

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 120 } }

        // Drop shadow
        Rectangle { z: -1; anchors.centerIn: parent; width: parent.width-2; height: parent.height-2
            radius: parent.radius; color: "#000000"; opacity: 0.30; y: 2 }
        // Muted purple halo
        Rectangle { z: -1; anchors.centerIn: parent
            width: parent.width+6; height: parent.height+6; radius: width/2
            color: root.purple; opacity: (root.volume === 0) ? 0.20 : 0.0 }

        Image {
            anchors.centerIn: parent
            source: getVolumeIcon(root.volume)
            sourceSize.width: 22; sourceSize.height: 22
            width: 22; height: 22
            opacity: (root.volume === 0 || speakerMA.containsMouse) ? 1.0 : 0.9
        }

        MouseArea {
            id: speakerMA
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 350
            ToolTip.text: root.volume > 0
                ? "Mute (currently " + root.volume + "%)"
                : "Unmute (restore 50%)"
            onEntered: if (root.volume !== 0) { parent.border.color = root.purpleSoft; parent.color = root.hoverBg }
            onExited:  if (root.volume !== 0) { parent.border.color = root.slateBorder; parent.color = root.slateBg }
            onClicked: {
                if (root.volume > 0) root.volumeValueChanged(0)
                else                 root.volumeValueChanged(50)
            }
        }
    }

    // ###########################################
    // # Volume slider bar (6–8 px, gradient fill, glowing handle)
    // ###########################################
    Item {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: root.showSlider
            ? Math.max(60, Math.min(200, root.volumeSliderWidth))
            : 0
        Layout.preferredHeight: 28
        visible: root.showSlider

        Rectangle {
            id: volTrack
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            height: root.hoverOrDrag ? 8 : 6
            radius: height / 2
            color: "#202040"
            border { color: "#2c2c52"; width: 1 }

            Rectangle {
                id: volFill
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: parent.width * root.fraction
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: root.purple }
                    GradientStop { position: 1.0; color: root.green }
                }
                Behavior on width {
                    enabled: !volMA.dragging
                    NumberAnimation { duration: 80 }
                }
                Rectangle {
                    anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 1 }
                    height: 1; color: "#ffffff"; opacity: 0.18; radius: 0.5
                }
            }

            Rectangle {
                id: volHandle
                anchors { left: volFill.right; leftMargin: root.hoverOrDrag ? -7 : -5; verticalCenter: parent.verticalCenter }
                width: root.hoverOrDrag ? 14 : 10
                height: width
                radius: width / 2
                color: "#ffffff"
                border { color: root.green; width: 2 }
                visible: true
                Behavior on width { NumberAnimation { duration: 80 } }
                Behavior on height { NumberAnimation { duration: 80 } }
                Behavior on anchors.leftMargin { NumberAnimation { duration: 80 } }
                Rectangle { z: -1; anchors.centerIn: parent; width: parent.width+8; height: parent.height+8
                    radius: width/2; color: root.purple; opacity: 0.22 }
                Rectangle { z: -1; anchors.centerIn: parent; width: parent.width+4; height: parent.height+4
                    radius: width/2; color: root.greenHi; opacity: 0.30 }
            }
        }

        // Hit area — enlarged to fill full Item height for easy grabbing
        MouseArea {
            id: volMA
            anchors.fill: parent
            anchors.topMargin: -4
            anchors.bottomMargin: -4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            ToolTip.visible: containsMouse; ToolTip.delay: 300
            ToolTip.text: "Volume: " + root.volume + "%"

            property bool dragging: false

            onPressed:  { dragging = true;  updateVolume(mouseX) }
            onPositionChanged: if (dragging) updateVolume(mouseX)
            onReleased: { dragging = false; updateVolume(mouseX) }
            onClicked: updateVolume(mouseX)

            function updateVolume(mouseX) {
                var w = volTrack.width
                if (w <= 0) return
                var pos = (mouseX - volTrack.x) / w
                pos = Math.max(0, Math.min(1, pos))
                root.volumeValueChanged(Math.round(pos * 100))
            }
        }
    }

    function getVolumeIcon(vol) {
        if (vol === 0) return "../../../../assets/icons/mute.svg"
        return "../../../../assets/icons/volume.svg"
    }
}
