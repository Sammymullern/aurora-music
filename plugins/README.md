# Plugins Directory

This directory contains plugins for Aurora Music.

## Plugin Structure

A plugin is a Python file that:
1. Imports from `app.plugins.base`
2. Subclasses one of the plugin base classes
3. Implements required methods
4. Provides plugin metadata

## Plugin Types

### Base Plugin
The basic plugin type for general functionality.

```python
from app.plugins.base import Plugin, PluginInfo

class MyPlugin(Plugin):
    def get_info(self) -> PluginInfo:
        return PluginInfo(
            name="My Plugin",
            version="1.0.0",
            description="Description",
            author="Author",
            license="MIT"
        )
    
    def initialize(self) -> bool:
        # Initialize plugin
        return True
    
    def shutdown(self) -> None:
        # Cleanup
        pass
```

### UI Plugin
For plugins that add UI elements.

```python
from app.plugins.base import UIPlugin

class MyUIPlugin(UIPlugin):
    def get_widget(self):
        # Return QWidget
        return MyWidget()
    
    def get_menu_item(self):
        # Return menu item config
        return {"title": "My Plugin", "action": self.show}
```

### Audio Plugin
For audio processing plugins.

```python
from app.plugins.base import AudioPlugin

class MyAudioPlugin(AudioPlugin):
    def process_audio(self, audio_data: bytes) -> bytes:
        # Process audio
        return processed_data
    
    def get_audio_filters(self):
        # Return MPV filter strings
        return ["filter1", "filter2"]
```

### Metadata Plugin
For fetching metadata from external sources.

```python
from app.plugins.base import MetadataPlugin

class MyMetadataPlugin(MetadataPlugin):
    def fetch_metadata(self, artist, album, title):
        # Fetch metadata
        return metadata_dict
    
    def fetch_artwork(self, artist, album):
        # Fetch artwork
        return image_bytes
```

## Plugin Events

Plugins can respond to events:
- `on_track_play(track_id)`
- `on_track_pause(track_id)`
- `on_track_stop(track_id)`
- `on_playlist_created(playlist_id)`
- `on_library_scanned(track_count)`

## Installation

Place plugin files in this directory. They will be automatically discovered by the plugin manager.
