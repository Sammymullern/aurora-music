import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: theme.background
    
    // Custom translation function that forces re-evaluation
    function tr(sourceText) {
        // Access translation.emptyString to create dependency
        var dummy = translation ? translation.emptyString : ""
        return qsTr(sourceText)
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 104
            color: theme.background

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 36
                anchors.rightMargin: 36
                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    Text {
                        text: root.tr("Settings")
                        color: theme.textPrimary
                        font.pixelSize: 30
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: root.tr("Tune Aurora Music to your listening setup")
                        color: theme.textSecondary
                        font.pixelSize: 14
                    }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            topPadding: 32
            bottomPadding: 48

            ColumnLayout {
                width: Math.min(parent.width * 0.94, 1100)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24
                
                // General section
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: generalCardContent.implicitHeight + 48
                    radius: 16
                    color: theme.surface
                    border.color: theme.border
                    border.width: 1

                    ColumnLayout {
                        id: generalCardContent
                        anchors.fill: parent
                        anchors.margins: 24

ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    
                    Text {
                        text: root.tr("General")
                        font.pixelSize: 22
                        font.bold: true
                        color: theme.textPrimary
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: theme.primary
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
                            color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
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
                            color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
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
                                    color: parent.parent.hovered ? theme.primaryLight : theme.primary
                                    radius: 8
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                            }

                            Text {
                                text: settings ? settings.updateStatus : ""
                                color: theme.textSecondary
                                font.pixelSize: 12
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
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
                                    color: theme.textPrimary
                                }
                                
                                Text {
                                    text: root.tr("Restart required if changed")
                                    font.pixelSize: 13
                                    color: theme.textSecondary
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
                                    if (settings) settings.language = currentText
                                }
                                
                                background: Rectangle {
                                    color: theme.background
                                    radius: 8
                                    border.color: theme.border
                                    border.width: 1
                                    
                                    Behavior on border.color {
                                        ColorAnimation { duration: 150 }
                                    }
                                }
                                
                                contentItem: Text {
                                    text: parent.displayText
                                    color: theme.textPrimary
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
                            color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
                    }
                }
                
                // Library section
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: libraryCardContent.implicitHeight + 48
                    radius: 16
                    color: theme.surface
                    border.color: theme.border
                    border.width: 1

                    ColumnLayout {
                        id: libraryCardContent
                        anchors.fill: parent
                        anchors.margins: 24

ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    
                    Text {
                        text: root.tr("Library")
                        font.pixelSize: 22
                        font.bold: true
                        color: theme.textPrimary
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: theme.primary
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
                            color: theme.textPrimary
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
                                        color: theme.background
                                        radius: 6
                                        border.color: theme.border
                                        border.width: 1
                                        
                                        Text {
                                            anchors.leftMargin: 14
                                            anchors.verticalCenter: parent.verticalCenter
                                            text: modelData
                                            color: theme.textPrimary
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
                                        color: parent.parent.hovered ? theme.primaryLight : theme.primary
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
                            color: theme.textPrimary
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
                                        color: parent.checked ? theme.primary : theme.background
                                        border.color: theme.border
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
                                    color: theme.textPrimary
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
                                        color: theme.textPrimary
                                    }
                                    
                                    Text {
                                        text: root.tr("New tracks are also picked up as soon as they appear")
                                        font.pixelSize: 13
                                        color: theme.textSecondary
                                        lineHeight: 1.4
                                    }
                                }
                                
                                ComboBox {
                                    Layout.fillWidth: true
                                    Layout.maximumWidth: 600
                                    Layout.preferredHeight: 48
                                    model: ["Every 5 min", "Every 15 min", "Every hour"]
                                    currentIndex: {
                                        if (!settings) return 0
                                        var index = model.indexOf(settings.scanFrequency)
                                        return index >= 0 ? index : 0
                                    }
                                    onActivated: {
                                        if (settings) settings.scanFrequency = currentText
                                    }
                                    
                                    background: Rectangle {
                                        color: theme.background
                                        radius: 8
                                        border.color: theme.border
                                        border.width: 1
                                        
                                        Behavior on border.color {
                                            ColorAnimation { duration: 150 }
                                        }
                                    }
                                    
                                    contentItem: Text {
                                        text: parent.displayText
                                        color: theme.textPrimary
                                        font.pixelSize: 14
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 14
                                    }
                                }
                            }
                        }
                    }
                    
                }
                    }
                }

                // Audio preferences
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: audioCardContent.implicitHeight + 48
                    radius: 16
                    color: theme.surface
                    border.color: theme.border
                    border.width: 1

                    ColumnLayout {
                        id: audioCardContent
                        anchors.fill: parent
                        anchors.margins: 24

ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 24

                    Text {
                        text: "Audio"
                        font.pixelSize: 22
                        font.bold: true
                        color: theme.textPrimary
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: theme.border
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 24
                        ColumnLayout {
                            Layout.preferredWidth: 220
                            spacing: 6
                            Text { text: "Playback engine"; font.pixelSize: 15; font.bold: true; color: theme.textPrimary }
                            Text { text: "Aurora uses MPV for reliable playback."; font.pixelSize: 13; color: theme.textSecondary; wrapMode: Text.WordWrap }
                        }
                        Text {
                            text: "MPV"
                            color: theme.primary
                            font.pixelSize: 14
                            font.bold: true
                            Layout.preferredWidth: 180
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 24
                        ColumnLayout {
                            Layout.preferredWidth: 220
                            spacing: 6
                            Text { text: "Output device"; font.pixelSize: 15; font.bold: true; color: theme.textPrimary }
                            Text { text: "Choose an output detected by MPV."; font.pixelSize: 13; color: theme.textSecondary; wrapMode: Text.WordWrap }
                        }
                        ComboBox {
                            id: outputDeviceCombo
                            Layout.fillWidth: true
                            Layout.maximumWidth: 600
                            Layout.preferredHeight: 46
                            model: player ? player.audioDevices : []
                            textRole: "description"
                            valueRole: "name"
                            currentIndex: {
                                if (!settings || !player) return 0
                                for (var i = 0; i < player.audioDevices.length; ++i)
                                    if (player.audioDevices[i].name === settings.outputDevice) return i
                                return 0
                            }
                            onActivated: if (settings) settings.outputDevice = currentValue
                            background: Rectangle {
                                color: theme.surface
                                radius: 10
                                border.color: theme.border
                            }
                            contentItem: Text {
                                text: outputDeviceCombo.displayText
                                color: theme.textPrimary
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 14
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 24
                        ColumnLayout {
                            Layout.preferredWidth: 220
                            spacing: 6
                            Text { text: "Audio buffer"; font.pixelSize: 15; font.bold: true; color: theme.textPrimary }
                            Text { text: "Smaller buffers reduce latency; larger buffers can improve stability."; font.pixelSize: 13; color: theme.textSecondary; wrapMode: Text.WordWrap }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.maximumWidth: 600
                            spacing: 16
                            Slider {
                                id: audioBufferSlider
                                Layout.fillWidth: true
                                from: 0.05
                                to: 2.0
                                stepSize: 0.05
                                value: settings ? settings.audioBuffer : 0.2
                                onValueChanged: if (settings) settings.audioBuffer = value
                                background: Rectangle {
                                    x: audioBufferSlider.leftPadding
                                    y: audioBufferSlider.topPadding + audioBufferSlider.availableHeight / 2 - height / 2
                                    width: audioBufferSlider.availableWidth
                                    height: 5
                                    radius: 3
                                    color: theme.surfaceVariant
                                    Rectangle { width: audioBufferSlider.visualPosition * parent.width; height: parent.height; radius: 3; color: theme.primary }
                                }
                                handle: Rectangle {
                                    x: audioBufferSlider.leftPadding + audioBufferSlider.visualPosition * audioBufferSlider.availableWidth - width / 2
                                    y: audioBufferSlider.topPadding + audioBufferSlider.availableHeight / 2 - height / 2
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: "white"
                                    border.color: theme.primary
                                }
                            }
                            Text {
                                text: Math.round(audioBufferSlider.value * 1000) + " ms"
                                color: theme.textPrimary
                                font.pixelSize: 14
                                Layout.preferredWidth: 64
                            }
                        }
                    }
                }
                    }
                }

                // Appearance section
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: appearanceCardContent.implicitHeight + 48
                    radius: 16
                    color: theme.surface
                    border.color: theme.border
                    border.width: 1

                    ColumnLayout {
                        id: appearanceCardContent
                        anchors.fill: parent
                        anchors.margins: 24

ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 28
                    
                    Text {
                        text: "Appearance"
                        font.pixelSize: 22
                        font.bold: true
                        color: theme.textPrimary
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        color: theme.primary
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
                                    color: theme.textPrimary
                                }
                                
                                Text {
                                    text: "Choose your color scheme"
                                    font.pixelSize: 13
                                    color: theme.textSecondary
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
                                        { name: "Aurora", color: theme.primary }
                                    ]
                                    
                                    Rectangle {
                                        Layout.preferredWidth: 64
                                        Layout.preferredHeight: 64
                                        radius: 10
                                        color: modelData.color
                                        border.color: settings && settings.theme === modelData.name ? theme.primary : theme.border
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
                                                color: theme.surface
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                            
                                            Text {
                                                text: modelData.name
                                                color: modelData.name === "Light" ? "#1a1a2e" : "#ffffff"
                                                font.pixelSize: 11
                                                font.bold: true
                                                Layout.alignment: Qt.AlignHCenter
                                            }
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: if (settings) settings.theme = modelData.name
                                            hoverEnabled: true
                                            
                                            onEntered: parent.border.color = theme.primary
                                            onExited: parent.border.color = settings && settings.theme === modelData.name ? theme.primary : theme.border
                                        }
                                    }
                                }
                            }
                        }
                    }
                            

                }
                    }
                }
                
                Item { Layout.preferredHeight: 20 }
            }
        }
    }
}
