import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    
    // Custom translation function that forces re-evaluation
    function tr(sourceText) {
        // Access translation.emptyString to create dependency
        var dummy = translation ? translation.emptyString : ""
        return qsTr(sourceText)
    }
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Sidebar
        Rectangle {
            id: sidebar
            Layout.preferredWidth: 260
            Layout.fillHeight: true
            color: "#16162b"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Header
                ColumnLayout {
                    Layout.topMargin: 40
                    Layout.leftMargin: 24
                    Layout.bottomMargin: 32
                    spacing: 8
                    
                    Text {
                        text: root.tr("Settings")
                        font.pixelSize: 32
                        font.bold: true
                        color: "#e0e0e0"
                    }
                    
                    Text {
                        text: root.tr("Configure the music player")
                        font.pixelSize: 13
                        color: "#a0a0a0"
                    }
                }
                
                // Sidebar items
                Repeater {
                    model: [
                        { name: root.tr("General"), icon: "⚙" },
                        { name: root.tr("Library"), icon: "📁" },
                        { name: root.tr("Audio"), icon: "🔊" },
                        { name: root.tr("Appearance"), icon: "🎨" },
                        { name: root.tr("Playback"), icon: "▶" },
                        { name: root.tr("Advanced"), icon: "⚡" }
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        color: sidebar.currentIndex === index ? "#7c3aed" : "transparent"
                        radius: 8
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 12
                            
                            Text {
                                text: modelData.icon
                                font.pixelSize: 20
                                color: sidebar.currentIndex === index ? "#ffffff" : "#a0a0a0"
                            }
                            
                            Text {
                                text: modelData.name
                                font.pixelSize: 15
                                color: sidebar.currentIndex === index ? "#ffffff" : "#a0a0a0"
                                font.bold: sidebar.currentIndex === index
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: sidebar.currentIndex = index
                            hoverEnabled: true
                            
                            onEntered: parent.color = sidebar.currentIndex === index ? "#7c3aed" : "#252542"
                            onExited: parent.color = sidebar.currentIndex === index ? "#7c3aed" : "transparent"
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }
            
            property int currentIndex: 0
        }
        
        // Content area
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            
            ColumnLayout {
                width: Math.min(parent.width * 0.9, 1100)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 56
                anchors.topMargin: 56
                anchors.bottomMargin: 56
                
                // General section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    visible: sidebar.currentIndex === 0
                    
                    Text {
                        text: root.tr("General")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#e0e0e0"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: "#7c3aed"
                        radius: 1
                    }
                    
                    // Startup subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            text: root.tr("Startup")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0e0"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.launchAtStartup : false
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.launchAtStartup = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Launch at system startup")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.startMinimized : false
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.startMinimized = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Start minimized")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.rememberLastSession : false
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.rememberLastSession = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Remember last session")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.restoreLastPlaylist : false
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.restoreLastPlaylist = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Restore last playlist")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                    
                    // Updates subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            text: root.tr("Updates")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0e0"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.autoCheckUpdates : false
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.autoCheckUpdates = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Automatically check for updates")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                            
                            Button {
                                text: root.tr("Check for updates now")
                                Layout.preferredWidth: 180
                                Layout.preferredHeight: 40
                                onClicked: { if (settings) settings.checkForUpdates() }
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.parent.hovered ? "#8b5cf6" : "#7c3aed"
                                    radius: 8
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Language subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 24
                            
                            ColumnLayout {
                                Layout.preferredWidth: 220
                                spacing: 20
                                
                                Text {
                                    text: root.tr("Language")
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#e0e0e0"
                                }
                                
                                Text {
                                    text: root.tr("Restart required if changed")
                                    font.pixelSize: 13
                                    color: "#a0a0a0"
                                    lineHeight: 1.4
                                }
                            }
                            
                            ComboBox {
                                id: languageComboBox
                                Layout.fillWidth: true
                                Layout.maximumWidth: 600
                                Layout.preferredHeight: 48
                                model: ["English", "Spanish", "French", "German", "Japanese"]
                                currentIndex: {
                                    if (!settings) return 0
                                    var index = model.indexOf(settings.language)
                                    return index >= 0 ? index : 0
                                }
                                onActivated: {
                                    if (settings) {
                                        settings.language = currentText
                                        // Force UI update by re-evaluating
                                        Qt.callLater(function() {
                                            languageComboBox.currentIndex = languageComboBox.currentIndex
                                        })
                                    }
                                }
                                
                                background: Rectangle {
                                    color: "#1a1a2e"
                                    radius: 8
                                    border.color: "#3a3a5c"
                                    border.width: 1
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.displayText
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 14
                                }
                            }
                        }
                    }
                    
                    // Notifications subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            text: root.tr("Notifications")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0e0"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.showDesktopNotifications : false
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.showDesktopNotifications = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Show desktop notifications")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.showCurrentlyPlaying : false
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.showCurrentlyPlaying = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Show currently playing track")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
                
                // Library section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    visible: sidebar.currentIndex === 1
                    
                    Text {
                        text: root.tr("Library")
                        font.pixelSize: 22
                        font.bold: true
                        color: "#e0e0e0"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: "#7c3aed"
                        radius: 1
                    }
                    
                    // Music folders subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            text: root.tr("Music Folders")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0e0"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Repeater {
                                model: settings ? settings.musicFolders : []
                                
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12
                                    
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 40
                                        color: "#1a1a2e"
                                        radius: 6
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Text {
                                            anchors.leftMargin: 14
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData
                                            color: "#e0e0e0"
                                            font.pixelSize: 14
                                        }
                                    }
                                    
                                    Button {
                                        text: root.tr("Remove")
                                        Layout.preferredWidth: 80
                                        Layout.preferredHeight: 40
                                        onClicked: settings.removeMusicFolder(modelData)
                                        
                                        contentItem: Text {
                                            text: parent.text
                                            color: "white"
                                            font.pixelSize: 13
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        
                                        background: Rectangle {
                                            color: parent.parent.hovered ? "#ef4444" : "#dc2626"
                                            radius: 6
                                            
                                            Behavior on color {
                                                ColorAnimation { duration: 150 }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Button {
                                    text: root.tr("Add Folder")
                                    Layout.preferredWidth: 120
                                    Layout.preferredHeight: 40
                                    onClicked: settings.browseMusicFolder()
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pixelSize: 14
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    background: Rectangle {
                                        color: parent.parent.hovered ? "#8b5cf6" : "#7c3aed"
                                        radius: 6
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                }
                                
                                Button {
                                    text: root.tr("Scan Now")
                                    Layout.preferredWidth: 100
                                    Layout.preferredHeight: 40
                                    onClicked: settings.scanLibrary()
                                    
                                    contentItem: Text {
                                        text: parent.text
                                        color: "white"
                                        font.pixelSize: 14
                                        font.bold: true
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    
                                    background: Rectangle {
                                        color: parent.parent.hovered ? "#8b5cf6" : "#7c3aed"
                                        radius: 6
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Library management subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            text: root.tr("Library Management")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0e0"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 16
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Switch {
                                    checked: settings ? settings.watchFoldersAutomatically : true
                                    Layout.preferredHeight: 40
                                    onCheckedChanged: { if (settings) settings.watchFoldersAutomatically = checked }
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 44
                                        implicitHeight: 24
                                        radius: 12
                                        color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        Rectangle {
                                            x: parent.parent.checked ? parent.width - width - 2 : 2
                                            y: parent.height / 2 - height / 2
                                            width: 20
                                            height: 20
                                            radius: 10
                                            color: "white"
                                            
                                            Behavior on x {
                                                NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                            }
                                        }
                                    }
                                }
                                
                                Text {
                                    text: root.tr("Watch folders automatically")
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 24
                                
                                ColumnLayout {
                                    Layout.preferredWidth: 220
                                    spacing: 20
                                    
                                    Text {
                                        text: root.tr("Scan frequency")
                                        font.pixelSize: 15
                                        font.bold: true
                                        color: "#e0e0e0"
                                    }
                                    
                                    Text {
                                        text: root.tr("How often to check for changes")
                                        font.pixelSize: 13
                                        color: "#a0a0a0"
                                        lineHeight: 1.4
                                    }
                                }
                                
                                ComboBox {
                                    Layout.fillWidth: true
                                    Layout.maximumWidth: 600
                                    Layout.preferredHeight: 48
                                    model: ["Manual", "Every 15 min", "Every hour"]
                                    currentIndex: {
                                        if (!settings) return 0
                                        var index = model.indexOf(settings.scanFrequency)
                                        return index >= 0 ? index : 0
                                    }
                                    onActivated: {
                                        if (settings) settings.scanFrequency = currentText
                                    }
                                    
                                    background: Rectangle {
                                        color: "#1a1a2e"
                                        radius: 8
                                        border.color: "#3a3a5c"
                                        border.width: 1
                                        
                                        Behavior on border.color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.displayText
                                        color: "#e0e0e0"
                                        font.pixelSize: 14
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 14
                                    }
                                }
                            }
                        }
                    }
                    
                    // Buttons subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            text: root.tr("Actions")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0e0"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Button {
                                text: root.tr("Rescan Library")
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 40
                                onClicked: settings.rescanLibrary()
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.parent.hovered ? "#8b5cf6" : "#7c3aed"
                                    radius: 6
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                            }
                            
                            Button {
                                text: root.tr("Clean Missing Songs")
                                Layout.preferredWidth: 160
                                Layout.preferredHeight: 40
                                onClicked: settings.cleanMissingSongs()
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.parent.hovered ? "#8b5cf6" : "#7c3aed"
                                    radius: 6
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                            }
                            
                            Button {
                                text: root.tr("Rebuild Database")
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 40
                                onClicked: settings.rebuildDatabase()
                                
                                contentItem: Text {
                                    text: parent.text
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.parent.hovered ? "#8b5cf6" : "#7c3aed"
                                    radius: 6
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Statistics subsection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        Text {
                            text: root.tr("Statistics")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e0e0e0"
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: "#252542"
                            radius: 8
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 24
                                spacing: 40
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Text {
                                        text: settings ? settings.libraryStats.songs || "0" : "0"
                                        font.pixelSize: 28
                                        font.bold: true
                                        color: "#7c3aed"
                                    }
                                    
                                    Text {
                                        text: root.tr("Songs")
                                        font.pixelSize: 14
                                        color: "#a0a0a0"
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Text {
                                        text: settings ? settings.libraryStats.albums || "0" : "0"
                                        font.pixelSize: 28
                                        font.bold: true
                                        color: "#7c3aed"
                                    }
                                    
                                    Text {
                                        text: root.tr("Albums")
                                        font.pixelSize: 14
                                        color: "#a0a0a0"
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Text {
                                        text: settings ? settings.libraryStats.artists || "0" : "0"
                                        font.pixelSize: 28
                                        font.bold: true
                                        color: "#7c3aed"
                                    }
                                    
                                    Text {
                                        text: root.tr("Artists")
                                        font.pixelSize: 14
                                        color: "#a0a0a0"
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 8
                                    
                                    Text {
                                        text: settings ? settings.libraryStats.size || "0 B" : "0 B"
                                        font.pixelSize: 28
                                        font.bold: true
                                        color: "#7c3aed"
                                    }
                                    
                                    Text {
                                        text: root.tr("Size")
                                        font.pixelSize: 14
                                        color: "#a0a0a0"
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Audio section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    visible: sidebar.currentIndex === 2
                    
                    Text {
                        text: "Audio"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#e0e0e0"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: "#7c3aed"
                        radius: 1
                    }
                            
                    // Audio backend row
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 24
                            
                            ColumnLayout {
                                Layout.preferredWidth: 220
                                spacing: 20
                                
                                Text {
                                    text: "Audio Backend"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#e0e0e0"
                                }
                                
                                Text {
                                    text: "Choose the playback engine"
                                    font.pixelSize: 13
                                    color: "#a0a0a0"
                                    lineHeight: 1.4
                                }
                            }
                            
                            ComboBox {
                                Layout.fillWidth: true
                                Layout.maximumWidth: 600
                                Layout.preferredHeight: 48
                                model: ["MPV (Recommended)", "GStreamer"]
                                
                                background: Rectangle {
                                    color: "#1a1a2e"
                                    radius: 8
                                    border.color: "#3a3a5c"
                                    border.width: 1
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.displayText
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 14
                                }
                            }
                        }
                    }
                            
                    // Output device row
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 24
                            
                            ColumnLayout {
                                Layout.preferredWidth: 220
                                spacing: 20
                                
                                Text {
                                    text: "Output Device"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#e0e0e0"
                                }
                                
                                Text {
                                    text: "Select your audio output"
                                    font.pixelSize: 13
                                    color: "#a0a0a0"
                                    lineHeight: 1.4
                                }
                            }
                            
                            ComboBox {
                                Layout.fillWidth: true
                                Layout.maximumWidth: 600
                                Layout.preferredHeight: 48
                                model: ["Default", "PulseAudio", "PipeWire", "ALSA"]
                                
                                background: Rectangle {
                                    color: "#1a1a2e"
                                    radius: 8
                                    border.color: "#3a3a5c"
                                    border.width: 1
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.displayText
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 14
                                }
                            }
                        }
                    }
                            
                    // Buffer size row
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 24
                            
                            ColumnLayout {
                                Layout.preferredWidth: 220
                                spacing: 20
                                
                                Text {
                                    text: "Buffer Size"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#e0e0e0"
                                }
                                
                                Text {
                                    text: "Lower = less latency, higher = more stable"
                                    font.pixelSize: 13
                                    color: "#a0a0a0"
                                    lineHeight: 1.4
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: 600
                                spacing: 16
                                
                                Slider {
                                    Layout.fillWidth: true
                                    from: 256
                                    to: 8192
                                    value: 2048
                                    
                                    background: Rectangle {
                                        color: "#1a1a2e"
                                        radius: 4
                                        height: 6
                                    }
                                    
                                    handle: Rectangle {
                                        x: parent.visualPosition * parent.width - width / 2
                                        y: parent.height / 2 - height / 2
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: "#7c3aed"
                                    }
                                }
                                
                                Text {
                                    text: "2048 KB"
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                    Layout.preferredWidth: 90
                                }
                            }
                        }
                    }
                }
                
                // Appearance section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    visible: sidebar.currentIndex === 3
                    
                    Text {
                        text: "Appearance"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#e0e0e0"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: "#7c3aed"
                        radius: 1
                    }
                            
                    // Theme row
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 24
                            
                            ColumnLayout {
                                Layout.preferredWidth: 220
                                spacing: 20
                                
                                Text {
                                    text: "Theme"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#e0e0e0"
                                }
                                
                                Text {
                                    text: "Choose your color scheme"
                                    font.pixelSize: 13
                                    color: "#a0a0a0"
                                    lineHeight: 1.4
                                }
                            }
                            
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.maximumWidth: 600
                                spacing: 14
                                
                                Repeater {
                                    model: [
                                        { name: "Dark", color: "#1a1a2e" },
                                        { name: "Light", color: "#f5f5f5" },
                                        { name: "Midnight", color: "#0f0f1a" },
                                        { name: "Aurora", color: "#7c3aed" }
                                    ]
                                    
                                    Rectangle {
                                        Layout.preferredWidth: 64
                                        Layout.preferredHeight: 64
                                        radius: 10
                                        color: modelData.color
                                        border.color: "#3a3a5c"
                                        border.width: 2
                                        
                                        Behavior on border.color {
                                            ColorAnimation { duration: 150 }
                                        }
                                        
                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 6
                                            
                                            Rectangle {
                                                Layout.preferredWidth: 22
                                                Layout.preferredHeight: 22
                                                radius: 11
                                                color: "#252542"
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            
                                            Text {
                                                text: modelData.name
                                                color: modelData.name === "Light" ? "#1a1a2e" : "#e0e0e0"
                                                font.pixelSize: 11
                                                font.bold: true
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: console.log("Selected theme:", modelData.name)
                                            hoverEnabled: true
                                            
                                            onEntered: parent.border.color = "#7c3aed"
                                            onExited: parent.border.color = "#3a3a5c"
                                        }
                                    }
                                }
                            }
                        }
                    }
                            
                    // Animated backgrounds row
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 20
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 24
                            
                            ColumnLayout {
                                Layout.preferredWidth: 220
                                spacing: 20
                                
                                Text {
                                    text: "Animated Backgrounds"
                                    font.pixelSize: 15
                                    font.bold: true
                                    color: "#e0e0e0"
                                }
                                
                                Text {
                                    text: "Enable subtle background animations"
                                    font.pixelSize: 13
                                    color: "#a0a0a0"
                                    lineHeight: 1.4
                                }
                            }
                            
                            Switch {
                                checked: true
                                Layout.preferredHeight: 48
                                
                                contentItem: Text {
                                    text: parent.checked ? "Enabled" : "Disabled"
                                    color: "#e0e0e0"
                                    font.pixelSize: 14
                                    leftPadding: parent.indicator.width + 12
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                indicator: Rectangle {
                                    implicitWidth: 50
                                    implicitHeight: 28
                                    radius: 14
                                    color: parent.checked ? "#7c3aed" : "#1a1a2e"
                                    border.color: "#3a3a5c"
                                    border.width: 1
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                    
                                    Rectangle {
                                        x: parent.parent.checked ? parent.width - width - 2 : 2
                                        y: parent.height / 2 - height / 2
                                        width: 22
                                        height: 22
                                        radius: 11
                                        color: "white"
                                        
                                        Behavior on x {
                                            NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Placeholder sections
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    visible: sidebar.currentIndex === 4 || sidebar.currentIndex === 5
                    
                    Text {
                        text: sidebar.currentIndex === 4 ? "Playback" : "Advanced"
                        font.pixelSize: 22
                        font.bold: true
                        color: "#e0e0e0"
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: "#7c3aed"
                        radius: 1
                    }
                    
                    Text {
                        text: "Coming soon"
                        color: "#666688"
                        font.pixelSize: 16
                        Layout.topMargin: 40
                    }
                }
                
                Item { Layout.preferredHeight: 20 }
            }
        }
    }
}
