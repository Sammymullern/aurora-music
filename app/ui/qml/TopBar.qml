import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Rectangle {
    id: root
    color: theme.surface
    readonly property var appWindow: Window.window
    readonly property bool maximized: appWindow && appWindow.visibility === Window.Maximized
    property bool reopenEqualizerAfterRestore: false

    function showEqualizer() {
        if (appWindow && appWindow.visibility === Window.Minimized) {
            reopenEqualizerAfterRestore = true
            appWindow.showNormal()
            appWindow.requestActivate()
            equalizerRestoreTimer.restart()
            return
        }
        equalizerPanel.open()
        Qt.callLater(equalizerPanel.reposition)
    }

    Timer {
        id: equalizerRestoreTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!root.appWindow || root.appWindow.visibility === Window.Minimized) return
            root.reopenEqualizerAfterRestore = false
            equalizerPanel.open()
            Qt.callLater(equalizerPanel.reposition)
            root.appWindow.requestActivate()
        }
    }

    Connections {
        target: root.appWindow
        function onVisibilityChanged() {
            if (root.appWindow.visibility === Window.Minimized) {
                if (equalizerPanel.visible) {
                    root.reopenEqualizerAfterRestore = true
                    equalizerPanel.close()
                }
            } else if (root.reopenEqualizerAfterRestore) {
                equalizerRestoreTimer.restart()
            }
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 10
        spacing: 8

        Label {
            text: "NelvaMusic"
            color: theme.textPrimary
            font.pixelSize: 14
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        ToolButton {
            id: equalizerButton
            implicitWidth: 64
            ToolTip.text: "Open equalizer"
            ToolTip.visible: hovered
            onClicked: root.showEqualizer()

            contentItem: Row {
                spacing: 5
                anchors.centerIn: parent
                Repeater {
                    model: [8, 14, 10]
                    delegate: Rectangle {
                        required property int modelData
                        width: 3
                        height: modelData
                        radius: 1.5
                        anchors.verticalCenter: parent.verticalCenter
                        color: equalizer.enabled ? theme.primaryLight : theme.textDisabled
                    }
                }
                Label {
                    text: "Equalizer"
                    color: theme.textPrimary
                    font.pixelSize: 11
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            background: Rectangle {
                radius: 8
                color: equalizerButton.hovered ? theme.surfaceVariant : "transparent"
                border.color: equalizer.enabled ? theme.border : "transparent"
            }
        }

        EqualizerPanel {
            id: equalizerPanel
            anchorItem: equalizerButton
            targetWindow: root.appWindow
        }

        ToolButton {
            text: "−"
            ToolTip.text: "Minimize"
            ToolTip.visible: hovered
            onClicked: if (root.appWindow) root.appWindow.showMinimized()
        }
        ToolButton {
            text: root.maximized ? "❐" : "□"
            ToolTip.text: root.maximized ? "Restore" : "Maximize"
            ToolTip.visible: hovered
            onClicked: {
                if (!root.appWindow) return
                root.appWindow.visibility = root.maximized ? Window.Windowed : Window.Maximized
            }
        }
        ToolButton {
            text: "×"
            ToolTip.text: "Close"
            ToolTip.visible: hovered
            onClicked: if (root.appWindow) root.appWindow.close()
        }
    }
}
