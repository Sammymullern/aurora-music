import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        
        ColumnLayout {
            width: parent.width
            spacing: 30
            anchors.margins: 40
            anchors.topMargin: 30
            anchors.bottomMargin: 30
            
            // Header
            Text {
                text: "Settings"
                font.pixelSize: 36
                font.bold: true
                color: "#e0e0e0"
                Layout.bottomMargin: 10
            }
            
            // Music library section
            SettingsSection {
                title: "Music Library"
                Layout.fillWidth: true
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    // Library folder input
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Library folders"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "Add folders containing your music files"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "/path/to/music"
                                placeholderTextColor: "#666688"
                                background: Rectangle {
                                    color: "#252542"
                                    radius: 8
                                    border.color: "#3a3a5c"
                                    border.width: 1
                                }
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                padding: 12
                            }
                            
                            Button {
                                text: "Browse"
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 44
                                
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
                                }
                            }
                        }
                    }
                    
                    // Library folders list
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 150
                        color: "#16162b"
                        radius: 8
                        border.color: "#3a3a5c"
                        border.width: 1
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8
                            
                            Text {
                                text: "No folders added yet"
                                color: "#666688"
                                font.pixelSize: 13
                                Layout.alignment: Qt.AlignHCenter
                                Layout.topMargin: 40
                            }
                        }
                    }
                }
            }
            
            // Audio section
            SettingsSection {
                title: "Audio"
                Layout.fillWidth: true
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 25
                    
                    // Audio backend
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Audio backend"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "Choose the audio playback engine"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            model: ["MPV (Recommended)", "GStreamer"]
                            
                            background: Rectangle {
                                color: "#252542"
                                radius: 8
                                border.color: "#3a3a5c"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                            }
                        }
                    }
                    
                    // Output device
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Output device"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "Select your audio output device"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            model: ["Default", "PulseAudio", "PipeWire", "ALSA"]
                            
                            background: Rectangle {
                                color: "#252542"
                                radius: 8
                                border.color: "#3a3a5c"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                            }
                        }
                    }
                    
                    // Buffer size
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Buffer size"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "Adjust for performance vs latency (lower = less latency)"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20
                            
                            Slider {
                                Layout.fillWidth: true
                                from: 256
                                to: 8192
                                value: 2048
                                
                                background: Rectangle {
                                    color: "#252542"
                                    radius: 4
                                    height: 6
                                }
                                
                                handle: Rectangle {
                                    x: parent.visualPosition * parent.width - width / 2
                                    y: parent.height / 2 - height / 2
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: "#7c3aed"
                                }
                            }
                            
                            Text {
                                text: "2048 samples"
                                color: "#e0e0e0"
                                font.pixelSize: 13
                                Layout.preferredWidth: 100
                            }
                        }
                    }
                }
            }
            
            // Appearance section
            SettingsSection {
                title: "Appearance"
                Layout.fillWidth: true
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 25
                    
                    // Theme selection
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Theme"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "Choose your preferred color scheme"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 15
                            
                            Repeater {
                                model: [
                                    { name: "Dark", color: "#1a1a2e" },
                                    { name: "Light", color: "#f5f5f5" },
                                    { name: "Midnight", color: "#0f0f1a" },
                                    { name: "Aurora", color: "#7c3aed" }
                                ]
                                
                                Rectangle {
                                    Layout.preferredWidth: 80
                                    Layout.preferredHeight: 80
                                    radius: 12
                                    color: modelData.color
                                    border.color: "#3a3a5c"
                                    border.width: 2
                                    
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 5
                                        
                                        Rectangle {
                                            Layout.preferredWidth: 30
                                            Layout.preferredHeight: 30
                                            radius: 15
                                            color: "#252542"
                                            Layout.alignment: Qt.AlignHCenter
                                        }
                                        
                                        Text {
                                            text: modelData.name
                                            color: modelData.name === "Light" ? "#1a1a2e" : "#e0e0e0"
                                            font.pixelSize: 12
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
                    
                    // Animated backgrounds
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Animated backgrounds"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "Enable subtle background animations"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            checked: true
                            
                            contentItem: Text {
                                text: parent.checked ? "Enabled" : "Disabled"
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                leftPadding: parent.indicator.width + 10
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 26
                                radius: 13
                                color: parent.checked ? "#7c3aed" : "#252542"
                                border.color: "#3a3a5c"
                                border.width: 1
                                
                                Rectangle {
                                    x: parent.parent.checked ? parent.width - width - 3 : 3
                                    y: parent.height / 2 - height / 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "white"
                                }
                            }
                        }
                    }
                }
            }
            
            // Library management section
            SettingsSection {
                title: "Library Management"
                Layout.fillWidth: true
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 25
                    
                    // Watch folders
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Watch folders"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "Automatically monitor folders for new files"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            checked: true
                            
                            contentItem: Text {
                                text: parent.checked ? "Enabled" : "Disabled"
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                leftPadding: parent.indicator.width + 10
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 26
                                radius: 13
                                color: parent.checked ? "#7c3aed" : "#252542"
                                border.color: "#3a3a5c"
                                border.width: 1
                                
                                Rectangle {
                                    x: parent.parent.checked ? parent.width - width - 3 : 3
                                    y: parent.height / 2 - height / 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: "white"
                                }
                            }
                        }
                    }
                    
                    // Scan frequency
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Scan frequency"
                            color: "#e0e0e0"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        
                        Text {
                            text: "How often to check for new files"
                            color: "#a0a0a0"
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            model: ["Every 5 minutes", "Every 15 minutes", "Every 30 minutes", "Every hour"]
                            
                            background: Rectangle {
                                color: "#252542"
                                radius: 8
                                border.color: "#3a3a5c"
                                border.width: 1
                            }
                            
                            contentItem: Text {
                                text: parent.displayText
                                color: "#e0e0e0"
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                            }
                        }
                    }
                }
            }
            
            // Bottom spacing
            Item { Layout.preferredHeight: 20 }
        }
    }
}
