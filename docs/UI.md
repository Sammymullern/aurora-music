# User Interface Documentation

## Overview

Aurora Music features a modern, glassmorphism-inspired UI built with PySide6 and QML. The interface is designed to be intuitive, responsive, and visually appealing with a dark purple theme.

## Design System

### Colors

- **Primary**: `#7c3aed` (Purple)
- **Background**: `#1a1a2e` (Dark Blue)
- **Secondary Background**: `#252542` (Lighter Dark Blue)
- **Accent**: `#2a2a4a` (Medium Dark Blue)
- **Text**: `#e0e0e0` (Light Gray)
- **Muted Text**: `#a0a0a0` (Gray)
- **Error**: `#ef4444` (Red)
- **Success**: `#10b981` (Green)

### Typography

- **Headings**: 24-36px, bold
- **Body**: 14-16px, regular
- **Small**: 12-13px, regular
- **Font Family**: System default (sans-serif)

### Components

#### Buttons

- **Primary**: Purple background (`#7c3aed`), rounded corners (radius: 25)
- **Secondary**: Gray background (`#4a4a6a`), rounded corners
- **Icon**: Circular buttons (radius: 20) for actions
- **Hover Effects**: Color darkening on hover

#### Dialogs

- **Size**: Compact (350x180-400px)
- **Background**: Dark with purple/red border
- **Radius**: 12px
- **Header**: Title with X close button
- **Spacing**: 15-20px margins

#### Cards

- **Playlist Card**: 190x240px, rounded corners (12px)
- **Gradient**: Pink to purple gradient for album art placeholder
- **Hover**: Color darkening effect
- **Actions**: 3-dotted menu button in bottom-right corner

#### Lists

- **Spacing**: 5-8px between items
- **Height**: 70-76px per track item
- **Radius**: 8px per item
- **Current Track**: Highlighted background (`#2a2a4a`)
- **Hover**: Subtle color change

## Views

### Main Window

The main window features a sidebar navigation with the following sections:
- **Library**: Browse your music collection
- **Playlists**: Manage and view playlists
- **Now Playing**: Current playback view
- **Settings**: Application configuration

### Library View

- **Filters**: Artist, Album, Genre, Year, Mood, BPM, Bitrate
- **Search**: Instant search across library
- **Grid/List Toggle**: Switch between grid and list views
- **Sort Options**: By name, date added, duration, etc.

### Playlist View

#### Playlist Detail View

**Hero Section:**
- Album art with gradient background
- Playlist name (large, bold)
- Song count and total duration
- Play, Shuffle, and Add Tracks buttons
- Separator line

**Track List:**
- Track number or play icon for currently playing
- Track title and artist/album info
- Duration
- Right-click context menu (Play, Remove)
- Current song indicator (purple highlight)
- Empty state with add songs button

**Bottom Stats Bar:**
- Song count
- Total duration
- Non-clickable display

#### Playlist Card

- Album art placeholder with gradient
- Playlist name
- Track count
- 3-dotted settings button (bottom-right)
- Hover effects
- Click to open playlist detail

### Add Tracks Dialog

**Layout:**
- Two-panel design (Available Songs | Selected Songs)
- Search bar for filtering available tracks
- Track items with add/remove buttons
- Bottom buttons (Cancel, Add X Tracks)
- Empty state for no search results

**Features:**
- Search by title, artist, or album
- Add multiple tracks at once
- Remove tracks from selection
- Real-time track count update

### Settings Dialogs

#### Edit Playlist Dialog
- Compact size (350x200)
- Playlist name input only
- X close button
- Save button
- Purple border

#### Delete Confirmation Dialog
- Compact size (350x180)
- Warning message
- Cancel and Delete buttons
- Red border for warning
- Delete button in red

## Interactions

### Mouse Interactions

- **Left Click**: Play track, open playlist, select item
- **Right Click**: Open context menu
- **Hover**: Visual feedback (color darkening)
- **Double Click**: Play track (in some views)

### Keyboard Shortcuts

| Key | Action |
|-----|--------|
| Space | Play/Pause |
| → | Next track |
| ← | Previous track |
| ↑ | Volume up |
| ↓ | Volume down |
| F | Fullscreen |
| Ctrl+F | Focus search |
| Ctrl+Q | Quit |
| Ctrl+N | New playlist |
| Ctrl+P | Preferences |

## Context Menus

### Track Context Menu
- **Play**: Start playing the selected track
- **Remove from Playlist**: Remove track from current playlist

### Playlist Card Context Menu
- **Edit**: Open edit dialog to rename playlist
- **Delete**: Open delete confirmation dialog

## Responsive Design

The UI adapts to different window sizes:
- Minimum window size: 1024x768
- Grid layouts use flexible spacing
- Scrollable areas for large content
- Dynamic button sizing

## Accessibility

- High contrast colors for readability
- Clear visual hierarchy
- Keyboard navigation support
- Screen reader compatible labels
- Focus indicators on interactive elements

## Performance

- Lazy loading of large lists
- Efficient model updates
- Minimal repaints with QML optimizations
- Smooth animations with hardware acceleration
