# Architecture Documentation

## Overview

Aurora Music follows a modular architecture with clear separation of concerns. The application is built using Python 3.13 with PySide6 for the UI and MPV for audio playback.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Main Application                       │
│                      (main.py)                           │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┼────────────┬────────────┐
        │            │            │            │
┌───────▼──────┐ ┌──▼────────┐ ┌─▼────────┐ ┌─▼────────┐
│   UI Layer   │ │  Player   │ │ Library  │ │ Database │
│  (PySide6)   │ │   (MPV)   │ │ Manager  │ │ (SQLite) │
└───────┬──────┘ └──┬────────┘ └─┬────────┘ └─┬────────┘
        │            │            │            │
        └────────────┼────────────┼────────────┘
                     │            │
              ┌──────▼─────┐ ┌──▼────────┐
              │  Metadata  │ │ Settings  │
              │ (Mutagen)  │ │ Manager   │
              └────────────┘ └───────────┘
```

## Core Components

### 1. UI Layer (`app/ui/`)

**Responsibilities:**
- User interface rendering with QML
- User input handling
- View navigation
- State management

**Key Files:**
- `main_window.py` - Main window controller
- `playlist_controller.py` - Playlist management for QML
- `qml/Main.qml` - Main QML entry point
- `qml/PlaylistDetailView.qml` - Playlist detail view
- `qml/PlaylistsView.qml` - Playlist list view
- `qml/PlaylistCard.qml` - Playlist card component

**Architecture:**
- Model-View-Controller (MVC) pattern
- QML for declarative UI
- Python controllers for business logic
- Signal-slot communication between QML and Python

### 2. Player Layer (`app/player/`)

**Responsibilities:**
- Audio playback
- Volume control
- Queue management
- Playback state tracking

**Key Files:**
- `player.py` - Main player implementation
- `queue.py` - Playback queue management
- `equalizer.py` - Audio equalizer

**Architecture:**
- Uses MPV as playback backend
- State machine for playback states
- Event-driven architecture with signals
- Thread-safe operations

### 3. Library Layer (`app/library/`)

**Responsibilities:**
- Music library management
- File scanning and monitoring
- Track metadata extraction
- Playlist operations

**Key Files:**
- `music_manager.py` - Music library manager
- `scanner.py` - File system scanner
- `watcher.py` - Folder monitoring
- `playlist.py` - Playlist operations

**Architecture:**
- Observer pattern for file system changes
- Lazy loading for large libraries
- Caching for performance
- Async operations for I/O

### 4. Database Layer (`app/database/`)

**Responsibilities:**
- Data persistence
- Query optimization
- Transaction management
- Schema management

**Key Files:**
- `models.py` - SQLAlchemy models
- `session.py` - Database session management

**Architecture:**
- ORM with SQLAlchemy
- Connection pooling
- Index-based queries
- Migration support

### 5. Metadata Layer (`app/metadata/`)

**Responsibilities:**
- Audio metadata extraction
- Tag parsing
- Image extraction
- Metadata normalization

**Key Files:**
- `extractor.py` - Metadata extraction using Mutagen

**Architecture:**
- Strategy pattern for different formats
- Caching for repeated access
- Error handling for corrupt files

### 6. Settings Layer (`app/settings/`)

**Responsibilities:**
- Configuration management
- Settings persistence
- Theme management
- User preferences

**Key Files:**
- `settings_manager.py` - Settings manager

**Architecture:**
- Singleton pattern
- Signal-based change notifications
- Type-safe settings

### 7. Recommendations Layer (`app/recommendations/`)

**Responsibilities:**
- AI-powered music recommendations
- Audio analysis
- Similarity calculations
- Mood detection

**Key Files:**
- `engine.py` - Recommendation engine

**Architecture:**
- Machine learning with librosa
- Feature extraction
- Similarity algorithms
- Caching for performance

### 8. Themes Layer (`app/themes/`)

**Responsibilities:**
- Theme management
- Color schemes
- Asset loading
- Dynamic theming

**Key Files:**
- `theme_manager.py` - Theme manager

**Architecture:**
- Plugin-based theme system
- Dynamic color generation
- Asset bundling

### 9. Plugins Layer (`app/plugins/`)

**Responsibilities:**
- Plugin loading
- Plugin lifecycle
- Plugin API
- Extension points

**Key Files:**
- `manager.py` - Plugin manager
- `base.py` - Base plugin class

**Architecture:**
- Plugin architecture
- Dynamic loading
- Dependency management
- Sandboxing

## Data Flow

### Playback Flow

```
User Click → UI Event → Player Controller → MPV Backend → Audio Output
                ↓
            Queue Update → Database Update → UI Refresh
```

### Library Scan Flow

```
Folder Add → Scanner → Metadata Extractor → Database → UI Update
                ↓
            Watcher → File Change Event → Re-scan
```

### Playlist Operations Flow

```
User Action → Playlist Controller → Database → Model Update → UI Refresh
                ↓
            Signal Emission → Other Components Update
```

## Communication Patterns

### Signal-Slot Pattern

Used extensively for loose coupling between components:

```python
# Example: Player emits signal when track changes
class Player(QObject):
    currentTrackChanged = Signal(int)
    
# UI connects to signal
player.currentTrackChanged.connect(update_ui)
```

### Observer Pattern

Used for file system monitoring:

```python
# Watcher observes folder changes
class FolderWatcher:
    def on_file_changed(self, event):
        # Notify scanner
        scanner.rescan(event.path)
```

### MVC Pattern

Used for UI components:

```
Model (Database) → View (QML) ← Controller (Python)
     ↑                    ↓
     └────────────────────┘
```

## Performance Considerations

### Database Optimization
- Indexed queries on frequently accessed fields
- Connection pooling
- Lazy loading of relationships
- Query result caching

### UI Performance
- Model-based views for efficient updates
- Lazy loading of large lists
- Asynchronous operations for I/O
- Hardware-accelerated rendering

### Memory Management
- Weak references for observers
- Resource cleanup on component destruction
- Streaming for large audio files
- Image caching with size limits

## Security Considerations

- Input validation for all user inputs
- SQL injection prevention via ORM
- File path sanitization
- Plugin sandboxing
- Secure configuration storage

## Testing Strategy

### Unit Tests
- Individual component testing
- Mock dependencies
- Fast execution

### Integration Tests
- Component interaction testing
- Database integration
- UI automation

### End-to-End Tests
- Full user workflows
- Real audio playback
- File system operations

## Deployment Architecture

### Development
- Local development environment
- Virtual environment isolation
- Hot reloading for QML

### Production
- Packaged as DEB/RPM/AppImage/Flatpak
- System dependencies managed
- Configuration in user home directory
- Database in user data directory

## Future Architecture Considerations

### Scalability
- Support for larger libraries (100k+ tracks)
- Distributed architecture for cloud features
- Caching layers for frequently accessed data

### Extensibility
- Plugin API enhancements
- Custom UI themes
- Third-party integrations

### Performance
- Background processing for metadata
- Incremental library updates
- Optimized database queries
- GPU acceleration for audio processing
