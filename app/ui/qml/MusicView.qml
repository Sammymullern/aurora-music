import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    color: "#1a1a2e"
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 24
        
        // Header
        Text {
            text: "Music"
            font.pixelSize: 32
            font.bold: true
            color: "#e0e0e0"
        }
        
        // Search and controls row
        RowLayout {
            Layout.fillWidth: true
            spacing: 16
            
            // Search bar
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "#252542"
                radius: 8
                border.color: "#3a3a5c"
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12
                    
                    Text {
                        text: "🔍"
                        font.pixelSize: 16
                        color: "#a0a0a0"
                    }
                    
                    TextField {
                        Layout.fillWidth: true
                        placeholderText: "Search..."
                        background: Rectangle {
                            color: "transparent"
                        }
                        color: "#e0e0e0"
                        font.pixelSize: 14
                        onTextChanged: {
                            if (musicManager) musicManager.setSearchQuery(text)
                        }
                    }
                }
            }
            
            // Sort dropdown
            ComboBox {
                Layout.preferredWidth: 140
                Layout.preferredHeight: 40
                model: ["A-Z", "Z-A", "Recently Added", "Most Played"]
                currentIndex: 0
                
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
            
            // View toggle
            Row {
                spacing: 8
                
                Rectangle {
                    width: 36
                    height: 36
                    radius: 6
                    color: "#7c3aed"
                    
                    Text {
                        anchors.centerIn: parent
                        text: "▢"
                        font.pixelSize: 16
                        color: "white"
                    }
                }
                
                Rectangle {
                    width: 36
                    height: 36
                    radius: 6
                    color: "#252542"
                    border.color: "#3a3a5c"
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "☰"
                        font.pixelSize: 16
                        color: "#a0a0a0"
                    }
                }
            }
        }
        
        // Filters
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            property string currentFilter: "all"
            
            Repeater {
                model: ["All", "Favorites", "Recently Added", "High Rating"]
                
                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 36
                    radius: 18
                    color: parent.currentFilter === modelData.toLowerCase().replace(" ", "_") ? "#7c3aed" : "#252542"
                    border.color: parent.currentFilter === modelData.toLowerCase().replace(" ", "_") ? "#7c3aed" : "#3a3a5c"
                    border.width: parent.currentFilter === modelData.toLowerCase().replace(" ", "_") ? 0 : 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 13
                        font.bold: parent.currentFilter === modelData.toLowerCase().replace(" ", "_")
                        color: parent.currentFilter === modelData.toLowerCase().replace(" ", "_") ? "white" : "#a0a0a0"
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            parent.parent.currentFilter = modelData.toLowerCase().replace(" ", "_")
                            if (musicManager) musicManager.setFilter(modelData.toLowerCase().replace(" ", "_"))
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
            
            Item { Layout.fillWidth: true }
        }
        
        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: "#3a3a5c"
        }
        
        // Songs count
        Text {
            text: musicManager ? "Songs (" + musicManager.songCount + ")" : "Songs (0)"
            font.pixelSize: 16
            font.bold: true
            color: "#e0e0e0"
        }
        
        // Songs table
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#252542"
            radius: 8
            border.color: "#3a3a5c"
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Table header
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: "#1a1a2e"
                    radius: 8
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 16
                        
                        Text {
                            Layout.preferredWidth: 300
                            text: "Title"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#a0a0a0"
                        }
                        
                        Text {
                            Layout.preferredWidth: 200
                            text: "Artist"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#a0a0a0"
                        }
                        
                        Text {
                            Layout.preferredWidth: 200
                            text: "Album"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#a0a0a0"
                        }
                        
                        Text {
                            Layout.preferredWidth: 80
                            text: "Duration"
                            font.pixelSize: 13
                            font.bold: true
                            color: "#a0a0a0"
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                // Table rows (placeholder)
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 0
                        
                        // Empty state
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: "transparent"
                            visible: musicManager && musicManager.songs.length === 0
                            
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 16
                                
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "🎵"
                                    font.pixelSize: 64
                                    color: "#3a3a5c"
                                }
                                
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "No songs found"
                                    font.pixelSize: 18
                                    color: "#a0a0a0"
                                }
                                
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: "Try a different search or add music to your library"
                                    font.pixelSize: 14
                                    color: "#606080"
                                }
                            }
                        }
                        
                        Repeater {
                            model: musicManager ? musicManager.songs : []
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                color: "#252542"
                                property bool isHovered: false
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 16
                                    anchors.rightMargin: 16
                                    spacing: 16
                                    
                                    Text {
                                        Layout.preferredWidth: 300
                                        text: modelData.title || "Unknown"
                                        font.pixelSize: 14
                                        color: "#e0e0e0"
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        Layout.preferredWidth: 200
                                        text: modelData.artist || "Unknown"
                                        font.pixelSize: 14
                                        color: "#a0a0a0"
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        Layout.preferredWidth: 200
                                        text: modelData.album || "Unknown"
                                        font.pixelSize: 14
                                        color: "#a0a0a0"
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        Layout.preferredWidth: 80
                                        text: modelData.duration || "0:00"
                                        font.pixelSize: 14
                                        color: "#a0a0a0"
                                    }
                                    
                                    // Heart button for favorites
                                    Rectangle {
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        radius: 16
                                        color: modelData.favorite ? "#ff6b6b" : "transparent"
                                        visible: parent.parent.isHovered || modelData.favorite
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.favorite ? "♥" : "♡"
                                            font.pixelSize: 18
                                            color: modelData.favorite ? "white" : "#a0a0a0"
                                        }
                                        
                                        MouseArea {
                                            anchors.fill: parent
                                            onClicked: {
                                                if (musicManager) musicManager.toggleFavorite(modelData.id)
                                            }
                                        }
                                    }
                                    
                                    Item { Layout.fillWidth: true }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: {
                                        parent.color = "#2a2a4a"
                                        parent.isHovered = true
                                    }
                                    onExited: {
                                        parent.color = "#252542"
                                        parent.isHovered = false
                                    }
                                    onClicked: {
                                        if (musicManager) musicManager.playSong(modelData.id)
                                    }
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }
}
