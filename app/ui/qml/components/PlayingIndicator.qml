import QtQuick 2.15

Item {
    id: root
    implicitWidth: 22
    implicitHeight: 22
    property bool active: false
    property bool playing: false
    property color color: theme.primary

    Repeater {
        model: 3
        delegate: Rectangle {
            id: bar
            width: 3
            radius: 2
            color: root.color
            anchors.bottom: parent.bottom
            x: index * 6 + 2
            height: root.active ? 8 + (index === 1 ? 5 : 0) : 3
            transformOrigin: Item.Bottom

            SequentialAnimation on scale {
                running: root.active && root.playing
                loops: Animation.Infinite
                onRunningChanged: if (!running) bar.scale = 1.0
                NumberAnimation {
                    from: 0.55
                    to: index === 1 ? 1.0 : 1.35
                    duration: 260 + index * 80
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    from: index === 1 ? 1.0 : 1.35
                    to: 0.55
                    duration: 260 + index * 80
                    easing.type: Easing.InOutSine
                }
            }
        }
    }
}
