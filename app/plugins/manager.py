"""
Plugin manager for loading and managing plugins
"""

import logging
import importlib.util
import sys
from pathlib import Path
from typing import Dict, List, Optional, Type
from dataclasses import dataclass

from PySide6.QtCore import QObject, Signal

from app.plugins.base import Plugin, PluginInfo, UIPlugin, AudioPlugin, MetadataPlugin

logger = logging.getLogger(__name__)


@dataclass
class PluginLoadResult:
    """Result of plugin loading"""
    plugin: Optional[Plugin]
    error: Optional[str]


class PluginManager(QObject):
    """Manager for loading and managing plugins"""
    
    # Signals
    plugin_loaded = Signal(str)  # Plugin name
    plugin_unloaded = Signal(str)  # Plugin name
    plugin_enabled = Signal(str)  # Plugin name
    plugin_disabled = Signal(str)  # Plugin name
    plugin_error = Signal(str, str)  # Plugin name, error message
    
    def __init__(self, plugin_dir: Optional[Path] = None):
        super().__init__()
        self.plugin_dir = plugin_dir or Path("plugins")
        self._plugins: Dict[str, Plugin] = {}
        self._plugin_classes: Dict[str, Type[Plugin]] = {}
    
    def discover_plugins(self) -> List[str]:
        """Discover available plugins in plugin directory"""
        discovered = []
        
        if not self.plugin_dir.exists():
            logger.warning(f"Plugin directory does not exist: {self.plugin_dir}")
            return discovered
        
        for plugin_path in self.plugin_dir.glob("*.py"):
            if plugin_path.name.startswith("_"):
                continue
            
            module_name = plugin_path.stem
            discovered.append(module_name)
            logger.debug(f"Discovered plugin: {module_name}")
        
        return discovered
    
    def load_plugin(self, module_name: str) -> PluginLoadResult:
        """Load a plugin by module name"""
        if module_name in self._plugins:
            return PluginLoadResult(self._plugins[module_name], None)
        
        try:
            # Load the module
            plugin_path = self.plugin_dir / f"{module_name}.py"
            if not plugin_path.exists():
                return PluginLoadResult(None, f"Plugin file not found: {plugin_path}")
            
            spec = importlib.util.spec_from_file_location(module_name, plugin_path)
            if spec is None or spec.loader is None:
                return PluginLoadResult(None, f"Failed to load spec for {module_name}")
            
            module = importlib.util.module_from_spec(spec)
            sys.modules[module_name] = module
            spec.loader.exec_module(module)
            
            # Find Plugin class
            plugin_class = None
            for attr_name in dir(module):
                attr = getattr(module, attr_name)
                if isinstance(attr, type) and issubclass(attr, Plugin) and attr != Plugin:
                    plugin_class = attr
                    break
            
            if plugin_class is None:
                return PluginLoadResult(None, f"No Plugin class found in {module_name}")
            
            # Instantiate plugin
            plugin = plugin_class()
            info = plugin.get_info()
            
            # Check compatibility
            # (In a real implementation, check min_app_version against current version)
            
            self._plugins[info.name] = plugin
            self._plugin_classes[info.name] = plugin_class
            
            self.plugin_loaded.emit(info.name)
            logger.info(f"Loaded plugin: {info.name} v{info.version}")
            
            return PluginLoadResult(plugin, None)
            
        except Exception as e:
            logger.error(f"Failed to load plugin {module_name}: {e}")
            return PluginLoadResult(None, str(e))
    
    def unload_plugin(self, plugin_name: str) -> bool:
        """Unload a plugin"""
        if plugin_name not in self._plugins:
            return False
        
        try:
            plugin = self._plugins[plugin_name]
            if plugin.is_enabled():
                plugin.disable()
            
            del self._plugins[plugin_name]
            if plugin_name in self._plugin_classes:
                del self._plugin_classes[plugin_name]
            
            self.plugin_unloaded.emit(plugin_name)
            logger.info(f"Unloaded plugin: {plugin_name}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to unload plugin {plugin_name}: {e}")
            self.plugin_error.emit(plugin_name, str(e))
            return False
    
    def enable_plugin(self, plugin_name: str) -> bool:
        """Enable a plugin"""
        if plugin_name not in self._plugins:
            return False
        
        try:
            plugin = self._plugins[plugin_name]
            if plugin.enable():
                self.plugin_enabled.emit(plugin_name)
                return True
            return False
            
        except Exception as e:
            logger.error(f"Failed to enable plugin {plugin_name}: {e}")
            self.plugin_error.emit(plugin_name, str(e))
            return False
    
    def disable_plugin(self, plugin_name: str) -> bool:
        """Disable a plugin"""
        if plugin_name not in self._plugins:
            return False
        
        try:
            plugin = self._plugins[plugin_name]
            plugin.disable()
            self.plugin_disabled.emit(plugin_name)
            return True
            
        except Exception as e:
            logger.error(f"Failed to disable plugin {plugin_name}: {e}")
            self.plugin_error.emit(plugin_name, str(e))
            return False
    
    def get_plugin(self, plugin_name: str) -> Optional[Plugin]:
        """Get a plugin by name"""
        return self._plugins.get(plugin_name)
    
    def get_all_plugins(self) -> Dict[str, Plugin]:
        """Get all loaded plugins"""
        return self._plugins.copy()
    
    def get_plugin_info(self, plugin_name: str) -> Optional[PluginInfo]:
        """Get plugin info"""
        plugin = self._plugins.get(plugin_name)
        if plugin:
            return plugin.get_info()
        return None
    
    def get_ui_plugins(self) -> List[UIPlugin]:
        """Get all UI plugins"""
        return [p for p in self._plugins.values() if isinstance(p, UIPlugin)]
    
    def get_audio_plugins(self) -> List[AudioPlugin]:
        """Get all audio plugins"""
        return [p for p in self._plugins.values() if isinstance(p, AudioPlugin)]
    
    def get_metadata_plugins(self) -> List[MetadataPlugin]:
        """Get all metadata plugins"""
        return [p for p in self._plugins.values() if isinstance(p, MetadataPlugin)]
    
    def is_plugin_loaded(self, plugin_name: str) -> bool:
        """Check if a plugin is loaded"""
        return plugin_name in self._plugins
    
    def is_plugin_enabled(self, plugin_name: str) -> bool:
        """Check if a plugin is enabled"""
        plugin = self._plugins.get(plugin_name)
        return plugin.is_enabled() if plugin else False
    
    def load_all_plugins(self) -> None:
        """Load all discovered plugins"""
        discovered = self.discover_plugins()
        for module_name in discovered:
            self.load_plugin(module_name)
    
    def unload_all_plugins(self) -> None:
        """Unload all plugins"""
        for plugin_name in list(self._plugins.keys()):
            self.unload_plugin(plugin_name)
    
    def notify_track_play(self, track_id: int) -> None:
        """Notify all plugins that a track started playing"""
        for plugin in self._plugins.values():
            if plugin.is_enabled():
                try:
                    plugin.on_track_play(track_id)
                except Exception as e:
                    logger.error(f"Plugin {plugin.get_info().name} error: {e}")
    
    def notify_track_pause(self, track_id: int) -> None:
        """Notify all plugins that a track paused"""
        for plugin in self._plugins.values():
            if plugin.is_enabled():
                try:
                    plugin.on_track_pause(track_id)
                except Exception as e:
                    logger.error(f"Plugin {plugin.get_info().name} error: {e}")
    
    def notify_track_stop(self, track_id: int) -> None:
        """Notify all plugins that a track stopped"""
        for plugin in self._plugins.values():
            if plugin.is_enabled():
                try:
                    plugin.on_track_stop(track_id)
                except Exception as e:
                    logger.error(f"Plugin {plugin.get_info().name} error: {e}")
    
    def notify_playlist_created(self, playlist_id: int) -> None:
        """Notify all plugins that a playlist was created"""
        for plugin in self._plugins.values():
            if plugin.is_enabled():
                try:
                    plugin.on_playlist_created(playlist_id)
                except Exception as e:
                    logger.error(f"Plugin {plugin.get_info().name} error: {e}")
    
    def notify_library_scanned(self, track_count: int) -> None:
        """Notify all plugins that library scan completed"""
        for plugin in self._plugins.values():
            if plugin.is_enabled():
                try:
                    plugin.on_library_scanned(track_count)
                except Exception as e:
                    logger.error(f"Plugin {plugin.get_info().name} error: {e}")
