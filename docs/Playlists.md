# Playlist System Documentation

## Overview

The playlist system in Aurora Music provides comprehensive playlist management capabilities including creation, editing, deletion, and track management. The system is built with a modern UI and efficient backend operations.

## Features

### Playlist Management

- **Create Playlists**: Create new playlists with custom names
- **Edit Playlists**: Rename playlists via the edit dialog
- **Delete Playlists**: Remove playlists with confirmation
- **Track Management**: Add, remove, and reorder tracks
- **Statistics**: View song count and total duration
- **Shuffle Play**: Randomize playlist order without repeats

### Playlist Views

#### Playlist List View

The playlist list view displays all playlists in a grid layout:

**Features:**
- Grid layout with playlist cards
- Each card shows:
  - Album art placeholder (gradient)
  - Playlist name
  - Track count
  - 3-dotted settings button
- Hover effects on cards
- Right-click context menu for actions
- Empty state when no playlists exist

**Actions:**
- **Click**: Open playlist detail view
- **3-dotted button**: Open context menu (Edit, Delete)
- **Right-click**: Open context menu

#### Playlist Detail View

The playlist detail view shows all tracks in a playlist:

**Hero Section:**
- Album art with gradient background
- Playlist name (large, bold)
- Song count and total duration
- Play button: Plays first track in order
- Shuffle button: Randomizes and plays first track
- Add Tracks button: Opens add tracks dialog
- Separator line

**Track List:**
- Track number or play icon for currently playing
- Track title and artist/album info
- Duration
- Current song indicator (purple highlight)
- Right-click context menu (Play, Remove)
- Empty state with add songs button

**Bottom Stats Bar:**
- Song count
- Total duration
- Non-clickable display

## Dialogs

### Add Tracks Dialog

**Layout:**
- Two-panel design (Available Songs | Selected Songs)
- Search bar for filtering available tracks
- Track items with add/remove buttons
- Bottom buttons (Cancel, Add X Tracks)

**Features:**
- Search by title, artist, or album
- Add multiple tracks at once
- Remove tracks from selection
- Real-time track count update
- Empty state for no search results

**Search Functionality:**
- Filters available tracks by title, artist, or album
- Case-insensitive search
- Real-time filtering as you type
- Shows empty state when no matches found

### Edit Playlist Dialog

**Layout:**
- Compact size (350x200)
- Dark background with purple border
- Header with title and X close button
- Playlist name input field
- Save button

**Features:**
- Pre-fills with current playlist name
- Updates playlist name in database
- Refreshes UI to show new name
- Closes dialog on save

### Delete Confirmation Dialog

**Layout:**
- Compact size (350x180)
- Dark background with red border (warning)
- Header with title and X close button
- Warning message
- Cancel and Delete buttons

**Features:**
- Warning message about irreversible action
- Delete button in red for emphasis
- Removes playlist from database
- Returns to playlist list view

## Context Menus

### Track Context Menu

**Options:**
- **Play**: Start playing the selected track
  - Updates current track indicator
  - Refreshes playlist model
- **Remove from Playlist**: Remove track from current playlist
  - Updates song count and duration
  - Refreshes playlist model

**Styling:**
- Dark background with purple border
- Rounded corners
- Hover effects
- Red color for remove option

### Playlist Card Context Menu

**Options:**
- **Edit**: Open edit dialog to rename playlist
- **Delete**: Open delete confirmation dialog

**Styling:**
- Dark background with purple border
- Rounded corners
- Hover effects
- Red color for delete option

## Backend Architecture

### Playlist Controller

The `PlaylistController` class manages playlist operations exposed to QML:

**Key Methods:**
- `createPlaylist(name, description)`: Create new playlist
- `deletePlaylist(playlist_id)`: Delete playlist
- `updatePlaylist(playlist_id, name, description)`: Update playlist info
- `addTrackToPlaylist(playlist_id, track_id)`: Add track to playlist
- `removeTrackFromPlaylist(playlist_id, track_id)`: Remove track from playlist
- `getPlaylistTracks(playlist_id)`: Get all tracks in playlist
- `getPlaylistStats(playlist_id)`: Get playlist statistics

**Signals:**
- `playlistsChanged`: Emitted when playlist list changes

### Playlist Model

The `PlaylistModel` class provides a Qt model for playlist list:

**Roles:**
- `name`: Playlist name
- `description`: Playlist description
- `trackCount`: Number of tracks
- `id`: Playlist ID

**Methods:**
- `rowCount()`: Number of playlists
- `data(index, role)`: Get data for index and role
- `refresh()`: Reload playlists from database

**Signals:**
- `modelChanged`: Emitted when model changes

## Database Schema

### Playlist Table

```python
class Playlist(Base):
    id: Integer (Primary Key)
    name: String
    description: String (Optional)
    created_at: DateTime
    updated_at: DateTime
    tracks: Relationship to Track
```

### Playlist-Track Association

Many-to-many relationship between playlists and tracks with ordering:

```python
playlist_tracks = Table(
    'playlist_tracks',
    Base.metadata,
    Column('playlist_id', Integer, ForeignKey('playlists.id')),
    Column('track_id', Integer, ForeignKey('tracks.id')),
    Column('position', Integer),  # Track order in playlist
    UniqueConstraint('playlist_id', 'track_id', 'position')
)
```

## Usage Examples

### Creating a Playlist

```python
# From QML
playlistController.createPlaylist("My Favorites", "Best songs")

# From Python
manager = PlaylistManager(db.get_session())
playlist = manager.create_playlist("My Favorites", "Best songs")
```

### Adding Tracks to Playlist

```python
# From QML
playlistController.addTrackToPlaylist(playlist_id, track_id)

# From Python
manager.add_track_to_playlist(playlist_id, track_id)
```

### Getting Playlist Tracks

```python
# From QML
var tracks = playlistController.getPlaylistTracks(playlist_id)

# From Python
tracks = manager.get_playlist_tracks(playlist_id)
```

### Shuffling Playlist

```qml
// From QML
Button {
    onClicked: {
        var tracks = playlistController.getPlaylistTracks(playlistId)
        var shuffled = tracks.slice()
        for (var i = shuffled.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1))
            var temp = shuffled[i]
            shuffled[i] = shuffled[j]
            shuffled[j] = temp
        }
        musicManager.playSong(shuffled[0].id)
        playlistTracksList.model = shuffled
    }
}
```

## Performance Considerations

### Database Optimization
- Indexed queries on playlist_id and track_id
- Lazy loading of track relationships
- Efficient count queries for statistics

### UI Performance
- Model-based views for efficient updates
- Signal-based refreshes
- Lazy loading of track metadata

### Memory Management
- Efficient data structures for large playlists
- Streaming for track data
- Cleanup of unused resources

## Future Enhancements

### Planned Features

- [ ] Smart playlists (auto-generated based on criteria)
- [ ] Playlist folders/organization
- [ ] Playlist sharing and collaboration
- [ ] Import/export playlists (M3U, PLS)
- [ ] Playlist templates
- [ ] Duplicate playlist with tracks
- [ ] Bulk track operations
- [ ] Playlist history/undo
- [ ] Playlist statistics and analytics
- [ ] Cross-fade between playlist tracks

### Potential Improvements

- Drag-and-drop reordering
- Multiple selection for bulk operations
- Playlist search within large collections
- Playlist sorting options
- Playlist filtering by criteria
- Playlist backup and restore
