import QtQuick 2.15

Item {
    id: root
    property string albumArt: ""
    property bool isPlaying: false
    property bool hasTrack: false
    property bool isPaused: false

    property real rotationValue: 0
    property real pulseValue: 0
    property real tiltX: 0
    property real tiltY: 0

    readonly property real baseScale: 1.0 + pulseValue * 0.035

    Rectangle {
        id: outerGlow
        z: -5
        anchors.centerIn: parent
        width: parent.width * 1.55
        height: parent.height * 1.55
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#407c3aed" }
            GradientStop { position: 0.5; color: "#208b5cf6" }
            GradientStop { position: 1.0; color: "#0010b981" }
        }
        opacity: root.isPlaying && root.hasTrack ? 0.55 : 0.28
        visible: root.hasTrack
        layer.enabled: true
        layer.smooth: true
    }

    Rectangle {
        id: midGlow
        z: -4
        anchors.centerIn: parent
        width: parent.width * 1.22
        height: parent.height * 1.22
        radius: width / 2
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#6010b981" }
            GradientStop { position: 0.5; color: "#307c3aed" }
            GradientStop { position: 1.0; color: "#007c3aed" }
        }
        opacity: root.isPlaying && root.hasTrack ? 0.32 : 0.14
        visible: root.hasTrack
        layer.enabled: true
        layer.smooth: true
    }

    Item {
        id: tiltContainer
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        rotation: rotationValue
        scale: baseScale

        transform: [
            Rotation {
                id: tiltRotX
                axis { x: 1; y: 0; z: 0 }
                angle: tiltX
            },
            Rotation {
                id: tiltRotY
                axis { x: 0; y: 1; z: 0 }
                angle: -tiltY
            }
        ]

        Rectangle {
            id: shadowRect
            z: -3
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.leftMargin: 8
            anchors.rightMargin: -8
            radius: parent.width * 0.08
            color: "#000000"
            opacity: 0.42
            layer.enabled: true
            layer.smooth: true
        }

        Rectangle {
            id: frameRect
            anchors.fill: parent
            radius: parent.width * 0.06
            color: "#2a2a52"
            border { color: "#7c3aed"; width: 1.5 }
            clip: true

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#4c1d95" }
                GradientStop { position: 0.5; color: "#5b21b6" }
                GradientStop { position: 1.0; color: "#047857" }
            }

            Image {
                anchors.fill: parent
                source: root.albumArt
                fillMode: Image.PreserveAspectCrop
                sourceSize.width: 1200
                sourceSize.height: 1200
                asynchronous: true
                cache: true
                visible: root.albumArt !== ""
            }

            Image {
                anchors.centerIn: parent
                source: "../../../../assets/icons/music.svg"
                readonly property real iconSize: Math.max(80, parent.width * 0.38)
                sourceSize.width: iconSize
                sourceSize.height: iconSize
                width: iconSize
                height: iconSize
                opacity: 0.88
                visible: root.albumArt === ""
            }

            Rectangle {
                id: glassSheen
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: parent.height * 0.48
                gradient: Gradient {
                    GradientStop { position: 0.00; color: "#70ffffff" }
                    GradientStop { position: 0.35; color: "#28ffffff" }
                    GradientStop { position: 1.00; color: "#00ffffff" }
                }
                visible: root.albumArt !== ""
                opacity: 0.55
            }
        }

        Rectangle {
            id: frameBorder
            z: 1
            anchors.fill: parent
            radius: parent.width * 0.06
            color: "#00000000"
            border { color: "#60ffffff"; width: 0.8 }
        }
    }

    Rectangle {
        id: pausedBadge
        z: 10
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -6
        width: pauseText.contentWidth + 30
        height: 36
        radius: 18
        color: "#12122a"
        opacity: root.isPaused && root.hasTrack ? 0.96 : 0
        border.color: "#7c3aed"
        border.width: 1.2
        visible: opacity > 0

        Text {
            id: pauseText
            anchors.centerIn: parent
            text: "⏸  PAUSED"
            font.pixelSize: 12
            font.bold: true
            color: "#e0dfff"
            font.letterSpacing: 0.8
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    NumberAnimation on rotationValue {
        id: spinAnim
        running: root.isPlaying && root.hasTrack
        loops: Animation.Infinite
        from: 0
        to: 360
        duration: 60000
        easing.type: Easing.Linear
        alwaysRunToEnd: true
    }

    NumberAnimation on pulseValue {
        id: pulseAnim
        running: root.isPlaying && root.hasTrack
        loops: Animation.Infinite
        from: 0.0
        to: 1.0
        duration: 1600
        easing.type: Easing.InOutSine
        alwaysRunToEnd: true
        onStopped: root.pulseValue = 0
    }

    property real tiltTime: 0
    onTiltTimeChanged: {
        root.tiltX = Math.sin(root.tiltTime * 0.9) * 1.8
        root.tiltY = Math.sin(root.tiltTime * 1.3) * 2.2
    }

    NumberAnimation on tiltTime {
        id: tiltAnim
        running: root.isPlaying && root.hasTrack
        loops: Animation.Infinite
        from: 0.0
        to: 6.283185
        duration: 7200
        easing.type: Easing.Linear
        alwaysRunToEnd: true
        onStopped: {
            root.tiltX = 0
            root.tiltY = 0
            root.tiltTime = 0
        }
    }

    Behavior on tiltX { NumberAnimation { duration: 400 } }
    Behavior on tiltY { NumberAnimation { duration: 400 } }
    Behavior on rotationValue {
        enabled: !spinAnim.running
        NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
    }
}
