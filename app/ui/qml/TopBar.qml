import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Rectangle {
    id: root
    color: theme.surface
    readonly property var appWindow: Window.window
    readonly property bool maximized: appWindow && appWindow.visibility === Window.Maximized
    
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
