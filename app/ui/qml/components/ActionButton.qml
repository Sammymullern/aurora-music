import QtQuick 2.15
import QtQuick.Controls 2.15

Button {
    id: root
    property bool primaryAction: false
    property bool destructiveAction: false

    implicitHeight: 42
    leftPadding: 16
    rightPadding: 16
    opacity: enabled ? 1.0 : 0.48

    contentItem: Text {
        text: root.text
        color: root.primaryAction || root.destructiveAction ? "#ffffff" : theme.textPrimary
        font.pixelSize: 13
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: 10
        color: root.destructiveAction
            ? (root.hovered ? "#dc2626" : "#ef4444")
            : root.primaryAction
                ? (root.hovered ? theme.primaryLight : theme.primary)
                : (root.hovered ? theme.backgroundLight : theme.surface)
        border.color: root.primaryAction || root.destructiveAction ? "transparent" : theme.border
        border.width: 1
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
