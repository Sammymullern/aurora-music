import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    visible: true
    width: 1400
    height: 900
    color: "#1a1a2e"
    
    // Glassmorphism effect
    property color glassColor: "#252542"
    property color glassBorder: "#3a3a5c"
    property real glassOpacity: 0.7
    
    RowLayout {
        anchors.fill: parent
        spacing: 0
        
        // Sidebar
        Sidebar {
            id: sidebar
            Layout.preferredWidth: 250
            Layout.fillHeight: true
        }
        
        // Main content area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#1a1a2e"
            
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                
                // Top bar
                TopBar {
                    id: topBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                }
                
                // Content area
                StackLayout {
                    id: contentStack
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    
                    // Library view
                    LibraryView {
                        id: libraryView
                    }
                    
                    // Now playing view
                    NowPlayingView {
                        id: nowPlayingView
                    }
                    
                    // Playlists view
                    PlaylistsView {
                        id: playlistsView
                    }
                    
                    // Settings view
                    SettingsView {
                        id: settingsView
                    }
                }
                
                // Player controls
                PlayerControls {
                    id: playerControls
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                }
            }
        }
    }
}
