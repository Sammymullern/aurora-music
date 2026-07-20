import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.width
            spacing: 20
            anchors.margins: 20
            
            Text {
                text: "Settings"
                font.pixelSize: 28
                font.bold: true
                color: "#e0e0e0"
            }
            
            // Music library section
            SettingsSection {
                title: "Music Library"
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "Library folders:"
                        color: "#e0e0e0"
                        font.pixelSize: 14
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "/path/to/music"
                        background: Rectangle {
                            color: "#252542"
                            radius: 8
                        }
                        color: "#e0e0e0"
                    }
                    
                    Button {
                        text: "Browse"
                        background: Rectangle {
                            color: "#7c3aed"
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
            
            // Audio section
            SettingsSection {
                title: "Audio"
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    Text {
                        text: "Audio backend:"
                        color: "#e0e0e0"
                        font.pixelSize: 14
                        Layout.preferredWidth: 120
                    }
                    
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["MPV", "GStreamer"]
                        background: Rectangle {
                            color: "#252542"
                            radius: 8
                        }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    Text {
                        text: "Output device:"
                        color: "#e0e0e0"
                        font.pixelSize: 14
                        Layout.preferredWidth: 120
                    }
                    
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Default", "PulseAudio", "PipeWire", "ALSA"]
                        background: Rectangle {
                            color: "#252542"
                            radius: 8
                        }
                    }
                }
            }
            
            // Appearance section
            SettingsSection {
                title: "Appearance"
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 20
                    
                    Text {
                        text: "Theme:"
                        color: "#e0e0e0"
                        font.pixelSize: 14
                        Layout.preferredWidth: 120
                    }
                    
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["Dark", "Light", "Midnight", "Aurora"]
                        background: Rectangle {
                            color: "#252542"
                            radius: 8
                        }
                    }
                }
            }
        }
    }
}
